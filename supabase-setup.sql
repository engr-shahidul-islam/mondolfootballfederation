-- Mondol Football Federation (MFF) database setup for Supabase.
-- Run this whole file in Supabase Dashboard -> SQL Editor -> New query.

create table if not exists public.mff_leaders (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  role text not null,
  bio text not null default '',
  image_url text,
  kind text not null default 'committee',
  created_at timestamptz not null default now()
);

create table if not exists public.mff_matches (
  id uuid primary key default gen_random_uuid(),
  home text not null,
  away text not null,
  match_date date,
  match_time text,
  venue text not null default '',
  competition text not null default '',
  status text not null default 'upcoming' check (status in ('upcoming','live','completed')),
  home_score integer check (home_score is null or home_score >= 0),
  away_score integer check (away_score is null or away_score >= 0),
  image_url text,
  created_at timestamptz not null default now()
);

-- Upgrade existing installations too (CREATE TABLE IF NOT EXISTS does not add columns).
alter table public.mff_matches add column if not exists image_url text;
notify pgrst, 'reload schema';

create table if not exists public.mff_news (
  id uuid primary key default gen_random_uuid(),
  title_en text not null default '',
  title_bn text not null default '',
  summary_en text not null default '',
  summary_bn text not null default '',
  news_date date,
  category text not null default 'Official Announcements',
  image_url text,
  created_at timestamptz not null default now(),
  constraint mff_news_has_title check (length(trim(title_en)) > 0 or length(trim(title_bn)) > 0)
);


-- Support distinct President, General Secretary and Committee sections.
alter table public.mff_leaders drop constraint if exists mff_leaders_kind_check;
alter table public.mff_leaders add constraint mff_leaders_kind_check check (kind in ('president','general-secretary','committee'));

create table if not exists public.mff_slides (
  id uuid primary key default gen_random_uuid(),
  title_en text not null default '',
  title_bn text not null default '',
  text_en text not null default '',
  text_bn text not null default '',
  cta_en text not null default 'Explore competitions',
  cta_bn text not null default 'প্রতিযোগিতা দেখুন',
  image_url text,
  sort_order integer not null default 100,
  created_at timestamptz not null default now()
);

create table if not exists public.mff_gallery (
  id uuid primary key default gen_random_uuid(),
  caption_en text not null default '',
  caption_bn text not null default '',
  category text not null default 'Football' check (category in ('Matchday','Training','Stadium','Football')),
  image_url text,
  sort_order integer not null default 100,
  created_at timestamptz not null default now()
);

