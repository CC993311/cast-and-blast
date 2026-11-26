-- FishBound Alaska regulations — Batch 2
-- 2026 Southeast Alaska regional rules only.
-- Alaska regulations are region-, water-, residency-, and sometimes emergency-order-specific.
-- These records are explicitly scoped to Southeast Alaska and must not be treated as statewide Alaska rules.
-- Species without a directly supported entry in this source are intentionally not assigned guessed limits.
-- Official source: Alaska Department of Fish and Game, 2026 Southeast Sport Fishing Regulations Summary Book.
-- https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southeast/2026se_sfregs_general_freshwater_saltwater.pdf
-- Emergency Orders: https://www.adfg.alaska.gov/sf/EONR

do $$
declare
  v_source_id uuid;
  r record;
  v_salmon jsonb := '[
    ["Chinook Salmon","chinook-salmon"],
    ["Coho Salmon","coho-salmon"],
    ["Chum Salmon","chum-salmon"],
    ["Pink Salmon","pink-salmon"],
    ["Sockeye Salmon","sockeye-salmon"]
  ]'::jsonb;
begin
  insert into public.regulation_sources (
    state_code, agency_name, source_title, source_url, regulation_year,
    checked_at, source_type, verification_status, notes
  ) values (
    'AK',
    'Alaska Department of Fish and Game',
    '2026 Southeast Alaska Sport Fishing Regulations Summary Book',
    'https://www.adfg.alaska.gov/static/regulations/fishregulations/PDFs/southeast/2026se_sfregs_general_freshwater_saltwater.pdf',
    2026, now(), 'official', 'verified',
    'Regional summary only. Rules differ by management area, water type, residency, and emergency order. Check current ADF&G emergency orders and the exact drainage or marine management area. Checked November 26, 2026.'
  ) returning id into v_source_id;

  -- Freshwater salmon: region-wide rules, with king salmon closed outside named exceptions.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, season_open, daily_bag_limit,
    possession_limit, minimum_length, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  values (
    'AK','Chinook Salmon','chinook-salmon','region','Southeast Alaska freshwater (outside Yakutat)',
    'southeast-alaska-freshwater','freshwater',
    'Closed unless a listed management-area exception or emergency order opens the fishery.',
    'No general retention limit while closed.',
    'No general retention limit while closed.',
    null,
    'Closed to king salmon fishing in Southeast Alaska freshwater outside the Yakutat Area, except listed Juneau/Glacier Bay, Sitka, Petersburg/Wrangell, and Ketchikan management-area exceptions. Yakutat has separate resident/nonresident limits.',
    jsonb_build_object(
      'region','Southeast Alaska freshwater outside Yakutat.',
      'season','Closed to king salmon fishing except management-area exceptions.',
      'exceptions','Juneau/Glacier Bay, Sitka, Petersburg/Wrangell, and Ketchikan Management Areas have separate rules.',
      'yakutat','Yakutat Area has separate rules: residents 1 per day/1 in possession at 20 inches or longer; under 20 inches 10 per day/10 in possession. Nonresidents have annual limit of 1 fish at 20 inches or longer; under 20 inches 10 per day/10 in possession.',
      'important','Check the exact management area and current emergency orders.'
    ),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, King Salmon.',
    v_source_id,'verified',now()
  );

  for r in
    select value->>0 as species_name, value->>1 as species_key
    from jsonb_array_elements(v_salmon)
    where value->>1 <> 'chinook-salmon'
  loop
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,waterbody_name,
      waterbody_key,waterbody_type,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'AK',r.species_name,r.species_key,'region',
      'Southeast Alaska freshwater outside Yakutat','southeast-alaska-freshwater','freshwater',
      'Open year-round unless a special regulation or emergency order applies.',
      case when r.species_key='coho-salmon'
        then '6 per day in Southeast Alaska at 16 inches or longer; fish under 16 inches are included in a 10-per-day combined limit with chum, coho, pink, and sockeye.'
        else '6 per day of this species at 16 inches or longer; fish under 16 inches are included in a 10-per-day combined limit with chum, coho, pink, and sockeye.'
      end,
      case when r.species_key='coho-salmon'
        then '12 in possession at 16 inches or longer; under-16-inch salmon are included in a 10-fish combined possession limit.'
        else '12 in possession of this species at 16 inches or longer; under-16-inch salmon are included in a 10-fish combined possession limit.'
      end,
      '16 inches for the species-specific limit; under-16-inch fish have a separate combined limit.',
      'Area-specific exceptions and emergency orders may change these limits.',
      jsonb_build_object(
        'region','Southeast Alaska freshwater outside Yakutat.',
        'size_16_inches_or_longer','6 of each species per day and 12 of each species in possession.',
        'under_16_inches','10 per day and 10 in possession combined for chum, coho, pink, and sockeye salmon, including kokanee.',
        'important','Special management-area rules and emergency orders override this general summary.'
      ),
      '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Salmon.',
      v_source_id,'verified',now()
    );
  end loop;

  -- Kokanee is expressly included with sockeye in the under-16-inch combination and the 16-inch sockeye group.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,
    waterbody_key,waterbody_type,season_open,daily_bag_limit,
    possession_limit,special_restrictions,rule_details,official_reference,
    source_id,verification_status,verified_at
  ) values (
    'AK','Kokanee Salmon','kokanee-salmon','region',
    'Southeast Alaska freshwater','southeast-alaska-freshwater','freshwater',
    'Open year-round unless a special regulation or emergency order applies.',
    'Included with sockeye salmon: 6 per day at 16 inches or longer; under-16-inch fish are part of the 10-per-day combined salmon limit.',
    '12 in possession at 16 inches or longer; under-16-inch fish are part of the 10-fish combined possession limit.',
    'Kokanee is expressly included in the sockeye salmon group for these summary limits.',
    jsonb_build_object('16_inches_or_longer','Included with sockeye salmon: 6 per day and 12 in possession.','under_16_inches','Included in the 10 per day / 10 in possession combined limit for chum, coho, pink, and sockeye salmon, including kokanee.','important','Check special area rules and emergency orders.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Salmon.',
    v_source_id,'verified',now()
  );

  -- Trout and char rules in freshwater.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,
    waterbody_key,waterbody_type,daily_bag_limit,possession_limit,
    minimum_length,maximum_length,special_restrictions,rule_details,
    official_reference,source_id,verification_status,verified_at
  ) values
  (
    'AK','Rainbow Trout','rainbow-trout','region','Southeast Alaska freshwater',
    'southeast-alaska-freshwater','freshwater',
    '2 per day combined with cutthroat trout','2 combined',
    '11 inches minimum','22 inches maximum',
    'Rainbow and cutthroat trout share one combined limit.',
    jsonb_build_object('combined_species','Rainbow Trout and Cutthroat Trout.','daily_limit','2 per day combined.','possession_limit','2 combined.','size_limit','11-inch minimum and 22-inch maximum.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Cutthroat and Rainbow Trout.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Steelhead','steelhead','region','Southeast Alaska freshwater',
    'southeast-alaska-freshwater','freshwater',
    '1 per day at 36 inches or longer','2 in possession',
    '36 inches minimum',null,
    'Annual limit of 2 fish; harvest record required.',
    jsonb_build_object('daily_limit','1 per day at 36 inches or longer.','possession_limit','2.','annual_limit','2 fish.','harvest_record','Required.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Steelhead Trout.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Dolly Varden','dolly-varden','region','Southeast Alaska freshwater',
    'southeast-alaska-freshwater','freshwater',
    '10 per day','10 in possession',null,null,
    'No size limit stated in the regional general rule; special waters may differ.',
    jsonb_build_object('daily_limit','10 per day.','possession_limit','10.','size_limit','No size limit in the regional general rule.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Dolly Varden.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Brook Trout','brook-trout','region','Southeast Alaska freshwater',
    'southeast-alaska-freshwater','freshwater',
    '10 per day','10 in possession',null,null,
    'No size limit stated in the regional general rule; special waters may differ.',
    jsonb_build_object('daily_limit','10 per day.','possession_limit','10.','size_limit','No size limit in the regional general rule.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Freshwater, Brook Trout.',
    v_source_id,'verified',now()
  );

  -- Saltwater salmon and steelhead rules. King salmon limits are emergency-order driven.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,
    waterbody_key,waterbody_type,season_open,daily_bag_limit,
    possession_limit,minimum_length,special_restrictions,rule_details,
    official_reference,source_id,verification_status,verified_at
  ) values
  (
    'AK','Chinook Salmon','chinook-salmon','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    'Limits for 2026 are established by emergency order under the Southeast Alaska King Salmon Management Plan.',
    'Check current emergency order; no fixed general number in the summary.',
    'Check current emergency order.',
    '28 inches minimum; fish under 28 inches may not be retained.',
    'Nonresidents require a harvest record. Charter operators and crew may not keep king salmon while clients are aboard.',
    jsonb_build_object('minimum_size','28 inches.','under_28_inches','Retention prohibited.','bag_and_possession','Established annually by emergency order.','nonresident','Harvest record required.','charter_crew','Charter operators and crew may not retain king salmon while clients are aboard.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, King Salmon.',
    v_source_id,'verified',now()
  );

  for r in
    select value->>0 as species_name, value->>1 as species_key
    from jsonb_array_elements(v_salmon)
    where value->>1 <> 'chinook-salmon'
  loop
    insert into public.regulation_rules (
      state_code,species_name,species_key,rule_scope,waterbody_name,
      waterbody_key,waterbody_type,season_open,daily_bag_limit,
      possession_limit,minimum_length,special_restrictions,rule_details,
      official_reference,source_id,verification_status,verified_at
    ) values (
      'AK',r.species_name,r.species_key,'region',
      'Southeast Alaska saltwater','southeast-alaska-saltwater','saltwater',
      'Open year-round unless a special regulation or emergency order applies.',
      '6 per day of each species at 16 inches or longer; under-16-inch salmon are included in a 10-per-day combined limit.',
      '12 in possession of each species at 16 inches or longer; under-16-inch salmon are included in a 10-fish combined possession limit.',
      '16 inches for the species-specific limit; under-16-inch fish have a separate combined limit.',
      'Management-area rules and emergency orders may modify these limits.',
      jsonb_build_object('16_inches_or_longer','6 of each species per day and 12 of each species in possession.','under_16_inches','10 per day and 10 in possession combined for chum, coho, pink, and sockeye salmon.','important','Check the current management-area rules and emergency orders.'),
      '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Salmon.',
      v_source_id,'verified',now()
    );
  end loop;

  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,
    waterbody_key,waterbody_type,daily_bag_limit,possession_limit,
    minimum_length,maximum_length,special_restrictions,rule_details,
    official_reference,source_id,verification_status,verified_at
  ) values
  (
    'AK','Steelhead','steelhead','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    '1 per day at 36 inches or longer','2 in possession',
    '36 inches minimum',null,
    'Annual limit of 2 fish; harvest record required.',
    jsonb_build_object('daily_limit','1 per day at 36 inches or longer.','possession_limit','2.','annual_limit','2 fish.','harvest_record','Required.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Steelhead Trout.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Rainbow Trout','rainbow-trout','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    '2 per day combined with cutthroat trout','2 combined',
    '11 inches minimum','22 inches maximum',
    'Rainbow and cutthroat trout share one combined limit.',
    jsonb_build_object('combined_species','Rainbow Trout and Cutthroat Trout.','daily_limit','2 per day combined.','possession_limit','2 combined.','size_limit','11-inch minimum and 22-inch maximum.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Cutthroat and Rainbow Trout.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Dolly Varden','dolly-varden','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    '10 per day','10 in possession',null,null,
    'No size limit stated in the regional general rule; special waters may differ.',
    jsonb_build_object('daily_limit','10 per day.','possession_limit','10.','size_limit','No size limit in the regional general rule.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Dolly Varden.',
    v_source_id,'verified',now()
  );

  -- Marine species with species-specific general regional provisions.
  insert into public.regulation_rules (
    state_code,species_name,species_key,rule_scope,waterbody_name,
    waterbody_key,waterbody_type,season_open,daily_bag_limit,
    possession_limit,minimum_length,special_restrictions,rule_details,
    official_reference,source_id,verification_status,verified_at
  ) values
  (
    'AK','Lingcod','lingcod','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    'May 16-November 30 for Alaska residents; area-specific seasonal openings apply.',
    'Residents: 1 per day. Nonresidents: 1 per day.',
    'Residents: 2. Nonresidents: 1.',
    null,
    'Nonresidents outside Yakutat have an annual limit of 2: one fish of any size and one fish 55 inches or longer. Yakutat has a separate nonresident annual rule. Charter operators and crew may not retain lingcod while clients are aboard.',
    jsonb_build_object('resident_season','May 16-November 30.','resident_limit','1 per day, 2 in possession, no size limit.','nonresident_limit','1 per day, 1 in possession.','nonresident_annual','Outside Yakutat: 2 annually, one of any size and one 55 inches or longer; harvest record required.','area_seasons','Northern Southeast May 16-June 14 and September 1-November 30; Central Southeast Outside May 16-June 30 and September 1-November 30; Southern Southeast Outer Coast May 16-July 31 and September 1-November 30; Southern Southeast Inside Waters May 16-November 30; Yakutat May 16-November 30.','charter_crew','Charter operators and crew may not retain lingcod while clients are aboard.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Lingcod.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Pacific Halibut','pacific-halibut','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    'February 1-December 31; closed January 1-31.',
    'Unguided anglers: 2 per day.',
    'Unguided anglers: 4.',
    null,
    'Federal rules govern halibut. Guided/charter bag, possession, size, landing, and in-season rules must be checked with NOAA. Proxy fishing is prohibited. Special onboard filleting requirements apply.',
    jsonb_build_object('season','February 1-December 31; closed January 1-31.','unguided_limit','2 per day, 4 in possession, no size limit in this state summary.','federal_management','Pacific halibut is federally managed under international treaty.','guided_anglers','Consult current federal rules for guided anglers.','proxy_fishing','Not allowed.','filleting','Federal/state onboard filleting and skin-identification requirements apply.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Halibut.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Sablefish','sablefish','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    'Open year-round unless a special regulation or emergency order applies.',
    'Residents: 6 per day. Nonresidents: 4 per day.',
    'Residents: 6. Nonresidents: 4.',
    null,
    'Nonresidents have an 8-fish annual limit and must keep a harvest record.',
    jsonb_build_object('resident_limit','6 per day, 6 in possession, no size limit.','nonresident_limit','4 per day, 4 in possession, no size limit.','nonresident_annual','8 fish; harvest record required.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, Sablefish.',
    v_source_id,'verified',now()
  ),
  (
    'AK','Rockfish','rockfish','region','Southeast Alaska saltwater',
    'southeast-alaska-saltwater','saltwater',
    'Open year-round unless a species-group or management-area closure applies.',
    'Pelagic: 3 per day. Slope: 1 per day. Demersal shelf: residents 1 per day; nonresidents 1 annually during July 1-August 25.',
    'Pelagic: 6. Slope: 2. Demersal shelf: residents 2; nonresidents 1.',
    null,
    'All sport fishing vessels must carry a functional deepwater release device. Released rockfish must be returned to depth of capture or 100 feet, whichever is shallower. Species-group definitions and area exceptions apply.',
    jsonb_build_object('pelagic_group','3 per day, 6 in possession; no size limit, except Sitka Area (CSEO).','slope_group','1 per day, 2 in possession; no size limit.','demersal_shelf_residents','1 per day, 2 in possession; no size limit.','demersal_shelf_nonresidents','July 1-August 25: 1 per day, 1 in possession, annual limit 1; harvest record required.','release_device','All vessels must carry a functional deepwater release device. Non-retained rockfish must be released at depth caught or 100 feet, whichever is shallower.','species_groups','Pelagic, slope, and demersal shelf groups have different species membership.'),
    '2026 Southeast Sport Fishing Regulations Summary Book, General Regulations — Saltwater, All Rockfish.',
    v_source_id,'verified',now()
  );

end $$;
