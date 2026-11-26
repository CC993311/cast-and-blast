-- FishBound Alaska remaining regional rules — 2026
-- Adds verified general rules for Bristol Bay, Kodiak, Kenai Peninsula,
-- North Gulf Coast, and Prince William Sound.
-- This is additive and safe to run again: it skips an existing verified
-- record with the same state/species/waterbody key.
--
-- These are regional/general summaries, NOT a complete list of every special
-- stream, lake, marine statistical area, or emergency order. Exact-water rules
-- take precedence. ADF&G emergency orders can change limits during the season.
--
-- Official sources:
-- Southwest 2026 booklet:
-- https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/Southwest/2026sw_sfregs_complete.pdf
-- Southcentral 2026 booklet:
-- https://newsrelease.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southcentral/2026sc_sfregs_complete.pdf
-- ADF&G emergency orders:
-- https://www.adfg.alaska.gov/sf/EONR
--
-- Relevant 2026 updates incorporated:
-- Bristol Bay: Naknek king salmon update; Nushagak and Wood River sockeye limits 10/day and 10 possession through Dec. 31.
-- Kodiak: Buskin sockeye closure; Ayakulik sockeye limit 10; Kodiak/Afognak rockfish and northern Afognak/Shuyak lingcod restrictions.
-- PWS: 2026 king salmon saltwater emergency limit April 1-Sept. 15.

do $$
declare
  v_sw uuid;
  v_sc uuid;
