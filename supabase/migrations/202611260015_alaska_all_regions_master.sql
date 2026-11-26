-- FishBound Alaska master regional coverage — 2026
-- One-time add-on for the four ADF&G sport-fishing regions.
-- Existing Alaska records from migrations 013 and 014 are retained; this script adds
-- verified general rules for additional Northern, Southcentral, and Southwest subregions.
-- Southeast records already exist from migration 013.
--
-- IMPORTANT:
-- Alaska rules vary by drainage, lake, marine management area, residency, and emergency order.
-- This file records only the exact general rules identified in the cited 2026 official summaries.
-- It does NOT replace checking the exact named water and current emergency orders.
-- Do not interpret a regional/subregional record as statewide.
--
-- Official sources:
-- Northern 2026 booklet:
-- https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/northern/2026northern_sfregs_complete.pdf
-- Southcentral 2026 booklet:
-- https://newsrelease.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southcentral/2026sc_sfregs_complete.pdf
-- Southwest 2026 booklet:
-- https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/Southwest/2026sw_sfregs_complete.pdf
-- Southeast 2026 general freshwater/saltwater rules already inserted in migration 013:
-- https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southeast/2026se_sfregs_general_freshwater_saltwater.pdf
-- Emergency Orders (override published summaries):
-- https://www.adfg.alaska.gov/sf/EONR

do $$
declare
  v_north_id uuid;
  v_sc_id uuid;
  v_sw_id uuid;
