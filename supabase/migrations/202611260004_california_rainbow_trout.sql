-- FishBound: California rainbow trout statewide guidance baseline
-- Source: official CDFW 2026 trout-season announcement.
-- This is general guidance only; seasons, size limits and exceptions vary by water.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = 'CDFW: Get Hooked — Trout Season 2026'
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
      'CDFW: Get Hooked — Trout Season 2026',
      'https://wildlife.ca.gov/News/Archive/get-hooked-trout-season-2026',
      2026,
      now(),
      'official',
      'verified',
      'Official CDFW announcement says most lakes, rivers and streams have a 5-trout daily limit and 10-trout possession limit. It explicitly warns that seasons, size limits, bag limits and gear restrictions differ by water and anglers should check the 2026 Freshwater Sport Fishing Regulations.'
    )
    returning id into v_source_id;
  end if;

  if not exists (
    select 1
    from public.regulation_rules
    where state_code = 'CA'
      and species_key = 'rainbow-trout'
      and rule_scope = 'statewide'
      and source_id = v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      minimum_length, special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Rainbow Trout',
      'rainbow-trout',
      'statewide',
      'Varies by waterbody; check local regulations',
      'Most lakes, rivers and streams: 5 trout per day; exceptions apply',
      'Most lakes, rivers and streams: 10 trout; exceptions apply',
      'Varies by waterbody',
      'CDFW states that seasons, daily bag limits, possession limits, minimum and maximum size limits, and gear restrictions can differ by water. Check the exact waterbody in the current CDFW Freshwater Sport Fishing Regulations before fishing.',
      jsonb_build_object(
        'coverage_note', 'General trout guidance for most California lakes, rivers and streams; not a guarantee for every water.',
        'daily_bag_limit_note', '5 trout per day on most waters; exceptions apply.',
        'possession_limit_note', '10 trout on most waters; exceptions apply.',
        'season_note', 'Opening and closing dates vary by waterbody.',
        'size_note', 'Minimum and maximum size limits vary by waterbody.'
      ),
      'CDFW 2026 trout-season announcement; see the current Freshwater Sport Fishing Regulations for water-specific rules.',
      v_source_id,
      'verified',
      now()
    );
  end if;
end $$;
