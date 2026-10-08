// pre-push で「push されるコミット」だけを検証するスクリプト。
// 作業ツリーの未コミット・未追跡ファイルに影響されないよう、push 対象のコミットを
// 一時的な git worktree に展開し、その中で型チェック・テストを実行する。
import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

const ZERO_SHA = /^0+$/;

const git = (args, cwd) => {
  const result = spawnSync('git', args, { cwd, encoding: 'utf8' });
  if (result.status !== 0) {
    throw new Error(`git ${args.join(' ')} failed:\n${result.stderr}`);
  }
  return result.stdout.trim();
};

const repoRoot = git(['rev-parse', '--show-toplevel']);

// pre-push の stdin: "<local ref> <local sha> <remote ref> <remote sha>" が1行ずつ渡される
const readPushedShas = () => {
  let input = '';
  try {
    input = fs.readFileSync(0, 'utf8');
  } catch {
    // stdin が無い（手動実行など）場合は HEAD を検証する
  }
  const shas = input
    .split(/\r?\n/)
    .map((line) => line.trim().split(/\s+/)[1])
    .filter((sha) => sha && !ZERO_SHA.test(sha)); // ブランチ削除は検証不要
  return shas.length > 0 ? [...new Set(shas)] : [git(['rev-parse', 'HEAD'], repoRoot)];
};

const run = (name, command, cwd) => {
  console.log(`\n▶ ${name}`);
  const result = spawnSync(command, { cwd, stdio: 'inherit', shell: true });
  if (result.status !== 0) {
    console.error(`✖ ${name} failed`);
    return false;
  }
  return true;
};

const runChecks = (root) =>
  [
    ['web-typecheck', 'npm run typecheck', path.join(root, 'web')],
    ['web-test', 'npm run test', path.join(root, 'web')],
    ['api-test', 'dotnet test', path.join(root, 'api')],
  ]
    // 途中で失敗しても残りは実行し、まとめて結果を出す
    .map(([name, command, cwd]) => run(name, command, cwd))
    .every(Boolean);

const verify = (sha) => {
  const short = sha.slice(0, 7);

  // push 対象が HEAD で作業ツリーがクリーンなら、worktree を作らずその場で検証する
  const isHead = sha === git(['rev-parse', 'HEAD'], repoRoot);
  const isClean = git(['status', '--porcelain'], repoRoot) === '';
  if (isHead && isClean) {
    console.log(`Verifying ${short} in the working tree (clean)`);
    return runChecks(repoRoot);
  }

  // 8.3 形式の短縮パス（MIYASH~1 など）はツールによってパス解決がずれるため展開しておく
  const tmpBase = fs.mkdtempSync(path.join(fs.realpathSync.native(os.tmpdir()), 'verify-push-'));
  const worktree = path.join(tmpBase, 'repo');
  console.log(`Verifying ${short} in a temporary worktree: ${worktree}`);

  try {
    git(['worktree', 'add', '--detach', worktree, sha], repoRoot);
    // 本体の node_modules をジャンクションで共有すると、Vite がリンクを実体パスに解決して
    // server.fs.allow（worktree 配下）の外と判定し、ブラウザモードのテストが読み込めない。
    // そのため worktree 内に独立してインストールする（ルートの依存はチェックで使わないので web のみ）
    const installed = run(
      'web-install',
      'npm ci --prefer-offline --no-audit --no-fund',
      path.join(worktree, 'web'),
    );
    return installed && runChecks(worktree);
  } finally {
    spawnSync('git', ['worktree', 'remove', '--force', worktree], { cwd: repoRoot });
    fs.rmSync(tmpBase, { recursive: true, force: true });
    spawnSync('git', ['worktree', 'prune'], { cwd: repoRoot });
  }
};

const ok = readPushedShas()
  .map(verify)
  .every(Boolean);
process.exit(ok ? 0 : 1);
