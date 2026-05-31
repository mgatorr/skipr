import { describe, it, expect } from 'vitest';
import { isHoneypotTripped } from '../../src/lib/honeypot';

describe('isHoneypotTripped', () => {
  it('is NOT tripped for empty / nullish values (real humans)', () => {
    expect(isHoneypotTripped('')).toBe(false);
    expect(isHoneypotTripped('   ')).toBe(false);
    expect(isHoneypotTripped(null)).toBe(false);
    expect(isHoneypotTripped(undefined)).toBe(false);
  });

  it('is tripped when the hidden field has any content (bots)', () => {
    expect(isHoneypotTripped('Acme Inc')).toBe(true);
    expect(isHoneypotTripped('x')).toBe(true);
  });
});
