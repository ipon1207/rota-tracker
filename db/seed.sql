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
     ('cli',   'コマンドライン・OS寄り', 1)
    ,('parse', 'パーサ・言語処理',       2)
    ,('data',  'データ・ストレージ',     3);

-- ============================================================
-- project
-- 難易度は 1〜3 が揃うように選定
-- ============================================================
INSERT INTO project (id, category_id, title, difficulty, sort_order) VALUES
     ('cli-ls',      'cli',   '自作 ls コマンド',           1, 1)
    ,('cli-cat',     'cli',   '自作 cat / wc / grep',       1, 2)
    ,('cli-shell',   'cli',   '自作シェル',                 3, 3)
    ,('parse-calc',  'parse', '電卓（四則演算 + 括弧）',    1, 1)
    ,('parse-json',  'parse', 'JSONパーサ',                 2, 2)
    ,('parse-tpl',   'parse', 'テンプレートエンジン',       2, 3)
    ,('data-kvs',    'data',  'KVS（メモリ上）',            1, 1)
    ,('data-log',    'data',  '追記型ログDB',               2, 2)
    ,('data-btree',  'data',  'B-Treeインデックス',         3, 3)
    ,('data-lru',    'data',  'キャッシュ（LRU実装）',      1, 4);

-- ============================================================
-- guide
-- 意図的に 10 件中 6 件だけ用意している。
-- ガイド未作成のプロジェクトがある状態を再現し、LEFT JOIN を検証するため。
-- ============================================================
INSERT INTO guide (project_id, goal, learn) VALUES
     ('cli-ls',
      'ディレクトリの中身を一覧表示。-l（詳細）と -a（隠しファイル）オプションまで対応',
      'ファイルシステムAPI、ファイルのメタデータ（パーミッション・所有者・サイズ・更新日時）、パーミッションの rwxr-xr-x 表記への変換')
    ,('cli-shell',
      'コマンド実行、パイプ（|）、リダイレクト（> <）が動くシェル',
      'プロセスの生成と待機（fork / exec / wait モデル）、ファイルディスクリプタの複製、パイプの実装、シグナル処理')
    ,('parse-calc',
      '1 + 2 * (3 - 4) のような文字列を正しい優先順位で計算',
      '演算子の優先順位と結合性のコードでの表現、再帰下降（expr → term → factor）、操車場アルゴリズムという別解')
    ,('parse-json',
      'JSON文字列を自言語のデータ構造に変換する parse 関数（ライブラリ不使用）',
      '字句解析と構文解析の分離、再帰下降パーサ（パーサ入門に最適）、エスケープ処理、エラー位置の報告')
    ,('data-btree',
      '挿入・検索・範囲検索ができるB-Tree（まずメモリ上でOK）',
      'なぜDBは二分木でなくB-Treeか（ページ単位I/Oとの相性）、ノード分割アルゴリズム、B-TreeとB+Treeの違い')
    ,('data-lru',
      '容量上限つきキャッシュ。あふれたら最も長く未使用のものを追い出す。GET/PUTともO(1)',
      'ハッシュマップ＋双方向連結リストの合わせ技（定番）、なぜO(1)になるのか、キャッシュ戦略の比較');

-- ============================================================
-- guide_step
-- ステップ数がプロジェクトごとに違う（4件と5件）状態を含める
-- ============================================================
INSERT INTO guide_step (project_id, step_no, body) VALUES
     ('cli-ls', 1, 'ファイル名を列挙して表示するだけの版を作る')
    ,('cli-ls', 2, '辞書順ソートを加える（本物のlsに合わせる）')
    ,('cli-ls', 3, 'stat相当の情報を取得して -l 形式で整形')
    ,('cli-ls', 4, 'カラム幅を揃える・ディレクトリを色付けするなどの仕上げ')

    ,('cli-shell', 1, '1行読んで分割し、コマンドを実行して待つだけのREPL')
    ,('cli-shell', 2, 'cd などのビルトインコマンド（execできない理由を考える）')
    ,('cli-shell', 3, 'リダイレクト: ファイルを開いてfdを付け替える')
    ,('cli-shell', 4, 'パイプ: 2プロセス間 → N段パイプへ一般化')
    ,('cli-shell', 5, 'シグナル処理（Ctrl-Cで子だけ死ぬ理由）、環境変数')

    ,('parse-calc', 1, 'トークナイザ（数値・演算子・括弧）')
    ,('parse-calc', 2, '文法を書き下す: expr = term ((''+''|''-'') term)* など')
    ,('parse-calc', 3, '文法をそのまま関数にする')
    ,('parse-calc', 4, '単項マイナス、べき乗（右結合！）、変数と代入')

    ,('parse-json', 1, 'トークナイザ: 記号・文字列・数値・true/false/null に分解')
    ,('parse-json', 2, '値のパース関数を相互再帰で書く（parseValue → parseObject / parseArray）')
    ,('parse-json', 3, 'エスケープと数値（指数表記・負数）を仕様どおりに')
    ,('parse-json', 4, 'JSONTestSuite（公開テスト集）を通してみる')

    ,('data-btree', 1, 'ノード構造（キー配列と子配列）を定義し、検索を実装')
    ,('data-btree', 2, '分割を伴わない挿入 → 葉の分割 → 分割の伝播（山場。図を描きながら）')
    ,('data-btree', 3, '範囲検索（B+Treeなら葉を連結リストで繋ぐ）')
    ,('data-btree', 4, '大量データで木の高さを確認、二分探索木と比較')

    ,('data-lru', 1, 'まず素朴に（配列管理、O(n)）動くものを作る')
    ,('data-lru', 2, '双方向連結リストを自作し、マップの値をリストのノードにする')
    ,('data-lru', 3, 'アクセスのたびノードを先頭へ、あふれたら末尾を削除')
    ,('data-lru', 4, 'ヒット率を測り、LFU・FIFOと比較実験');

