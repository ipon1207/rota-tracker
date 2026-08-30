-- 動作確認用の最小シード。実データの一部（3カテゴリ / 10プロジェクト）を抜粋。
-- schema.sql を流した直後に実行する前提（テーブルは空）。
-- 何度でも流せるよう、先頭で全削除する。

DELETE FROM entry_step;
DELETE FROM entry;
DELETE FROM roadmap_stop;
DELETE FROM roadmap_route;
DELETE FROM project_keyword;
DELETE FROM guide_step;
DELETE FROM guide;
DELETE FROM glossary_term;
DELETE FROM project;
DELETE FROM category;

-- ============================================================
-- category
-- ============================================================
INSERT INTO category (id, name, sort_order) VALUES
     (N'cli',   N'コマンドライン・OS寄り', 1)
    ,(N'parse', N'パーサ・言語処理',       2)
    ,(N'data',  N'データ・ストレージ',     3);

-- ============================================================
-- project
-- 難易度は 1〜3 が揃うように選定
-- ============================================================
INSERT INTO project (id, category_id, title, difficulty, sort_order) VALUES
     (N'cli-ls',      N'cli',   N'自作 ls コマンド',           1, 1)
    ,(N'cli-cat',     N'cli',   N'自作 cat / wc / grep',       1, 2)
    ,(N'cli-shell',   N'cli',   N'自作シェル',                 3, 3)
    ,(N'parse-calc',  N'parse', N'電卓（四則演算 + 括弧）',    1, 1)
    ,(N'parse-json',  N'parse', N'JSONパーサ',                 2, 2)
    ,(N'parse-tpl',   N'parse', N'テンプレートエンジン',       2, 3)
    ,(N'data-kvs',    N'data',  N'KVS（メモリ上）',            1, 1)
    ,(N'data-log',    N'data',  N'追記型ログDB',               2, 2)
    ,(N'data-btree',  N'data',  N'B-Treeインデックス',         3, 3)
    ,(N'data-lru',    N'data',  N'キャッシュ（LRU実装）',      1, 4);

-- ============================================================
-- guide
-- 意図的に 10 件中 6 件だけ用意している。
-- ガイド未作成のプロジェクトがある状態を再現し、LEFT JOIN を検証するため。
-- ============================================================
INSERT INTO guide (project_id, goal, learn) VALUES
     (N'cli-ls',
      N'ディレクトリの中身を一覧表示。-l（詳細）と -a（隠しファイル）オプションまで対応',
      N'ファイルシステムAPI、ファイルのメタデータ（パーミッション・所有者・サイズ・更新日時）、パーミッションの rwxr-xr-x 表記への変換')
    ,(N'cli-shell',
      N'コマンド実行、パイプ（|）、リダイレクト（> <）が動くシェル',
      N'プロセスの生成と待機（fork / exec / wait モデル）、ファイルディスクリプタの複製、パイプの実装、シグナル処理')
    ,(N'parse-calc',
      N'1 + 2 * (3 - 4) のような文字列を正しい優先順位で計算',
      N'演算子の優先順位と結合性のコードでの表現、再帰下降（expr → term → factor）、操車場アルゴリズムという別解')
    ,(N'parse-json',
      N'JSON文字列を自言語のデータ構造に変換する parse 関数（ライブラリ不使用）',
      N'字句解析と構文解析の分離、再帰下降パーサ（パーサ入門に最適）、エスケープ処理、エラー位置の報告')
    ,(N'data-btree',
      N'挿入・検索・範囲検索ができるB-Tree（まずメモリ上でOK）',
      N'なぜDBは二分木でなくB-Treeか（ページ単位I/Oとの相性）、ノード分割アルゴリズム、B-TreeとB+Treeの違い')
    ,(N'data-lru',
      N'容量上限つきキャッシュ。あふれたら最も長く未使用のものを追い出す。GET/PUTともO(1)',
      N'ハッシュマップ＋双方向連結リストの合わせ技（定番）、なぜO(1)になるのか、キャッシュ戦略の比較');

