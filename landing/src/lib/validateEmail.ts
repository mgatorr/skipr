export interface EmailValidation {
  valid: boolean;
  /** Trimmed + lowercased address, present only when valid. */
  normalized?: string;
  error?: string;
}

// Pragmatic RFC-5322 subset: local@domain.tld with no spaces and a real TLD.
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const MAX_LENGTH = 254;

/**
 * Validate and normalize a waitlist email. Pure and dependency-free so it can be
 * unit-tested and reused on both the endpoint and (optionally) the client.
 */
export function validateEmail(input: string): EmailValidation {
  const normalized = (input ?? '').trim().toLowerCase();

  if (normalized.length === 0) {
    return { valid: false, error: 'Please enter your email.' };
  }
  if (normalized.length > MAX_LENGTH) {
    return { valid: false, error: 'That email is too long.' };
  }
  if (!EMAIL_RE.test(normalized)) {
    return { valid: false, error: 'Please enter a valid email address.' };
  }
  return { valid: true, normalized };
}
