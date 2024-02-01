DROP TABLE IF EXISTS public.products CASCADE;
DROP TABLE IF EXISTS public.inventory;
DROP TABLE IF EXISTS public.filament;

create table if not exists public.products
(
    id          integer generated always as identity
        primary key,
    name        text,
    vendor      text,
    description text,
    type        text,
    image       text
);

create table if not exists public.inventory
(
    id            integer generated always as identity
        primary key,
    product_id    integer
        constraint fk_product
            references public.products,
    acquired_date date,
    active        boolean,
    location_id   integer
);

create table if not exists public.filament
(
    id            integer generated always as identity
        primary key,
    color         text,
    weight        integer,
    material_type text,
    product_id    integer
        constraint fk_product
            references public.products
);

alter table public.inventory
    owner to postgres;

alter table public.filament
    owner to postgres;

alter table public.products
    owner to postgres;


