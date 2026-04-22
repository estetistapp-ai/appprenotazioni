begin;

create extension if not exists pgcrypto;

-- =====================================================
-- SALONS
-- =====================================================
create table if not exists public.salons (
  id text primary key,
  name text not null,
  slug text not null unique,
  active boolean not null default true,
  created_at timestamptz not null default now()
);

insert into public.salons (id, name, slug, active)
select
  'salone_1',
  'Salon Parrucchiere',
  'salone-1',
  true
where not exists (
  select 1 from public.salons where id = 'salone_1'
);

-- =====================================================
-- BUSINESS SETTINGS
-- =====================================================
create table if not exists public.business_settings (
  id text primary key,
  salon_id text not null,
  slot_minutes integer not null default 15,
  min_advance_min integer not null default 60,
  closed_weekdays integer[] not null default array[0,1],
  holidays text[] not null default array[]::text[],
  morning_enabled boolean not null default true,
  morning_start text not null default '09:00',
  morning_end text not null default '13:00',
  afternoon_enabled boolean not null default true,
  afternoon_start text not null default '15:30',
  afternoon_end text not null default '20:00',
  brand_title text not null default 'Salon Parrucchiere',
  brand_subtitle text not null default 'Prenota il tuo appuntamento in pochi secondi',
  brand_description text not null default '',
  logo_url text,
  icon_192 text,
  icon_512 text,
  updated_at timestamptz not null default now()
);

alter table public.business_settings
  add column if not exists salon_id text,
  add column if not exists slot_minutes integer,
  add column if not exists min_advance_min integer,
  add column if not exists closed_weekdays integer[],
  add column if not exists holidays text[],
  add column if not exists morning_enabled boolean,
  add column if not exists morning_start text,
  add column if not exists morning_end text,
  add column if not exists afternoon_enabled boolean,
  add column if not exists afternoon_start text,
  add column if not exists afternoon_end text,
  add column if not exists brand_title text,
  add column if not exists brand_subtitle text,
  add column if not exists brand_description text,
  add column if not exists logo_url text,
  add column if not exists icon_192 text,
  add column if not exists icon_512 text,
  add column if not exists updated_at timestamptz default now();

update public.business_settings
set
  slot_minutes = coalesce(slot_minutes, 15),
  min_advance_min = coalesce(min_advance_min, 60),
  closed_weekdays = coalesce(closed_weekdays, array[0,1]),
  holidays = coalesce(holidays, array[]::text[]),
  morning_enabled = coalesce(morning_enabled, true),
  morning_start = coalesce(morning_start, '09:00'),
  morning_end = coalesce(morning_end, '13:00'),
  afternoon_enabled = coalesce(afternoon_enabled, true),
  afternoon_start = coalesce(afternoon_start, '15:30'),
  afternoon_end = coalesce(afternoon_end, '20:00'),
  brand_title = coalesce(brand_title, 'Salon Parrucchiere'),
  brand_subtitle = coalesce(brand_subtitle, 'Prenota il tuo appuntamento in pochi secondi'),
  brand_description = coalesce(brand_description, ''),
  updated_at = now();

update public.business_settings
set salon_id = coalesce(salon_id, 'salone_1');

alter table public.business_settings
  alter column salon_id set not null,
  alter column slot_minutes set default 15,
  alter column min_advance_min set default 60,
  alter column closed_weekdays set default array[0,1],
  alter column holidays set default array[]::text[],
  alter column morning_enabled set default true,
  alter column morning_start set default '09:00',
  alter column morning_end set default '13:00',
  alter column afternoon_enabled set default true,
  alter column afternoon_start set default '15:30',
  alter column afternoon_end set default '20:00',
  alter column brand_title set default 'Salon Parrucchiere',
  alter column brand_subtitle set default 'Prenota il tuo appuntamento in pochi secondi',
  alter column brand_description set default '';

alter table public.business_settings
  alter column salon_id set not null,
  alter column slot_minutes set not null,
  alter column min_advance_min set not null,
  alter column closed_weekdays set not null,
  alter column holidays set not null,
  alter column morning_enabled set not null,
  alter column morning_start set not null,
  alter column morning_end set not null,
  alter column afternoon_enabled set not null,
  alter column afternoon_start set not null,
  alter column afternoon_end set not null,
  alter column brand_title set not null,
  alter column brand_subtitle set not null,
  alter column brand_description set not null,
  alter column updated_at set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'business_settings_slot_minutes_check'
  ) then
    alter table public.business_settings
      add constraint business_settings_slot_minutes_check
      check (slot_minutes in (15, 30));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'business_settings_salon_id_fkey'
  ) then
    alter table public.business_settings
      add constraint business_settings_salon_id_fkey
      foreign key (salon_id) references public.salons(id) on delete cascade;
  end if;
