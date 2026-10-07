// docs/ 配下の原本から GitHub Wiki 用のページ一式を生成する
// 使い方: node scripts/build-wiki.mjs <出力ディレクトリ>
//
// - Wiki はサブフォルダを無視してページ名（ファイル名）で解決するため、出力はフラットにする
// - 原本同士の相対リンクは Wiki のページ名へ、それ以外はリポジトリ上の URL へ書き換える
// - 原本は書き換えない（リポジトリ上でのリンクを壊さないため）

import { existsSync, mkdirSync, readFileSync, readdirSync, rmSync, statSync, writeFileSync } from "node:fs";
import { basename, dirname, extname, join, posix, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const REPO_URL = "https://github.com/ipon1207/rota-tracker";
const BRANCH = "main";
const IMAGE_EXTENSIONS = new Set([".png", ".jpg", ".jpeg", ".gif", ".svg", ".webp"]);

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const outDir = process.argv[2] ? resolve(process.argv[2]) : null;
if (!outDir) {
  console.error("出力ディレクトリを指定してください: node scripts/build-wiki.mjs <outDir>");
  process.exit(1);
}

/** @typedef {{ source: string, page: string, group: "root" | "task" | "spike" }} WikiPage */

/** 公開対象。source はリポジトリルートからの POSIX パス */
function collectPages() {
  /** @type {WikiPage[]} */
  const pages = [];
  const addDir = (dir, group) => {
    const abs = join(repoRoot, dir);
    if (!existsSync(abs)) return;
    for (const name of readdirSync(abs)) {
      if (extname(name) !== ".md") continue;
      pages.push({ source: posix.join(dir, name), page: basename(name, ".md"), group });
    }
  };

  addDir("docs/wiki", "root");
  // 原本が存在するときだけ公開する（空のテンプレートは置かない方針のため）
  if (existsSync(join(repoRoot, "docs/DESIGN_NOTES.md"))) {
    pages.push({ source: "docs/DESIGN_NOTES.md", page: "DESIGN_NOTES", group: "root" });
  }
  addDir("docs/task", "task");
  addDir("docs/spike", "spike");

  const seen = new Map();
  for (const p of pages) {
    if (seen.has(p.page)) {
      throw new Error(`Wikiのページ名が衝突しています: ${seen.get(p.page)} と ${p.source}`);
    }
    seen.set(p.page, p.source);
  }
  return pages;
}

/** 先頭の Issue 番号で並べる。番号のないものは末尾 */
function byIssueNumber(a, b) {
  const num = (p) => {
    const m = /^(\d+)-/.exec(p.page);
    return m ? Number(m[1]) : Number.POSITIVE_INFINITY;
  };
  return num(a) - num(b) || a.page.localeCompare(b.page, "ja");
}

function pageLink(page) {
  return encodeURIComponent(page);
}

/** リンク先を Wiki 用に解決する。書き換え不要なら null */
function rewriteTarget(target, sourceDir, isImage, pagesBySource) {
  if (/^([a-z][a-z0-9+.-]*:|#|\/)/i.test(target)) return null;

  const hashIndex = target.indexOf("#");
  const pathPart = hashIndex === -1 ? target : target.slice(0, hashIndex);
  const hash = hashIndex === -1 ? "" : target.slice(hashIndex);
  if (pathPart === "") return null;

  let decoded;
  try {
    decoded = decodeURI(pathPart);
  } catch {
    decoded = pathPart;
  }
  const resolved = posix.normalize(posix.join(sourceDir, decoded));
  if (resolved.startsWith("..")) return null;

  const page = pagesBySource.get(resolved);
  if (page) return pageLink(page) + hash;

  const encoded = resolved.split("/").map(encodeURIComponent).join("/");
  if (isImage || IMAGE_EXTENSIONS.has(posix.extname(resolved).toLowerCase())) {
    return `${REPO_URL}/raw/${BRANCH}/${encoded}`;
  }
  const abs = join(repoRoot, resolved);
  const isDir = decoded.endsWith("/") || (existsSync(abs) && statSync(abs).isDirectory());
  return `${REPO_URL}/${isDir ? "tree" : "blob"}/${BRANCH}/${encoded}${hash}`;
}

/** コードフェンスの外にある Markdown リンク・画像だけを書き換える */
function convertMarkdown(text, source, pagesBySource) {
  const sourceDir = posix.dirname(source);
  const linkPattern = /(!?)\[([^\]]*)\]\(([^)\s]+)(\s+"[^"]*")?\)/g;
  let inFence = false;

  return text
    .split("\n")
    .map((line) => {
      if (/^\s*(```|~~~)/.test(line)) {
        inFence = !inFence;
        return line;
      }
      if (inFence) return line;
      return line.replace(linkPattern, (whole, bang, label, target, title = "") => {
        const next = rewriteTarget(target, sourceDir, bang === "!", pagesBySource);
        return next === null ? whole : `${bang}[${label}](${next}${title})`;
      });
    })
    .join("\n");
}

function buildSidebar(pages) {
  const list = (group) =>
    pages
      .filter((p) => p.group === group)
      .sort(byIssueNumber)
      .map((p) => `- [${p.page}](${pageLink(p.page)})`)
      .join("\n");

  const rootPages = pages.filter((p) => p.group === "root" && p.page !== "Home");
  return [
    "- [Home](Home)",
    ...rootPages.map((p) => `- [${p.page}](${pageLink(p.page)})`),
    "",
    "### task",
    "",
    list("task"),
    "",
    "### spike",
    "",
    list("spike"),
    "",
  ].join("\n");
}

const FOOTER = `このWikiは [docs/](${REPO_URL}/tree/${BRANCH}/docs) から自動生成しています。直接編集しても次回の同期で上書きされるため、修正はリポジトリへのPRで行ってください。
`;

function main() {
  const pages = collectPages();
  const pagesBySource = new Map(pages.map((p) => [p.source, p.page]));

  rmSync(outDir, { recursive: true, force: true });
  mkdirSync(outDir, { recursive: true });

  for (const p of pages) {
    const text = readFileSync(join(repoRoot, p.source), "utf8");
    writeFileSync(join(outDir, `${p.page}.md`), convertMarkdown(text, p.source, pagesBySource));
  }
  writeFileSync(join(outDir, "_Sidebar.md"), buildSidebar(pages));
  writeFileSync(join(outDir, "_Footer.md"), FOOTER);

  console.log(`${pages.length} ページを ${relative(process.cwd(), outDir) || "."} に出力しました`);
}

main();
