-- Tighten EXECUTE on the SECURITY DEFINER functions so PostgREST's anon role
-- cannot invoke them via /rest/v1/rpc.
--
-- Postgres grants EXECUTE to PUBLIC by default, so the anon key could call
-- these RPCs even though 0001 only *added* an authenticated grant. The key-mint
-- functions already fail closed on `auth.uid() is null`, but exposing them to
-- anon is needless surface; cf_handle_new_user is a signup trigger and should
-- never be RPC-callable at all.

revoke all on function public.cf_handle_new_user() from public, anon, authenticated;

revoke all on function public.cf_create_api_key(text) from public, anon;
revoke all on function public.cf_revoke_api_key(uuid) from public, anon;

-- Signed-in users keep the ability to mint / revoke their own keys.
grant execute on function public.cf_create_api_key(text) to authenticated;
grant execute on function public.cf_revoke_api_key(uuid) to authenticated;
