-- MFF repair migration for an EXISTING Supabase project.
-- Safe to run more than once. Does not delete existing records.
-- Run in Supabase Dashboard -> SQL Editor -> New query.

-- 1) Match image field used by the current website code.
alter table if exists public.mff_matches add column if not exists image_url text;

-- 2) Create standings table if it is missing, then make sure expected columns exist.
create table if not exists public.mff_standings (
  id uuid primary key default gen_random_uuid(),
  competition text not null default '',
  season text not null default '',
  team text not null default '',
  played integer not null default 0,
  won integer not null default 0,
  drawn integer not null default 0,
  lost integer not null default 0,
  goals_for integer not null default 0,
  goals_against integer not null default 0,
  points integer not null default 0,
  created_at timestamptz not null default now()
);
alter table public.mff_standings add column if not exists competition text not null default '';
alter table public.mff_standings add column if not exists season text not null default '';
alter table public.mff_standings add column if not exists team text not null default '';
alter table public.mff_standings add column if not exists played integer not null default 0;
alter table public.mff_standings add column if not exists won integer not null default 0;
alter table public.mff_standings add column if not exists drawn integer not null default 0;
alter table public.mff_standings add column if not exists lost integer not null default 0;
alter table public.mff_standings add column if not exists goals_for integer not null default 0;
alter table public.mff_standings add column if not exists goals_against integer not null default 0;
alter table public.mff_standings add column if not exists points integer not null default 0;
alter table public.mff_standings add column if not exists created_at timestamptz not null default now();

-- 3) Permissions and RLS for standings. Admin-only writes; public reads.
alter table public.mff_standings enable row level security;
grant select on public.mff_standings to anon, authenticated;
grant insert, update, delete on public.mff_standings to authenticated;
drop policy if exists "Public can read MFF standings" on public.mff_standings;
create policy "Public can read MFF standings" on public.mff_standings
  for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage standings" on public.mff_standings;
create policy "MFF admins manage standings" on public.mff_standings
  for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

-- 4) Ensure public image bucket and access policies exist.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('mff-uploads', 'mff-uploads', true, 5242880,
        array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];
drop policy if exists "Public can view MFF uploaded images" on storage.objects;
create policy "Public can view MFF uploaded images" on storage.objects
  for select to anon, authenticated using (bucket_id = 'mff-uploads');
drop policy if exists "MFF admins upload images" on storage.objects;
create policy "MFF admins upload images" on storage.objects
  for insert to authenticated with check (bucket_id = 'mff-uploads' and public.is_mff_admin());
drop policy if exists "MFF admins update images" on storage.objects;
create policy "MFF admins update images" on storage.objects
  for update to authenticated using (bucket_id = 'mff-uploads' and public.is_mff_admin())
  with check (bucket_id = 'mff-uploads' and public.is_mff_admin());
drop policy if exists "MFF admins delete images" on storage.objects;
create policy "MFF admins delete images" on storage.objects
  for delete to authenticated using (bucket_id = 'mff-uploads' and public.is_mff_admin());

-- 5) Refresh PostgREST schema cache so new table/column are recognized.
notify pgrst, 'reload schema';
