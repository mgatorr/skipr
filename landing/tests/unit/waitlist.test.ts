import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock the Neon driver at the boundary so no network call happens. `neon()`
// returns a tagged-template function; we capture it as `sqlMock`. vi.hoisted
// makes these available to the hoisted vi.mock factory.
const { sqlMock, neonMock } = vi.hoisted(() => {
  const sqlMock = vi.fn();
  const neonMock = vi.fn(() => sqlMock);
  return { sqlMock, neonMock };
});
vi.mock('@neondatabase/serverless', () => ({ neon: neonMock }));

import { addToWaitlist } from '../../src/lib/waitlist';

const base = {
  email: 'user@example.com',
  connectionString: 'postgresql://user:pass@ep-test.neon.tech/db?sslmode=require',
};

beforeEach(() => {
  sqlMock.mockReset();
  neonMock.mockClear();
});

describe('addToWaitlist (Neon)', () => {
  it('dry-run returns created without inserting', async () => {
    const r = await addToWaitlist({ ...base, dryRun: true });
    expect(r.status).toBe('created');
    expect(sqlMock).not.toHaveBeenCalled();
    expect(neonMock).not.toHaveBeenCalled();
  });

  it('returns error (never fake success) when the connection string is missing', async () => {
    const r = await addToWaitlist({ email: base.email });
    expect(r.status).toBe('error');
    expect(sqlMock).not.toHaveBeenCalled();
  });

  it('inserts into the waitlist table and returns created', async () => {
    sqlMock.mockResolvedValue([{ id: 'uuid-1' }]);
    const r = await addToWaitlist({ ...base, source: 'landing' });
    expect(r.status).toBe('created');
    expect(neonMock).toHaveBeenCalledWith(base.connectionString);
    // Tagged template: sqlMock(stringsArray, ...values)
    const [strings, ...values] = sqlMock.mock.calls[0];
    expect(strings.join('').toLowerCase()).toMatch(/insert into\s+waitlist/);
    expect(values).toEqual(['user@example.com', 'landing']);
  });

  it('maps a conflict (0 rows returned) to idempotent success', async () => {
    sqlMock.mockResolvedValue([]); // ON CONFLICT DO NOTHING → no row
    const r = await addToWaitlist(base);
    expect(r.status).toBe('already');
  });

  it('passes null source when none is provided', async () => {
    sqlMock.mockResolvedValue([{ id: 'uuid-2' }]);
    await addToWaitlist(base);
    const [, , source] = sqlMock.mock.calls[0];
    expect(source).toBeNull();
  });

  it('maps a thrown/network failure to error', async () => {
    sqlMock.mockRejectedValue(new Error('network down'));
    const r = await addToWaitlist(base);
    expect(r.status).toBe('error');
  });

  it('never returns the raw email in the result', async () => {
    sqlMock.mockResolvedValue([{ id: 'uuid-3' }]);
    const r = await addToWaitlist(base);
    expect(JSON.stringify(r)).not.toContain('user@example.com');
  });
});
