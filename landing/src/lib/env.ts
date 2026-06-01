/**
 * Server-side environment access. These values are read only inside on-demand
 * endpoints and never imported into client code (Principle II — secrets stay
 * server-side and out of the browser bundle).
 *
 * The waitlist stores leads in our own Neon Postgres database, provisioned
 * through the Vercel Marketplace. The Neon connection string is a secret: it is
 * used only in the server-rendered `/api/waitlist` endpoint and never shipped to
 * the client. Vercel's Neon integration injects `DATABASE_URL` (and
 * `POSTGRES_URL`) automatically across Production/Preview/Development.
 */
export interface WaitlistEnv {
  /** Neon Postgres connection string (pooled). Secret — server-side only. */
  connectionString: string | undefined;
  /** When true, skip the real insert and treat submissions as success. */
  dryRun: boolean;
}

export function getWaitlistEnv(): WaitlistEnv {
  return {
    connectionString: process.env.DATABASE_URL ?? process.env.POSTGRES_URL,
    dryRun: process.env.WAITLIST_DRY_RUN === '1',
  };
}
