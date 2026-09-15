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

// node_modules を丸ごと共有すると .tmp（tsbuildinfo）や .vite などのキャッシュが
// 本体と混ざるため、パッケージだけをジャンクションで共有し、キャッシュ類は分離する
const linkNodeModules = (sourceDir, targetDir) => {
  if (!fs.existsSync(sourceDir)) return;
  fs.mkdirSync(targetDir, { recursive: true });
  for (const entry of fs.readdirSync(sourceDir, { withFileTypes: true })) {
    if (entry.name.startsWith('.') && entry.name !== '.bin') continue;
    const src = path.join(sourceDir, entry.name);
    const dest = path.join(targetDir, entry.name);
    if (entry.isDirectory() || entry.isSymbolicLink()) {
      fs.symlinkSync(src, dest, 'junction');
    } else {
      fs.copyFileSync(src, dest);
    }
  }
};

// worktree 削除時にリンク先（本体の node_modules）まで辿られないよう、先にリンクだけ外す
const unlinkNodeModules = (targetDir) => {
  if (!fs.existsSync(targetDir)) return;
  for (const name of fs.readdirSync(targetDir)) {
    const dest = path.join(targetDir, name);
    if (fs.lstatSync(dest).isSymbolicLink()) fs.unlinkSync(dest);
  }
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
    linkNodeModules(path.join(repoRoot, 'node_modules'), path.join(worktree, 'node_modules'));
    linkNodeModules(path.join(repoRoot, 'web', 'node_modules'), path.join(worktree, 'web', 'node_modules'));
    return runChecks(worktree);
  } finally {
    unlinkNodeModules(path.join(worktree, 'node_modules'));
    unlinkNodeModules(path.join(worktree, 'web', 'node_modules'));
    spawnSync('git', ['worktree', 'remove', '--force', worktree], { cwd: repoRoot });
    fs.rmSync(tmpBase, { recursive: true, force: true });
    spawnSync('git', ['worktree', 'prune'], { cwd: repoRoot });
  }
};

const ok = readPushedShas()
  .map(verify)
  .every(Boolean);
process.exit(ok ? 0 : 1);
