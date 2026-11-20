-- MOVEON shop database setup
-- Paste this whole file into Supabase → SQL Editor → New query → Run.
-- Before running, change the email on the "admins" line near the bottom to the manager's email.

-- 1. Products
create table if not exists public.products (
  id          bigint generated always as identity primary key,
  name        text    not null,
  price       numeric(10,2) not null default 0,
  category    text    not null default 'T-Shirts',
  sizes       text[]  not null default '{}',
  description text    not null default '',
  color       text    not null default '#141414',
  shape       text    not null default 'tee',
  images      text[]  not null default '{}',
  is_new      boolean not null default true,
  in_stock    boolean not null default true,
  sort_order  int     not null default 0,
  created_at  timestamptz not null default now()
);

-- 2. Shop details (one row)
create table if not exists public.settings (
  id        int primary key default 1 check (id = 1),
  tagline   text not null default '',
  about     text not null default '',
  whatsapp  text not null default '',
  phone     text not null default '',
  instagram text not null default '',
  orders    text not null default '',
  location  text not null default ''
);

-- 3. Who may manage the shop
create table if not exists public.admins (
  email text primary key
);

create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where lower(email) = lower(auth.jwt() ->> 'email'));
$$;

-- Let the website (anon) and signed-in managers (authenticated) use these tables through the API
grant usage on schema public to anon, authenticated;
grant select on public.products, public.settings to anon, authenticated;
grant insert, update, delete on public.products, public.settings to authenticated;
grant select on public.admins to authenticated;
grant usage, select on all sequences in schema public to authenticated;
grant execute on function public.is_admin() to anon, authenticated;

-- 4. Security: everyone can read, only admins can change
alter table public.products enable row level security;
alter table public.settings enable row level security;
alter table public.admins   enable row level security;

drop policy if exists "read products" on public.products;
drop policy if exists "admin writes products" on public.products;
drop policy if exists "read settings" on public.settings;
drop policy if exists "admin writes settings" on public.settings;
drop policy if exists "admin reads admins" on public.admins;

create policy "read products"         on public.products for select using (true);
create policy "admin writes products" on public.products for all    using (public.is_admin()) with check (public.is_admin());
create policy "read settings"         on public.settings for select using (true);
create policy "admin writes settings" on public.settings for all    using (public.is_admin()) with check (public.is_admin());
create policy "admin reads admins"    on public.admins   for select using (public.is_admin());

-- 5. Photo storage (public to view, admins to upload/delete)
insert into storage.buckets (id, name, public)
values ('product-photos', 'product-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "public reads photos" on storage.objects;
drop policy if exists "admin uploads photos" on storage.objects;
drop policy if exists "admin updates photos" on storage.objects;
drop policy if exists "admin deletes photos" on storage.objects;

create policy "public reads photos"  on storage.objects for select using (bucket_id = 'product-photos');
create policy "admin uploads photos" on storage.objects for insert with check (bucket_id = 'product-photos' and public.is_admin());
create policy "admin updates photos" on storage.objects for update using (bucket_id = 'product-photos' and public.is_admin());
create policy "admin deletes photos" on storage.objects for delete using (bucket_id = 'product-photos' and public.is_admin());

-- 6. Starting data (the current MOVEON shop)
insert into public.settings (id, tagline, about, whatsapp, phone, instagram, orders, location) values (
  1,
  'Live Free, Express Boldly.',
  E'Born in the heart of King William''s Town in the Eastern Cape, MOVEON is a clothing brand created by bold young men and women with a vision to empower others.\n\nWe celebrate individuality, free spirit, and the power of self-expression through unique streetwear and culture-driven fashion. Whether you''re dancing in the streets, chasing your dreams, or creating your path, MOVEON moves with you.\n\nIt''s not just fashion. It''s a way of life.',
  '082 123 4567', '', '@moveon.clothing', 'WhatsApp + delivery', 'King William''s Town, Eastern Cape'
) on conflict (id) do nothing;

insert into public.products (name, price, category, sizes, description, color, images, is_new, in_stock, sort_order)
select * from (values
  ('Beige Tee', 249, 'T-Shirts', array['S','M','L','XL'], 'Oversized beige tee with the MOVEON logo on the chest and a big print on the back.', '#e8d6bf', array['img/beige-front.jpg','img/beige-back.jpg'], true, true, 1),
  ('Black Tee', 249, 'T-Shirts', array['S','M','L','XL'], 'Black tee with the white MOVEON logo on the chest.', '#141414', array['img/black-front.jpg','img/black-white-pair.jpg'], true, true, 2),
  ('White Tee', 249, 'T-Shirts', array['S','M','L','XL'], 'White tee with the MOVEON logo on the chest and a big print on the back.', '#f4f4f2', array['img/white-front.jpg','img/white-side.jpg'], true, true, 3)
) as v(name, price, category, sizes, description, color, images, is_new, in_stock, sort_order)
where not exists (select 1 from public.products);

-- 7. The manager's email. CHANGE THIS to the real email before running.
insert into public.admins (email) values ('wamachumangqandu@gmail.com') on conflict do nothing;