-- ============================================================
-- guide_step
-- ステップ数がプロジェクトごとに違う（4件と5件）状態を含める
-- ============================================================
INSERT INTO guide_step (project_id, step_no, body) VALUES
     (N'cli-ls', 1, N'ファイル名を列挙して表示するだけの版を作る')
    ,(N'cli-ls', 2, N'辞書順ソートを加える（本物のlsに合わせる）')
    ,(N'cli-ls', 3, N'stat相当の情報を取得して -l 形式で整形')
    ,(N'cli-ls', 4, N'カラム幅を揃える・ディレクトリを色付けするなどの仕上げ')

    ,(N'cli-shell', 1, N'1行読んで分割し、コマンドを実行して待つだけのREPL')
    ,(N'cli-shell', 2, N'cd などのビルトインコマンド（execできない理由を考える）')
    ,(N'cli-shell', 3, N'リダイレクト: ファイルを開いてfdを付け替える')
    ,(N'cli-shell', 4, N'パイプ: 2プロセス間 → N段パイプへ一般化')
    ,(N'cli-shell', 5, N'シグナル処理（Ctrl-Cで子だけ死ぬ理由）、環境変数')

    ,(N'parse-calc', 1, N'トークナイザ（数値・演算子・括弧）')
    ,(N'parse-calc', 2, N'文法を書き下す: expr = term ((''+''|''-'') term)* など')
    ,(N'parse-calc', 3, N'文法をそのまま関数にする')
    ,(N'parse-calc', 4, N'単項マイナス、べき乗（右結合！）、変数と代入')

    ,(N'parse-json', 1, N'トークナイザ: 記号・文字列・数値・true/false/null に分解')
    ,(N'parse-json', 2, N'値のパース関数を相互再帰で書く（parseValue → parseObject / parseArray）')
    ,(N'parse-json', 3, N'エスケープと数値（指数表記・負数）を仕様どおりに')
    ,(N'parse-json', 4, N'JSONTestSuite（公開テスト集）を通してみる')

    ,(N'data-btree', 1, N'ノード構造（キー配列と子配列）を定義し、検索を実装')
    ,(N'data-btree', 2, N'分割を伴わない挿入 → 葉の分割 → 分割の伝播（山場。図を描きながら）')
    ,(N'data-btree', 3, N'範囲検索（B+Treeなら葉を連結リストで繋ぐ）')
    ,(N'data-btree', 4, N'大量データで木の高さを確認、二分探索木と比較')

    ,(N'data-lru', 1, N'まず素朴に（配列管理、O(n)）動くものを作る')
    ,(N'data-lru', 2, N'双方向連結リストを自作し、マップの値をリストのノードにする')
    ,(N'data-lru', 3, N'アクセスのたびノードを先頭へ、あふれたら末尾を削除')
    ,(N'data-lru', 4, N'ヒット率を測り、LFU・FIFOと比較実験');

-- ============================================================
-- glossary_term
-- demo_kind は一部だけ非 NULL（デモ有無での絞り込みを検証するため）
-- id は IDENTITY 任せ。参照側は term から引く
-- ============================================================
INSERT INTO glossary_term (term, description, demo_kind) VALUES
     (N'readdir / stat システムコール',
      N'ディレクトリの中身を読む readdir と、ファイルの詳細情報（サイズ・更新日時・パーミッションなど）を取る stat という、OSが提供する基本機能です。多くの言語の標準ライブラリはこれらの薄いラッパーなので、正体を知るとファイル操作全般の見通しが良くなります。', NULL)
    ,(N'パーミッションビット',
      N'ファイルの「読み・書き・実行」の許可を、所有者・グループ・その他の3者分、合計9個のビットで表す仕組みです。755のような8進数表記と rwxr-xr-x 表記は、同じ情報の別の書き方です。', NULL)
    ,(N'fork / execvp / waitpid',
      N'UNIXでプロセスを作る基本3点セットです。fork で自分の分身を作り、execvp で分身の中身を別のプログラムに入れ替え、waitpid で親が子の終了を待ちます。シェルはこの流れをひたすら繰り返すプログラムです。', NULL)
    ,(N'pipe / dup2',
      N'pipe は読み口と書き口がセットになった土管を作り、dup2 はファイルディスクリプタ（入出力の番号札）を付け替えます。「a | b」は、aの標準出力をパイプの書き口に、bの標準入力を読み口に付け替えることで実現されています。', NULL)
    ,(N'再帰下降構文解析',
      N'文法規則を1つずつ関数にして、関数同士が再帰的に呼び合う形で構文解析する手法です。手書きパーサの定番で、電卓・JSON・SQLまで同じ発想で書けます。', NULL)
    ,(N'操車場アルゴリズム',
      N'数式を読みながら演算子を一時置き場（スタック）に積み、優先順位に従って並べ替えるアルゴリズムです。再帰を使わずに電卓を作れる、もう1つの道です。', NULL)
    ,(N'演算子の結合性',
      N'同じ優先順位の演算子が並んだとき、左右どちらから計算するかの規則です。5-3-1 は左から、2^3^2 は右から。パーサの再帰の向きに直結します。', NULL)
    ,(N'RFC 8259',
      N'JSONの仕様書です。数値や文字列エスケープの正確な文法が数ページで定義されており、自作パーサの「正解」はすべてここにあります。', NULL)
    ,(N'字句解析（lexer）',
      N'文字の列を「数値」「記号」「文字列」などの意味のある最小単位（トークン）の列に変換する前処理です。ここを分離すると、後段の構文解析が格段に書きやすくなります。', NULL)
    ,(N'JSONTestSuite',
      N'世界中のJSONパーサを苛める目的で作られた公開テスト集です。自作パーサに食わせると、仕様の読み落としが容赦なく見つかります。', NULL)
    ,(N'LRU cache O(1)',
      N'「最も長く使われていないものを捨てる」キャッシュを、取得も追加も一定時間で行う実装のことです。ハッシュマップと双方向リストの合わせ技で実現します。', N'lru')
    ,(N'双方向連結リスト',
      N'各要素が前後両方への参照を持つリストです。要素の位置がわかっていれば、途中からの取り外しと先頭への付け直しが一定時間でできるのが、LRUでの主役たる理由です。', N'lru')
    ,(N'LFU / FIFO / Clock アルゴリズム',
      N'使用頻度で捨てる(LFU)、古い順に捨てる(FIFO)、近似LRUのClockという、LRU以外のキャッシュ退避戦略です。比較実験すると、ワークロードによって最適が変わることがわかります。', NULL);