end $$;

create unique index if not exists idx_business_settings_salon_id
on public.business_settings(salon_id);

insert into public.business_settings (
  id,
  salon_id,
  slot_minutes,
  min_advance_min,
  closed_weekdays,
  holidays,
  morning_enabled,
  morning_start,
  morning_end,
  afternoon_enabled,
  afternoon_start,
  afternoon_end,
  brand_title,
  brand_subtitle,
  brand_description,
  logo_url,
  icon_192,
  icon_512
)
select
  'salone_1__settings',
  'salone_1',
  15,
  60,
  array[0,1],
  array[]::text[],
  true,
  '09:00',
  '13:00',
  true,
  '15:30',
  '20:00',
  'Salon Parrucchiere',
  'Prenota il tuo appuntamento in pochi secondi',
  '',
  '',
  '/icons/icon-192.png',
  '/icons/icon-512.png'
where not exists (
  select 1 from public.business_settings where salon_id = 'salone_1'
);

-- =====================================================
-- SERVICES
-- =====================================================
create table if not exists public.services (
  id text primary key,
  salon_id text not null,
  name text not null,
  duration_min integer not null,
  price numeric(10,2) not null default 0,
  active boolean not null default true,
  updated_at timestamptz not null default now()
);

alter table public.services
  add column if not exists salon_id text,
  add column if not exists duration_min integer,
  add column if not exists price numeric(10,2),
  add column if not exists active boolean,
  add column if not exists updated_at timestamptz default now();

update public.services
set
  duration_min = coalesce(duration_min, 30),
  price = coalesce(price, 0),
  active = coalesce(active, true),
  updated_at = now();

update public.services
set salon_id = coalesce(salon_id, 'salone_1');

alter table public.services
  alter column salon_id set not null,
  alter column duration_min set default 30,
  alter column price set default 0,
  alter column active set default true;

alter table public.services
  alter column salon_id set not null,
  alter column duration_min set not null,
  alter column price set not null,
  alter column active set not null,
  alter column updated_at set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'services_duration_min_check'
  ) then
    alter table public.services
      add constraint services_duration_min_check
      check (duration_min > 0);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'services_salon_id_fkey'
  ) then
    alter table public.services
      add constraint services_salon_id_fkey
      foreign key (salon_id) references public.salons(id) on delete cascade;
  end if;
end $$;

create index if not exists idx_services_salon_id
on public.services(salon_id);

insert into public.services (id, salon_id, name, duration_min, price, active)
values
  ('salone_1__barba', 'salone_1', 'Barba', 15, 10, true),
  ('salone_1__taglio', 'salone_1', 'Taglio', 30, 15, true),
  ('salone_1__barba_taglio', 'salone_1', 'Barba + Taglio', 45, 20, true)
on conflict (id) do update
set
  salon_id = excluded.salon_id,
  name = excluded.name,
  duration_min = excluded.duration_min,
  price = excluded.price,
  active = excluded.active;

-- =====================================================
-- COLLABORATORS (MAX 5)
-- =====================================================
create table if not exists public.collaborators (
  id text primary key,
  salon_id text not null,
  name text not null,
  active boolean not null default true,
  calendar_id text,
  color text,
  weekly_off_days integer[] not null default array[]::integer[],
  holidays text[] not null default array[]::text[],
  morning_enabled boolean not null default true,
  morning_start text not null default '09:00',
  morning_end text not null default '13:00',
  morning_open text,
  morning_close text,
  afternoon_enabled boolean not null default true,
  afternoon_start text not null default '15:30',
  afternoon_end text not null default '20:00',
  afternoon_open text,
  afternoon_close text,
  updated_at timestamptz not null default now()
);

