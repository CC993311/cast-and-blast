-- FishBound: California freshwater species batch 3
-- Source: CDFW 2026 Freshwater Sport Fishing Regulations, updated July 10, 2026.
-- Sections 5.37, 5.50 and 5.51. Water-specific and district exceptions remain applicable.
-- Safe to run more than once.

do $$
declare
  v_source_id uuid;
begin
  select id into v_source_id
  from public.regulation_sources
  where state_code = 'CA'
    and source_title = 'CDFW 2026 Freshwater Sport Fishing Regulations — Species Batch 3'
  order by created_at desc
  limit 1;

  if v_source_id is null then
    insert into public.regulation_sources (
      state_code, agency_name, source_title, source_url, regulation_year,
      checked_at, source_type, verification_status, notes
    ) values (
      'CA',
      'California Department of Fish and Wildlife',
      'CDFW 2026 Freshwater Sport Fishing Regulations — Species Batch 3',
      'https://nrm.dfg.ca.gov/FileHandler.ashx?DocumentID=209090',
      2026,
      now(),
      'official',
      'verified',
      'Official 2026 California Freshwater Sport Fishing Regulations booklet, updated July 10, 2026. Species provisions in Title 14 CCR §§ 5.37, 5.50 and 5.51.'
    )
    returning id into v_source_id;
  end if;

  -- Grass Carp: prohibited from take and possession except for the
  -- specifically described Sacramento River drainage exception.
  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='grass-carp'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Grass Carp',
      'grass-carp',
      'statewide',
      'No take or possession at any time, except for the specific Siskiyou and Shasta County exception',
      'Zero, except under the specific Siskiyou and Shasta County exception',
      'Possession prohibited except under the specific Siskiyou and Shasta County exception',
      'In any waters within the Sacramento River drainage above and including Lake Shasta in Siskiyou and Shasta Counties, any grass carp taken must be killed immediately by removing the head and retained by the angler. The angler must notify CDFW as soon as possible and no later than 24 hours after taking the fish.',
      jsonb_build_object(
        'general_rule','No grass carp may be taken or possessed at any time. Any grass carp inadvertently taken must be immediately returned unharmed to the water.',
        'specific_exception','In Siskiyou and Shasta Counties, in any waters within the Sacramento River drainage above and including Lake Shasta, all grass carp taken must be killed immediately by removing the head and retained by the angler.',
        'notification','For the stated Siskiyou and Shasta County exception, notify CDFW at 1-530-225-2278 as soon as possible and no later than 24 hours after taking and possessing a grass carp.',
        'scope_note','This is a narrow geographic exception. Confirm the exact waterbody and current CDFW instructions before relying on it.'
      ),
      'California Code of Regulations, Title 14, § 5.37(a)-(b), 2026 Freshwater Sport Fishing Regulations.',
      v_source_id,
      'verified',
      now()
    );
  end if;

  -- Mountain Whitefish: only open when trout may be taken in that water;
  -- five-fish limit.
  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='mountain-whitefish'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Mountain Whitefish',
      'mountain-whitefish',
      'statewide',
      'May be taken only in waters and during periods when trout may be taken',
      '5 fish',
      '5 fish',
      'Mountain whitefish may not be taken in any water except when trout may be taken in that water. Check the exact waterbody for trout season and special restrictions.',
      jsonb_build_object(
        'season','No mountain whitefish may be taken in any water except when trout may be taken in that water.',
        'daily_limit','5 fish',
        'possession_limit','5 fish',
        'water_specific_rules','The applicable trout season and any special waterbody restrictions determine when mountain whitefish may be taken.'
      ),
      'California Code of Regulations, Title 14, § 5.50, 2026 Freshwater Sport Fishing Regulations.',
      v_source_id,
      'verified',
      now()
    );
  end if;

  -- Northern Pike: all fish taken must be killed, retained and reported.
  if not exists (
    select 1 from public.regulation_rules
    where state_code='CA' and species_key='northern-pike'
      and rule_scope='statewide' and source_id=v_source_id
  ) then
    insert into public.regulation_rules (
      state_code, species_name, species_key, rule_scope,
      season_open, daily_bag_limit, possession_limit,
      special_restrictions, rule_details,
      official_reference, source_id, verification_status, verified_at
    ) values (
      'CA',
      'Northern Pike',
      'northern-pike',
      'statewide',
      'Any northern pike taken is subject to mandatory removal and reporting requirements',
      'No numeric bag limit stated in § 5.51; mandatory kill, retain and report rules apply',
      'No numeric possession limit stated in § 5.51; fish taken must be retained for CDFW',
      'No northern pike, dead or alive, may be released into any water. All northern pike taken must be killed immediately by removing the head and retained by the angler. Notify CDFW as soon as possible and no later than 24 hours after taking the fish. Maintain the head and body refrigerated or frozen whenever possible until CDFW collects it.',
      jsonb_build_object(
        'release_rule','No northern pike, dead or alive, may be released into any water at any time.',
        'required_action','All northern pike taken must be killed immediately by removing the head and retained by the angler.',
        'notification','Notify CDFW through CalTIP at 1-888-DFW-CALTIP as soon as possible and no later than 24 hours after taking and possessing a northern pike.',
        'storage','Keep the head and body refrigerated or frozen whenever possible until CDFW collects the fish.',
        'limit_note','Section 5.51 states mandatory handling, retention and reporting requirements; it does not state a numeric daily bag or possession limit.'
      ),
      'California Code of Regulations, Title 14, § 5.51, 2026 Freshwater Sport Fishing Regulations.',
      v_source_id,
      'verified',
      now()
    );
  end if;
end $$;