/**
 * Server-side environment access. These values are read only inside on-demand
 * endpoints and never imported into client code (Principle II — secrets stay
 * server-side and out of the browser bundle).
 */
export interface WaitlistEnv {
  apiKey: string | undefined;
  audienceId: string | undefined;
  /** When true, skip the real Resend call and treat submissions as success. */
  dryRun: boolean;
}

export function getWaitlistEnv(): WaitlistEnv {
  return {
    apiKey: process.env.RESEND_API_KEY,
    audienceId: process.env.RESEND_AUDIENCE_ID,
    dryRun: process.env.WAITLIST_DRY_RUN === '1',
  };
}
