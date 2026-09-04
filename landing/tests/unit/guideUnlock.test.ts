import { describe, it, expect } from 'vitest';
import { GUIDE_UNLOCK_KEY, GUIDE_UNLOCK_VALUE } from '../../src/lib/guideUnlock';

describe('guideUnlock', () => {
  it('exposes a stable storage key', () => {
    expect(GUIDE_UNLOCK_KEY).toBe('skipr-guide-unlocked');
    expect(GUIDE_UNLOCK_VALUE).toBe('1');
  });
});