begin
  -- Reuse existing source rows if this script is run more than once.
  select id into v_north_id from public.regulation_sources
  where state_code='AK' and source_title='2026 Northern Alaska Sport Fishing Regulations Summary Book'
  order by created_at desc limit 1;
  if v_north_id is null then
    insert into public.regulation_sources (
      state_code,agency_name,source_title,source_url,regulation_year,
      checked_at,source_type,verification_status,notes
    ) values (
      'AK','Alaska Department of Fish and Game',
      '2026 Northern Alaska Sport Fishing Regulations Summary Book',
      'https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/northern/2026northern_sfregs_complete.pdf',
      2026,now(),'official','verified',
      'Northern drainage-specific general rules transcribed from the 2026 ADF&G booklet. Special waters and emergency orders override these records.'
    ) returning id into v_north_id;
  end if;

  select id into v_sc_id from public.regulation_sources
  where state_code='AK' and source_title='2026 Southcentral Alaska Sport Fishing Regulations Summary Book'
  order by created_at desc limit 1;
  if v_sc_id is null then
    insert into public.regulation_sources (
      state_code,agency_name,source_title,source_url,regulation_year,
      checked_at,source_type,verification_status,notes
    ) values (
      'AK','Alaska Department of Fish and Game',
      '2026 Southcentral Alaska Sport Fishing Regulations Summary Book',
      'https://newsrelease.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southcentral/2026sc_sfregs_complete.pdf',
      2026,now(),'official','verified',
      'Susitna River Drainage Unit 1 general rules from the 2026 ADF&G booklet. Other Southcentral areas have separate rules.'
    ) returning id into v_sc_id;
  end if;

  select id into v_sw_id from public.regulation_sources
  where state_code='AK' and source_title='2026 Southwest Alaska Sport Fishing Regulations Summary Book'
  order by created_at desc limit 1;
  if v_sw_id is null then
    insert into public.regulation_sources (
      state_code,agency_name,source_title,source_url,regulation_year,
      checked_at,source_type,verification_status,notes
    ) values (
      'AK','Alaska Department of Fish and Game',
      '2026 Southwest Alaska Sport Fishing Regulations Summary Book',
      'https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/Southwest/2026sw_sfregs_complete.pdf',
      2026,now(),'official','verified',
      'Alaska Peninsula and Aleutian Islands freshwater general rules from the 2026 ADF&G booklet. Bristol Bay and Kodiak have distinct rules.'
    ) returning id into v_sw_id;
  end if;

  -- NORTHERN: Northwestern drainages (not all Northern Alaska waters).
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Northern Alaska — Northwestern Drainages','northern-northwestern-drainages',
    x.water_type,x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Northern Alaska Sport Fishing Regulations Summary, Northwestern Drainages, General Regulations.',
    v_north_id,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','freshwater','Open year-round unless special regulations or an emergency order apply.','20 inches or longer: 1 per day. Under 20 inches: 10 per day.','20 inches or longer: 1 in possession. Under 20 inches: 10 in possession.','20 inches separates the two limit groups.','A king salmon removed from the water must be retained and counts toward the angler’s limit. Check special waters and emergency orders.','{"20_inches_or_longer":"1 per day, 1 in possession.","under_20_inches":"10 per day, 10 in possession.","exceptions":"Special drainage rules and emergency orders may override."}'::jsonb),
    ('Chum Salmon','chum-salmon','freshwater','Open year-round unless special regulations or an emergency order apply.','10 per day combined with coho, pink, and sockeye salmon.','10 in possession combined with coho, pink, and sockeye salmon.',null,'The four listed salmon species share one combined limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"10 combined per day.","possession_limit":"10 combined in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Coho Salmon','coho-salmon','freshwater','Open year-round unless special regulations or an emergency order apply.','10 per day combined with chum, pink, and sockeye salmon.','10 in possession combined with chum, pink, and sockeye salmon.',null,'The four listed salmon species share one combined limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"10 combined per day.","possession_limit":"10 combined in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Pink Salmon','pink-salmon','freshwater','Open year-round unless special regulations or an emergency order apply.','10 per day combined with chum, coho, and sockeye salmon.','10 in possession combined with chum, coho, and sockeye salmon.',null,'The four listed salmon species share one combined limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"10 combined per day.","possession_limit":"10 combined in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','freshwater','Open year-round unless special regulations or an emergency order apply.','10 per day combined with chum, coho, and pink salmon.','10 in possession combined with chum, coho, and pink salmon.',null,'The four listed salmon species share one combined limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"10 combined per day.","possession_limit":"10 combined in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Arctic Char','arctic-char','freshwater','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Dolly Varden and Lake Trout. Flowing and salt waters: 10 per day combined with Dolly Varden and Lake Trout.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Dolly Varden and Lake Trout; flowing/saltwater group may include no more than 2 Lake Trout.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession combined; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Dolly Varden','dolly-varden','freshwater','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Arctic Char and Lake Trout. Flowing and salt waters: 10 per day combined.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Arctic Char and Lake Trout; flowing/saltwater group may include no more than 2 Lake Trout.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession combined; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Lake Trout','lake-trout','freshwater','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Arctic Char and Dolly Varden. Flowing and salt waters: included in 10-fish combined limit.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Arctic Char and Dolly Varden; no more than 2 Lake Trout may be retained in the flowing/saltwater group.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession combined; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Northern Pike','northern-pike','freshwater','Open year-round unless special regulations or an emergency order apply.','10 per day.','10 in possession.',null,'Check special drainage rules and emergency orders.','{"daily_limit":"10 per day.","possession_limit":"10 in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Burbot','burbot','freshwater','Open year-round unless special regulations or an emergency order apply.','15 per day.','15 in possession.',null,'Check special drainage rules and emergency orders.','{"daily_limit":"15 per day.","possession_limit":"15 in possession.","size_limit":"No size limit in the Northwestern general rule."}'::jsonb),
    ('Pacific Halibut','pacific-halibut','saltwater','February 1-December 31 open; January 1-31 closed.','Unguided anglers: 2 per day.','Unguided anglers: 4 in possession.',null,'Federal rules govern Pacific Halibut. Guided anglers must check current federal limits; special filleting/identification requirements apply.','{"season":"February 1-December 31 open; January 1-31 closed.","unguided_limit":"2 per day, 4 in possession.","management":"Federally managed; guided angler limits and in-season changes are federal."}'::jsonb)
  ) as x(species_name,species_key,water_type,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key and q.waterbody_key='northern-northwestern-drainages'
      and q.verification_status='verified'
  );

  -- NORTHERN: Kuskokwim and Goodnews drainages.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Northern Alaska — Kuskokwim and Goodnews Drainages','northern-kuskokwim-goodnews',
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Northern Alaska Sport Fishing Regulations Summary, Kuskokwim and Goodnews Drainages, page 10.',
    v_north_id,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','May 1-July 25 open; otherwise closed unless a special regulation or emergency order applies.','20 inches or longer: 3 per day; only 2 may be 28 inches or longer. Under 20 inches: 10 per day.','20 inches or longer: 3 in possession; only 2 may be 28 inches or longer. Under 20 inches: 10 in possession.','20 inches; maximum 2 fish at least 28 inches.','King salmon season is specifically May 1-July 25 in the 2026 general rule. Check current emergency orders.','{"season":"May 1-July 25 open.","20_inches_or_longer":"3 per day, 3 in possession; only 2 may be 28 inches or longer.","under_20_inches":"10 per day, 10 in possession."}'::jsonb),
    ('Chum Salmon','chum-salmon','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Coho, Pink, and Sockeye Salmon.','5 in possession combined with Coho, Pink, and Sockeye Salmon.',null,'Combined salmon limit applies to the four species.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"5 combined per day.","possession_limit":"5 combined in possession.","size_limit":"No size limit in the general rule."}'::jsonb),
    ('Coho Salmon','coho-salmon','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Chum, Pink, and Sockeye Salmon.','5 in possession combined with Chum, Pink, and Sockeye Salmon.',null,'Combined salmon limit applies to the four species.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"5 combined per day.","possession_limit":"5 combined in possession.","size_limit":"No size limit in the general rule."}'::jsonb),
    ('Pink Salmon','pink-salmon','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Chum, Coho, and Sockeye Salmon.','5 in possession combined with Chum, Coho, and Sockeye Salmon.',null,'Combined salmon limit applies to the four species.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"5 combined per day.","possession_limit":"5 combined in possession.","size_limit":"No size limit in the general rule."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Chum, Coho, and Pink Salmon.','5 in possession combined with Chum, Coho, and Pink Salmon.',null,'Combined salmon limit applies to the four species.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"5 combined per day.","possession_limit":"5 combined in possession.","size_limit":"No size limit in the general rule."}'::jsonb),
    ('Arctic Char','arctic-char','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Dolly Varden and Lake Trout. Flowing and salt waters: 10 per day combined.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Dolly Varden and Lake Trout; no more than 2 Lake Trout may be included.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Dolly Varden','dolly-varden','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Arctic Char and Lake Trout. Flowing and salt waters: 10 per day combined.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Arctic Char and Lake Trout; no more than 2 Lake Trout may be included.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Lake Trout','lake-trout','Open year-round unless special regulations or an emergency order apply.','Lakes: 2 per day combined with Arctic Char and Dolly Varden. Flowing and salt waters: 10 per day combined.','Lakes: 2 combined. Flowing and salt waters: 10 combined.','In flowing and salt waters, only 2 of the combined fish may be 20 inches or longer.','Shares a combined limit with Arctic Char and Dolly Varden; no more than 2 Lake Trout may be included.','{"combined_species":"Arctic Char, Dolly Varden, and Lake Trout.","lakes":"2 per day, 2 in possession combined; no size limit.","flowing_and_salt_waters":"10 per day, 10 in possession; only 2 may be 20 inches or longer and only 2 may be Lake Trout."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Open year-round unless special regulations or an emergency order apply.','2 per day.','2 in possession.','Only 1 may be 20 inches or longer.','Check special drainage rules and emergency orders.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","large_fish_limit":"Only 1 may be 20 inches or longer."}'::jsonb),
    ('Northern Pike','northern-pike','Open year-round unless special regulations or an emergency order apply.','10 per day.','10 in possession.',null,'Check special drainage rules and emergency orders.','{"daily_limit":"10 per day.","possession_limit":"10 in possession.","size_limit":"No size limit in the general rule."}'::jsonb),
    ('Burbot','burbot','Open year-round unless special regulations or an emergency order apply.','15 per day.','15 in possession.',null,'Check special drainage rules and emergency orders.','{"daily_limit":"15 per day.","possession_limit":"15 in possession.","size_limit":"No size limit in the general rule."}'::jsonb)
  ) as x(species_name,species_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key and q.waterbody_key='northern-kuskokwim-goodnews'
      and q.verification_status='verified'
  );

  -- SOUTHWEST: Alaska Peninsula and Aleutian Islands freshwater.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southwest Alaska — Alaska Peninsula and Aleutian Islands Freshwater',
    'southwest-alaska-peninsula-aleutians','freshwater',x.season_text,
    x.daily_text,x.possession_text,x.minimum_text,x.special_text,x.details,
    '2026 Southwest Alaska Sport Fishing Regulations Summary, Alaska Peninsula and Aleutian Islands Freshwater, page 19.',
    v_sw_id,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','January 1-July 25 open; closed outside this season unless a special regulation or emergency order applies.','20 inches or longer: 2 per day. Under 20 inches: 10 per day.','20 inches or longer: 2 in possession. Under 20 inches: 10 in possession.','20 inches minimum for the 2-fish limit.','Annual limit of 5 Chinook Salmon 20 inches or longer; harvest record required. Chignik River drainage was closed by 2026 emergency order.','{"season":"January 1-July 25 open.","20_inches_or_longer":"2 per day, 2 in possession.","under_20_inches":"10 per day, 10 in possession.","annual_limit":"5 Chinook Salmon 20 inches or longer; harvest record required.","closure":"Chignik River drainage closed by 2026 emergency order."}'::jsonb),
    ('Chum Salmon','chum-salmon','Open year-round unless special regulations or an emergency order apply.','Remote Zone: 5 per day combined with Coho, Pink, and Sockeye at 20 inches or longer; under 20 inches: 10 combined.','Remote Zone: 10 in possession combined at 20 inches or longer; under 20 inches: 10 combined.','20 inches separates the size groups.','Unalaska Bay Drainages have a separate combined limit: 5 per day and 5 in possession at 20 inches or longer, with species-specific sublimits for coho and sockeye.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","remote_zone":"20 inches or longer: 5 per day, 10 in possession combined; under 20 inches: 10 per day, 10 in possession combined.","unalaska_bay":"20 inches or longer: 5 per day, 5 in possession; only 2 may be Coho and only 2 may be Sockeye. Under 20 inches: 10 per day, 10 in possession."}'::jsonb),
    ('Coho Salmon','coho-salmon','Open year-round unless special regulations or an emergency order apply.','Remote Zone: 5 per day combined with Chum, Pink, and Sockeye at 20 inches or longer; under 20 inches: 10 combined.','Remote Zone: 10 in possession combined at 20 inches or longer; under 20 inches: 10 combined.','20 inches separates the size groups.','Unalaska Bay Drainages have a separate combined limit: 5 per day and 5 in possession at 20 inches or longer, with no more than 2 Coho.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","remote_zone":"20 inches or longer: 5 per day, 10 in possession combined; under 20 inches: 10 per day, 10 in possession combined.","unalaska_bay":"20 inches or longer: 5 per day, 5 in possession; only 2 may be Coho and only 2 may be Sockeye. Under 20 inches: 10 per day, 10 in possession."}'::jsonb),
    ('Pink Salmon','pink-salmon','Open year-round unless special regulations or an emergency order apply.','Remote Zone: 5 per day combined with Chum, Coho, and Sockeye at 20 inches or longer; under 20 inches: 10 combined.','Remote Zone: 10 in possession combined at 20 inches or longer; under 20 inches: 10 combined.','20 inches separates the size groups.','Unalaska Bay Drainages have a separate combined limit and named species sublimits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","remote_zone":"20 inches or longer: 5 per day, 10 in possession combined; under 20 inches: 10 per day, 10 in possession combined.","unalaska_bay":"20 inches or longer: 5 per day, 5 in possession; only 2 may be Coho and only 2 may be Sockeye. Under 20 inches: 10 per day, 10 in possession."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Open year-round unless special regulations or an emergency order apply.','Remote Zone: 5 per day combined with Chum, Coho, and Pink at 20 inches or longer; under 20 inches: 10 combined.','Remote Zone: 10 in possession combined at 20 inches or longer; under 20 inches: 10 combined.','20 inches separates the size groups.','Unalaska Bay Drainages have a separate combined limit and named species sublimits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","remote_zone":"20 inches or longer: 5 per day, 10 in possession combined; under 20 inches: 10 per day, 10 in possession combined.","unalaska_bay":"20 inches or longer: 5 per day, 5 in possession; only 2 may be Coho and only 2 may be Sockeye. Under 20 inches: 10 per day, 10 in possession."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Open year-round unless special regulations or an emergency order apply.','2 per day combined with Steelhead.','2 in possession combined with Steelhead.',null,'Only 1 may be 20 inches or longer. Annual limit of 2 fish 20 inches or longer; harvest record required.','{"combined_species":"Rainbow Trout and Steelhead.","daily_limit":"2 per day, 2 in possession combined.","large_fish_limit":"Only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required."}'::jsonb),
    ('Steelhead','steelhead','Open year-round unless special regulations or an emergency order apply.','2 per day combined with Rainbow Trout.','2 in possession combined with Rainbow Trout.',null,'Only 1 may be 20 inches or longer. Annual limit of 2 fish 20 inches or longer; harvest record required.','{"combined_species":"Rainbow Trout and Steelhead.","daily_limit":"2 per day, 2 in possession combined.","large_fish_limit":"Only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required."}'::jsonb),
    ('Dolly Varden','dolly-varden','Open year-round unless special regulations or an emergency order apply.','10 per day.','10 in possession.',null,'No size limit in the Alaska Peninsula/Aleutian Islands freshwater general rule; special waters may differ.','{"daily_limit":"10 per day.","possession_limit":"10 in possession.","size_limit":"No size limit in the general rule."}'::jsonb)
  ) as x(species_name,species_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key and q.waterbody_key='southwest-alaska-peninsula-aleutians'
      and q.verification_status='verified'
  );

  -- SOUTHCENTRAL: Susitna River Drainage Unit 1.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southcentral Alaska — Susitna River Drainage Unit 1','southcentral-susitna-unit-1',
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, Susitna River Drainage, Unit 1, page 17.',
    v_sc_id,'2026-01-01','verified',now()
  from (values
    ('Chum Salmon','chum-salmon','Open year-round unless special regulations or an emergency order apply.','16 inches or longer: 3 per day combined with Coho and Sockeye. Under 16 inches: 10 per day combined.','16 inches or longer: 6 in possession combined with Coho and Sockeye. Under 16 inches: 10 in possession combined.','16 inches separates the size groups.','The 3-fish large salmon limit is shared with Coho and Sockeye.','{"combined_species":"Chum, Coho, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 6 in possession combined.","under_16_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Coho Salmon','coho-salmon','Open year-round unless special regulations or an emergency order apply.','16 inches or longer: 3 per day combined with Chum and Sockeye. Under 16 inches: 10 per day combined.','16 inches or longer: 6 in possession combined with Chum and Sockeye. Under 16 inches: 10 in possession combined.','16 inches separates the size groups.','The 3-fish large salmon limit is shared with Chum and Sockeye. Area-specific coho handling and after-limit restrictions may apply.','{"combined_species":"Chum, Coho, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 6 in possession combined.","under_16_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Open year-round unless special regulations or an emergency order apply.','16 inches or longer: 3 per day combined with Chum and Coho. Under 16 inches: 10 per day combined.','16 inches or longer: 6 in possession combined with Chum and Coho. Under 16 inches: 10 in possession combined.','16 inches separates the size groups.','The 3-fish large salmon limit is shared with Chum and Coho.','{"combined_species":"Chum, Coho, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 6 in possession combined.","under_16_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Pink Salmon','pink-salmon','Open year-round unless special regulations or an emergency order apply.','6 per day.','6 in possession.',null,'No size limit in this Unit 1 general rule.','{"daily_limit":"6 per day.","possession_limit":"6 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Flowing waters: April 15-June 14 catch-and-release only; June 15-April 14 open. Lakes: open year-round.','Flowing and unstocked lakes: 2 per day combined with Steelhead. Stocked lakes: 5 per day combined with Steelhead.','Flowing and unstocked lakes: 2 combined. Stocked lakes: 5 combined.','Only 1 may be 20 inches or longer.','Rainbow Trout and Steelhead share a combined limit. Specific stocked-lake and drainage rules may differ.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"April 15-June 14: catch-and-release only. June 15-April 14: 2 per day, 2 in possession combined; only 1 may be 20 inches or longer.","unstocked_lakes":"Open year-round; 2 per day, 2 in possession combined; only 1 may be 20 inches or longer.","stocked_lakes":"Open year-round; 5 per day, 5 in possession combined; only 1 may be 20 inches or longer."}'::jsonb),
    ('Steelhead','steelhead','Flowing waters: April 15-June 14 catch-and-release only; June 15-April 14 open. Lakes: open year-round.','Flowing and unstocked lakes: 2 per day combined with Rainbow Trout. Stocked lakes: 5 per day combined.','Flowing and unstocked lakes: 2 combined. Stocked lakes: 5 combined.','Only 1 may be 20 inches or longer.','Rainbow Trout and Steelhead share a combined limit. Specific stocked-lake and drainage rules may differ.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"April 15-June 14: catch-and-release only. June 15-April 14: 2 per day, 2 in possession combined; only 1 may be 20 inches or longer.","unstocked_lakes":"Open year-round; 2 per day, 2 in possession combined; only 1 may be 20 inches or longer.","stocked_lakes":"Open year-round; 5 per day, 5 in possession combined; only 1 may be 20 inches or longer."}'::jsonb),
    ('Arctic Char','arctic-char','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Dolly Varden in unstocked lakes and flowing waters; stocked lakes also have a 5-fish combined limit.','5 in possession combined with Dolly Varden.','In unstocked lakes and flowing waters, only 1 may be 12 inches or longer.','Arctic Char and Dolly Varden share a combined limit; stocked lakes may have separate details.','{"combined_species":"Arctic Char and Dolly Varden.","unstocked_lakes_and_flowing_waters":"5 per day, 5 in possession combined; only 1 may be 12 inches or longer.","stocked_lakes":"5 per day, 5 in possession combined; check stocked-lake exceptions."}'::jsonb),
    ('Dolly Varden','dolly-varden','Open year-round unless special regulations or an emergency order apply.','5 per day combined with Arctic Char in unstocked lakes and flowing waters; stocked lakes also have a 5-fish combined limit.','5 in possession combined with Arctic Char.','In unstocked lakes and flowing waters, only 1 may be 12 inches or longer.','Arctic Char and Dolly Varden share a combined limit; stocked lakes may have separate details.','{"combined_species":"Arctic Char and Dolly Varden.","unstocked_lakes_and_flowing_waters":"5 per day, 5 in possession combined; only 1 may be 12 inches or longer.","stocked_lakes":"5 per day, 5 in possession combined; check stocked-lake exceptions."}'::jsonb),
    ('Lake Trout','lake-trout','Open year-round unless special regulations or an emergency order apply.','2 per day.','2 in possession.',null,'No size limit in the Unit 1 general table; special waters may differ.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","size_limit":"No size limit in the Unit 1 general table."}'::jsonb),
    ('Burbot','burbot','Open year-round unless special regulations or an emergency order apply.','5 per day.','5 in possession.',null,'No size limit in the Unit 1 general table; special waters and set-line rules may differ.','{"daily_limit":"5 per day.","possession_limit":"5 in possession.","size_limit":"No size limit in the Unit 1 general table."}'::jsonb),
    ('Northern Pike','northern-pike','Open year-round unless special regulations or an emergency order apply.','No limit.','No limit.',null,'Live release is prohibited in the Susitna River Drainage. Pike must not be released alive.','{"daily_limit":"No limit.","possession_limit":"No limit.","live_release":"Prohibited; live northern pike may not be released."}'::jsonb)
  ) as x(species_name,species_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key and q.waterbody_key='southcentral-susitna-unit-1'
      and q.verification_status='verified'
  );

end $$;

-- This is a single add-on script for all four ADF&G regions when combined with
-- the already-run Southeast and West Cook Inlet records. It intentionally does
-- not invent missing rules for every lake, river, or marine management area.
-- Check the exact location and current emergency orders before using any limit.
