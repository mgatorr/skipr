/**
 * Honeypot spam check. The form renders a visually-hidden field (e.g. `company`)
 * that humans never see and never fill. Any non-empty value means a bot.
 * Pure so it can be unit-tested.
 */
export function isHoneypotTripped(value: string | null | undefined): boolean {
  return typeof value === 'string' && value.trim().length > 0;
}
