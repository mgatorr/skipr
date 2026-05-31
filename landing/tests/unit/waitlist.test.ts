import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock the Resend SDK at the boundary so no network call happens.
const createMock = vi.fn();
vi.mock('resend', () => ({
  Resend: vi.fn().mockImplementation(() => ({
    contacts: { create: createMock },
  })),
}));

import { addToWaitlist } from '../../src/lib/waitlist';

const base = { email: 'user@example.com', apiKey: 're_test', audienceId: 'aud_1' };

beforeEach(() => {
  createMock.mockReset();
});

describe('addToWaitlist', () => {
  it('dry-run returns created without calling Resend', async () => {
    const r = await addToWaitlist({ ...base, dryRun: true });
    expect(r.status).toBe('created');
    expect(createMock).not.toHaveBeenCalled();
  });

  it('returns created on a successful Resend call with the right payload', async () => {
    createMock.mockResolvedValue({ data: { id: 'c_1' }, error: null });
    const r = await addToWaitlist({ ...base, source: 'landing' });
    expect(r.status).toBe('created');
    expect(createMock).toHaveBeenCalledWith(
      expect.objectContaining({
        audienceId: 'aud_1',
        email: 'user@example.com',
        unsubscribed: false,
      }),
    );
  });

  it('maps an "already exists" error to idempotent success', async () => {
    createMock.mockResolvedValue({ data: null, error: { message: 'Contact already exists' } });
    const r = await addToWaitlist(base);
    expect(r.status).toBe('already');
  });

  it('maps other provider errors to error', async () => {
    createMock.mockResolvedValue({ data: null, error: { message: 'Internal server error' } });
    const r = await addToWaitlist(base);
    expect(r.status).toBe('error');
  });

  it('maps a thrown/network failure to error', async () => {
    createMock.mockRejectedValue(new Error('network down'));
    const r = await addToWaitlist(base);
    expect(r.status).toBe('error');
  });

  it('never returns the raw email in the result', async () => {
    createMock.mockResolvedValue({ data: { id: 'c_1' }, error: null });
    const r = await addToWaitlist(base);
    expect(JSON.stringify(r)).not.toContain('user@example.com');
  });
});
