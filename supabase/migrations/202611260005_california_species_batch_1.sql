-- FishBound: California freshwater species batch 1
-- Source: CDFW 2026 Freshwater Sport Fishing Regulations, updated 2026-07-10.
-- Covers statewide baselines only. Water/district exceptions are called out in each record.
-- Safe to run more than once.

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
      'Official CDFW 2026 freshwater regulations booklet, updated July 10, 2026. This batch contains statewide species baselines and notes known district/water exceptions.'
    )
    returning id into v_source_id;
  end if;

  -- Smallmouth and spotted bass are included in California's black bass rules.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='smallmouth-bass' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Smallmouth Bass','smallmouth-bass','statewide','Open all year','5 fish per day',
      '12 inches total length in lakes, reservoirs and the Sacramento–San Joaquin Delta; no general minimum in rivers, streams, canals and private ponds.',
      'California black bass rules include smallmouth bass. Special waters may have different size limits, catch-and-release rules, or closures.',
      jsonb_build_object(
        'lakes_reservoirs_delta',jsonb_build_object('season','Open all year unless a special closure applies','daily_bag_limit','5 fish','minimum_length','12 inches total length'),
        'rivers_streams_canals_private_ponds',jsonb_build_object('season','Open all year unless a special closure applies','daily_bag_limit','5 fish','minimum_length','No general minimum size'),
        'important','Special black bass regulations and water-specific exceptions may override this statewide baseline. Check the exact water in the current CDFW booklet.'
      ),
      'California Code of Regulations, Title 14, Section 5.00; 2026 CDFW Freshwater Sport Fishing Regulations, page 26.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='spotted-bass' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Spotted Bass','spotted-bass','statewide','Open all year','5 fish per day',
      '12 inches total length in lakes, reservoirs and the Sacramento–San Joaquin Delta; no general minimum in rivers, streams, canals and private ponds.',
      'California black bass rules include spotted bass. Special waters may have different size limits, catch-and-release rules, or closures.',
      jsonb_build_object(
        'lakes_reservoirs_delta',jsonb_build_object('season','Open all year unless a special closure applies','daily_bag_limit','5 fish','minimum_length','12 inches total length'),
        'rivers_streams_canals_private_ponds',jsonb_build_object('season','Open all year unless a special closure applies','daily_bag_limit','5 fish','minimum_length','No general minimum size'),
        'important','Special black bass regulations and water-specific exceptions may override this statewide baseline. Check the exact water in the current CDFW booklet.'
      ),
      'California Code of Regulations, Title 14, Section 5.00; 2026 CDFW Freshwater Sport Fishing Regulations, page 26.',
      v_source_id,'verified',now()
    );
  end if;

  -- Channel and blue catfish are covered by the same Catfish and Bullheads rule.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='channel-catfish' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      special_restrictions,rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Channel Catfish','channel-catfish','statewide','Open all year except special closures',
      'No statewide numeric limit; district and water exceptions apply',
      'Some districts and named waters have specific limits. Examples include a 10-fish limit in the Colorado River District and Southern District, with lower limits on certain named lakes.',
      jsonb_build_object(
        'general_rule','Open all year except closures; no general numeric limit for catfish.',
        'regional_exceptions','The Colorado River District and Southern District have 10-fish limits in specified waters. Multiple named lakes and counties have different limits.',
        'important','The exact waterbody and district must be checked before relying on a limit.'
      ),
      'California Code of Regulations, Title 14, Section 5.15; 2026 CDFW Freshwater Sport Fishing Regulations, pages 27–28.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='blue-catfish' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      special_restrictions,rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Blue Catfish','blue-catfish','statewide','Open all year except special closures',
      'No statewide numeric limit; district and water exceptions apply',
      'Blue catfish are included in California''s Catfish and Bullheads rule. Some districts and named waters have specific limits.',
      jsonb_build_object(
        'general_rule','Open all year except closures; no general numeric limit for catfish.',
        'regional_exceptions','The Colorado River District and Southern District have 10-fish limits in specified waters. Multiple named lakes and counties have different limits.',
        'important','The exact waterbody and district must be checked before relying on a limit.'
      ),
      'California Code of Regulations, Title 14, Section 5.15; 2026 CDFW Freshwater Sport Fishing Regulations, pages 27–28.',
      v_source_id,'verified',now()
    );
  end if;

  -- Crappie and bluegill share one combined bag limit with all sunfish and crappie.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='black-crappie' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Black Crappie','black-crappie','statewide','Open all year except district or special closures',
      '25 sunfish and crappie combined per day',
      'No general size limit',
      'The 25-fish limit is shared across all sunfish and crappie species, not 25 of each species. Barrett and Upper Otay Lakes have a zero bag limit; Hodges and El Capitan Lakes have a 10-inch minimum for crappie.',
      jsonb_build_object('combined_limit','25 sunfish and crappie of all species combined','size_limit','No general size limit','exceptions','Barrett and Upper Otay Lakes: zero bag limit for all species. Hodges and El Capitan Lakes: crappie minimum 10 inches total length.','season','All year except district or special closures.'),
      'California Code of Regulations, Title 14, Section 5.82; 2026 CDFW Freshwater Sport Fishing Regulations, page 33.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='white-crappie' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','White Crappie','white-crappie','statewide','Open all year except district or special closures',
      '25 sunfish and crappie combined per day',
      'No general size limit',
      'The 25-fish limit is shared across all sunfish and crappie species, not 25 of each species. Barrett and Upper Otay Lakes have a zero bag limit; Hodges and El Capitan Lakes have a 10-inch minimum for crappie.',
      jsonb_build_object('combined_limit','25 sunfish and crappie of all species combined','size_limit','No general size limit','exceptions','Barrett and Upper Otay Lakes: zero bag limit for all species. Hodges and El Capitan Lakes: crappie minimum 10 inches total length.','season','All year except district or special closures.'),
      'California Code of Regulations, Title 14, Section 5.82; 2026 CDFW Freshwater Sport Fishing Regulations, page 33.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='bluegill' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Bluegill','bluegill','statewide','Open all year except district or special closures',
      '25 sunfish and crappie combined per day',
      'No general size limit',
      'Bluegill share the combined 25-fish limit with all sunfish and crappie species. Barrett and Upper Otay Lakes have a zero bag limit.',
      jsonb_build_object('combined_limit','25 sunfish and crappie of all species combined','size_limit','No general size limit','exceptions','Barrett and Upper Otay Lakes: zero bag limit for all species.','season','All year except district or special closures.'),
      'California Code of Regulations, Title 14, Section 5.82; 2026 CDFW Freshwater Sport Fishing Regulations, page 33.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='striped-bass' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Striped Bass','striped-bass','statewide','Open all year except special closures',
      '2 fish per day',
      '18 inches total length',
      'The Colorado River District, Southern District, and New Hogan, San Antonio, and Santa Margarita Lakes have a 10-fish limit with no minimum size. Striped bass hybrids with white bass are treated as striped bass.',
      jsonb_build_object('general_rule','2 fish per day; 18-inch minimum total length.','exceptions','Colorado River District, Southern District, New Hogan Lake, San Antonio Lake, and Santa Margarita Lake: 10 fish per day with no size limit.','hybrids','Striped bass hybrids with white bass are regulated as striped bass.'),
      'California Code of Regulations, Title 14, Section 5.75; 2026 CDFW Freshwater Sport Fishing Regulations, page 31.',
      v_source_id,'verified',now()
    );
  end if;

  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='hybrid-striped-bass' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      minimum_length,special_restrictions,rule_details,official_reference,
      source_id,verification_status,verified_at
    ) values (
      'CA','Hybrid Striped Bass','hybrid-striped-bass','statewide','Open all year except special closures',
      '2 fish per day',
      '18 inches total length',
      'California treats striped bass hybrids with white bass as striped bass. The Colorado River District, Southern District, and New Hogan, San Antonio, and Santa Margarita Lakes have a 10-fish limit with no minimum size.',
      jsonb_build_object('general_rule','2 fish per day; 18-inch minimum total length.','exceptions','Colorado River District, Southern District, New Hogan Lake, San Antonio Lake, and Santa Margarita Lake: 10 fish per day with no size limit.','classification','Striped bass hybrids with white bass are regulated as striped bass.'),
      'California Code of Regulations, Title 14, Section 5.75; 2026 CDFW Freshwater Sport Fishing Regulations, page 31.',
      v_source_id,'verified',now()
    );
  end if;
end $$;