-- ============================================================
-- glossary_term
-- demo_kind は一部だけ非 NULL（デモ有無での絞り込みを検証するため）
-- id は IDENTITY 任せ。参照側は term から引く
-- ============================================================
INSERT INTO glossary_term (term, description, demo_kind) VALUES
     ('readdir / stat システムコール',
      'ディレクトリの中身を読む readdir と、ファイルの詳細情報（サイズ・更新日時・パーミッションなど）を取る stat という、OSが提供する基本機能です。多くの言語の標準ライブラリはこれらの薄いラッパーなので、正体を知るとファイル操作全般の見通しが良くなります。', NULL)
    ,('パーミッションビット',
      'ファイルの「読み・書き・実行」の許可を、所有者・グループ・その他の3者分、合計9個のビットで表す仕組みです。755のような8進数表記と rwxr-xr-x 表記は、同じ情報の別の書き方です。', NULL)
    ,('fork / execvp / waitpid',
      'UNIXでプロセスを作る基本3点セットです。fork で自分の分身を作り、execvp で分身の中身を別のプログラムに入れ替え、waitpid で親が子の終了を待ちます。シェルはこの流れをひたすら繰り返すプログラムです。', NULL)
    ,('pipe / dup2',
      'pipe は読み口と書き口がセットになった土管を作り、dup2 はファイルディスクリプタ（入出力の番号札）を付け替えます。「a | b」は、aの標準出力をパイプの書き口に、bの標準入力を読み口に付け替えることで実現されています。', NULL)
    ,('再帰下降構文解析',
      '文法規則を1つずつ関数にして、関数同士が再帰的に呼び合う形で構文解析する手法です。手書きパーサの定番で、電卓・JSON・SQLまで同じ発想で書けます。', NULL)
    ,('操車場アルゴリズム',
      '数式を読みながら演算子を一時置き場（スタック）に積み、優先順位に従って並べ替えるアルゴリズムです。再帰を使わずに電卓を作れる、もう1つの道です。', NULL)
    ,('演算子の結合性',
      '同じ優先順位の演算子が並んだとき、左右どちらから計算するかの規則です。5-3-1 は左から、2^3^2 は右から。パーサの再帰の向きに直結します。', NULL)
    ,('RFC 8259',
      'JSONの仕様書です。数値や文字列エスケープの正確な文法が数ページで定義されており、自作パーサの「正解」はすべてここにあります。', NULL)
    ,('字句解析（lexer）',
      '文字の列を「数値」「記号」「文字列」などの意味のある最小単位（トークン）の列に変換する前処理です。ここを分離すると、後段の構文解析が格段に書きやすくなります。', NULL)
    ,('JSONTestSuite',
      '世界中のJSONパーサを苛める目的で作られた公開テスト集です。自作パーサに食わせると、仕様の読み落としが容赦なく見つかります。', NULL)
    ,('LRU cache O(1)',
      '「最も長く使われていないものを捨てる」キャッシュを、取得も追加も一定時間で行う実装のことです。ハッシュマップと双方向リストの合わせ技で実現します。', 'lru')
    ,('双方向連結リスト',
      '各要素が前後両方への参照を持つリストです。要素の位置がわかっていれば、途中からの取り外しと先頭への付け直しが一定時間でできるのが、LRUでの主役たる理由です。', 'lru')
    ,('LFU / FIFO / Clock アルゴリズム',
      '使用頻度で捨てる(LFU)、古い順に捨てる(FIFO)、近似LRUのClockという、LRU以外のキャッシュ退避戦略です。比較実験すると、ワークロードによって最適が変わることがわかります。', NULL);

