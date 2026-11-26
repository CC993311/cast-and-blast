-- FishBound: California ocean species batch 1
-- Source: CDFW 2026 Ocean Sport Fishing Regulations, updated July 17, 2026.
-- Safe to run more than once. Regional seasons and limits are stated explicitly.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = 'CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 1'
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Department of Fish and Wildlife',
      'CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 1',
      'https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=239985',
      2026,
      now(),
      'official',
      'verified',
      'Official 2026 California Ocean Sport Fishing Regulations booklet, last updated July 17, 2026. California Halibut and Pacific Halibut rules include regional season or bag-limit differences.'
    )
    returning id into v_source_id;
  end if;

  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='california-halibut'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit, minimum_length,
      special_restrictions, rule_details, official_reference,
      source_id, verification_status, verified_at
    ) values (
      'CA',
      'California Halibut',
      'california-halibut',
      'statewide',
      'Open year-round',
      'North of Point Sur: 2 fish. South of Point Sur: 5 fish.',
      'North of Point Sur: 2 fish. South of Point Sur: 5 fish.',
      '22 inches total length',
      'Bag and possession limits differ at Point Sur, Monterey County. Check current local closures and marine protected area restrictions.',
      jsonb_build_object(
        'season','Open year-round.',
        'daily_bag_limit','North of Point Sur, Monterey County: 2 fish. South of Point Sur: 5 fish.',
        'possession_limit','North of Point Sur: 2 fish. South of Point Sur: 5 fish.',
        'minimum_size','22 inches total length.',
        'regional_note','Point Sur is the boundary between the northern and southern bag-limit areas. Marine protected area and local restrictions still apply.'
      ),
      'CDFW 2026 Ocean Sport Fishing Regulations; current regional ocean regulation summaries.',
      v_source_id,
      'verified',
      now()
    );
  end if;

  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='pacific-halibut'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit, minimum_length,
      gear_restrictions, special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Pacific Halibut',
      'pacific-halibut',
      'statewide',
      '2026 season: April 1-November 15 north of Point Arena; April 1-December 31 south of Point Arena, or until the quota is reached, whichever occurs first.',
      '1 fish',
      '1 fish',
      'No minimum size limit',
      'When angling, no more than one line with two hooks attached may be used. A harpoon, gaff, or net may assist with a fish legally caught by angling, subject to additional restrictions.',
      'Season dates differ north and south of Point Arena, Mendocino County. The southern season may close earlier if the quota is reached. Check CDFW for in-season closure notices before fishing.',
      jsonb_build_object(
        'season','North of Point Arena: April 1 through November 15, 2026. South of Point Arena: April 1 through December 31, 2026, or until the quota is reached, whichever occurs first.',
        'daily_bag_limit','1 fish.',
        'possession_limit','1 fish.',
        'minimum_size','No minimum size limit.',
        'gear','When angling, no more than one line with two hooks attached may be used.',
        'regional_note','Point Arena, Mendocino County, separates the northern and southern season areas. Check current CDFW in-season closure notices.'
      ),
      'CDFW Pacific Halibut Regulations and 2026 Ocean Sport Fishing Regulations.',
      v_source_id,
      'verified',
      now()
    );
  end if;
end $$;