begin
  select id into v_sw from public.regulation_sources
  where state_code='AK'
    and source_title='2026 Southwest Alaska Sport Fishing Regulations Summary Book'
  order by created_at desc limit 1;

  select id into v_sc from public.regulation_sources
  where state_code='AK'
    and source_title='2026 Southcentral Alaska Sport Fishing Regulations Summary Book'
  order by created_at desc limit 1;

  if v_sw is null or v_sc is null then
    raise exception 'FishBound Alaska 2026 source rows are missing. Run the Alaska master migration 202611260015 first.';
  end if;

  -- BRISTOL BAY: general fresh and salt waters.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southwest Alaska — Bristol Bay General Fresh and Salt Waters',
    'bristol-bay-general',x.water_type,x.season_text,x.daily_text,x.possession_text,
    x.minimum_text,x.special_text,x.details,
    '2026 Southwest Alaska Sport Fishing Regulations Summary, Bristol Bay, pages 10-11.',
    v_sw,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','freshwater','May 1-July 31 for king salmon; check exact drainage rules.','20 inches or longer: 3 per day; only 1 may be 28 inches or longer. Under 20 inches: 10 per day.','20 inches or longer: 3 in possession; under 20 inches: 10 in possession.','20 inches; only 1 fish 28 inches or longer in the daily/possession group.','Annual limit 5 fish 20 inches or longer across Bristol Bay fresh and salt waters. Nushagak/Mulchatna maximum 4; Wood River maximum 2. Naknek drainage has its own 2026 annual sublimit. A fish removed from water must be retained.','{"season":"May 1-July 31.","freshwater_20_inches_or_longer":"3 per day, 3 in possession; only 1 may be 28 inches or longer.","freshwater_under_20_inches":"10 per day, 10 in possession.","annual_limit":"5 fish 20 inches or longer across Bristol Bay fresh and salt waters; max 4 from Nushagak/Mulchatna and max 2 from Wood River. Check Naknek drainage annual sublimit separately.","handling":"A king salmon removed from the water must be retained."}'::jsonb),
    ('Chinook Salmon','chinook-salmon','saltwater','May 1-July 31 for king salmon; check exact management area rules.','3 per day; only 2 may be 28 inches or longer.','3 in possession; only 2 may be 28 inches or longer.','Only 2 may be 28 inches or longer.','Annual limit 5 fish 20 inches or longer across Bristol Bay fresh and salt waters. Exact drainage/area rules may be more restrictive. A fish removed from water must be retained.','{"season":"May 1-July 31.","daily_limit":"3 per day, 3 in possession; only 2 may be 28 inches or longer.","annual_limit":"5 fish 20 inches or longer across Bristol Bay fresh and salt waters; drainage sublimits apply.","handling":"A king salmon removed from the water must be retained."}'::jsonb),
    ('Chum Salmon','chum-salmon','freshwater','Open year-round unless a special regulation or emergency order applies.','5 per day combined with Coho, Pink, and Sockeye Salmon.','5 in possession combined with Coho, Pink, and Sockeye Salmon.',null,'Nushagak/Mulchatna and Wood River sockeye emergency limits are 10 per day and 10 in possession through Dec. 31, 2026; those sockeye limits are in combination with the 5-fish limit for other salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"5 per day, 5 in possession combined.","emergency_order_note":"Nushagak/Mulchatna and Wood River sockeye limits are 10 per day and 10 in possession through 2026-12-31; other salmon remain 5 combined."}'::jsonb),
    ('Coho Salmon','coho-salmon','freshwater','Open year-round unless a special regulation or emergency order applies.','5 per day combined with Chum, Pink, and Sockeye Salmon.','5 in possession combined with Chum, Pink, and Sockeye Salmon.',null,'Nushagak/Mulchatna and Wood River sockeye emergency limits are 10 per day and 10 in possession through Dec. 31, 2026; other salmon remain 5 combined.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"5 per day, 5 in possession combined.","emergency_order_note":"Nushagak/Mulchatna and Wood River sockeye limits are 10 per day and 10 in possession through 2026-12-31; other salmon remain 5 combined."}'::jsonb),
    ('Pink Salmon','pink-salmon','freshwater','Open year-round unless a special regulation or emergency order applies.','5 per day combined with Chum, Coho, and Sockeye Salmon.','5 in possession combined with Chum, Coho, and Sockeye Salmon.',null,'Nushagak/Mulchatna and Wood River sockeye emergency limits are 10 per day and 10 in possession through Dec. 31, 2026; other salmon remain 5 combined.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"5 per day, 5 in possession combined.","emergency_order_note":"Nushagak/Mulchatna and Wood River sockeye limits are 10 per day and 10 in possession through 2026-12-31; other salmon remain 5 combined."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','freshwater','Open year-round unless a special regulation or emergency order applies.','5 per day combined with Chum, Coho, and Pink Salmon in general Bristol Bay waters.','5 in possession combined in general Bristol Bay waters.',null,'Nushagak/Mulchatna and Wood River drainages have a 2026 emergency limit of 10 sockeye per day and 10 in possession through Dec. 31, 2026.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"5 per day, 5 in possession combined.","nushagak_mulchatna_eo":"Sockeye: 10 per day, 10 in possession through 2026-12-31; other salmon remain 5 combined.","wood_river_eo":"Sockeye: 10 per day, 10 in possession through 2026-12-31; other salmon remain 5 combined."}'::jsonb),
    ('Arctic Char','arctic-char','freshwater','June 8-October 31 and November 1-June 7; see seasonal limits.','June 8-October 31: 3 per day combined with Dolly Varden. November 1-June 7: 10 per day combined.','June 8-October 31: 3 in possession combined. November 1-June 7: 10 in possession combined.',null,'Combined with Dolly Varden.','{"combined_species":"Arctic Char and Dolly Varden.","june_8_october_31":"3 per day, 3 in possession combined.","november_1_june_7":"10 per day, 10 in possession combined."}'::jsonb),
    ('Dolly Varden','dolly-varden','freshwater','June 8-October 31 and November 1-June 7; see seasonal limits.','June 8-October 31: 3 per day combined with Arctic Char. November 1-June 7: 10 per day combined.','June 8-October 31: 3 in possession combined. November 1-June 7: 10 in possession combined.',null,'Combined with Arctic Char.','{"combined_species":"Arctic Char and Dolly Varden.","june_8_october_31":"3 per day, 3 in possession combined.","november_1_june_7":"10 per day, 10 in possession combined."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','freshwater','Open year-round; seasonal bag limits apply.','June 8-October 31: 2 per day. November 1-June 7: 5 per day.','June 8-October 31: 2 in possession. November 1-June 7: 5 in possession.','Only 1 may be 20 inches or longer.','Bristol Bay general freshwater rule. Special waters may differ.','{"june_8_october_31":"2 per day, 2 in possession; only 1 may be 20 inches or longer.","november_1_june_7":"5 per day, 5 in possession; only 1 may be 20 inches or longer."}'::jsonb),
    ('Arctic Grayling','arctic-grayling','freshwater','Open year-round unless a special regulation applies.','2 per day.','2 in possession.',null,'Special waters may differ.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Lake Trout','lake-trout','freshwater','Open year-round unless a special regulation applies.','4 per day.','4 in possession.',null,'Special waters may differ.','{"daily_limit":"4 per day.","possession_limit":"4 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Northern Pike','northern-pike','freshwater','Open year-round unless a special regulation applies.','5 per day.','5 in possession.','Only 1 may be 30 inches or longer.','Special waters may differ.','{"daily_limit":"5 per day.","possession_limit":"5 in possession.","large_fish_limit":"Only 1 may be 30 inches or longer."}'::jsonb),
    ('Burbot','burbot','freshwater','Open year-round unless a special regulation applies.','15 per day.','15 in possession.',null,'Special waters may differ.','{"daily_limit":"15 per day.","possession_limit":"15 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Pacific Halibut','pacific-halibut','saltwater','February 1-December 31 open; January 1-31 closed.','Unguided anglers: 2 per day.','Unguided anglers: 4 in possession.',null,'Federally managed. Guided angler limits are set by federal regulations.','{"season":"February 1-December 31 open.","unguided_limit":"2 per day, 4 in possession.","management":"Federally managed; guided angler limits are federal."}'::jsonb)
  ) as x(species_name,species_key,water_type,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key='bristol-bay-general' and q.verification_status='verified'
  );

  -- BRISTOL BAY: current 2026 sockeye emergency-order areas.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,special_restrictions,
    rule_details,official_reference,source_id,effective_from,effective_to,
    verification_status,verified_at
  )
  select 'AK','Sockeye Salmon','sockeye-salmon','waterbody',x.area_name,x.area_key,
    'freshwater','June 30-December 31, 2026','10 per day','10 in possession',
    '2026 ADF&G emergency order: limit increased to 10 sockeye per day and 10 in possession. Other salmon, except king and sockeye, remain 5 combined.',
    x.details,x.reference,v_sw,'2026-06-30','2026-12-31','verified',now()
  from (values
    ('Nushagak-Mulchatna River Drainage','bristol-bay-nushagak-mulchatna','{"emergency_order":"2-RS-2-37-26","sockeye_limit":"10 per day, 10 in possession through 2026-12-31.","other_salmon":"Other salmon, excluding king and sockeye, remain 5 combined."}'::jsonb,'ADF&G EO 2-RS-2-37-26, released June 29, 2026.'),
    ('Wood River Drainage','bristol-bay-wood-river','{"emergency_order":"2-RS-2-36-26","sockeye_limit":"10 per day, 10 in possession through 2026-12-31; no size limit.","other_salmon":"Other salmon, excluding king and sockeye, remain 5 combined."}'::jsonb,'ADF&G EO 2-RS-2-36-26, released June 29, 2026.')
  ) as x(area_name,area_key,details,reference)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key='sockeye-salmon'
      and q.waterbody_key=x.area_key and q.verification_status='verified'
  );

  -- KODIAK ISLAND FRESH WATER: road zone and remote zone.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',x.area_name,x.area_key,
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Southwest Alaska Sport Fishing Regulations Summary, Kodiak Island Fresh Water, page 24; 2026 emergency orders where noted.',
    v_sw,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','Kodiak Island — General Freshwater','kodiak-freshwater-general','Open year-round except where closed by emergency order or special regulation.','20 inches or longer: 2 per day. Under 20 inches: 10 per day.','20 inches or longer: 2 in possession. Under 20 inches: 10 in possession.',null,'Annual limit 5 fish. Karluk and Ayakulik River drainages closed to king salmon fishing in 2026.','{"20_inches_or_longer":"2 per day, 2 in possession.","under_20_inches":"10 per day, 10 in possession.","annual_limit":"5 fish; harvest record required.","closures":"Karluk and Ayakulik River drainages closed to king salmon fishing in 2026."}'::jsonb),
    ('Chum Salmon','chum-salmon','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations or an emergency order applies.','20 inches or longer: 5 per day combined with Coho, Pink, and Sockeye. Under 20 inches: 10 per day combined.','20 inches or longer: 10 in possession combined. Under 20 inches: 10 in possession combined.','20 inches separates the size groups.','Combined salmon limits apply to Chum, Coho, Pink, and Sockeye.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","20_inches_or_longer":"5 per day, 10 in possession combined.","under_20_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Coho Salmon','coho-salmon','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations or an emergency order applies.','20 inches or longer: 5 per day combined with Chum, Pink, and Sockeye. Under 20 inches: 10 per day combined.','20 inches or longer: 10 in possession combined. Under 20 inches: 10 in possession combined.','20 inches separates the size groups.','Combined salmon limits apply to Chum, Coho, Pink, and Sockeye.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","20_inches_or_longer":"5 per day, 10 in possession combined.","under_20_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Pink Salmon','pink-salmon','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations or an emergency order applies.','20 inches or longer: 5 per day combined with Chum, Coho, and Sockeye. Under 20 inches: 10 per day combined.','20 inches or longer: 10 in possession combined. Under 20 inches: 10 in possession combined.','20 inches separates the size groups.','Combined salmon limits apply to Chum, Coho, Pink, and Sockeye.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","20_inches_or_longer":"5 per day, 10 in possession combined.","under_20_inches":"10 per day, 10 in possession combined."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations or an emergency order applies.','20 inches or longer: 5 per day combined with Chum, Coho, and Pink. Under 20 inches: 10 per day combined.','20 inches or longer: 10 in possession combined. Under 20 inches: 10 in possession combined.','20 inches separates the size groups.','Ayakulik River has a 2026 sockeye limit of 10 per day; Buskin River is closed to sockeye sport fishing through Dec. 31, 2026.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","20_inches_or_longer":"5 per day, 10 in possession combined in the general remote zone.","under_20_inches":"10 per day, 10 in possession combined.","ayakulik_eo":"Sockeye 10 per day, 10 in possession through 2026-12-31; king salmon fishing closed.","buskin_eo":"Sport fishing for sockeye salmon, including catch-and-release, closed through 2026-12-31."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations apply.','2 per day combined with Steelhead.','2 in possession combined with Steelhead.','Only 1 may be 20 inches or longer.','Annual limit of 2 rainbow/steelhead trout 20 inches or longer; harvest record required. Road Zone is catch-and-release except listed stocked lakes.','{"daily_limit":"2 per day, 2 in possession combined with Steelhead; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required.","road_zone":"Catch-and-release only in Road Zone except listed stocked lakes, where rainbow trout are 10 per day and 10 in possession, only 1 may be 20 inches or longer."}'::jsonb),
    ('Steelhead','steelhead','Kodiak Island — Remote Zone Freshwater','kodiak-remote-freshwater','Open year-round unless special regulations apply.','2 per day combined with Rainbow Trout.','2 in possession combined with Rainbow Trout.','Only 1 may be 20 inches or longer.','Annual limit of 2 rainbow/steelhead trout 20 inches or longer; harvest record required. Road Zone is catch-and-release except listed stocked lakes.','{"daily_limit":"2 per day, 2 in possession combined with Rainbow Trout; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required.","road_zone":"Catch-and-release only except listed stocked lakes."}'::jsonb),
    ('Arctic Char','arctic-char','Kodiak Island — General Freshwater','kodiak-freshwater-general','Open year-round unless special regulations apply.','10 per day combined with Dolly Varden.','10 in possession combined with Dolly Varden.',null,'Combined with Dolly Varden.','{"combined_species":"Arctic Char and Dolly Varden.","daily_limit":"10 per day, 10 in possession combined.","size_limit":"No size limit."}'::jsonb),
    ('Dolly Varden','dolly-varden','Kodiak Island — General Freshwater','kodiak-freshwater-general','Open year-round unless special regulations apply.','10 per day combined with Arctic Char.','10 in possession combined with Arctic Char.',null,'Combined with Arctic Char.','{"combined_species":"Arctic Char and Dolly Varden.","daily_limit":"10 per day, 10 in possession combined.","size_limit":"No size limit."}'::jsonb)
  ) as x(species_name,species_key,area_name,area_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key=x.area_key and q.verification_status='verified'
  );

  -- KODIAK: Ayakulik and Buskin current sockeye emergency orders.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,special_restrictions,
    rule_details,official_reference,source_id,effective_from,effective_to,
    verification_status,verified_at
  )
  select 'AK','Sockeye Salmon','sockeye-salmon','waterbody',x.area_name,x.area_key,
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.special_text,
    x.details,x.reference,v_sw,x.start_date,'2026-12-31','verified',now()
  from (values
    ('Ayakulik River Drainage','kodiak-ayakulik-sockeye','June 26-December 31, 2026','10 per day','10 in possession','King salmon fishing remains closed; incidental king salmon must be immediately returned to the water.','{"emergency_order":"2-RS-4-30-26","sockeye_limit":"10 per day; 10 in possession through 2026-12-31.","king_salmon":"Sport fishing for king salmon remains closed; incidentally caught kings must be immediately returned to the water."}'::jsonb,'ADF&G EO 2-RS-4-30-26, released June 24, 2026.','2026-06-26'::date),
    ('Buskin River Drainage','kodiak-buskin-sockeye','June 24-December 31, 2026','Closed to sport fishing','No retention or possession','Sport fishing for sockeye salmon is closed, including catch-and-release; incidentally caught sockeye must be released immediately without removing them from the water.','{"emergency_order":"2-RS-4-27-26","closure":"Sport fishing for sockeye salmon, including catch-and-release, is closed through 2026-12-31.","incidental_catch":"Do not target, possess, retain, or remove incidentally caught sockeye from the water."}'::jsonb,'ADF&G EO 2-RS-4-27-26, released June 22, 2026.','2026-06-24'::date)
  ) as x(area_name,area_key,season_text,daily_text,possession_text,special_text,details,reference,start_date)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key='sockeye-salmon'
      and q.waterbody_key=x.area_key and q.verification_status='verified'
  );

  -- KODIAK / ALASKA PENINSULA / ALEUTIANS SALT WATER.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',x.area_name,x.area_key,
    'saltwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Southwest Alaska Sport Fishing Regulations Summary, Alaska Peninsula, Aleutian Islands, and Kodiak Island Salt Waters, pages 21-23; 2026 ADF&G emergency orders.',
    v_sw,'2026-01-01','verified',now()
  from (values
    ('Pacific Halibut','pacific-halibut','Alaska Peninsula, Aleutian Islands, and Kodiak — Salt Water','sw-kodiak-peninsula-halibut','February 1-December 31 open; January 1-31 closed.','Unguided anglers: 2 per day.','Unguided anglers: 4 in possession.',null,'Federally managed. Guided angler limits are federal.','{"season":"February 1-December 31 open.","unguided_limit":"2 per day, 4 in possession.","management":"Federally managed; guided angler limits are federal."}'::jsonb),
    ('Lingcod','lingcod','Alaska Peninsula, Aleutian Islands, and Kodiak — Salt Water','sw-kodiak-peninsula-lingcod','July 1-December 31 open; January 1-June 30 closed.','Remainder of area: 2 per day. Northern Afognak/Shuyak special area: 1 per day.','Remainder of area: 4 in possession. Northern Afognak/Shuyak special area: 2 in possession.','Northern Afognak/Shuyak special area: 35 inches or longer.','Northern Afognak and Shuyak Islands north of Tonki Cape/Black Cape: 1 per day, 2 in possession, 35 inches or longer through Dec. 31, 2026.','{"general_season":"July 1-December 31.","general_limit":"2 per day, 4 in possession; no size limit.","afognak_shuyak_eo":"1 per day, 2 in possession, 35 inches or longer through 2026-12-31."}'::jsonb),
    ('Rockfish','rockfish','Alaska Peninsula and Aleutian Islands — Salt Water','sw-peninsula-aleutian-rockfish','Open year-round unless a special regulation or emergency order applies.','10 per day.','20 in possession.',null,'Kodiak and Afognak have separate limits.','{"daily_limit":"10 per day, 20 in possession.","kodiak_exception":"Kodiak and Afognak waters have separate limits; see separate Kodiak entries."}'::jsonb),
    ('Rockfish','rockfish','Kodiak Island — General Salt Water','sw-kodiak-rockfish-general','Open year-round unless a special regulation or emergency order applies.','5 per day.','10 in possession.',null,'Remainder of Kodiak Island: only 2 per day and 4 in possession may be nonpelagic; only 1 per day and 2 in possession may be Yelloweye Rockfish. 2026 EO zones have separate species-specific limits.','{"general_kodiak":"5 per day, 10 in possession; only 2 per day and 4 in possession may be nonpelagic; only 1 per day and 2 in possession may be Yelloweye Rockfish.","cape_ikolik_dangerous_cape_eo":"5 per day, 10 in possession; no more than 2 per day and 4 in possession of one rockfish species; max 1 per day and 2 in possession Yelloweye; max 1 per day and 2 in possession Black Rockfish.","north_afognak_shuyak_eo":"3 per day, 3 in possession; only 1 may be a single rockfish species."}'::jsonb),
    ('Rockfish','rockfish','Kodiak and Afognak — Cape Ikolik/Dangerous Cape EO Area','sw-kodiak-rockfish-eo-cape-ikolik','June 1-December 31, 2026','5 per day.','10 in possession.',null,'No more than 2 per day and 4 in possession may be one rockfish species; max 1 per day and 2 in possession Yelloweye; max 1 per day and 2 in possession Black Rockfish.','{"emergency_order":"2-RF-4-23-26","daily_limit":"5 per day, 10 in possession.","single_species_cap":"No more than 2 per day, 4 in possession of one species.","yelloweye_cap":"1 per day, 2 in possession.","black_rockfish_cap":"1 per day, 2 in possession."}'::jsonb),
    ('Rockfish','rockfish','Northern Afognak and Shuyak Islands — Salt Water','sw-north-afognak-shuyak-rockfish-eo','June 1-December 31, 2026','3 per day.','3 in possession.',null,'Only 1 may be a single rockfish species.','{"emergency_order":"2-RF-4-23-26","daily_limit":"3 per day, 3 in possession.","single_species_cap":"Only 1 may be a single rockfish species."}'::jsonb)
  ) as x(species_name,species_key,area_name,area_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key=x.area_key and q.verification_status='verified'
  );

  -- SOUTHCENTRAL: Kenai Peninsula fresh waters (excluding Kenai River and North Gulf Coast).
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southcentral Alaska — Kenai Peninsula Fresh Waters','southcentral-kenai-peninsula-fresh',
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, Kenai Peninsula Fresh Waters, pages 60-61.',
    v_sc,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','Closed to king salmon fishing in 2026 except Kasilof River and Ninilchik River.','Closed in all other Kenai Peninsula fresh waters.','No retention in closed waters.',null,'Kasilof and Ninilchik have separate 2026 emergency orders and rules. The combined annual limit of 5 king salmon 20 inches or longer applies across listed Southcentral areas where retention is allowed.','{"general_status":"King salmon fishing closed in 2026 except Kasilof River and Ninilchik River.","exceptions":"Kasilof River and Ninilchik River have separate rules and emergency orders.","annual_limit":"Combined annual limit of 5 fish 20 inches or longer across designated Southcentral areas."}'::jsonb),
    ('Chum Salmon','chum-salmon','Open year-round unless special regulations or an emergency order applies.','16 inches or longer: 3 per day combined with Coho, Pink, and Sockeye; only 2 may be Coho. Under 16 inches: 10 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined.','16 inches separates size groups.','Combined salmon limits apply in unstocked lakes and flowing waters. Stocked lakes have separate combined salmon limits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 3 in possession combined; only 2 may be Coho.","under_16_inches":"10 per day, 10 in possession combined.","stocked_lakes":"10 per day, 10 in possession in combination with King Salmon."}'::jsonb),
    ('Coho Salmon','coho-salmon','Open year-round unless special regulations or an emergency order applies.','16 inches or longer: 3 per day combined with Chum, Pink, and Sockeye; only 2 may be Coho. Under 16 inches: 10 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined.','16 inches separates size groups.','A Coho 16 inches or longer removed from the water must be retained and counts toward the angler’s limit. Stocked lakes have separate combined salmon limits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 3 in possession combined; only 2 may be Coho.","under_16_inches":"10 per day, 10 in possession combined.","handling":"A Coho 16 inches or longer removed from the water must be retained.","stocked_lakes":"10 per day, 10 in possession in combination with King Salmon."}'::jsonb),
    ('Pink Salmon','pink-salmon','Open year-round unless special regulations or an emergency order applies.','16 inches or longer: 3 per day combined with Chum, Coho, and Sockeye. Under 16 inches: 10 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined.','16 inches separates size groups.','Stocked lakes have separate combined salmon limits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 3 in possession combined; only 2 may be Coho.","under_16_inches":"10 per day, 10 in possession combined.","stocked_lakes":"10 per day, 10 in possession in combination with King Salmon."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Open year-round unless special regulations or an emergency order applies.','16 inches or longer: 3 per day combined with Chum, Coho, and Pink. Under 16 inches: 10 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined.','16 inches separates size groups.','Stocked lakes have separate combined salmon limits.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","16_inches_or_longer":"3 per day, 3 in possession combined; only 2 may be Coho.","under_16_inches":"10 per day, 10 in possession combined.","stocked_lakes":"10 per day, 10 in possession in combination with King Salmon."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Steelhead. Lakes: 5 per day combined with Steelhead.','Flowing waters: 2 in possession. Lakes: 5 in possession.','Only 1 may be 20 inches or longer.','Combined with Steelhead. Total annual limit of 2 fish 20 inches or longer north of Point Adam across designated Southcentral areas.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"2 per day, 2 in possession; only 1 may be 20 inches or longer.","lakes":"5 per day, 5 in possession; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer across designated Southcentral areas north of Point Adam; harvest record required."}'::jsonb),
    ('Steelhead','steelhead','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Rainbow Trout. Lakes: 5 per day combined with Rainbow Trout.','Flowing waters: 2 in possession. Lakes: 5 in possession.','Only 1 may be 20 inches or longer.','Combined with Rainbow Trout. Total annual limit of 2 fish 20 inches or longer north of Point Adam across designated Southcentral areas.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"2 per day, 2 in possession; only 1 may be 20 inches or longer.","lakes":"5 per day, 5 in possession; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer across designated Southcentral areas north of Point Adam; harvest record required."}'::jsonb),
    ('Arctic Char','arctic-char','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Dolly Varden. Lakes: 5 per day combined with Dolly Varden.','Flowing waters: 2 in possession. Lakes: 5 in possession.',null,'Combined with Dolly Varden.','{"combined_species":"Arctic Char and Dolly Varden.","flowing_waters":"2 per day, 2 in possession.","lakes":"5 per day, 5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Dolly Varden','dolly-varden','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Arctic Char. Lakes: 5 per day combined with Arctic Char.','Flowing waters: 2 in possession. Lakes: 5 in possession.',null,'Combined with Arctic Char.','{"combined_species":"Arctic Char and Dolly Varden.","flowing_waters":"2 per day, 2 in possession.","lakes":"5 per day, 5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Arctic Grayling','arctic-grayling','Open year-round unless special regulations apply.','5 per day.','5 in possession.',null,'Special waters may differ.','{"daily_limit":"5 per day.","possession_limit":"5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Lake Trout','lake-trout','Open year-round unless special regulations apply.','20 inches or longer: 2 per day. Under 20 inches: 10 per day.','20 inches or longer: 2 in possession. Under 20 inches: 10 in possession.','20 inches separates size groups.','Special waters may differ.','{"20_inches_or_longer":"2 per day, 2 in possession.","under_20_inches":"10 per day, 10 in possession."}'::jsonb),
    ('Burbot','burbot','Open year-round unless special regulations apply.','2 per day.','2 in possession.',null,'Special waters may differ.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","size_limit":"No size limit."}'::jsonb)
  ) as x(species_name,species_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key='southcentral-kenai-peninsula-fresh'
      and q.verification_status='verified'
  );

  -- SOUTHCENTRAL: North Gulf Coast freshwaters.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southcentral Alaska — North Gulf Coast Freshwaters','southcentral-north-gulf-fresh',
    'freshwater',x.season_text,x.daily_text,x.possession_text,x.minimum_text,
    x.special_text,x.details,
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, North Gulf Coast Freshwater, pages 70-73.',
    v_sc,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','Closed year-round to king salmon fishing, except youth-only fisheries specifically announced by ADF&G.','Closed.','No retention.',null,'2026 North Gulf Coast general rule. Check any current youth-only fishery announcement.','{"status":"Closed year-round to king salmon fishing; youth-only fisheries may be separately announced."}'::jsonb),
    ('Chum Salmon','chum-salmon','Open year-round outside Resurrection Bay; Resurrection Bay freshwater salmon season has area-specific dates.','Outside Resurrection Bay: 16 inches or longer, 3 per day combined with Coho, Pink, and Sockeye; under 16 inches, 10 per day combined. Resurrection Bay downstream of Seward Highway/Nash Road markers: June 16-December 31, 3 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined. Resurrection Bay downstream marker area: 3 combined.','16 inches separates size groups outside Resurrection Bay.','Combined with Coho, Pink, and Sockeye. Only 2 of the 3 large salmon may be Coho.','{"outside_resurrection_bay":"16 inches or longer: 3 per day, 3 in possession combined, only 2 may be Coho; under 16 inches: 10 per day, 10 in possession.","resurrection_bay":"Jan 1-June 15 closed to salmon fishing. June 16-Dec 31 downstream of Seward Highway and Nash Road markers: 3 per day, 3 in possession combined; only 2 may be Coho."}'::jsonb),
    ('Coho Salmon','coho-salmon','Open year-round outside Resurrection Bay; Resurrection Bay freshwater salmon season has area-specific dates.','Outside Resurrection Bay: 16 inches or longer, 3 per day combined with Chum, Pink, and Sockeye; under 16 inches, 10 per day combined. Resurrection Bay downstream of Seward Highway/Nash Road markers: June 16-December 31, 3 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined. Resurrection Bay downstream marker area: 3 combined.','16 inches separates size groups outside Resurrection Bay.','Combined with Chum, Pink, and Sockeye. Only 2 of the 3 salmon may be Coho.','{"outside_resurrection_bay":"16 inches or longer: 3 per day, 3 in possession combined, only 2 may be Coho; under 16 inches: 10 per day, 10 in possession.","resurrection_bay":"Jan 1-June 15 closed to salmon fishing. June 16-Dec 31 downstream of Seward Highway and Nash Road markers: 3 per day, 3 in possession combined; only 2 may be Coho."}'::jsonb),
    ('Pink Salmon','pink-salmon','Open year-round outside Resurrection Bay; Resurrection Bay freshwater salmon season has area-specific dates.','Outside Resurrection Bay: 16 inches or longer, 3 per day combined with Chum, Coho, and Sockeye; under 16 inches, 10 per day combined. Resurrection Bay downstream of Seward Highway/Nash Road markers: June 16-December 31, 3 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined. Resurrection Bay downstream marker area: 3 combined.','16 inches separates size groups outside Resurrection Bay.','Combined with Chum, Coho, and Sockeye.','{"outside_resurrection_bay":"16 inches or longer: 3 per day, 3 in possession combined; under 16 inches: 10 per day, 10 in possession.","resurrection_bay":"Jan 1-June 15 closed to salmon fishing. June 16-Dec 31 downstream of Seward Highway and Nash Road markers: 3 per day, 3 in possession combined."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Open year-round outside Resurrection Bay; Resurrection Bay freshwater salmon season has area-specific dates.','Outside Resurrection Bay: 16 inches or longer, 3 per day combined with Chum, Coho, and Pink; under 16 inches, 10 per day combined. Resurrection Bay downstream of Seward Highway/Nash Road markers: June 16-December 31, 3 per day combined.','16 inches or longer: 3 in possession combined. Under 16 inches: 10 in possession combined. Resurrection Bay downstream marker area: 3 combined.','16 inches separates size groups outside Resurrection Bay.','Combined with Chum, Coho, and Pink.','{"outside_resurrection_bay":"16 inches or longer: 3 per day, 3 in possession combined; under 16 inches: 10 per day, 10 in possession.","resurrection_bay":"Jan 1-June 15 closed to salmon fishing. June 16-Dec 31 downstream of Seward Highway and Nash Road markers: 3 per day, 3 in possession combined."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Steelhead. Lakes: 5 per day combined with Steelhead.','Flowing waters: 2 in possession. Lakes: 5 in possession.','Only 1 may be 20 inches or longer.','Annual limit 2 rainbow/steelhead trout 20 inches or longer; harvest record required.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"2 per day, 2 in possession; only 1 may be 20 inches or longer.","lakes":"5 per day, 5 in possession; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required."}'::jsonb),
    ('Steelhead','steelhead','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Rainbow Trout. Lakes: 5 per day combined with Rainbow Trout.','Flowing waters: 2 in possession. Lakes: 5 in possession.','Only 1 may be 20 inches or longer.','Annual limit 2 rainbow/steelhead trout 20 inches or longer; harvest record required.','{"combined_species":"Rainbow Trout and Steelhead.","flowing_waters":"2 per day, 2 in possession; only 1 may be 20 inches or longer.","lakes":"5 per day, 5 in possession; only 1 may be 20 inches or longer.","annual_limit":"2 fish 20 inches or longer; harvest record required."}'::jsonb),
    ('Arctic Char','arctic-char','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Dolly Varden. Lakes: 5 per day combined with Dolly Varden.','Flowing waters: 2 in possession. Lakes: 5 in possession.',null,'Combined with Dolly Varden.','{"combined_species":"Arctic Char and Dolly Varden.","flowing_waters":"2 per day, 2 in possession.","lakes":"5 per day, 5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Dolly Varden','dolly-varden','Open year-round unless special regulations apply.','Flowing waters: 2 per day combined with Arctic Char. Lakes: 5 per day combined with Arctic Char.','Flowing waters: 2 in possession. Lakes: 5 in possession.',null,'Combined with Arctic Char.','{"combined_species":"Arctic Char and Dolly Varden.","flowing_waters":"2 per day, 2 in possession.","lakes":"5 per day, 5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Arctic Grayling','arctic-grayling','Open year-round unless special regulations apply.','5 per day.','5 in possession.',null,'Special waters may differ.','{"daily_limit":"5 per day.","possession_limit":"5 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Lake Trout','lake-trout','Open year-round unless special regulations apply.','2 per day.','2 in possession.',null,'No size limit in North Gulf Coast freshwater general rule.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","size_limit":"No size limit."}'::jsonb)
  ) as x(species_name,species_key,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key='southcentral-north-gulf-fresh'
      and q.verification_status='verified'
  );

  -- PRINCE WILLIAM SOUND: general fresh and salt water.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,minimum_length,
    special_restrictions,rule_details,official_reference,source_id,
    effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'region',
    'Southcentral Alaska — Prince William Sound General Fresh and Salt Waters',
    'southcentral-prince-william-sound',x.water_type,x.season_text,x.daily_text,
    x.possession_text,x.minimum_text,x.special_text,x.details,
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, Prince William Sound, pages 74-75.',
    v_sc,'2026-01-01','verified',now()
  from (values
    ('Chinook Salmon','chinook-salmon','freshwater','Open year-round unless a special regulation applies.','20 inches or longer: 2 per day. Under 20 inches: 10 per day.','20 inches or longer: 4 in possession. Under 20 inches: 10 in possession.',null,'No annual limit or harvest recording requirement; king salmon stamp is required. Charter operators and crew may not retain king salmon while clients are on board.','{"freshwater_20_inches_or_longer":"2 per day, 4 in possession.","freshwater_under_20_inches":"10 per day, 10 in possession.","annual_limit":"No annual limit or recording requirement; king stamp required."}'::jsonb),
    ('Chinook Salmon','chinook-salmon','saltwater','April 1-September 15: 1 per day, 1 in possession, any size by 2026 emergency order. September 16-March 31: 2 per day, 4 in possession, no size limit.','April 1-September 15: 1 per day. September 16-March 31: 2 per day.','April 1-September 15: 1 in possession. September 16-March 31: 4 in possession.',null,'Terminal Harvest Areas have separate year-round limits. Charter operators and crew may not retain king salmon while clients are on board.','{"saltwater_april_1_september_15":"1 per day, 1 in possession, any size by 2026 emergency order.","saltwater_september_16_march_31":"2 per day, 4 in possession, no size limit.","terminal_harvest_areas":"Whittier, Cordova, Valdez, and Chenega Terminal Harvest Areas: 2 per day, 4 in possession, year-round.","annual_limit":"No annual limit or recording requirement; king stamp required."}'::jsonb),
    ('Chum Salmon','chum-salmon','freshwater','Open year-round unless a special regulation applies.','6 per day combined with Coho, Pink, and Sockeye Salmon.','12 in possession combined with Coho, Pink, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Coho Salmon','coho-salmon','freshwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Pink, and Sockeye Salmon.','12 in possession combined with Chum, Pink, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Pink Salmon','pink-salmon','freshwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Coho, and Sockeye Salmon.','12 in possession combined with Chum, Coho, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','freshwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Coho, and Pink Salmon.','12 in possession combined with Chum, Coho, and Pink Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Chum Salmon','chum-salmon','saltwater','Open year-round unless a special regulation applies.','6 per day combined with Coho, Pink, and Sockeye Salmon.','12 in possession combined with Coho, Pink, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon. Pink and Chum taken in sport fisheries may be used as bait but count toward the bag limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho.","bait_note":"Pink and Chum sport-caught salmon used as bait count toward the bag limit and must not be alive."}'::jsonb),
    ('Coho Salmon','coho-salmon','saltwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Pink, and Sockeye Salmon.','12 in possession combined with Chum, Pink, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Pink Salmon','pink-salmon','saltwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Coho, and Sockeye Salmon.','12 in possession combined with Chum, Coho, and Sockeye Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon. Pink and Chum used as bait count toward bag limit.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho.","bait_note":"Pink and Chum sport-caught salmon used as bait count toward the bag limit and must not be alive."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','saltwater','Open year-round unless a special regulation applies.','6 per day combined with Chum, Coho, and Pink Salmon.','12 in possession combined with Chum, Coho, and Pink Salmon.',null,'Only 3 per day and 3 in possession may be Coho Salmon.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","daily_limit":"6 per day, 12 in possession combined; only 3 per day and 3 in possession may be Coho."}'::jsonb),
    ('Rainbow Trout','rainbow-trout','freshwater','June 15-April 14 open for unstocked lakes and flowing waters; stocked lakes open year-round.','Unstocked lakes and flowing waters: 2 per day. Stocked lakes: 10 per day.','Unstocked lakes and flowing waters: 2 in possession. Stocked lakes: 10 in possession.','Unstocked lakes, flowing waters, and salt waters: 11-inch minimum and 16-inch maximum during June 15-April 14.','Combined with Steelhead and Cutthroat Trout. Stocked lakes have separate limits.','{"unstocked_lakes_flowing_and_salt":"June 15-April 14: 2 per day, 2 in possession, 11-inch minimum and 16-inch maximum, combined with Steelhead and Cutthroat.","stocked_lakes":"10 per day, 10 in possession, no size limit."}'::jsonb),
    ('Steelhead','steelhead','freshwater','June 15-April 14 open for unstocked lakes and flowing waters; stocked lakes open year-round.','Unstocked lakes and flowing waters: 2 per day. Stocked lakes: 10 per day.','Unstocked lakes and flowing waters: 2 in possession. Stocked lakes: 10 in possession.','Unstocked lakes, flowing waters, and salt waters: 11-inch minimum and 16-inch maximum during June 15-April 14.','Combined with Rainbow Trout and Cutthroat Trout.','{"unstocked_lakes_flowing_and_salt":"June 15-April 14: 2 per day, 2 in possession, 11-inch minimum and 16-inch maximum, combined with Rainbow Trout and Cutthroat.","stocked_lakes":"10 per day, 10 in possession, no size limit."}'::jsonb),
    ('Arctic Char','arctic-char','freshwater','Open year-round unless a special regulation applies.','10 per day combined with Dolly Varden.','10 in possession combined with Dolly Varden.',null,'Combined with Dolly Varden.','{"combined_species":"Arctic Char and Dolly Varden.","daily_limit":"10 per day, 10 in possession combined.","size_limit":"No size limit."}'::jsonb),
    ('Dolly Varden','dolly-varden','freshwater','Open year-round unless a special regulation applies.','10 per day combined with Arctic Char.','10 in possession combined with Arctic Char.',null,'Combined with Arctic Char.','{"combined_species":"Arctic Char and Dolly Varden.","daily_limit":"10 per day, 10 in possession combined.","size_limit":"No size limit."}'::jsonb),
    ('Arctic Grayling','arctic-grayling','freshwater','Open year-round unless a special regulation applies.','10 per day.','10 in possession.',null,'Special waters may differ.','{"daily_limit":"10 per day.","possession_limit":"10 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Lake Trout','lake-trout','freshwater','Open year-round unless a special regulation applies.','2 per day.','2 in possession.',null,'Special waters may differ.','{"daily_limit":"2 per day.","possession_limit":"2 in possession.","size_limit":"No size limit."}'::jsonb),
    ('Lingcod','lingcod','saltwater','July 1-December 31 open; January 1-June 30 closed.','1 per day.','1 in possession.','Minimum 35 inches with head attached, or 28 inches with head removed.','Deepwater release device required when sport fishing in salt water.','{"season":"July 1-December 31.","daily_limit":"1 per day, 1 in possession.","minimum_size":"35 inches with head attached, or 28 inches with head removed."}'::jsonb),
    ('Rockfish','rockfish','saltwater','Open year-round unless a special regulation applies.','3 per day.','6 in possession.',null,'Only 1 per day and 1 in possession may be a nonpelagic rockfish. January 1-June 30: no retention of Yelloweye Rockfish. Deepwater release device required.','{"daily_limit":"3 per day, 6 in possession.","nonpelagic_limit":"Only 1 per day, 1 in possession may be nonpelagic.","yelloweye":"No retention January 1-June 30.","release_device":"Deepwater release device required."}'::jsonb),
    ('Pacific Halibut','pacific-halibut','saltwater','February 1-December 31 open; January 1-31 closed.','Unguided anglers: 2 per day.','Unguided anglers: 4 in possession.',null,'Federally managed. Guided angler limits are federal.','{"season":"February 1-December 31 open.","unguided_limit":"2 per day, 4 in possession.","management":"Federally managed; guided angler limits are federal."}'::jsonb)
  ) as x(species_name,species_key,water_type,season_text,daily_text,possession_text,minimum_text,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key='southcentral-prince-william-sound'
      and q.waterbody_type=x.water_type and q.verification_status='verified'
  );

  -- PRINCE WILLIAM SOUND: selected Copper River Highway streams special area.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,waterbody_key,
    waterbody_type,season_open,daily_bag_limit,possession_limit,special_restrictions,
    rule_details,official_reference,source_id,effective_from,verification_status,verified_at
  )
  select 'AK',x.species_name,x.species_key,'waterbody',
    'Prince William Sound — Copper River Highway Streams','pws-copper-river-highway-streams',
    'freshwater','Open year-round unless a stream-specific closure applies.',
    '3 per day combined with the other listed salmon species.',
    '3 in possession combined with the other listed salmon species.',
    x.special_text,x.details,
    '2026 Southcentral Alaska Sport Fishing Regulations Summary, Prince William Sound, page 75.',
    v_sc,'2026-01-01','verified',now()
  from (values
    ('Chum Salmon','chum-salmon','Chum, Coho, Pink, and Sockeye Salmon share a combined limit of 3 per day and 3 in possession. Some named streams have additional species sublimits or closures.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"3 per day, 3 in possession combined.","coho_handling":"A Coho removed from the water must be retained and counts toward the daily limit.","special_areas":"Eyak Lake, Eccles Creek, and Hartney Creek have year-round salmon closures; other named streams have separate limits."}'::jsonb),
    ('Coho Salmon','coho-salmon','Chum, Coho, Pink, and Sockeye Salmon share a combined limit of 3 per day and 3 in possession. Some named streams have additional species sublimits or closures.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"3 per day, 3 in possession combined.","coho_handling":"A Coho removed from the water must be retained and counts toward the daily limit.","special_areas":"Eyak Lake, Eccles Creek, and Hartney Creek have year-round salmon closures; other named streams have separate limits."}'::jsonb),
    ('Pink Salmon','pink-salmon','Chum, Coho, Pink, and Sockeye Salmon share a combined limit of 3 per day and 3 in possession. Some named streams have additional species sublimits or closures.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"3 per day, 3 in possession combined.","special_areas":"Eyak Lake, Eccles Creek, and Hartney Creek have year-round salmon closures; other named streams have separate limits."}'::jsonb),
    ('Sockeye Salmon','sockeye-salmon','Chum, Coho, Pink, and Sockeye Salmon share a combined limit of 3 per day and 3 in possession. Some named streams have additional species sublimits or closures.','{"combined_species":"Chum, Coho, Pink, and Sockeye Salmon.","general_limit":"3 per day, 3 in possession combined.","special_areas":"Johnstone Bay fresh waters: only 2 per day and 2 in possession may be Coho. Robe River downstream section: only 1 per day and 1 in possession may be Sockeye and only 1 Coho."}'::jsonb)
  ) as x(species_name,species_key,special_text,details)
  where not exists (
    select 1 from public.regulation_rules q
    where q.state_code='AK' and q.species_key=x.species_key
      and q.waterbody_key='pws-copper-river-highway-streams'
      and q.verification_status='verified'
  );

end $$;

-- Reminder: Alaska's published summaries are not a complete digest of all rules.
-- Check the exact drainage/management area and current ADF&G emergency orders.
