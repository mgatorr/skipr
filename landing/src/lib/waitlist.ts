import { Resend } from 'resend';

export type WaitlistStatus = 'created' | 'already' | 'error';

export interface WaitlistResult {
  status: WaitlistStatus;
}

export interface AddToWaitlistOptions {
  /** Already-validated, normalized email. */
  email: string;
  /** Optional attribution tag (e.g. "landing", "article:<slug>"). */
  source?: string;
  apiKey?: string;
  audienceId?: string;
  /** When true (or when credentials are missing), skip the real Resend call. */
  dryRun?: boolean;
}

/**
 * Add a contact to the owned Resend Audience. Idempotent: an "already exists"
 * response is treated as success. The raw email is never returned or logged.
 */
export async function addToWaitlist(opts: AddToWaitlistOptions): Promise<WaitlistResult> {
  const { email, source, apiKey, audienceId, dryRun } = opts;

  // Dev/e2e/local without credentials: behave as success without a network call.
  if (dryRun || !apiKey || !audienceId) {
    return { status: 'created' };
  }

  try {
    const resend = new Resend(apiKey);
    // `source` is kept for future attribution; Resend's contact has no native
    // source field, so we don't send it (and we never log the email either).
    void source;
    const { error } = await resend.contacts.create({
      audienceId,
      email,
      unsubscribed: false,
    });

    if (error) {
      if (/already\s*exists|already\s*in/i.test(error.message ?? '')) {
        return { status: 'already' };
      }
      return { status: 'error' };
    }
    return { status: 'created' };
  } catch {
    // Never surface provider internals or the email; just signal a retryable error.
    return { status: 'error' };
  }
}
