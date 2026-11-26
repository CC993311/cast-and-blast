-- FishBound Alaska regulations — Batch 3
-- 2026 Southcentral Alaska: West Cook Inlet only.
-- These records are NOT statewide Alaska rules and do not cover the rest of Southcentral.
-- Exact drainage-specific exceptions and current emergency orders must be checked before relying on a rule.
-- Official source: Alaska Department of Fish and Game, 2026 Southcentral Sport Fishing Regulations Summary,
-- West Cook Inlet, pages 11-13.
-- https://newsrelease.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southcentral/2026sc_sfregs_complete.pdf
-- Emergency Orders: https://www.adfg.alaska.gov/sf/EONR

do $$
declare
  v_source_id uuid;
begin
  insert into public.regulation_sources (
    state_code, agency_name, source_title, source_url, regulation_year,
    checked_at, source_type, verification_status, notes
  ) values (
    'AK',
    'Alaska Department of Fish and Game',
    '2026 Southcentral Alaska Sport Fishing Regulations Summary — West Cook Inlet',
    'https://newsrelease.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southcentral/2026sc_sfregs_complete.pdf',
    2026, now(), 'official', 'verified',
    'West Cook Inlet general regulations only, 2026 summary pages 11-13. Not statewide and not a complete Southcentral rule set. Special drainage regulations and emergency orders override these general rules. Checked November 26, 2026.'
  ) returning id into v_source_id;

  -- Salmon species share one combined limit in West Cook Inlet.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, minimum_length, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  select
    'AK', s.species_name, s.species_key, 'region',
    'Southcentral Alaska — West Cook Inlet',
    'southcentral-west-cook-inlet', 'freshwater',
    'January 1-September 30 open; October 1-December 31 closed to all salmon fishing.',
    '16 inches or longer: 3 per day combined for chum, coho, pink, and sockeye salmon. Under 16 inches: 10 per day combined.',
    '16 inches or longer: 6 in possession combined for chum, coho, pink, and sockeye salmon. Under 16 inches: 10 in possession combined.',
    '16 inches separates the large-fish limit from the under-16-inch combined limit.',
    'These four species share the stated combined limit; special drainage rules and emergency orders may be stricter. A coho 16 inches or longer that is removed from the water must be retained and counts toward the angler’s bag limit. After taking a daily bag limit of coho 16 inches or longer from a West Cook Inlet drainage, fishing may not continue in West Cook Inlet waters that day.',
    jsonb_build_object(
      'combined_species','Chum Salmon, Coho Salmon, Pink Salmon, and Sockeye Salmon.',
      'season','January 1-September 30 open; October 1-December 31 closed to all salmon fishing.',
      '16_inches_or_longer','3 per day and 6 in possession combined for the four listed species.',
      'under_16_inches','10 per day and 10 in possession combined for the four listed species.',
      'coho_handling','A coho 16 inches or longer removed from the water must be retained and counts toward the bag limit of the angler who hooked it.',
      'coho_after_limit','After taking a daily bag limit of coho 16 inches or longer from a West Cook Inlet drainage, fishing may not continue in West Cook Inlet waters that day.',
      'exceptions','Special drainage regulations and emergency orders override these general rules.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 12.',
    v_source_id, 'verified', now()
  from (values
    ('Chum Salmon','chum-salmon'),
    ('Coho Salmon','coho-salmon'),
    ('Pink Salmon','pink-salmon'),
    ('Sockeye Salmon','sockeye-salmon')
  ) as s(species_name,species_key);

  -- 2026 emergency-order closure for king salmon in West Cook Inlet.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  ) values (
    'AK','Chinook Salmon','chinook-salmon','region',
    'Southcentral Alaska — West Cook Inlet','southcentral-west-cook-inlet','freshwater',
    'Closed to king salmon fishing in 2026 by emergency order.',
    'No retention; fishing is closed.',
    'No retention while the fishery is closed.',
    'The 2026 West Cook Inlet summary identifies a closure by emergency order. This is a 2026 emergency-order status, not a permanent statewide rule; check current ADF&G emergency orders for later changes.',
    jsonb_build_object(
      '2026_status','King salmon fishing is closed in West Cook Inlet by emergency order.',
      'scope','West Cook Inlet only.',
      'important','Emergency orders can change during the season. Confirm current orders.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 12.',
    v_source_id,'verified',now()
  );

  -- Rainbow trout and steelhead share one combined rule.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, maximum_length, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  select
    'AK', s.species_name, s.species_key, 'region',
    'Southcentral Alaska — West Cook Inlet',
    'southcentral-west-cook-inlet','freshwater',
    'Flowing waters: April 15-June 14 catch-and-release only; June 15-April 14 open. Lakes: open year-round.',
    '2 per day combined for rainbow/steelhead trout.',
    '2 in possession combined for rainbow/steelhead trout.',
    null,
    'Annual limit of 2 rainbow/steelhead trout 20 inches or longer taken north of the latitude of Point Adam from the listed Southcentral areas; harvest must be recorded immediately. Special drainage rules and emergency orders may differ.',
    jsonb_build_object(
      'combined_species','Rainbow Trout and Steelhead.',
      'flowing_waters_season','April 15-June 14: catch-and-release only; June 15-April 14: open.',
      'lake_season','Open year-round.',
      'daily_limit','2 per day combined.',
      'possession_limit','2 in possession combined.',
      'large_fish_limit','Only 1 fish may be 20 inches or longer.',
      'annual_limit','2 rainbow/steelhead trout 20 inches or longer taken north of the latitude of Point Adam from West Cook Inlet, Susitna River Drainage, Knik Arm, Anchorage Bowl, Kenai Lake drainages, Kenai River tributaries, and Kenai Peninsula.',
      'harvest_record','Immediately record any retained rainbow/steelhead trout 20 inches or longer.',
      'exceptions','Special drainage regulations and emergency orders override these general rules.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 12.',
    v_source_id,'verified',now()
  from (values
    ('Rainbow Trout','rainbow-trout'),
    ('Steelhead','steelhead')
  ) as s(species_name,species_key);

  -- Arctic char and Dolly Varden share a combined rule.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, maximum_length, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  select
    'AK', s.species_name, s.species_key, 'region',
    'Southcentral Alaska — West Cook Inlet',
    'southcentral-west-cook-inlet','freshwater',
    'Open year-round unless special regulations or an emergency order apply.',
    '5 per day combined for Arctic Char and Dolly Varden.',
    '5 in possession combined for Arctic Char and Dolly Varden.',
    'Only 1 of the 5 may be 12 inches or longer.',
    'Arctic Char and Dolly Varden share one combined limit.',
    jsonb_build_object(
      'combined_species','Arctic Char and Dolly Varden.',
      'season','Open year-round unless special regulations or an emergency order apply.',
      'daily_limit','5 per day combined.',
      'possession_limit','5 in possession combined.',
      'size_restriction','Only 1 fish may be 12 inches or longer.',
      'exceptions','Special drainage regulations and emergency orders override these general rules.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 12.',
    v_source_id,'verified',now()
  from (values
    ('Arctic Char','arctic-char'),
    ('Dolly Varden','dolly-varden')
  ) as s(species_name,species_key);

  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  ) values (
    'AK','Lake Trout','lake-trout','region',
    'Southcentral Alaska — West Cook Inlet','southcentral-west-cook-inlet','freshwater',
    'Open year-round unless special regulations or an emergency order apply.',
    '2 per day.',
    '2 in possession.',
    'No size limit is listed in the West Cook Inlet general species table. Special drainage regulations and emergency orders may differ.',
    jsonb_build_object(
      'season','Open year-round unless special regulations or an emergency order apply.',
      'daily_limit','2 per day.',
      'possession_limit','2 in possession.',
      'size_limit','No size limit listed in the West Cook Inlet general species table.',
      'exceptions','Special drainage regulations and emergency orders override these general rules.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 12.',
    v_source_id,'verified',now()
  );

  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  ) values (
    'AK','Northern Pike','northern-pike','region',
    'Southcentral Alaska — West Cook Inlet','southcentral-west-cook-inlet','freshwater',
    'Open year-round unless special regulations or an emergency order apply.',
    'No limit.',
    'No limit.',
    'Live release is prohibited. Any northern pike caught may not be released alive back into the water. Special ice-fishing line allowances apply only in named waters.',
    jsonb_build_object(
      'season','Open year-round unless special regulations or an emergency order apply.',
      'daily_limit','No limit.',
      'possession_limit','No limit.',
      'live_release','Prohibited. Northern pike may not be released alive.',
      'special_gear_note','Special ice-fishing line allowances are limited to named waters in the official booklet.',
      'exceptions','Special drainage regulations and emergency orders override these general rules.'
    ),
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, West Cook Inlet, page 13.',
    v_source_id,'verified',now()
  );
end $$;
