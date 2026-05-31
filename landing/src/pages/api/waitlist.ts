import type { APIRoute } from 'astro';
import { validateEmail } from '../../lib/validateEmail';
import { isHoneypotTripped } from '../../lib/honeypot';
import { addToWaitlist } from '../../lib/waitlist';
import { getWaitlistEnv } from '../../lib/env';

// On-demand: this is the ONLY server-rendered route. Keeps the Resend key
// server-side and out of the client bundle (Principle II).
export const prerender = false;

type Outcome = 'success' | 'invalid' | 'error';

async function readFields(request: Request): Promise<Record<string, string>> {
  const contentType = request.headers.get('content-type') ?? '';
  if (contentType.includes('application/json')) {
    const body = await request.json().catch(() => ({}));
    return body && typeof body === 'object' ? (body as Record<string, string>) : {};
  }
  const form = await request.formData();
  const out: Record<string, string> = {};
  for (const [k, v] of form.entries()) out[k] = typeof v === 'string' ? v : '';
  return out;
}

function wantsJson(request: Request): boolean {
  const accept = request.headers.get('accept') ?? '';
  const ct = request.headers.get('content-type') ?? '';
  return accept.includes('application/json') || ct.includes('application/json');
}

function respond(request: Request, outcome: Outcome, httpStatus: number): Response {
  if (wantsJson(request)) {
    const ok = outcome === 'success';
    return new Response(JSON.stringify({ ok, status: outcome }), {
      status: httpStatus,
      headers: { 'content-type': 'application/json' },
    });
  }
  // No-JS path: redirect to a hash state that the static page reveals with CSS
  // `:target` — works with JavaScript fully disabled, page stays static.
  return new Response(null, {
    status: 303,
    headers: { Location: `/#wl-${outcome}` },
  });
}

export const POST: APIRoute = async ({ request }) => {
  const fields = await readFields(request);

  // 1. Honeypot: silently succeed, store nothing.
  if (isHoneypotTripped(fields.company)) {
    return respond(request, 'success', 200);
  }

  // 2. Validate.
  const check = validateEmail(fields.email ?? '');
  if (!check.valid || !check.normalized) {
    return respond(request, 'invalid', 400);
  }

  // 3. Store in the owned audience.
  const env = getWaitlistEnv();
  const result = await addToWaitlist({
    email: check.normalized,
    source: fields.source,
    apiKey: env.apiKey,
    audienceId: env.audienceId,
    dryRun: env.dryRun,
  });

  if (result.status === 'error') {
    return respond(request, 'error', 502);
  }
  // 'created' and 'already' are both success (idempotent UX).
  return respond(request, 'success', 200);
};
