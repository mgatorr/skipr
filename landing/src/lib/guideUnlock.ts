/** localStorage key for MVP guide unlock (static Astro — no SSR cookie check). */
export const GUIDE_UNLOCK_KEY = 'skipr-guide-unlocked';
export const GUIDE_UNLOCK_VALUE = '1';

export function isGuideUnlocked(): boolean {
  try {
    return localStorage.getItem(GUIDE_UNLOCK_KEY) === GUIDE_UNLOCK_VALUE;
  } catch {
    return false;
  }
}

/** Persist unlock and reveal gated docs on this page. */
export function unlockGuide(): void {
  try {
    localStorage.setItem(GUIDE_UNLOCK_KEY, GUIDE_UNLOCK_VALUE);
  } catch {
    // private mode / blocked storage — still unlock this session via class
  }
  document.documentElement.classList.add('guide-unlocked');
  document.dispatchEvent(new CustomEvent('skipr:guide-unlocked'));
}

/** Apply persisted unlock on load (call from docs pages). */
export function applyGuideUnlockFromStorage(): void {
  if (isGuideUnlocked()) {
    document.documentElement.classList.add('guide-unlocked');
  }
}