-- ============================================================
-- project_keyword
-- 「再帰下降構文解析」を parse-calc と parse-json の両方から参照している。
-- 用語 → 使っているプロジェクトの逆引きは、ここが2件返ることで確認できる
-- ============================================================
INSERT INTO project_keyword (project_id, term_id, sort_order)
SELECT src.project_id, t.id, src.sort_order
FROM (VALUES
     (N'cli-ls',     N'readdir / stat システムコール',      1)
    ,(N'cli-ls',     N'パーミッションビット',                2)
    ,(N'cli-shell',  N'fork / execvp / waitpid',            1)
    ,(N'cli-shell',  N'pipe / dup2',                        2)
    ,(N'parse-calc', N'再帰下降構文解析',                    1)
    ,(N'parse-calc', N'操車場アルゴリズム',                  2)
    ,(N'parse-calc', N'演算子の結合性',                      3)
    ,(N'parse-json', N'RFC 8259',                           1)
    ,(N'parse-json', N'再帰下降構文解析',                    2)
    ,(N'parse-json', N'字句解析（lexer）',                   3)
    ,(N'parse-json', N'JSONTestSuite',                      4)
    ,(N'data-lru',   N'LRU cache O(1)',                     1)
    ,(N'data-lru',   N'双方向連結リスト',                    2)
    ,(N'data-lru',   N'LFU / FIFO / Clock アルゴリズム',     3)
) AS src(project_id, term, sort_order)
JOIN glossary_term t ON t.term = src.term;

-- ============================================================
-- roadmap_route / roadmap_stop
-- warmup はカテゴリをまたぐ。lang と db は1カテゴリ内で完結する
-- ============================================================
INSERT INTO roadmap_route (id, name, description, sort_order) VALUES
     (N'warmup', N'フェーズ0: ウォームアップ',
      N'★☆☆から2〜3個やって完走の勢いをつける。全部やらなくてOK', 1)
    ,(N'lang',   N'言語処理ルート',
      N'パーサの黄金ルート。電卓の再帰下降がJSONに、パース経験がテンプレートに直結', 2)
    ,(N'db',     N'データベースルート',
      N'メモリ上のKVSを永続化し、インデックスを足して簡易DBMSへ育てる', 3);

INSERT INTO roadmap_stop (route_id, position, project_id) VALUES
     (N'warmup', 1, N'parse-calc')
    ,(N'warmup', 2, N'cli-ls')
    ,(N'warmup', 3, N'data-lru')

    ,(N'lang', 1, N'parse-calc')
    ,(N'lang', 2, N'parse-json')
    ,(N'lang', 3, N'parse-tpl')

    ,(N'db', 1, N'data-kvs')
    ,(N'db', 2, N'data-log')
    ,(N'db', 3, N'data-btree');

-- ============================================================
-- entry / entry_step
-- 3状態すべてと、記録なしのプロジェクトが混在する状態を作る。
-- 進捗集計や状態フィルタは、この偏りがないと検証できない
-- ============================================================
INSERT INTO entry (project_id, status, lang, memo, repo_url, start_date, done_date) VALUES
     (N'parse-calc', N'done',  N'TypeScript',
      N'再帰下降で書いた。べき乗の右結合で1回詰まった。',
      N'https://github.com/example/mini-calc', '2026-07-01', '2026-07-05')
    ,(N'cli-ls',     N'doing', N'C#',
      N'-l の整形まで。カラム幅揃えが残り。',
      NULL, '2026-08-20', NULL)
    ,(N'data-lru',   N'doing', N'TypeScript',
      NULL, NULL, '2026-08-28', NULL)
    ,(N'parse-json', N'todo',  NULL, NULL, NULL, NULL, NULL);

-- チェック済みステップ。done は全部、doing は途中まで
INSERT INTO entry_step (project_id, step_no, is_checked) VALUES
     (N'parse-calc', 1, 1)
    ,(N'parse-calc', 2, 1)
    ,(N'parse-calc', 3, 1)
    ,(N'parse-calc', 4, 1)

    ,(N'cli-ls', 1, 1)
    ,(N'cli-ls', 2, 1)
    ,(N'cli-ls', 3, 1)
    ,(N'cli-ls', 4, 0)

    ,(N'data-lru', 1, 1)
    ,(N'data-lru', 2, 0)
    ,(N'data-lru', 3, 0)
    ,(N'data-lru', 4, 0);