create table if not exists public.mff_teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text not null default '',
  description text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.mff_players (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  team text not null default '',
  position text not null default '',
  shirt_number text not null default '',
  bio text not null default '',
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.mff_competitions (
  id uuid primary key default gen_random_uuid(),
  title_en text not null default '',
  title_bn text not null default '',
  description_en text not null default '',
  description_bn text not null default '',
  season text not null default '',
  start_date date,
  end_date date,
  venue text not null default '',
  status text not null default 'upcoming' check (status in ('upcoming','ongoing','completed')),
  registration_url text not null default '',
  image_url text,
  created_at timestamptz not null default now(),
  constraint mff_competitions_has_title check (length(trim(title_en)) > 0 or length(trim(title_bn)) > 0)
);

create table if not exists public.mff_standings (
  id uuid primary key default gen_random_uuid(),
  competition text not null,
  season text not null,
  team text not null,
  played integer not null default 0 check (played >= 0),
  won integer not null default 0 check (won >= 0),
  drawn integer not null default 0 check (drawn >= 0),
  lost integer not null default 0 check (lost >= 0),
  goals_for integer not null default 0 check (goals_for >= 0),
  goals_against integer not null default 0 check (goals_against >= 0),
  points integer not null default 0 check (points >= 0),
  created_at timestamptz not null default now()
);

create table if not exists public.mff_videos (
  id uuid primary key default gen_random_uuid(),
  title_en text not null default '',
  title_bn text not null default '',
  description_en text not null default '',
  description_bn text not null default '',
  video_url text not null,
  image_url text,
  created_at timestamptz not null default now(),
  constraint mff_videos_has_title check (length(trim(title_en)) > 0 or length(trim(title_bn)) > 0)
);

create table if not exists public.mff_documents (
  id uuid primary key default gen_random_uuid(),
  title_en text not null default '',
  title_bn text not null default '',
  description_en text not null default '',
  description_bn text not null default '',
  category text not null default 'Official document',
  document_date date,
  file_url text not null default '',
  created_at timestamptz not null default now(),
  constraint mff_documents_has_title check (length(trim(title_en)) > 0 or length(trim(title_bn)) > 0)
);

create table if not exists public.mff_site_settings (
  id text primary key default 'main' check (id = 'main'),
  content jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Starter carousel content: four editable home slides.
insert into public.mff_slides (title_en,title_bn,text_en,text_bn,cta_en,cta_bn,image_url,sort_order)
select 'ONE FEDERATION. ONE PASSION.','এক ফেডারেশন, এক আবেগ','Bringing our football community together through competition, character and opportunity.','প্রতিযোগিতা, শৃঙ্খলা ও সুযোগের মাধ্যমে ফুটবল কমিউনিটিকে একত্রিত করা।','Explore competitions','প্রতিযোগিতা দেখুন','https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=2200&q=85',1
where not exists (select 1 from public.mff_slides)
union all
select 'THE BEAUTIFUL GAME. OUR COMMUNITY.','সুন্দর খেলা, আমাদের কমিউনিটি','Celebrating teamwork, fair play and the next generation of football talent.','দলগত সহযোগিতা, ন্যায্য খেলা এবং আগামী প্রজন্মের ফুটবল প্রতিভাকে উদযাপন।','Meet the federation','ফেডারেশন সম্পর্কে জানুন','https://images.unsplash.com/photo-1574629810360-7efabe195018?auto=format&fit=crop&w=2200&q=85',2
where not exists (select 1 from public.mff_slides)
union all
select 'EVERY MATCH. A NEW STORY.','প্রতিটি ম্যাচ, নতুন গল্প','Follow fixtures, results and the moments that bring supporters together.','ফিক্সচার, ফলাফল এবং সমর্থকদের একত্রিত করা মুহূর্তগুলোর সঙ্গে থাকুন।','View match centre','ম্যাচ সেন্টার দেখুন','https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=2200&q=85',3
where not exists (select 1 from public.mff_slides)
union all
select 'BUILDING FOOTBALL FOR EVERYONE.','সবার জন্য ফুটবল গড়ে তুলি','Creating welcoming pathways for players, teams, volunteers and supporters.','খেলোয়াড়, দল, স্বেচ্ছাসেবক ও সমর্থকদের জন্য অন্তর্ভুক্তিমূলক সুযোগ তৈরি।','Discover MFF','MFF আবিষ্কার করুন','https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=2200&q=85',4
where not exists (select 1 from public.mff_slides);

-- Starter gallery images; these are illustrative stock photos and can be replaced in Admin.
insert into public.mff_gallery (caption_en,caption_bn,category,image_url,sort_order)
select 'Matchday','ম্যাচের মুহূর্ত','Matchday','https://images.unsplash.com/photo-1574629810360-7efabe195018?auto=format&fit=crop&w=1200&q=85',1
where not exists (select 1 from public.mff_gallery)
union all
select 'Training','অনুশীলন','Training','https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=85',2
where not exists (select 1 from public.mff_gallery)
union all
select 'Stadium','স্টেডিয়াম','Stadium','https://images.unsplash.com/photo-1522778119026-d647f0596c20?auto=format&fit=crop&w=1200&q=85',3
where not exists (select 1 from public.mff_gallery)
union all
select 'Football','ফুটবল','Football','https://images.unsplash.com/photo-1508098682722-e99c43a406b2?auto=format&fit=crop&w=1200&q=85',4
where not exists (select 1 from public.mff_gallery);

insert into public.mff_site_settings (id,content)
values ('main', jsonb_build_object(
  'aboutTitleEn','A stronger future through football',
  'aboutTitleBn','ফুটবলের মাধ্যমে আরও শক্তিশালী ভবিষ্যৎ',
  'aboutTextEn','Mondol Football Federation brings people together through the game, supporting participation, development and fair play.',
  'aboutTextBn','মণ্ডল ফুটবল ফেডারেশন খেলাধুলার মাধ্যমে মানুষকে একত্রিত করে, অংশগ্রহণ, উন্নয়ন ও ন্যায্য খেলাকে উৎসাহিত করে।',
  'missionEn','Promote access to football, support player development, and encourage participation at every level.',
  'missionBn','ফুটবলে অংশগ্রহণের সুযোগ বৃদ্ধি, খেলোয়াড়দের বিকাশে সহায়তা এবং সব পর্যায়ে অংশগ্রহণ উৎসাহিত করা।',
  'visionEn','Build an inclusive football community shaped by opportunity, respect, and fair play.',
  'visionBn','সুযোগ, সম্মান ও ন্যায্য খেলাকে ভিত্তি করে একটি অন্তর্ভুক্তিমূলক ফুটবল কমিউনিটি গড়ে তোলা।'
)) on conflict (id) do nothing;

create table if not exists public.mff_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

-- RLS helper: only user IDs explicitly listed in mff_admins may write.
create or replace function public.is_mff_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (select 1 from public.mff_admins where user_id = auth.uid());
$$;
revoke all on function public.is_mff_admin() from public;
grant execute on function public.is_mff_admin() to authenticated;

alter table public.mff_leaders enable row level security;
alter table public.mff_matches enable row level security;
alter table public.mff_news enable row level security;
alter table public.mff_slides enable row level security;
alter table public.mff_gallery enable row level security;
alter table public.mff_teams enable row level security;
alter table public.mff_players enable row level security;
alter table public.mff_competitions enable row level security;
alter table public.mff_standings enable row level security;
alter table public.mff_videos enable row level security;
alter table public.mff_documents enable row level security;
alter table public.mff_site_settings enable row level security;
alter table public.mff_admins enable row level security;

grant usage on schema public to anon, authenticated;
grant select on public.mff_leaders, public.mff_matches, public.mff_news, public.mff_slides, public.mff_gallery, public.mff_teams, public.mff_players, public.mff_competitions, public.mff_standings, public.mff_videos, public.mff_documents, public.mff_site_settings to anon, authenticated;
grant insert, update, delete on public.mff_leaders, public.mff_matches, public.mff_news, public.mff_slides, public.mff_gallery, public.mff_teams, public.mff_players, public.mff_competitions, public.mff_standings, public.mff_videos, public.mff_documents, public.mff_site_settings to authenticated;

-- Public can view published content; only listed MFF admins can change it.
drop policy if exists "Public can read MFF leaders" on public.mff_leaders;
create policy "Public can read MFF leaders" on public.mff_leaders for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage leaders" on public.mff_leaders;
create policy "MFF admins manage leaders" on public.mff_leaders for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF matches" on public.mff_matches;
create policy "Public can read MFF matches" on public.mff_matches for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage matches" on public.mff_matches;
create policy "MFF admins manage matches" on public.mff_matches for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF news" on public.mff_news;
create policy "Public can read MFF news" on public.mff_news for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage news" on public.mff_news;
create policy "MFF admins manage news" on public.mff_news for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF slides" on public.mff_slides;
create policy "Public can read MFF slides" on public.mff_slides for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage slides" on public.mff_slides;
create policy "MFF admins manage slides" on public.mff_slides for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF gallery" on public.mff_gallery;
create policy "Public can read MFF gallery" on public.mff_gallery for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage gallery" on public.mff_gallery;
create policy "MFF admins manage gallery" on public.mff_gallery for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF teams" on public.mff_teams;
create policy "Public can read MFF teams" on public.mff_teams for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage teams" on public.mff_teams;
create policy "MFF admins manage teams" on public.mff_teams for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF players" on public.mff_players;
create policy "Public can read MFF players" on public.mff_players for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage players" on public.mff_players;
create policy "MFF admins manage players" on public.mff_players for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF competitions" on public.mff_competitions;
create policy "Public can read MFF competitions" on public.mff_competitions for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage competitions" on public.mff_competitions;
create policy "MFF admins manage competitions" on public.mff_competitions for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF standings" on public.mff_standings;
create policy "Public can read MFF standings" on public.mff_standings for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage standings" on public.mff_standings;
create policy "MFF admins manage standings" on public.mff_standings for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF videos" on public.mff_videos;
create policy "Public can read MFF videos" on public.mff_videos for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage videos" on public.mff_videos;
create policy "MFF admins manage videos" on public.mff_videos for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF documents" on public.mff_documents;
create policy "Public can read MFF documents" on public.mff_documents for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage documents" on public.mff_documents;
create policy "MFF admins manage documents" on public.mff_documents for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

drop policy if exists "Public can read MFF site settings" on public.mff_site_settings;
create policy "Public can read MFF site settings" on public.mff_site_settings for select to anon, authenticated using (true);
drop policy if exists "MFF admins manage site settings" on public.mff_site_settings;
create policy "MFF admins manage site settings" on public.mff_site_settings for all to authenticated using (public.is_mff_admin()) with check (public.is_mff_admin());

-- No client-side access to the admin allowlist; the owner adds IDs in SQL Editor.
revoke all on public.mff_admins from anon, authenticated;

-- Public image URLs; only listed admins may upload/change/delete files.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('mff-uploads', 'mff-uploads', true, 2097152, array['image/jpeg','image/png','image/webp','image/gif'])
on conflict (id) do update set public = true, file_size_limit = 2097152, allowed_mime_types = array['image/jpeg','image/png','image/webp','image/gif'];

drop policy if exists "Public can view MFF uploaded images" on storage.objects;
create policy "Public can view MFF uploaded images" on storage.objects for select to anon, authenticated using (bucket_id = 'mff-uploads');
drop policy if exists "MFF admins upload images" on storage.objects;
create policy "MFF admins upload images" on storage.objects for insert to authenticated with check (bucket_id = 'mff-uploads' and public.is_mff_admin());
drop policy if exists "MFF admins update images" on storage.objects;
create policy "MFF admins update images" on storage.objects for update to authenticated using (bucket_id = 'mff-uploads' and public.is_mff_admin()) with check (bucket_id = 'mff-uploads' and public.is_mff_admin());
drop policy if exists "MFF admins delete images" on storage.objects;
create policy "MFF admins delete images" on storage.objects for delete to authenticated using (bucket_id = 'mff-uploads' and public.is_mff_admin());

-- After creating an admin user in Authentication -> Users, run this separately:
-- insert into public.mff_admins (user_id) values ('PASTE-THE-ADMIN-USER-UUID-HERE');
