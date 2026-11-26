-- FishBound: California freshwater species batch 2
-- Based on current California Code of Regulations, Title 14, §§ 1.77, 5.15, 5.65, 5.82 and 5.90.
-- Rules below are statewide category rules; named-water and district exceptions are called out.
-- Safe to run more than once.

do $$
declare
  v_source_id uuid;
  v_species text;
  v_key text;
  v_names text[] := array[
    'Pumpkinseed','pumpkinseed',
    'Redear Sunfish','redear-sunfish',
    'Green Sunfish','green-sunfish',
    'Warmouth','warmouth',
    'Black Bullhead','black-bullhead',
    'Brown Bullhead','brown-bullhead',
    'Flathead Catfish','flathead-catfish',
    'Yellow Bullhead','yellow-bullhead',
    'American Shad','american-shad',
    'White Bass','white-bass'
  ];
  i integer;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = 'California Code of Regulations, Title 14 — Inland Species Rules (2026)'
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Fish and Game Commission / California Department of Fish and Wildlife',
      'California Code of Regulations, Title 14 — Inland Species Rules (2026)',
      'https://wildlife.ca.gov/Regulations/Fishing',
      2026,
      now(),
      'official',
      'verified',
      'Current California inland species provisions: §§ 1.77, 5.15, 5.65, 5.82 and 5.90. Rules are statewide baselines and do not replace district or water-specific exceptions.'
    )
    returning id into v_source_id;
  end if;

  -- Sunfish are expressly defined to include pumpkinseed, redear sunfish,
  -- green sunfish and warmouth; § 5.82 gives one combined limit for sunfish
  -- and crappie of all species.
  for i in 1..4 loop
    v_species := v_names[(i * 2) - 1];
    v_key := v_names[i * 2];
    if not exists (
      select 1 from public.regulation_rules
      where state_code='CA' and species_key=v_key
        and rule_scope='statewide' and source_id=v_source_id
    ) then
      insert into public.regulation_rules (
        state_code,species_name,species_key,rule_scope,season_open,
        daily_bag_limit,minimum_length,special_restrictions,
        rule_details,official_reference,source_id,verification_status,verified_at
      ) values (
        'CA',v_species,v_key,'statewide',
        'Open all year except closures listed under district or special regulations',
        '25 sunfish and crappie combined per day',
        'No general size limit',
        'The 25-fish limit is combined across all sunfish and crappie species, not 25 of each species. Barrett and Upper Otay Lakes in San Diego County have a zero bag limit for all species. Hodges and El Capitan Lakes have a 10-inch total-length minimum for crappie.',
        jsonb_build_object(
          'combined_daily_limit','25 sunfish and crappie of all species combined',
          'general_size_limit','No size limit',
          'water_exceptions','Barrett and Upper Otay Lakes (San Diego County): zero bag limit for all species. Hodges and El Capitan Lakes (San Diego County): crappie minimum 10 inches total length.',
          'season','Open all year except closures listed under district or special regulations.',
          'classification','California defines sunfish to include bluegill, green sunfish, redear sunfish, pumpkinseed, warmouth and Sacramento perch.'
        ),
        'California Code of Regulations, Title 14, §§ 1.77 and 5.82.',
        v_source_id,'verified',now()
      );
    end if;
  end loop;

  -- Catfish and bullheads: statewide open season with no general numeric
  -- limit, subject to the extensive exceptions listed in § 5.15.
  for i in 5..8 loop
    v_species := v_names[(i * 2) - 1];
    v_key := v_names[i * 2];
    if not exists (
      select 1 from public.regulation_rules
      where state_code='CA' and species_key=v_key
        and rule_scope='statewide' and source_id=v_source_id
    ) then
      insert into public.regulation_rules (
        state_code,species_name,species_key,rule_scope,season_open,
        daily_bag_limit,special_restrictions,rule_details,
        official_reference,source_id,verification_status,verified_at
      ) values (
        'CA',v_species,v_key,'statewide',
        'Open all year except closures listed under special regulations',
        'No statewide numeric limit; district and water exceptions apply',
        'California § 5.15 sets no general numeric limit for bullheads or other catfish, but lists many district and named-water exceptions. Check the exact waterbody before keeping fish.',
        jsonb_build_object(
          'general_rule','Bullheads: no limit. Other catfish: no limit except the waters and bag limits listed in § 5.15.',
          'water_exceptions','The regulation lists district-wide and named-water limits, including 10-fish and 5-fish limits in specified waters. This statewide entry does not replace those exceptions.',
          'season','Open all year except closures listed under special regulations.',
          'important','Check the complete current § 5.15 table for the exact waterbody.'
        ),
        'California Code of Regulations, Title 14, § 5.15.',
        v_source_id,'verified',now()
      );
    end if;
  end loop;

  -- American shad.
  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='american-shad'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,
      daily_bag_limit,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','American Shad','american-shad','statewide',
      'Open all year except closures listed under special regulations',
      '25 fish per day',
      'Shad may be taken only by angling, except that a dip net may be used in the Valley District.',
      jsonb_build_object(
        'daily_limit','25 fish',
        'methods_of_take','Angling only, except a dip net may be used in the Valley District.',
        'season','Open all year except closures listed under special regulations.'
      ),
      'California Code of Regulations, Title 14, § 5.65.',
      v_source_id,'verified',now()
    );
  end if;

  -- White bass.
  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='white-bass'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,
      daily_bag_limit,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','White Bass','white-bass','statewide',
      'Open all year',
      'No limit',
      'Live white bass may not be possessed or transported. Except at Lake Nacimiento, any white bass taken must immediately be killed by removing the head or cutting through the gills. At Lake Nacimiento, fish must immediately be released into the water or killed in that manner.',
      jsonb_build_object(
        'daily_limit','No limit',
        'live_fish_rule','No live white bass may be possessed or transported.',
        'general_handling_rule','Any white bass taken must immediately be killed by removing the head or cutting through the gills.',
        'lake_nacimiento_exception','At Lake Nacimiento (San Luis Obispo County), any white bass taken must immediately be released into the water or killed by removing the head or cutting through the gills.',
        'season','Open all year.'
      ),
      'California Code of Regulations, Title 14, § 5.90.',
      v_source_id,'verified',now()
    );
  end if;
end $$;
