-- MFF: Fix Match & Results image uploads for an existing Supabase project
-- Run this in Supabase Dashboard -> SQL Editor.
alter table public.mff_matches add column if not exists image_url text;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('mff-uploads', 'mff-uploads', true, 12582912, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 12582912,
  allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists "Public can view MFF uploaded images" on storage.objects;
create policy "Public can view MFF uploaded images"
on storage.objects for select to anon, authenticated
using (bucket_id = 'mff-uploads');

-- Existing admin upload policies are retained; uploads require an authenticated MFF admin.
