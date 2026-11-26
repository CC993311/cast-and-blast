-- FishBound: California largemouth bass statewide baseline
-- Source: CDFW 2026 Freshwater Sport Fishing Regulations booklet.
-- This inserts only the statewide baseline. Water-specific exceptions still need
-- their own verified records and must be checked in the official booklet.
-- Run once in Supabase SQL Editor.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = '2026 Freshwater Sport Fishing Regulations'
    and regulation_year = 2026
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Department of Fish and Wildlife',
      '2026 Freshwater Sport Fishing Regulations',
      'https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=209090',
      2026,
      now(),
      'official',
      'verified',
      'Official CDFW 2026 freshwater regulations booklet. This source record supports the general statewide black bass baseline only; special-water exceptions must be checked separately.'
    )
    returning id into v_source_id;
  end if;

  if not exists (
    select 1 from public.regulation_rules
    where state_code = 'CA'
      and species_key = 'largemouth-bass'
      and rule_scope = 'statewide'
      and source_id = v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, season_close, daily_bag_limit,
      minimum_length, special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Largemouth Bass',
      'largemouth-bass',
      'statewide',
      'Open all year',
      null,
      '5 fish per day',
      '12 inches total length in lakes, reservoirs and the Sacramento–San Joaquin Delta; no general minimum in rivers, streams, canals and private ponds.',
      'Special regulations, closures, county/district rules and water-specific exceptions may override the statewide baseline. Check the exact water in the current CDFW booklet before keeping fish.',
      jsonb_build_object(
        'applies_under', 'California black bass regulations (includes largemouth bass)',
        'lakes_reservoirs_delta', jsonb_build_object(
          'season', 'Open all year unless a special closure applies',
          'daily_bag_limit', '5 fish',
          'minimum_length', '12 inches total length'
        ),
        'rivers_streams_canals_private_ponds', jsonb_build_object(
          'season', 'Open all year unless a special closure applies',
          'daily_bag_limit', '5 fish',
          'minimum_length', 'No general minimum size'
        ),
        'important', 'This is the statewide baseline only. Special waters and local exceptions can have different seasons, bag limits or size limits.'
      ),
      'California Code of Regulations, Title 14, Section 5.00; CDFW 2026 Freshwater Sport Fishing Regulations booklet.',
      v_source_id,
      'verified',
      now()
    );
  end if;
end $$;
