import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock supabase-js at the boundary so no network call happens.
const insertMock = vi.fn();
const fromMock = vi.fn(() => ({ insert: insertMock }));
vi.mock('@supabase/supabase-js', () => ({
  createClient: vi.fn(() => ({ from: fromMock })),
}));

import { addToWaitlist } from '../../src/lib/waitlist';

const base = {
  email: 'user@example.com',
  url: 'https://proj.supabase.co',
  anonKey: 'anon_test',
};

beforeEach(() => {
  insertMock.mockReset();
  fromMock.mockClear();
});

describe('addToWaitlist (Supabase)', () => {
  it('dry-run returns created without inserting', async () => {
    const r = await addToWaitlist({ ...base, dryRun: true });
    expect(r.status).toBe('created');
    expect(insertMock).not.toHaveBeenCalled();
  });

  it('returns error (never fake success) when credentials are missing', async () => {
    const r = await addToWaitlist({ email: base.email });
    expect(r.status).toBe('error');
    expect(insertMock).not.toHaveBeenCalled();
  });

  it('inserts into the waitlist table and returns created', async () => {
    insertMock.mockResolvedValue({ error: null });
    const r = await addToWaitlist({ ...base, source: 'landing' });
    expect(r.status).toBe('created');
    expect(fromMock).toHaveBeenCalledWith('waitlist');
    expect(insertMock).toHaveBeenCalledWith({ email: 'user@example.com', source: 'landing' });
  });

  it('maps a unique-violation (23505) to idempotent success', async () => {
    insertMock.mockResolvedValue({ error: { code: '23505', message: 'duplicate key value' } });
    const r = await addToWaitlist(base);
    expect(r.status).toBe('already');
  });

  it('maps other database errors to error', async () => {
    insertMock.mockResolvedValue({ error: { code: '23502', message: 'not null violation' } });
    const r = await addToWaitlist(base);
    expect(r.status).toBe('error');
  });

  it('maps a thrown/network failure to error', async () => {
    insertMock.mockRejectedValue(new Error('network down'));
    const r = await addToWaitlist(base);
    expect(r.status).toBe('error');
  });

  it('never returns the raw email in the result', async () => {
    insertMock.mockResolvedValue({ error: null });
    const r = await addToWaitlist(base);
    expect(JSON.stringify(r)).not.toContain('user@example.com');
  });
});
