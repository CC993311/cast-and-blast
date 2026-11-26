-- FishBound: California ocean species batch 3 (30 species)
-- Source: CDFW 2026 Ocean Sport Fishing Regulations, Title 14 CCR §§27.56 and 27.60.
-- General ocean rules apply only in California's Ocean/San Francisco Bay District.
-- Species with specific exceptions, in-season changes, or special regional rules must be checked
-- against the linked CDFW regulations before fishing. This batch intentionally does not invent
-- species-specific size limits or seasons.
do $$
declare
  v_source_id uuid;
  r record;
  v_unlimited text[] := array[
    'jacksmelt','northern-anchovy','pacific-mackerel','pacific-sardine',
    'queenfish','pacific-staghorn-sculpin'
  ];
  v_species jsonb := '[
    ["Jacksmelt","jacksmelt"],
    ["Northern Anchovy","northern-anchovy"],
    ["Pacific Mackerel","pacific-mackerel"],
    ["Pacific Sardine","pacific-sardine"],
    ["Queenfish","queenfish"],
    ["Pacific Staghorn Sculpin","pacific-staghorn-sculpin"],
    ["Opaleye","opaleye"],
    ["Black Perch","black-perch"],
    ["California Corbina","california-corbina"],
    ["Spotfin Croaker","spotfin-croaker"],
    ["Bluefish","bluefish"],
    ["Atlantic Mackerel","atlantic-mackerel"],
    ["Atlantic Cod","atlantic-cod"],
    ["Haddock","haddock"],
    ["Pollock","pollock"],
    ["Wahoo","wahoo"],
    ["Mahi-Mahi","mahi-mahi"],
    ["Pacific Tomcod","pacific-tomcod"],
    ["Albacore Tuna","albacore-tuna"],
    ["Yellowfin Tuna","yellowfin-tuna"],
    ["Atlantic Bluefin Tuna","atlantic-bluefin-tuna"],
    ["Pacific Bonito","pacific-bonito"],
    ["Yellowtail Amberjack","yellowtail-amberjack"],
    ["Swordfish","swordfish"],
    ["Blue Marlin","blue-marlin"],
    ["Striped Marlin","striped-marlin"],
    ["Sailfish","sailfish"],
    ["Pacific Herring","pacific-herring"],
    ["Sablefish","sablefish"],
    ["Pacific Cod","pacific-cod"]
  ]'::jsonb;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code='CA'
    and source_title='CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 3'
  order by created_at desc limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code,agency_name,source_title,source_url,regulation_year,
      checked_at,source_type,verification_status,notes
    ) values (
      'CA','California Department of Fish and Wildlife',
      'CDFW 2026 Ocean Sport Fishing Regulations — Species Batch 3',
      'https://wildlife.ca.gov/Fishing/Ocean/Regulations/Sport-Fishing/General-Ocean-Fishing-Regs',
      2026,now(),'official','verified',
      'General ocean finfish provisions, Title 14 CCR §§27.56 and 27.60, checked November 26, 2026. Species-specific regulations and in-season changes override these general provisions. Confirm exact species and location on the current CDFW regulations page.'
    ) returning id into v_source_id;
  end if;

  for r in select value->>0 as species_name, value->>1 as species_key from jsonb_array_elements(v_species)
  loop
    if not exists (
      select 1 from public.regulation_rules
      where state_code='CA' and species_key=r.species_key
        and rule_scope='statewide' and source_id=v_source_id
    ) then
      insert into public.regulation_rules (
        state_code,species_name,species_key,rule_scope,season_open,
        daily_bag_limit,possession_limit,minimum_length,
        special_restrictions,rule_details,official_reference,
        source_id,verification_status,verified_at
      ) values (
        'CA',r.species_name,r.species_key,'statewide',
        'General ocean rule: open year-round unless a species-specific season, area closure, or in-season restriction applies.',
        case when r.species_key = any(v_unlimited)
          then 'No daily bag limit under Title 14 CCR §27.60(b).'
          else 'General limit: 20 finfish combined across all species, with no more than 10 of this species per person, unless a species-specific rule applies.'
        end,
        case when r.species_key = any(v_unlimited)
          then 'No daily bag limit under Title 14 CCR §27.60(b).'
          else 'General limit: 20 finfish combined across all species, with no more than 10 of this species per person, unless a species-specific rule applies.'
        end,
        'No general minimum size under §27.56; species-specific size limits may override.',
        'These are general ocean-district rules, not freshwater rules. Some species in this batch have additional federal, species-specific, seasonal, or regional restrictions. Check the current CDFW species page and location-based rules before fishing.',
        jsonb_build_object(
          'regulation_basis','California Title 14 CCR §§27.56 and 27.60.',
          'daily_bag_limit',case when r.species_key = any(v_unlimited)
            then 'No daily bag limit under §27.60(b).'
            else '20 finfish combined; no more than 10 of any one species, unless a specific rule applies.'
          end,
          'season_and_size','General rule: no closed season or minimum size unless a specific regulation provides otherwise.',
          'important','This record summarizes the general ocean rule only. Species-specific regulations, federal rules, marine protected areas, and in-season changes take precedence. Confirm the exact species and fishing location with CDFW.',
          'official_check','https://wildlife.ca.gov/Fishing/Ocean/Regulations/Sport-Fishing/General-Ocean-Fishing-Regs'
        ),
        'Title 14 CCR §§27.56 and 27.60; CDFW 2026 Ocean Sport Fishing Regulations.',
        v_source_id,'verified',now()
      );
    end if;
  end loop;
end $$;