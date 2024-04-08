DROP TABLE IF EXISTS public.items CASCADE;
DROP TABLE IF EXISTS public.groups CASCADE;
DROP TABLE IF EXISTS public.items_groups CASCADE;
DROP TABLE IF EXISTS public.users CASCADE;
DROP TABLE IF EXISTS public.teams CASCADE;
DROP TABLE IF EXISTS public.rules CASCADE;
DROP TABLE IF EXISTS public.rules_teams CASCADE;
DROP TABLE IF EXISTS public.rules_users CASCADE;
DROP TABLE IF EXISTS public.user_teams CASCADE;
DROP TABLE IF EXISTS public.rules_items CASCADE;
DROP TABLE IF EXISTS public.rules_groups CASCADE;


CREATE TABLE if not exists public.items
(
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    type  VARCHAR(100) NOT NULL,
    data  JSONB,
    image VARCHAR(100)
);

create TABLE if not exists public.groups
(
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    description  VARCHAR(100),
    visible BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS public.users
(
    id    SERIAL PRIMARY KEY,
    username  VARCHAR(100) NOT NULL,
    name  VARCHAR(100) NOT NULL,
    email  VARCHAR(100) NOT NULL,
    password  VARCHAR(89) NOT NULL,
    discord  VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS public.teams
(
    id    SERIAL PRIMARY KEY,
    name  VARCHAR(100) NOT NULL,
    description  VARCHAR(100),
    visible BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS public.rules
(
    id    SERIAL PRIMARY KEY,
    value integer default null
);

CREATE TABLE IF NOT EXISTS public.items_groups
(
    item_id INTEGER REFERENCES public.items(id),
    group_id INTEGER REFERENCES public.groups(id),
    PRIMARY KEY (item_id, group_id)
);


CREATE TABLE IF NOT EXISTS public.rules_teams
(
    rule_id INTEGER REFERENCES public.rules(id),
    team_id INTEGER REFERENCES public.teams(id),
    PRIMARY KEY (rule_id, team_id)
);

CREATE TABLE IF NOT EXISTS public.rules_users
(
    rule_id INTEGER REFERENCES public.rules(id),
    user_id INTEGER REFERENCES public.users(id),
    PRIMARY KEY (rule_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.user_teams
(
    user_id INTEGER REFERENCES public.users(id),
    team_id INTEGER REFERENCES public.teams(id),
    PRIMARY KEY (user_id, team_id)
);

CREATE TABLE IF NOT EXISTS rules_items
(
    rule_id INTEGER REFERENCES public.rules(id),
    item_id INTEGER REFERENCES public.items(id),
    value INTEGER,
    PRIMARY KEY (rule_id, item_id)
);

CREATE TABLE IF NOT EXISTS public.rules_groups
(
    rule_id INTEGER REFERENCES public.rules(id),
    group_id INTEGER REFERENCES public.groups(id),
    value INTEGER,
    PRIMARY KEY (rule_id, group_id)
);



alter table public.items
    owner to postgres;
alter table public.groups
    owner to postgres;
alter table public.items_groups
    owner to postgres;
alter table public.users
    owner to postgres;
alter table public.teams
    owner to postgres;
alter table public.rules
    owner to postgres;
alter table public.rules_teams
    owner to postgres;
alter table public.rules_users
    owner to postgres;
alter table public.user_teams
    owner to postgres;
alter table public.rules_items
    owner to postgres;
alter table public.rules_groups
    owner to postgres;