-- ============================================================
-- project_keyword
-- 「再帰下降構文解析」を parse-calc と parse-json の両方から参照している。
-- 用語 → 使っているプロジェクトの逆引きは、ここが2件返ることで確認できる
-- ============================================================
INSERT INTO project_keyword (project_id, term_id, sort_order)
SELECT src.project_id, t.id, src.sort_order
FROM (VALUES
     ('cli-ls',     'readdir / stat システムコール',      1)
    ,('cli-ls',     'パーミッションビット',                2)
    ,('cli-shell',  'fork / execvp / waitpid',            1)
    ,('cli-shell',  'pipe / dup2',                        2)
    ,('parse-calc', '再帰下降構文解析',                    1)
    ,('parse-calc', '操車場アルゴリズム',                  2)
    ,('parse-calc', '演算子の結合性',                      3)
    ,('parse-json', 'RFC 8259',                           1)
    ,('parse-json', '再帰下降構文解析',                    2)
    ,('parse-json', '字句解析（lexer）',                   3)
    ,('parse-json', 'JSONTestSuite',                      4)
    ,('data-lru',   'LRU cache O(1)',                     1)
    ,('data-lru',   '双方向連結リスト',                    2)
    ,('data-lru',   'LFU / FIFO / Clock アルゴリズム',     3)
) AS src(project_id, term, sort_order)
JOIN glossary_term t ON t.term = src.term;

-- ============================================================
-- roadmap_route / roadmap_stop
-- warmup はカテゴリをまたぐ。lang と db は1カテゴリ内で完結する
-- ============================================================
INSERT INTO roadmap_route (id, name, description, sort_order) VALUES
     ('warmup', 'フェーズ0: ウォームアップ',
      '★☆☆から2〜3個やって完走の勢いをつける。全部やらなくてOK', 1)
    ,('lang',   '言語処理ルート',
      'パーサの黄金ルート。電卓の再帰下降がJSONに、パース経験がテンプレートに直結', 2)
    ,('db',     'データベースルート',
      'メモリ上のKVSを永続化し、インデックスを足して簡易DBMSへ育てる', 3);

INSERT INTO roadmap_stop (route_id, position, project_id) VALUES
     ('warmup', 1, 'parse-calc')
    ,('warmup', 2, 'cli-ls')
    ,('warmup', 3, 'data-lru')

    ,('lang', 1, 'parse-calc')
    ,('lang', 2, 'parse-json')
    ,('lang', 3, 'parse-tpl')

    ,('db', 1, 'data-kvs')
    ,('db', 2, 'data-log')
    ,('db', 3, 'data-btree');

-- ============================================================
-- entry / entry_step
-- 3状態すべてと、記録なしのプロジェクトが混在する状態を作る。
-- 進捗集計や状態フィルタは、この偏りがないと検証できない
-- ============================================================
INSERT INTO entry (project_id, status, lang, memo, repo_url, start_date, done_date) VALUES
     ('parse-calc', 'done',  'TypeScript',
      '再帰下降で書いた。べき乗の右結合で1回詰まった。',
      'https://github.com/example/mini-calc', '2026-07-01', '2026-07-05')
    ,('cli-ls',     'doing', 'C#',
      '-l の整形まで。カラム幅揃えが残り。',
      NULL, '2026-08-20', NULL)
    ,('data-lru',   'doing', 'TypeScript',
      NULL, NULL, '2026-08-28', NULL)
    ,('parse-json', 'todo',  NULL, NULL, NULL, NULL, NULL);

-- チェック済みステップ。done は全部、doing は途中まで
INSERT INTO entry_step (project_id, step_no, is_checked) VALUES
     ('parse-calc', 1, TRUE)
    ,('parse-calc', 2, TRUE)
    ,('parse-calc', 3, TRUE)
    ,('parse-calc', 4, TRUE)

    ,('cli-ls', 1, TRUE)
    ,('cli-ls', 2, TRUE)
    ,('cli-ls', 3, TRUE)
    ,('cli-ls', 4, FALSE)

    ,('data-lru', 1, TRUE)
    ,('data-lru', 2, FALSE)
    ,('data-lru', 3, FALSE)
    ,('data-lru', 4, FALSE);
