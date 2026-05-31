/**
 * Server-side environment access. These values are read only inside on-demand
 * endpoints and never imported into client code (Principle II — keys stay
 * server-side and out of the browser bundle).
 *
 * The waitlist stores leads in our own Supabase Postgres table. We use the
 * **anon** key together with a row-level-security policy that allows INSERT only
 * (no select/update/delete), so even if the key leaked it could not read or
 * delete the list.
 */
export interface WaitlistEnv {
  url: string | undefined;
  anonKey: string | undefined;
  /** When true, skip the real Supabase insert and treat submissions as success. */
  dryRun: boolean;
}

export function getWaitlistEnv(): WaitlistEnv {
  return {
    url: process.env.SUPABASE_URL,
    anonKey: process.env.SUPABASE_ANON_KEY,
    dryRun: process.env.WAITLIST_DRY_RUN === '1',
  };
}
