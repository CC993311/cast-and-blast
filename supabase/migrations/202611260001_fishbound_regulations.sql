-- FishBound Regulations Database v1
-- Run this in Supabase SQL Editor for project ubnmhqxitiigsctbsmqy.
-- This creates separate regulation tables and does NOT modify catches, profiles, journal, or other app tables.

create extension if not exists pgcrypto;

create table if not exists public.regulation_states (
  state_code text primary key check (length(state_code) = 2),
  state_name text not null unique,
  agency_name text not null,
  agency_url text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.regulation_sources (
  id uuid primary key default gen_random_uuid(),
  state_code text not null references public.regulation_states(state_code) on delete cascade,
  agency_name text not null,
  source_title text not null,
  source_url text not null,
  regulation_year integer,
  publication_date date,
  effective_from date,
  effective_to date,
  checked_at timestamptz,
  source_type text not null default 'official',
  verification_status text not null default 'needs_review'
    check (verification_status in ('needs_review','verified','superseded','unavailable')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.regulation_rules (
  id uuid primary key default gen_random_uuid(),
  state_code text not null references public.regulation_states(state_code) on delete cascade,
  species_name text not null,
  species_key text not null,
  waterbody_name text,
  waterbody_key text,
  waterbody_type text,
  rule_scope text not null default 'statewide'
    check (rule_scope in ('statewide','waterbody','region','county','special')),
  season_open text,
  season_close text,
  daily_bag_limit text,
  possession_limit text,
  minimum_length text,
  maximum_length text,
  slot_limit text,
  gear_restrictions text,
  special_restrictions text,
  rule_details jsonb not null default '{}'::jsonb,
  official_reference text,
  source_id uuid not null references public.regulation_sources(id) on delete restrict,
  effective_from date,
  effective_to date,
  verification_status text not null default 'needs_review'
    check (verification_status in ('needs_review','verified','superseded')),
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint regulation_rules_verified_has_verified_source check (
    verification_status <> 'verified' or verified_at is not null
  )
);

create index if not exists regulation_rules_lookup_idx
  on public.regulation_rules (state_code, species_key);
create index if not exists regulation_rules_waterbody_idx
  on public.regulation_rules (state_code, waterbody_key);
create index if not exists regulation_rules_status_idx
  on public.regulation_rules (verification_status);
create index if not exists regulation_sources_state_year_idx
  on public.regulation_sources (state_code, regulation_year desc);

alter table public.regulation_states enable row level security;
alter table public.regulation_sources enable row level security;
alter table public.regulation_rules enable row level security;

drop policy if exists "Public can read regulation states" on public.regulation_states;
create policy "Public can read regulation states"
  on public.regulation_states for select to anon, authenticated using (true);

drop policy if exists "Public can read regulation sources" on public.regulation_sources;
create policy "Public can read regulation sources"
  on public.regulation_sources for select to anon, authenticated using (true);

drop policy if exists "Public can read verified regulation rules" on public.regulation_rules;
create policy "Public can read verified regulation rules"
  on public.regulation_rules for select to anon, authenticated
  using (verification_status = 'verified');

-- Official agency directory for all 50 states.
insert into public.regulation_states (state_code, state_name, agency_name, agency_url) values
('AL','Alabama','Alabama Department of Conservation and Natural Resources','https://www.outdooralabama.com/fishing'),
('AK','Alaska','Alaska Department of Fish and Game','https://www.adfg.alaska.gov/index.cfm?adfg=fishregulations.main'),
('AZ','Arizona','Arizona Game and Fish Department','https://www.azgfd.com/fishing/'),
('AR','Arkansas','Arkansas Game and Fish Commission','https://www.agfc.com/fishing/'),
('CA','California','California Department of Fish and Wildlife','https://wildlife.ca.gov/Regulations'),
('CO','Colorado','Colorado Parks and Wildlife','https://cpw.state.co.us/thingstodo/Pages/Fishing.aspx'),
('CT','Connecticut','Connecticut Department of Energy and Environmental Protection','https://portal.ct.gov/deep/fishing'),
('DE','Delaware','Delaware Department of Natural Resources and Environmental Control','https://dnrec.delaware.gov/fish-wildlife/'),
('FL','Florida','Florida Fish and Wildlife Conservation Commission','https://myfwc.com/fishing/'),
('GA','Georgia','Georgia Department of Natural Resources','https://georgiawildlife.com/fishing'),
('HI','Hawaii','Hawaii Department of Land and Natural Resources','https://dlnr.hawaii.gov/dar/'),
('ID','Idaho','Idaho Department of Fish and Game','https://idfg.idaho.gov/rules/fish'),
('IL','Illinois','Illinois Department of Natural Resources','https://www.ifishillinois.org/regulations/'),
('IN','Indiana','Indiana Department of Natural Resources','https://www.in.gov/dnr/fish-and-wildlife/'),
('IA','Iowa','Iowa Department of Natural Resources','https://www.iowadnr.gov/fishing'),
('KS','Kansas','Kansas Department of Wildlife and Parks','https://ksoutdoors.gov/Fishing'),
('KY','Kentucky','Kentucky Department of Fish and Wildlife Resources','https://fw.ky.gov/Fish/Pages/default.aspx'),
('LA','Louisiana','Louisiana Department of Wildlife and Fisheries','https://www.wlf.louisiana.gov/page/fishing'),
('ME','Maine','Maine Department of Inland Fisheries and Wildlife','https://www.maine.gov/ifw/fishing-boating/fishing/index.html'),
('MD','Maryland','Maryland Department of Natural Resources','https://dnr.maryland.gov/fisheries/Pages/default.aspx'),
('MA','Massachusetts','Massachusetts Division of Fisheries and Wildlife','https://www.mass.gov/freshwater-fishing'),
('MI','Michigan','Michigan Department of Natural Resources','https://www.michigan.gov/dnr/things-to-do/fishing'),
('MN','Minnesota','Minnesota Department of Natural Resources','https://www.dnr.state.mn.us/fishing/index.html'),
('MS','Mississippi','Mississippi Department of Wildlife, Fisheries, and Parks','https://www.mdwfp.com/fishing-boating'),
('MO','Missouri','Missouri Department of Conservation','https://mdc.mo.gov/fishing'),
('MT','Montana','Montana Fish, Wildlife and Parks','https://fwp.mt.gov/fish'),
('NE','Nebraska','Nebraska Game and Parks Commission','https://outdoornebraska.gov/fishing/'),
('NV','Nevada','Nevada Department of Wildlife','https://www.ndow.org/get-outside/fishing/'),
('NH','New Hampshire','New Hampshire Fish and Game Department','https://www.wildlife.nh.gov/fishing'),
('NJ','New Jersey','New Jersey Division of Fish and Wildlife','https://dep.nj.gov/njfw/fishing/'),
('NM','New Mexico','New Mexico Department of Game and Fish','https://wildlife.dgf.nm.gov/fishing/'),
('NY','New York','New York State Department of Environmental Conservation','https://dec.ny.gov/things-to-do/freshwater-fishing'),
('NC','North Carolina','North Carolina Wildlife Resources Commission','https://www.ncwildlife.gov/fishing'),
('ND','North Dakota','North Dakota Game and Fish Department','https://gf.nd.gov/fishing'),
('OH','Ohio','Ohio Department of Natural Resources, Division of Wildlife','https://ohiodnr.gov/discover-and-learn/safety-conservation/about-ODNR/wildlife/fishing'),
('OK','Oklahoma','Oklahoma Department of Wildlife Conservation','https://www.wildlifedepartment.com/fishing'),
('OR','Oregon','Oregon Department of Fish and Wildlife','https://myodfw.com/recreation-report/fishing-report'),
('PA','Pennsylvania','Pennsylvania Fish and Boat Commission','https://www.pa.gov/agencies/fishandboat/fishing.html'),
('RI','Rhode Island','Rhode Island Department of Environmental Management','https://dem.ri.gov/natural-resources-bureau/fish-wildlife'),
('SC','South Carolina','South Carolina Department of Natural Resources','https://www.dnr.sc.gov/fishing.html'),
('SD','South Dakota','South Dakota Game, Fish and Parks','https://gfp.sd.gov/fishing/'),
('TN','Tennessee','Tennessee Wildlife Resources Agency','https://www.tn.gov/twra/fishing.html'),
('TX','Texas','Texas Parks and Wildlife Department','https://tpwd.texas.gov/regulations/outdoor-annual/fishing'),
('UT','Utah','Utah Division of Wildlife Resources','https://wildlife.utah.gov/fishing.html'),
('VT','Vermont','Vermont Fish and Wildlife Department','https://vtfishandwildlife.com/fish'),
('VA','Virginia','Virginia Department of Wildlife Resources','https://dwr.virginia.gov/fishing/regulations/'),
('WA','Washington','Washington Department of Fish and Wildlife','https://wdfw.wa.gov/fishing/regulations'),
('WV','West Virginia','West Virginia Division of Natural Resources','https://wvdnr.gov/fishing/'),
('WI','Wisconsin','Wisconsin Department of Natural Resources','https://dnr.wisconsin.gov/topic/Fishing'),
('WY','Wyoming','Wyoming Game and Fish Department','https://wgfd.wyo.gov/fishing-boating')
on conflict (state_code) do update set
  state_name = excluded.state_name,
  agency_name = excluded.agency_name,
  agency_url = excluded.agency_url;

-- No fishing limits are seeded here: verified rule records must be transcribed
-- from current official publications and linked to a source record.
