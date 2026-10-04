-- 依存関係の逆順に並べ、冪等にする
DROP TABLE IF EXISTS guide_step;
DROP TABLE IF EXISTS entry_step;
DROP TABLE IF EXISTS guide;
DROP TABLE IF EXISTS project_keyword;
DROP TABLE IF EXISTS roadmap_stop;
DROP TABLE IF EXISTS entry;
DROP TABLE IF EXISTS glossary_term;
DROP TABLE IF EXISTS project;
DROP TABLE IF EXISTS roadmap_route;
DROP TABLE IF EXISTS category;

CREATE TABLE category (
     id         VARCHAR(20) PRIMARY KEY
    ,name       VARCHAR(50) NOT NULL
    ,sort_order INT         NOT NULL
);

CREATE TABLE project (
     id          VARCHAR(30)  PRIMARY KEY
    ,category_id VARCHAR(20)  NOT NULL
    ,title       VARCHAR(120) NOT NULL
    ,difficulty  INT          NULL
    ,sort_order  INT          NOT NULL
    ,FOREIGN KEY (category_id) REFERENCES category(id) ON DELETE CASCADE
);

CREATE TABLE glossary_term (
     id          INT            PRIMARY KEY GENERATED ALWAYS AS IDENTITY
    ,term        VARCHAR(120)   NOT NULL UNIQUE
    ,description VARCHAR(1000)  NOT NULL
    ,demo_kind   VARCHAR(30)    NULL
);

CREATE TABLE project_keyword (
     project_id VARCHAR(30)
    ,term_id    INT
    ,sort_order INT          NOT NULL
    ,PRIMARY KEY (project_id, term_id)
    ,FOREIGN KEY (project_id) REFERENCES project(id)       ON DELETE CASCADE
    ,FOREIGN KEY (term_id)    REFERENCES glossary_term(id) ON DELETE CASCADE
);

CREATE TABLE guide (
     project_id VARCHAR(30)  PRIMARY KEY
    ,goal       VARCHAR(400) NOT NULL
    ,learn      VARCHAR(800) NOT NULL
    ,FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE
);

CREATE TABLE guide_step (
     project_id VARCHAR(30)
    ,step_no    INT          NOT NULL
    ,body       VARCHAR(400) NOT NULL
    ,PRIMARY KEY (project_id, step_no)
    ,FOREIGN KEY (project_id) REFERENCES guide(project_id) ON DELETE CASCADE
);

CREATE TABLE roadmap_route (
     id          VARCHAR(20)  PRIMARY KEY
    ,name        VARCHAR(60)  NOT NULL
    ,description VARCHAR(200) NOT NULL
    ,sort_order  INT          NOT NULL
);

CREATE TABLE roadmap_stop (
     route_id   VARCHAR(20)
    ,position   INT
    ,project_id VARCHAR(30)
    ,PRIMARY KEY (route_id, position)
    ,FOREIGN KEY (route_id) REFERENCES roadmap_route(id) ON DELETE CASCADE
    ,FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE CASCADE
);

CREATE TABLE entry (
     project_id VARCHAR(30)  PRIMARY KEY
    ,status     VARCHAR(10)  NOT NULL
    ,lang       VARCHAR(60)  NULL
    ,memo       TEXT         NULL
    ,repo_url   VARCHAR(500) NULL
    ,start_date DATE         NULL
    ,done_date  DATE         NULL
    ,updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
    ,CONSTRAINT ck_status CHECK (status IN ('todo', 'doing', 'done'))
    ,FOREIGN KEY (project_id) REFERENCES project(id) ON DELETE NO ACTION
);

CREATE TABLE entry_step (
     project_id VARCHAR(30)
    ,step_no    INT
    ,is_checked BOOLEAN      NOT NULL
    ,PRIMARY KEY (project_id, step_no)
    ,FOREIGN KEY (project_id) REFERENCES entry(project_id) ON DELETE CASCADE
);
