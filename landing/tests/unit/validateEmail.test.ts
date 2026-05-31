import { describe, it, expect } from 'vitest';
import { validateEmail } from '../../src/lib/validateEmail';

describe('validateEmail', () => {
  it('accepts a normal email and normalizes case + whitespace', () => {
    const r = validateEmail('  User@Example.COM ');
    expect(r.valid).toBe(true);
    expect(r.normalized).toBe('user@example.com');
  });

  it('accepts plus-addressing', () => {
    expect(validateEmail('a.b+tag@sub.example.io').valid).toBe(true);
  });

  it('rejects empty / whitespace-only', () => {
    expect(validateEmail('').valid).toBe(false);
    expect(validateEmail('   ').valid).toBe(false);
  });

  it('rejects strings without a proper @domain', () => {
    expect(validateEmail('not-an-email').valid).toBe(false);
    expect(validateEmail('foo@').valid).toBe(false);
    expect(validateEmail('@bar.com').valid).toBe(false);
    expect(validateEmail('foo@bar').valid).toBe(false);
  });

  it('rejects overlong addresses (> 254 chars)', () => {
    const long = 'a'.repeat(250) + '@x.com';
    expect(validateEmail(long).valid).toBe(false);
  });

  it('returns an error message when invalid', () => {
    const r = validateEmail('nope');
    expect(r.valid).toBe(false);
    expect(r.error).toBeTruthy();
  });
});