alter table public.collaborators
  add column if not exists salon_id text,
  add column if not exists calendar_id text,
  add column if not exists color text,
  add column if not exists weekly_off_days integer[] not null default array[]::integer[],
  add column if not exists holidays text[] not null default array[]::text[],
  add column if not exists morning_enabled boolean not null default true,
  add column if not exists morning_start text not null default '09:00',
  add column if not exists morning_end text not null default '13:00',
  add column if not exists morning_open text,
  add column if not exists morning_close text,
  add column if not exists afternoon_enabled boolean not null default true,
  add column if not exists afternoon_start text not null default '15:30',
  add column if not exists afternoon_end text not null default '20:00',
  add column if not exists afternoon_open text,
  add column if not exists afternoon_close text,
  add column if not exists updated_at timestamptz default now();

update public.collaborators
set
  weekly_off_days = coalesce(weekly_off_days, array[]::integer[]),
  holidays = coalesce(holidays, array[]::text[]),
  morning_enabled = coalesce(morning_enabled, true),
  morning_start = coalesce(morning_start, morning_open, '09:00'),
  morning_end = coalesce(morning_end, morning_close, '13:00'),
  morning_open = coalesce(morning_open, morning_start, '09:00'),
  morning_close = coalesce(morning_close, morning_end, '13:00'),
  afternoon_enabled = coalesce(afternoon_enabled, true),
  afternoon_start = coalesce(afternoon_start, afternoon_open, '15:30'),
  afternoon_end = coalesce(afternoon_end, afternoon_close, '20:00'),
  afternoon_open = coalesce(afternoon_open, afternoon_start, '15:30'),
  afternoon_close = coalesce(afternoon_close, afternoon_end, '20:00'),
  updated_at = now();

update public.collaborators
set salon_id = coalesce(salon_id, 'salone_1');

alter table public.collaborators
  alter column salon_id set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'collaborators_salon_id_fkey'
  ) then
    alter table public.collaborators
      add constraint collaborators_salon_id_fkey
      foreign key (salon_id) references public.salons(id) on delete cascade;
  end if;
end $$;

create index if not exists idx_collaborators_salon_id
on public.collaborators(salon_id);

insert into public.collaborators (
  id,
  salon_id,
  name,
  active,
  calendar_id,
  color,
  weekly_off_days,
  holidays,
  morning_enabled,
  morning_start,
  morning_end,
  morning_open,
  morning_close,
  afternoon_enabled,
  afternoon_start,
  afternoon_end,
  afternoon_open,
  afternoon_close
)
select
  'salone_1__collaboratore_1',
  'salone_1',
  'Collaboratore 1',
  true,
  'collaboratore_1',
  '',
  array[]::integer[],
  array[]::text[],
  true,
  '09:00',
  '13:00',
  '09:00',
  '13:00',
  true,
  '15:30',
  '20:00',
  '15:30',
  '20:00'
where not exists (select 1 from public.collaborators where salon_id = 'salone_1');

-- =====================================================
-- APPOINTMENTS (DATABASE ONLY)
-- =====================================================
create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  salon_id text not null,
  event_id text not null unique,
  google_event_id text,
  calendar_id text not null,
  customer_name text not null,
  phone text not null default '',
  customer_phone text,
  customer_names text[],
  service_id text not null,
  service_name text not null,
  collaborator_id text not null,
  collaborator_name text not null,
  notes text,
  price numeric(10,2) not null default 0,
  date text not null,
  time text not null,
  date_iso text,
  start_time text,
  end_time text,
  start_iso timestamptz not null,
  end_iso timestamptz not null,
  people_count integer not null default 1,
  group_label text,
  recurrence_label text,
  recurring_rule_id uuid,
  status text not null default 'confirmed',
  created_at timestamptz not null default now()
);

alter table public.appointments
  add column if not exists salon_id text,
  add column if not exists google_event_id text,
  add column if not exists customer_phone text,
  add column if not exists customer_names text[],
  add column if not exists date_iso text,
  add column if not exists start_time text,
  add column if not exists end_time text,
  add column if not exists recurring_rule_id uuid;

update public.appointments
set
  phone = coalesce(phone, ''),
  price = coalesce(price, 0),
  people_count = greatest(1, coalesce(people_count, 1)),
  status = coalesce(status, 'confirmed'),
  date_iso = coalesce(date_iso, date),
  start_time = coalesce(start_time, time),
  end_time = coalesce(end_time, ''),
  created_at = coalesce(created_at, now());

update public.appointments
set salon_id = coalesce(salon_id, 'salone_1');

