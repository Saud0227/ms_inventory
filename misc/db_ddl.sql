DROP TABLE IF EXISTS public.inventory;
DROP TABLE IF EXISTS public.fillament;
DROP TABLE IF EXISTS public.products;

create table public.fillament
(
    id            integer generated always as identity
        primary key,
    color         text,
    weight        integer,
    material_type text
);

create table if not exists public.products
(
    id          integer generated always as identity
        primary key,
    name        text,
    vendor      text,
    description text,
    type        text,
    image       text,
    fillament_id  integer
        constraint fk_fillament
            references public.fillament
);

create table public.inventory
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

alter table public.inventory
    owner to postgres;

alter table public.fillament
    owner to postgres;

alter table public.products
    owner to postgres;


