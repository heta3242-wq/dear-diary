-- Dear Diary: run this once in Supabase → SQL Editor → New query → Run

-- 1) one row per user per day
create table if not exists public.entries (
  user_id    uuid not null references auth.users(id) on delete cascade,
  date       date not null,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, date)
);

-- 2) everyone can only see and change their own pages
alter table public.entries enable row level security;

drop policy if exists "entries: read own"   on public.entries;
drop policy if exists "entries: insert own" on public.entries;
drop policy if exists "entries: update own" on public.entries;
drop policy if exists "entries: delete own" on public.entries;

create policy "entries: read own"   on public.entries for select using (auth.uid() = user_id);
create policy "entries: insert own" on public.entries for insert with check (auth.uid() = user_id);
create policy "entries: update own" on public.entries for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "entries: delete own" on public.entries for delete using (auth.uid() = user_id);

-- 3) a PRIVATE bucket for photos; each user gets their own folder (<user id>/...)
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('diary-photos', 'diary-photos', false, 10485760, array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "diary photos: read own"   on storage.objects;
drop policy if exists "diary photos: upload own" on storage.objects;
drop policy if exists "diary photos: delete own" on storage.objects;

create policy "diary photos: read own" on storage.objects for select
  using (bucket_id = 'diary-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "diary photos: upload own" on storage.objects for insert
  with check (bucket_id = 'diary-photos' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "diary photos: delete own" on storage.objects for delete
  using (bucket_id = 'diary-photos' and (storage.foldername(name))[1] = auth.uid()::text);
