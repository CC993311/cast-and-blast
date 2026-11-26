-- FishBound: California sturgeon regulations batch
-- Source: California Department of Fish and Wildlife, Sturgeon Report Card and Regulations.
-- White Sturgeon is catch-and-release only. Green Sturgeon take is prohibited.
-- Safe to run more than once.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = 'CDFW Sturgeon Report Card and Regulations (2026)'
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Department of Fish and Wildlife',
      'CDFW Sturgeon Report Card and Regulations (2026)',
      'https://wildlife.ca.gov/Conservation/Fishes/Sturgeon/Report-Card',
      2026,
      now(),
      'official',
      'verified',
      'Official CDFW sturgeon rules: White Sturgeon catch-and-release only; Green Sturgeon take prohibited. Check current area closures and report-card requirements before fishing.'
    )
    returning id into v_source_id;
  end if;

  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='white-sturgeon'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      gear_restrictions, special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'White Sturgeon',
      'white-sturgeon',
      'statewide',
      'Catch-and-release only; subject to area closures and other restrictions',
      'No harvest — all White Sturgeon must be released',
      'No sturgeon may be kept',
      'Only one single-point, single-shank, barbless hook may be used. No trolling, snagging, gaffing, or snaring. Hook-gap restrictions apply in some inland waters.',
      'A Sturgeon Fishing Report Card is required. White Sturgeon larger than 60 inches fork length must not be removed from the water. White Sturgeon must voluntarily take bait or lure inside the mouth. Area closures apply.',
      jsonb_build_object(
        'harvest','Catch-and-release only. No White Sturgeon may be kept.',
        'report_card','A Sturgeon Fishing Report Card is required for anyone fishing for White Sturgeon in California waters.',
        'handling','White Sturgeon larger than 60 inches fork length must not be removed from the water.',
        'hook_rule','Only one single-point, single-shank, barbless hook may be used.',
        'other_gear_rules','No trolling, snagging, gaffing, or snaring. Hook-gap restrictions apply in some inland waters.',
        'area_restrictions','Area closures apply. Consult current CDFW sturgeon regulations and maps before fishing.'
      ),
      'California Department of Fish and Wildlife, Sturgeon Report Card — Regulations at a glance.',
      v_source_id,
      'verified',
      now()
    );
  end if;

  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='green-sturgeon'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Green Sturgeon',
      'green-sturgeon',
      'statewide',
      'Take is prohibited year-round',
      'Zero — take is prohibited',
      'Zero — possession is prohibited',
      'Green Sturgeon are federally listed as threatened. Any Green Sturgeon caught must remain in the water and be released immediately. It is illegal to fish for Green Sturgeon in California.',
      jsonb_build_object(
        'take','Take is prohibited. It is illegal to fish for Green Sturgeon in California.',
        'handling','Any Green Sturgeon caught must be kept in the water and released immediately.',
        'daily_limit','Zero. No Green Sturgeon may be kept.',
        'possession','Possession is prohibited.'
      ),
      'California Department of Fish and Wildlife, Sturgeon Report Card — Species Restrictions.',
      v_source_id,
      'verified',
      now()
    );
  end if;
end $$;