alter table public.appointments
  alter column salon_id set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'appointments_status_check'
  ) then
    alter table public.appointments
      add constraint appointments_status_check
      check (status in ('confirmed', 'cancelled'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'appointments_end_after_start_check'
  ) then
    alter table public.appointments
      add constraint appointments_end_after_start_check
      check (end_iso > start_iso);
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'appointments_salon_id_fkey'
  ) then
    alter table public.appointments
      add constraint appointments_salon_id_fkey
      foreign key (salon_id) references public.salons(id) on delete cascade;
  end if;
end $$;

create index if not exists idx_appointments_start_iso on public.appointments(start_iso);
create index if not exists idx_appointments_end_iso on public.appointments(end_iso);
create index if not exists idx_appointments_collaborator on public.appointments(collaborator_id);
create index if not exists idx_appointments_date on public.appointments(date);
create index if not exists idx_appointments_status on public.appointments(status);
create index if not exists idx_appointments_salon_id on public.appointments(salon_id);
create index if not exists idx_appointments_salon_collaborator_date on public.appointments(salon_id, collaborator_id, date);

-- =====================================================
-- RECURRING RULES
-- =====================================================
create table if not exists public.recurring_rules (
  id uuid primary key default gen_random_uuid(),
  salon_id text not null,
  customer_name text not null,
  phone text not null default '',
  service_id text not null,
  collaborator_id text not null,
  start_date text not null,
  time text not null,
  every integer not null,
  unit text not null,
  occurrences integer,
  notes text,
  recurrence_label text not null,
  created_event_ids text[] not null default array[]::text[],
  created_at timestamptz not null default now()
);

alter table public.recurring_rules
  add column if not exists salon_id text;

update public.recurring_rules
set salon_id = coalesce(salon_id, 'salone_1');

alter table public.recurring_rules
  alter column salon_id set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'recurring_rules_unit_check'
  ) then
    alter table public.recurring_rules
      add constraint recurring_rules_unit_check
      check (unit in ('days', 'weeks', 'months'));
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint where conname = 'recurring_rules_salon_id_fkey'
  ) then
    alter table public.recurring_rules
      add constraint recurring_rules_salon_id_fkey
      foreign key (salon_id) references public.salons(id) on delete cascade;
  end if;
end $$;

create index if not exists idx_recurring_rules_salon_id
on public.recurring_rules(salon_id);

-- =====================================================
-- UPDATED_AT TRIGGER
-- =====================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_business_settings_updated_at on public.business_settings;
create trigger trg_business_settings_updated_at
before update on public.business_settings
for each row
execute function public.set_updated_at();

drop trigger if exists trg_services_updated_at on public.services;
create trigger trg_services_updated_at
before update on public.services
for each row
execute function public.set_updated_at();

drop trigger if exists trg_collaborators_updated_at on public.collaborators;
create trigger trg_collaborators_updated_at
before update on public.collaborators
for each row
execute function public.set_updated_at();

-- =====================================================
-- MAX 5 COLLABORATORS
-- =====================================================
create or replace function public.enforce_max_5_collaborators()
returns trigger
language plpgsql
as $$
begin
  if (
    select count(*)
    from public.collaborators
    where salon_id = new.salon_id
      and id <> coalesce(new.id, '')
  ) >= 5 then
    raise exception 'Massimo 5 collaboratori consentiti per salone';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_enforce_max_5_collaborators on public.collaborators;
create trigger trg_enforce_max_5_collaborators
before insert on public.collaborators
for each row
execute function public.enforce_max_5_collaborators();

-- =====================================================
-- RLS
-- =====================================================
alter table public.salons enable row level security;
alter table public.business_settings enable row level security;
alter table public.services enable row level security;
alter table public.collaborators enable row level security;
alter table public.appointments enable row level security;
alter table public.recurring_rules enable row level security;

drop policy if exists salons_all on public.salons;
create policy salons_all
on public.salons
for all
using (true)
with check (true);

drop policy if exists business_settings_all on public.business_settings;
create policy business_settings_all
on public.business_settings
for all
using (true)
with check (true);

drop policy if exists services_all on public.services;
create policy services_all
on public.services
for all
using (true)
with check (true);

drop policy if exists collaborators_all on public.collaborators;
create policy collaborators_all
on public.collaborators
for all
using (true)
with check (true);

drop policy if exists appointments_all on public.appointments;
create policy appointments_all
on public.appointments
for all
using (true)
with check (true);

drop policy if exists recurring_rules_all on public.recurring_rules;
create policy recurring_rules_all
on public.recurring_rules
for all
using (true)
with check (true);

commit;
