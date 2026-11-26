-- FishBound: California ocean species batch 2
-- Official sources: CDFW 2026 Ocean Sport Fishing Regulations and current groundfish/regional summaries.
-- Groundfish rules are subject to in-season changes, management-area seasons, depth restrictions,
-- marine protected areas, and species-specific exceptions. Check the current CDFW map before fishing.
-- Safe to run more than once.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code='CA'
    and source_title='CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 2'
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Department of Fish and Wildlife',
      'CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 2',
      'https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=239985',
      2026,
      now(),
      'official',
      'verified',
      'Official 2026 Ocean Sport Fishing Regulations, last updated July 17, 2026, supplemented by CDFW groundfish and regional summaries current in November 2026. Groundfish seasons and depth restrictions vary by management area and may change in-season.'
    )
    returning id into v_source_id;
  end if;

  -- Lingcod: statewide bag and size limits; season/depth rules vary by area.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='lingcod' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,gear_restrictions,special_restrictions,
      rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Lingcod','lingcod','statewide',
      'Season and depth restrictions vary by Groundfish Management Area. In 2026, many areas are closed January 1-March 31; the Southern Management Area has additional quarterly depth restrictions.',
      '2 fish',
      '2 fish',
      '22 inches total length',
      'When lingcod are aboard or in possession, only one line with no more than two hooks may be used. Vessel anglers must have a descending device when taking or possessing federal groundfish.',
      'Groundfish Management Area seasons, depth boundaries, and marine protected area closures apply. Check the current CDFW groundfish summary and interactive map for the exact fishing location. Lingcod fillets must retain the entire skin and be at least 14 inches long.',
      jsonb_build_object(
        'daily_bag_limit','2 fish',
        'possession_limit','2 fish',
        'minimum_size','22 inches total length',
        'season_and_depth','Varies by Groundfish Management Area. In 2026 many areas are closed January 1-March 31. Southern Management Area has additional seasonal depth restrictions.',
        'gear','Only one line with no more than two hooks when lingcod are aboard or in possession. Descending device required for federal groundfish from a vessel.',
        'fillet_rule','Fillets must be at least 14 inches long and retain the entire skin.',
        'check_before_fishing','Consult current CDFW groundfish area summary and interactive map for in-season changes, depth boundaries and MPAs.'
      ),
      'Title 14 CCR §§ 27.20, 27.25-27.50, 27.65, 28.27; CDFW 2026 Groundfish Summary.',
      v_source_id,'verified',now()
    );
  end if;

  -- Rockfish: combined RCG complex daily limit and species exceptions.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='rockfish' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,gear_restrictions,special_restrictions,
      rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Rockfish','rockfish','statewide',
      'Season and depth restrictions vary by Groundfish Management Area and species group; closures and in-season changes apply.',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      'No general minimum size limit',
      'Only one line with no more than two hooks when rockfish are aboard or in possession. A descending device is required when taking or possessing federal groundfish from a vessel.',
      'RCG means rockfish, cabezon and greenlings combined. Copper rockfish: 1 fish. Vermilion/sunset rockfish: 4 combined in the Northern Management Area and 2 combined elsewhere. Canary rockfish: 2. Bronzespotted, cowcod, quillback and yelloweye rockfish may not be retained. Groundfish seasons, depth boundaries and MPAs apply.',
      jsonb_build_object(
        'combined_daily_limit','10 rockfish, cabezon and greenlings combined, subject to species exceptions',
        'special_limits','Copper rockfish: 1. Vermilion/sunset rockfish: 4 combined in Northern Management Area; 2 combined in all other areas. Canary rockfish: 2.',
        'prohibited_species','Bronzespotted rockfish, cowcod, quillback rockfish and yelloweye rockfish: zero retention; may not be taken or possessed.',
        'minimum_size','No general minimum size for rockfish.',
        'season_and_depth','Varies by Groundfish Management Area, species group, depth and in-season changes.',
        'gear','Only one line with no more than two hooks when rockfish are aboard or in possession. Descending device required from a vessel.',
        'important','RCG limit is shared with cabezon and greenlings; it is not a separate 10-fish allowance for each group.'
      ),
      'Title 14 CCR §§ 1.91, 27.20, 27.25-27.50, 28.55; CDFW 2026 Groundfish Summary.',
      v_source_id,'verified',now()
    );
  end if;

  -- Cabezon: included in RCG combined limit.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='cabezon' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,gear_restrictions,special_restrictions,
      rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Cabezon','cabezon','statewide',
      'Season and depth restrictions vary by Groundfish Management Area; shore-based anglers and divers have specified exemptions.',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      'No general minimum size limit',
      'Only one line with no more than two hooks when cabezon are aboard or in possession. Descending device requirements apply to vessel fishing for federal groundfish.',
      'Cabezon shares the RCG limit with all rockfish and greenlings. Regional season/depth rules and MPAs apply. Fillets must retain the entire skin.',
      jsonb_build_object(
        'combined_daily_limit','10 rockfish, cabezon and greenlings combined, subject to species exceptions',
        'minimum_size','No general minimum size limit.',
        'season_and_depth','Varies by Groundfish Management Area; check current CDFW summary and interactive map.',
        'gear','Only one line with no more than two hooks when cabezon are aboard or in possession.',
        'fillet_rule','Fillets must retain the entire skin.',
        'important','The RCG limit is shared with rockfish and greenlings.'
      ),
      'Title 14 CCR §§ 27.20, 27.25-27.50, 28.28; CDFW 2026 Groundfish Summary.',
      v_source_id,'verified',now()
    );
  end if;

  -- Kelp Greenling: included in RCG combined limit.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='kelp-greenling' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,gear_restrictions,special_restrictions,
      rule_details,official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Kelp Greenling','kelp-greenling','statewide',
      'Season and depth restrictions vary by Groundfish Management Area; check current CDFW area rules.',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      '10 RCG fish combined per person, subject to species-specific exceptions',
      'No general minimum size limit',
      'Only one line with no more than two hooks when greenlings of genus Hexagrammos are aboard or in possession. Descending device requirements apply to vessel fishing for federal groundfish.',
      'Kelp greenling shares the RCG limit with rockfish and cabezon. Regional season/depth rules and MPAs apply. Fillets must retain the entire skin.',
      jsonb_build_object(
        'combined_daily_limit','10 rockfish, cabezon and greenlings combined, subject to species exceptions',
        'minimum_size','No general minimum size limit.',
        'season_and_depth','Varies by Groundfish Management Area; check current CDFW summary and interactive map.',
        'gear','Only one line with no more than two hooks when greenlings of genus Hexagrammos are aboard or in possession.',
        'fillet_rule','Fillets must retain the entire skin.',
        'important','The RCG limit is shared with rockfish and cabezon.'
      ),
      'Title 14 CCR §§ 27.20, 27.25-27.50, 28.29; CDFW 2026 Groundfish Summary.',
      v_source_id,'verified',now()
    );
  end if;

  -- White Seabass.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='white-seabass' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','White Seabass','white-seabass','statewide',
      'Open year-round',
      '3 fish; only 1 fish south of Point Conception from March 15 through June 15',
      '3 fish; only 1 fish south of Point Conception from March 15 through June 15',
      '28 inches total length or 20.5 inches alternate length',
      'The reduced one-fish limit applies south of Point Conception between March 15 and June 15. Fillets must be at least 19 inches long and retain a one-inch square patch of silver skin.',
      jsonb_build_object(
        'season','Open year-round.',
        'daily_bag_limit','3 fish, except only 1 fish may be taken south of Point Conception from March 15 through June 15.',
        'possession_limit','Same as daily bag limit.',
        'minimum_size','28 inches total length or 20.5 inches alternate length.',
        'fillet_rule','Fillets at least 19 inches long with a one-inch square patch of silver skin.'
      ),
      'Title 14 CCR § 28.35 and § 27.65; CDFW 2026 Ocean Sport Fishing Regulations.',
      v_source_id,'verified',now()
    );
  end if;

  -- California Sheephead.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='california-sheephead' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','California Sheephead','california-sheephead','statewide',
      '2026: Open year-round for divers and shore-based anglers. Boat-based fishery open March 1 through December 31.',
      '2 fish',
      '2 fish',
      '12 inches total length',
      'Boat-based fishing is closed January 1 through February 28, 2026. Divers and shore-based anglers may fish year-round. Fillets must be at least 6.75 inches long and retain the entire skin.',
      jsonb_build_object(
        'season','2026: Divers and shore-based anglers: year-round. Boat-based anglers: March 1 through December 31.',
        'daily_bag_limit','2 fish.',
        'possession_limit','2 fish.',
        'minimum_size','12 inches total length.',
        'fillet_rule','Fillets at least 6.75 inches long with the entire skin attached.',
        'important','The season differs by fishing method. Confirm current CDFW updates before fishing.'
      ),
      'Title 14 CCR § 28.29 and § 27.65; CDFW 2026 Central and Southern Region summaries.',
      v_source_id,'verified',now()
    );
  end if;

  -- Pacific Sanddab: no individual daily bag limit; no limit species exception.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='pacific-sanddab' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Pacific Sanddab','pacific-sanddab','statewide',
      'Open year-round at all depths, subject to area closures and marine protected areas.',
      'No species-specific daily bag limit',
      'No species-specific possession limit',
      'No minimum size limit stated',
      'Pacific sanddab is listed among species with no individual daily bag limit. Marine protected areas and other location closures still apply.',
      jsonb_build_object(
        'season','Open year-round at all depths, subject to area closures and MPAs.',
        'daily_bag_limit','No species-specific daily bag limit.',
        'possession_limit','No species-specific possession limit.',
        'minimum_size','No minimum size limit stated.',
        'general_note','Species with no daily bag limit are not counted toward the general boat limit.'
      ),
      'Title 14 CCR §§ 27.56 and 27.60(b); CDFW 2026 Ocean Sport Fishing Regulations.',
      v_source_id,'verified',now()
    );
  end if;

  -- English Sole: default ocean finfish limits apply; no special species limit shown.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='english-sole' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','English Sole','english-sole','statewide',
      'No species-specific closed season listed; groundfish area restrictions and closures apply.',
      'Included in the general limit of 20 finfish combined, with no more than 10 of any one species',
      'Included in the general limit of 20 finfish combined, with no more than 10 of any one species',
      'No species-specific minimum size limit listed',
      'English sole is a groundfish species. Check current groundfish management area seasons, depth restrictions, marine protected areas and any in-season changes.',
      jsonb_build_object(
        'daily_bag_limit','General ocean finfish limit: 20 finfish combined, with no more than 10 of any one species.',
        'possession_limit','General ocean finfish limit: 20 finfish combined, with no more than 10 of any one species.',
        'minimum_size','No species-specific minimum size limit listed in the CDFW summary.',
        'season_and_depth','Groundfish management area seasons and depth restrictions apply; check current CDFW map.',
        'classification','English sole is included in the federally managed groundfish complex.'
      ),
      'Title 14 CCR §§ 27.20, 27.60 and 27.65; CDFW 2026 Ocean Sport Fishing Regulations.',
      v_source_id,'verified',now()
    );
  end if;

  -- California Barracuda.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='california-barracuda' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','California Barracuda','california-barracuda','statewide',
      'Open year-round',
      '10 fish, included within the general 20-finfish combined limit',
      '10 fish, included within the general 20-finfish combined limit',
      '28 inches total length',
      'Barracuda fillets must be at least 17 inches long and retain a one-inch square patch of silver skin.',
      jsonb_build_object(
        'season','Open year-round.',
        'daily_bag_limit','10 fish as part of the 20-finfish general bag limit.',
        'possession_limit','10 fish as part of the 20-finfish general bag limit.',
        'minimum_size','28 inches total length.',
        'fillet_rule','Fillets at least 17 inches long with a one-inch square patch of silver skin.'
      ),
      'Title 14 CCR §§ 27.60 and 28.25; CDFW 2026 Ocean Sport Fishing Regulations.',
      v_source_id,'verified',now()
    );
  end if;

  -- Leopard Shark.
  if not exists (select 1 from public.regulation_rules where state_code='CA' and species_key='leopard-shark' and rule_scope='statewide' and source_id=v_source_id) then
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'CA','Leopard Shark','leopard-shark','statewide',
      'Open year-round at all depths, except Groundfish Exclusion Areas where take and possession are prohibited.',
      '3 fish',
      '3 fish',
      '36 inches total length',
      'Take and possession are prohibited in Groundfish Exclusion Areas. In-season changes may occur. Check the current CDFW interactive map.',
      jsonb_build_object(
        'season','Open year-round at all depths except Groundfish Exclusion Areas.',
        'daily_bag_limit','3 fish.',
        'possession_limit','3 fish.',
        'minimum_size','36 inches total length.',
        'area_restrictions','No take or possession in Groundfish Exclusion Areas.',
        'in_season_changes','CDFW may change these rules in-season; check current regulations before fishing.'
      ),
      'Title 14 CCR § 28.56; CDFW 2026 Ocean Sport Fishing Regulations.',
      v_source_id,'verified',now()
    );
  end if;
end $$;