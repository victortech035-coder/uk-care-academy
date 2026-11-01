-- Run in Supabase SQL Editor. This is a secure starter schema.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  created_at timestamptz not null default now()
);
create table if not exists public.lesson_progress (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_slug text not null,
  completed_at timestamptz not null default now(),
  unique(user_id, lesson_slug)
);
create table if not exists public.quiz_attempts (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  quiz_name text not null,
  score integer not null check(score >= 0),
  total integer not null check(total > 0 and score <= total),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
alter table public.lesson_progress enable row level security;
alter table public.quiz_attempts enable row level security;
create policy "Users read own profile" on public.profiles for select to authenticated using (auth.uid() = id);
create policy "Users update own profile" on public.profiles for update to authenticated using (auth.uid() = id) with check (auth.uid() = id);
create policy "Users read own progress" on public.lesson_progress for select to authenticated using (auth.uid() = user_id);
create policy "Users add own progress" on public.lesson_progress for insert to authenticated with check (auth.uid() = user_id);
create policy "Users delete own progress" on public.lesson_progress for delete to authenticated using (auth.uid() = user_id);
create policy "Users read own attempts" on public.quiz_attempts for select to authenticated using (auth.uid() = user_id);
-- For a production exam, DO NOT allow browser clients to submit trusted scores.
-- Add a server-side Edge Function that validates responses and writes attempts.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles(id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();
