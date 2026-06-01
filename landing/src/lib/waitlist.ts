import { neon } from '@neondatabase/serverless';

export type WaitlistStatus = 'created' | 'already' | 'error';

export interface WaitlistResult {
  status: WaitlistStatus;
}

export interface AddToWaitlistOptions {
  /** Already-validated, normalized email. */
  email: string;
  /** Optional attribution tag (e.g. "landing", "article:<slug>"). */
  source?: string;
  /** Neon Postgres connection string (secret — server-side only). */
  connectionString?: string;
  /** Explicit bypass for dev/e2e — only this flag skips the real insert. */
  dryRun?: boolean;
}

/**
 * Add a lead to our owned Neon `waitlist` table. Idempotent: `ON CONFLICT DO
 * NOTHING` means a repeat email is treated as success (`already`). The raw email
 * is never returned or logged.
 *
 * Note: only an explicit `dryRun` bypasses the insert. A missing connection
 * string in a real run returns `error` (never a fake success), so leads are
 * never lost silently (SC-002). The query is parameterized (no SQL injection).
 */
export async function addToWaitlist(opts: AddToWaitlistOptions): Promise<WaitlistResult> {
  const { email, source, connectionString, dryRun } = opts;

  if (dryRun) {
    return { status: 'created' };
  }
  if (!connectionString) {
    return { status: 'error' };
  }

  try {
    const sql = neon(connectionString);
    // RETURNING id is present only on a fresh insert; ON CONFLICT yields 0 rows.
    const rows = await sql`
      insert into waitlist (email, source)
      values (${email}, ${source ?? null})
      on conflict (email) do nothing
      returning id
    `;
    return { status: rows.length > 0 ? 'created' : 'already' };
  } catch {
    // Never surface internals or the email; just signal a retryable error.
    return { status: 'error' };
  }
}
