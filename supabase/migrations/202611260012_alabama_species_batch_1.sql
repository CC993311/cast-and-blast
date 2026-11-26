-- FishBound Alabama regulations — Batch 1
-- Covers the species currently listed in guides.html (116 species).
-- Only species with an explicit rule in the linked Alabama agency sources are inserted as verified.
-- Species not represented below remain without a verified rule; no limits are inferred.
-- Sources checked November 26, 2026:
-- Freshwater: https://www.outdooralabama.com/fishing/freshwater-fishing-creel-and-size-limits
-- Saltwater: https://www.outdooralabama.com/fishing/saltwater-recreational-size-creel-limits
-- Official regulation index: https://www.outdooralabama.com/hunting/alabama-hunting-and-fishing-regulations

do $$
declare
  v_fresh_source uuid;
  v_salt_source uuid;
begin
  insert into public.regulation_sources (
    state_code, agency_name, source_title, source_url, regulation_year,
    checked_at, source_type, verification_status, notes
  ) values (
    'AL',
    'Alabama Department of Conservation and Natural Resources',
    'Outdoor Alabama — Freshwater Fishing Creel and Size Limits',
    'https://www.outdooralabama.com/fishing/freshwater-fishing-creel-and-size-limits',
    2026, now(), 'official', 'verified',
    'Official agency page linking the Alabama Hunting and Fishing Digest and listing statewide freshwater creel and size rules plus named-water exceptions. Checked November 26, 2026. Confirm the latest digest and water-specific exceptions before fishing.'
  )
  returning id into v_fresh_source;

  insert into public.regulation_sources (
    state_code, agency_name, source_title, source_url, regulation_year,
    checked_at, source_type, verification_status, notes
  ) values (
    'AL',
    'Alabama Department of Conservation and Natural Resources — Marine Resources Division',
    'Outdoor Alabama — Saltwater Recreational Size and Creel Limits',
    'https://www.outdooralabama.com/fishing/saltwater-recreational-size-creel-limits',
    2026, now(), 'official', 'verified',
    'Official agency page for Alabama state-water saltwater size and daily creel limits. Species with federal season or area controls must also be checked against current federal notices. Checked November 26, 2026.'
  )
  returning id into v_salt_source;

  -- Freshwater black bass aggregate: 10 black bass per day; no more than 5 smallmouth.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_type,
    daily_bag_limit, possession_limit, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  select 'AL', x.species_name, x.species_key, 'statewide', 'freshwater',
    '10 black bass combined per day',
    '10 black bass combined',
    x.special_restrictions,
    jsonb_build_object(
      'rule_group','Black Bass aggregate',
      'daily_limit','10 black bass combined per day.',
      'smallmouth_limit','No more than 5 of the 10 may be smallmouth bass.',
      'waterbody_exceptions','Special rules apply on named waters, including Guntersville, Harris, Lake Jackson, Lewis Smith, Pickwick, and Walter F. George (Lake Eufaula). Shoal bass possession is prohibited in Little Uchee, Uchee, Osanippa, Halawakee, and Wacoochee creeks.',
      'important','This is an aggregate limit shared with other black bass species, not a separate limit for each species.'
    ),
    'Alabama freshwater creel and size limits; Black Bass entry and Size Limits section.',
    v_fresh_source, 'verified', now()
  from (values
    ('Largemouth Bass','largemouth-bass','Check named-water slot and minimum-size exceptions.'),
    ('Smallmouth Bass','smallmouth-bass','No more than 5 smallmouth bass may be included in the 10-fish black bass aggregate; named-water size exceptions apply.'),
    ('Spotted Bass','spotted-bass','Check named-water size exceptions; Alabama bass/spotted bass naming varies by drainage.'),
    ('Shoal Bass','shoal-bass','Possession is prohibited in Little Uchee, Uchee, Osanippa, Halawakee, and Wacoochee creeks.'),
    ('Redeye Bass','redeye-bass','Alabama black bass aggregate includes the regional redeye bass group; identify the drainage-specific species correctly.')
  ) as x(species_name,species_key,special_restrictions)
  where not exists (
    select 1 from public.regulation_rules rr
    where rr.state_code='AL' and rr.species_key=x.species_key
      and rr.source_id=v_fresh_source and rr.rule_scope='statewide'
  );

  -- Other freshwater species with explicit entries in the agency table.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_type,
    daily_bag_limit, possession_limit, minimum_length, special_restrictions,
    rule_details, official_reference, source_id, verification_status, verified_at
  )
  select 'AL', x.species_name, x.species_key, 'statewide', 'freshwater',
    x.daily_bag_limit, x.possession_limit, x.minimum_length, x.special_restrictions,
    x.rule_details, x.official_reference, v_fresh_source, 'verified', now()
  from (values
    (
      'Walleye','walleye','2 per day','2',
      null::text,
      'Take or attempted take is prohibited in several named waters; any walleye caught there must be released immediately with least possible harm.',
      jsonb_build_object('daily_limit','2 per day.','closed_waters','Sweetwater Lake; White Plains Lake and upstream Shoal Creek; Lake Mitchell and listed tributaries; Walnut Creek; Hatchet Creek; Weogufka Creek; Mulberry Fork and Sipsey Fork and listed tributaries.','release_rule','Immediately release any walleye taken in those closed waters with least possible harm.'),
      'Alabama freshwater creel and size limits; Walleye entry.'
    ),
    (
      'White Bass','white-bass','15 per day','15',
      null::text,
      'Special aggregate rules apply on the Chattahoochee River, its impoundments, and tributaries.',
      jsonb_build_object('daily_limit','15 per day.','special_waters','Chattahoochee River and its impoundments and tributaries have a combined limit with striped bass and hybrids; see reciprocal-water rules.'),
      'Alabama freshwater creel and size limits; White Bass entry and Size Limits section.'
    ),
    (
      'Striped Bass','striped-bass','15 combined per day with hybrids and combinations','15 combined',
      null::text,
      'No more than 5 of the 15 combined fish may exceed 22 inches total length. Water-specific exceptions apply, including Chattahoochee River waters, Lewis Smith, Yates, Thurlow, and Lake Martin. Saltwater state-water rules are listed separately.',
      jsonb_build_object('daily_limit','15 striped bass, hybrids, and combinations combined.','over_22_inches','No more than 5 of the 15 may exceed 22 inches total length.','waterbody_exceptions','Chattahoochee River and its impoundments and tributaries; Lewis Smith, Yates, and Thurlow reservoirs; Lake Martin. Additional water-specific restrictions apply.'),
      'Alabama freshwater creel and size limits; Striped Bass and Hybrids entry.'
    ),
    (
      'Hybrid Striped Bass','hybrid-striped-bass','15 combined per day with striped bass and combinations','15 combined',
      null::text,
      'No more than 5 of the 15 combined fish may exceed 22 inches total length. Water-specific exceptions apply.',
      jsonb_build_object('daily_limit','15 striped bass, hybrids, and combinations combined.','over_22_inches','No more than 5 of the 15 may exceed 22 inches total length.','waterbody_exceptions','Chattahoochee River and its impoundments and tributaries; Lewis Smith, Yates, and Thurlow reservoirs; Lake Martin.'),
      'Alabama freshwater creel and size limits; Striped Bass and Hybrids entry.'
    ),
    (
      'Black Crappie','black-crappie','30 combined crappie per day','30 combined',
      '9 inches total length generally',
      'Nine-inch minimum has named-water and small-impoundment exceptions.',
      jsonb_build_object('daily_limit','30 crappie combined per day.','minimum_size','9 inches total length generally.','exceptions','Impoundments under 500 surface acres; reciprocal Chattahoochee waters; Bear Creek Reservoir; Lake Jackson at Florala; Weiss Reservoir (special exception applies).'),
      'Alabama freshwater creel and size limits; Crappie entry.'
    ),
    (
      'White Crappie','white-crappie','30 combined crappie per day','30 combined',
      '9 inches total length generally',
      'Nine-inch minimum has named-water and small-impoundment exceptions.',
      jsonb_build_object('daily_limit','30 crappie combined per day.','minimum_size','9 inches total length generally.','exceptions','Impoundments under 500 surface acres; reciprocal Chattahoochee waters; Bear Creek Reservoir; Lake Jackson at Florala; Weiss Reservoir (special exception applies).'),
      'Alabama freshwater creel and size limits; Crappie entry.'
    ),
    (
      'Yellow Perch','yellow-perch','No limit listed','No limit listed',
      null::text,
      'The statewide agency table lists no daily creel limit.',
      jsonb_build_object('daily_limit','No limit listed in the statewide freshwater table.','important','Water-specific rules may still apply.'),
      'Alabama freshwater creel and size limits; Yellow Perch entry.'
    ),
    (
      'Channel Catfish','channel-catfish','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Blue Catfish','blue-catfish','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the named river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Flathead Catfish','flathead-catfish','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the named river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Black Bullhead','black-bullhead','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the named river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Brown Bullhead','brown-bullhead','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the named river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Yellow Bullhead','yellow-bullhead','Under 34 inches: no limit; over 34 inches: 1 per day','Same as daily creel limit',
      null::text,
      'The over-34-inch rule does not apply in the named river basins. Live catfish 34 inches or greater may not be transported beyond Alabama.',
      jsonb_build_object('daily_limit','Under 34 inches: no limit. Over 34 inches: 1 per day.','basin_exceptions','Perdido, Conecuh, Blackwater, Yellow, Choctawhatchee, Chipola, and Chattahoochee river basins.','transport','Live catfish 34 inches or greater may not be transported beyond Alabama.','threshold_note','The agency page distinguishes under 34 inches from over 34 inches; check the current code for fish measuring exactly 34 inches.'),
      'Alabama freshwater creel and size limits; Catfish entry.'
    ),
    (
      'Rainbow Trout','rainbow-trout','5 per day','5',
      null::text,
      'On Sipsey Fork from Lewis Smith Dam downstream to the Mulberry Fork confluence, no more than two rods may be used and trout may not be culled from the creel.',
      jsonb_build_object('daily_limit','5 per day.','Sipsey_Fork','Maximum two rods; no culling from the creel on the specified Sipsey Fork reach.'),
      'Alabama freshwater creel and size limits; Rainbow Trout entry.'
    ),
    (
      'White Sturgeon','white-sturgeon','Catch and release only','0 retained',
      null::text,
      'All sturgeon must be immediately returned to the water with the least possible harm.',
      jsonb_build_object('retention','Prohibited; immediately return all sturgeon to the water with least possible harm.'),
      'Alabama freshwater creel and size limits; Sturgeon entry.'
    ),
    (
      'Green Sturgeon','green-sturgeon','Catch and release only','0 retained',
      null::text,
      'All sturgeon must be immediately returned to the water with the least possible harm.',
      jsonb_build_object('retention','Prohibited; immediately return all sturgeon to the water with least possible harm.'),
      'Alabama freshwater creel and size limits; Sturgeon entry.'
    ),
    (
      'Paddlefish','paddlefish','Catch and release only','0 retained',
      null::text,
      'All paddlefish must be immediately returned to the water with the least possible harm.',
      jsonb_build_object('retention','Prohibited; immediately return all paddlefish to the water with least possible harm.'),
      'Alabama freshwater creel and size limits; Paddlefish entry.'
    )
  ) as x(species_name,species_key,daily_bag_limit,possession_limit,minimum_length,special_restrictions,rule_details,official_reference)
  where not exists (
    select 1 from public.regulation_rules rr
    where rr.state_code='AL' and rr.species_key=x.species_key
      and rr.source_id=v_fresh_source and rr.rule_scope='statewide'
  );

  -- Saltwater state-water rules. These are separate from freshwater records.
  insert into public.regulation_rules (
    state_code, species_name, species_key, rule_scope, waterbody_name,
    waterbody_key, waterbody_type, daily_bag_limit, possession_limit,
    minimum_length, maximum_length, special_restrictions, rule_details,
    official_reference, source_id, verification_status, verified_at
  )
  select 'AL', x.species_name, x.species_key, 'region',
    'Alabama state saltwater waters', 'alabama-state-saltwater-waters', 'saltwater',
    x.daily_bag_limit, x.possession_limit, x.minimum_length, x.maximum_length,
    x.special_restrictions, x.rule_details, x.official_reference,
    v_salt_source, 'verified', now()
  from (values
    (
      'Red Drum','red-drum','3 per person per day','3 per person',
      '16 inches total length','26 inches total length',
      'Slot limit: fish must be 16–26 inches total length.',
      jsonb_build_object('daily_limit','3 per person.','slot_limit','16–26 inches total length.'),
      'Outdoor Alabama Saltwater Recreational Size and Creel Limits; Red Drum entry.'
    ),
    (
      'Yellowfin Tuna','yellowfin-tuna','3 per person per day','3 per person',
      '27 inches curved fork length','No maximum listed',
      'Federal and in-season requirements may apply; check current NOAA notices and federal rules.',
      jsonb_build_object('daily_limit','3 per person.','minimum_size','27 inches curved fork length.','federal_rules','Federal and in-season requirements may apply.'),
      'Outdoor Alabama Saltwater Recreational Size and Creel Limits; Yellowfin Tuna entry.'
    ),
    (
      'Striped Bass','striped-bass','2 per person per day in the listed saltwater state-water fishery','2 per person',
      '16 inches total length',null::text,
      'This saltwater entry is distinct from the freshwater striped bass and hybrid aggregate rule. The agency page notes that only two striped bass are allowed within Marine Resources Division jurisdiction.',
      jsonb_build_object('daily_limit','2 per person.','minimum_size','16 inches total length.','jurisdiction_note','Only two striped bass are allowed within Marine Resources Division jurisdiction.'),
      'Outdoor Alabama Saltwater Recreational Size and Creel Limits; Striped Bass entry and jurisdiction note.'
    )
  ) as x(species_name,species_key,daily_bag_limit,possession_limit,minimum_length,maximum_length,special_restrictions,rule_details,official_reference)
  where not exists (
    select 1 from public.regulation_rules rr
    where rr.state_code='AL' and rr.species_key=x.species_key
      and rr.source_id=v_salt_source and rr.rule_scope='region'
      and rr.waterbody_key='alabama-state-saltwater-waters'
  );

end $$;
