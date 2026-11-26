-- FishBound regulations read permissions
-- Run in Supabase SQL Editor for project ubnmhqxitiigsctbsmqy.
-- RLS policies still control which rows are visible.
grant usage on schema public to anon, authenticated;
grant select on table public.regulation_states to anon, authenticated;
grant select on table public.regulation_sources to anon, authenticated;
grant select on table public.regulation_rules to anon, authenticated;
