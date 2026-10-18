-- =====================================================================
-- isitiyaGarden: security tests for NFR02 (authentication),
-- NFR03 (authorization) and NFR10 (information accuracy).
--
-- HOW TO RUN: paste the WHOLE file into the Supabase SQL Editor and click
-- Run. The last query shows one row per test. Compare "expected" with
-- "actual"; the "result" column says PASS or FAIL.
--
-- It pretends to be different users by switching the database role and
-- the login token, exactly as the real app's requests arrive. It uses the
-- three demo accounts from the seed data:
--   1111... farmer Nomsa    2222... farmer Thando    3333... buyer Ayanda
--
-- It runs inside a transaction that is never committed, so nothing it
-- does is saved. Run the single line  rollback;  afterwards to be sure.
-- =====================================================================
begin;

create temp table results (test text, expected text, actual text);
grant all on results to public;

-- Runs one statement as the current role and reports what happened.
create function pg_temp.attempt(stmt text) returns text language plpgsql as $$
declare n bigint;
begin
  execute stmt;
  get diagnostics n = row_count;
  return 'allowed, rows affected: ' || n;
exception when others then
  return 'BLOCKED';
end $$;

-- Counts the rows a query is allowed to see as the current role.
create function pg_temp.visible(q text) returns text language plpgsql as $$
declare n bigint;
begin
  execute 'select count(*) from (' || q || ') t' into n;
  return 'rows visible: ' || n;
exception when others then
  return 'ERROR';
end $$;

-- ---------- Logged in as the BUYER (Ayanda) ---------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"33333333-3333-3333-3333-333333333333","role":"authenticated"}', true);

insert into results select 'S01 Buyer edits a farmer''s listing',
  'allowed, rows affected: 0',
  pg_temp.attempt($q$update produce_listings set quantity = 999
    where farmer_id = '11111111-1111-1111-1111-111111111111'$q$);

insert into results select 'S02 Buyer deletes a farmer''s listing',
  'allowed, rows affected: 0',
  pg_temp.attempt($q$delete from produce_listings
    where farmer_id = '11111111-1111-1111-1111-111111111111'$q$);

insert into results select 'S03 Buyer creates a listing',
  'BLOCKED',
  pg_temp.attempt($q$insert into produce_listings
    (farmer_id, name, category_id, quantity, unit_id, price, community_id)
    values ('33333333-3333-3333-3333-333333333333','Hack',1,1,1,10,1)$q$);

insert into results select 'S04 Buyer edits another user''s profile',
  'allowed, rows affected: 0',
  pg_temp.attempt($q$update profiles set full_name = 'Hacked'
    where id = '11111111-1111-1111-1111-111111111111'$q$);

insert into results select 'S05 Buyer changes their own role',
  'BLOCKED',
  pg_temp.attempt($q$update profiles set role = 'farmer'
    where id = '33333333-3333-3333-3333-333333333333'$q$);

insert into results select 'S06 Buyer sees an UNAVAILABLE listing (NFR10)',
  'rows visible: 0',
  pg_temp.visible($q$select 1 from produce_listings where name = 'Green peppers'$q$);

insert into results select 'S07 Buyer sees only their own buyer profile',
  'rows visible: 1',
  pg_temp.visible($q$select 1 from buyer_profiles$q$);

reset role;

-- ---------- Logged in as FARMER Thando --------------------------------
set local role authenticated;
select set_config('request.jwt.claims',
  '{"sub":"22222222-2222-2222-2222-222222222222","role":"authenticated"}', true);

insert into results select 'S08 Farmer edits another farmer''s listing',
  'allowed, rows affected: 0',
  pg_temp.attempt($q$update produce_listings set quantity = 999
    where farmer_id = '11111111-1111-1111-1111-111111111111'$q$);

insert into results select 'S09 Farmer sees their OWN unavailable listing',
  'rows visible: 1',
  pg_temp.visible($q$select 1 from produce_listings
    where farmer_id = '22222222-2222-2222-2222-222222222222'
      and name = 'Green peppers'$q$);

insert into results select 'S10 Farmer reads buyer profiles',
  'rows visible: 0',
  pg_temp.visible($q$select 1 from buyer_profiles$q$);

reset role;

-- ---------- NOT logged in (anonymous) ---------------------------------
set local role anon;

insert into results select 'S11 Logged-out user reads listings (NFR02)',
  'rows visible: 0',
  pg_temp.visible($q$select 1 from active_listings$q$);

insert into results select 'S12 Logged-out user reads profiles (NFR02)',
  'rows visible: 0',
  pg_temp.visible($q$select 1 from profiles$q$);

reset role;

-- ---------- Report -----------------------------------------------------
select test,
       expected,
       actual,
       case when expected = actual then 'PASS' else 'FAIL' end as result
from results
order by test;
