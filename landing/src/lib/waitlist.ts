import { createClient } from '@supabase/supabase-js';

export type WaitlistStatus = 'created' | 'already' | 'error';

export interface WaitlistResult {
  status: WaitlistStatus;
}

export interface AddToWaitlistOptions {
  /** Already-validated, normalized email. */
  email: string;
  /** Optional attribution tag (e.g. "landing", "article:<slug>"). */
  source?: string;
  url?: string;
  anonKey?: string;
  /** Explicit bypass for dev/e2e — only this flag skips the real insert. */
  dryRun?: boolean;
}

const UNIQUE_VIOLATION = '23505';

/**
 * Add a lead to our owned Supabase `waitlist` table. Idempotent: a unique-email
 * violation is treated as success. The raw email is never returned or logged.
 *
 * Note: only an explicit `dryRun` bypasses the insert. Missing credentials in a
 * real run return `error` (never a fake success), so leads are never lost
 * silently (SC-002).
 */
export async function addToWaitlist(opts: AddToWaitlistOptions): Promise<WaitlistResult> {
  const { email, source, url, anonKey, dryRun } = opts;

  if (dryRun) {
    return { status: 'created' };
  }
  if (!url || !anonKey) {
    return { status: 'error' };
  }

  try {
    const supabase = createClient(url, anonKey, { auth: { persistSession: false } });
    // No `.select()` — the RLS policy is INSERT-only, so we don't read back.
    const { error } = await supabase.from('waitlist').insert({ email, source: source ?? null });

    if (error) {
      if (
        error.code === UNIQUE_VIOLATION ||
        /duplicate key|already exists/i.test(error.message ?? '')
      ) {
        return { status: 'already' };
      }
      return { status: 'error' };
    }
    return { status: 'created' };
  } catch {
    // Never surface internals or the email; just signal a retryable error.
    return { status: 'error' };
  }
}
