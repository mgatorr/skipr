// i18n strings (copy from the Claude Design "field guide" zine). English primary, Spanish secondary.
export const defaultLocale = 'en' as const;
export const locales = ['en', 'es'] as const;
export type Locale = (typeof locales)[number];

export const ui = {
  en: {
    'deck.left': 'Est. 2026 · Independent software · A field guide for founders',
    'nav.anti': 'the black box',
    'nav.how': 'the method',
    'nav.cta': 'Join the waitlist',

    'hero.stamp': 'Coming soon',
    'hero.vol': 'Vol. 01 — for founders who outgrew no-code',
    'hero.h1':
      'Build <span class="own">real</span> software with AI —<br>and <em>actually</em> own it.',
    'hero.dek':
      'skipr is a friendly desktop app that turns your idea into a real, deployed product — <b>your code, your GitHub repo, your deploy</b>. All the power of Claude Code, none of the <span class="struck">terminal</span>.',
    'hero.note':
      'You already shipped a toy on Lovable or Base44. This is the real thing — the one you own.',
    'hero.email.l': 'Your email',
    'hero.email': 'you@yourstartup.com',
    'hero.btn': 'Join the waitlist',
    'hero.foot': '✱ Not affiliated with Anthropic · skipr.dev',

    'spec.cap': 'Fig. 1 — the hand-off',
    'spec.tag': 'they keep the box / you get the keys',
    'spec.crate': 'sealed',
    'spec.key': 'the keys',
    'spec.folder': 'owner: you',

    'slug.0': 'real code',
    'slug.1': 'your repo',
    'slug.2': 'you learn',
    'slug.3': 'no lock-in',
    'slug.x0': 'no sealed boxes',
    'slug.x1': 'no terminal',
    'slug.x2': 'no black box',
    'slug.x3': 'no rented apps',

    'anti.num': 'Plate 01 — the anti-black-box',
    'anti.title':
      'No-code handed you a fish.<br>We hand you <em>the rod, the boat,</em> and <span class="o">the keys.</span>',
    'anti.lead':
      "Lovable, Base44 and friends ship you something that runs — beautifully, until you need to change it, move it, or actually own it. That's the black box. Here is the difference, on the table:",

    'a.id': 'Exhibit A',
    'a.tag': 'no-code platforms',
    'a.h': 'The sealed box',
    'a.sub': 'Looks finished. Try to open it.',
    'a.l1': 'Rented — never owned',
    'a.l2': "Code you can't see or take with you",
    'a.l3': 'Locked to their platform',
    'a.l4': 'You stay dependent on them',
    'a.l5': 'Hits a ceiling, fast',
    'a.seal': 'property of the platform — do not open',

    'div.lbl': 'the upgrade',

    'b.id': 'Exhibit B',
    'b.tag': 'skipr',
    'b.h': 'Your <span class="b">repo</span>',
    'b.sub': 'Open it. Read it. It has your name on it.',
    'b.l1': 'Real code, on your machine',
    'b.l2': 'Your GitHub repo, your commits',
    'b.l3': 'Deploy anywhere you want',
    'b.l4': 'You learn while you build',
    'b.l5': 'No ceiling, ever',
    'b.branch': '⎇ main',
    'b.owner': 'owner: ',
    'b.ownerb': 'you ✓',
    'b.t1': 'src/',
    'b.t2': 'App.tsx',
    'b.t3': 'components/',
    'b.t4': 'supabase/',
    'b.t5': 'README.md',
    'b.key': 'keys: handed over',

    'creed.mk': 'the whole point',
    creed:
      'We don\'t hand you a fish. We teach you to fish — and let you <span class="o">skip the pain of the rod.</span> You graduate from <span class="struck">no-code</span> owning software you understand.',

    'how.num': 'Plate 02 — the method',
    'how.title': 'From idea to <em>owned,</em><br>in five moves.',
    'how.lead':
      'Not a feature list — a guided route. Every step happens inside skipr, in plain language, with no terminal anywhere in sight.',
    'm1.h': 'Set up',
    'm1.p':
      "Install skipr, sign in to Claude Code. No terminal, no config files, no YAML. You're ready in about two minutes.",
    'm1.tool': 'skipr + Claude Code',
    'm1.when': '~2 minutes',
    'm2.h': 'Spec it',
    'm2.p':
      'Describe what you want in plain words. skipr shapes it into a real product spec you can read, edit and approve before a line is written.',
    'm2.tool': 'skipr',
    'm2.when': 'in your words',
    'm3.h': 'Build it',
    'm3.p':
      "Claude Code writes real, readable code — and shows you what it's doing and why. You build understanding, not just output.",
    'm3.tool': 'Claude Code',
    'm3.when': 'you watch & learn',
    'm4.h': 'Own it',
    'm4.p':
      'Everything lands in your own GitHub repo. Your commits, your history — yours to keep, fork, or hand to a developer later.',
    'm4.tool': 'GitHub',
    'm4.when': 'yours, forever',
    'm5.h': 'Ship it',
    'm5.p':
      'Deploy to Vercel with a Supabase backend. A real, live app on your own domain — owned end to end.',
    'm5.tool': 'Vercel + Supabase',
    'm5.when': 'live & owned',
    'how.foot': 'The whole stack, in your name:',

    'stack.h': 'Your stack, <em>your call.</em>',
    'stack.tag': 'no lock-in, by design',
    'stack.lead':
      "skipr starts with GitHub, Vercel and Supabase — mature, boring-in-the-best-way tools that simply work. They're sensible defaults, not handcuffs.",
    'stack.c1': 'Version control',
    'stack.c2': 'Deploy',
    'stack.c3': 'Backend & data',
    'stack.or': 'or your choice',
    'stack.soon': 'more soon',
    'stack.foot':
      'More first-class platforms land over time — and <span class="o">you</span> decide which, by your own criteria or by talking it through with Claude as you build.',

    'foot.cta': 'Stop renting your software.<br>Start <em>owning</em> it.',
    'foot.email.l': 'Your email',
    'foot.email': 'you@yourstartup.com',
    'foot.btn': 'Join the waitlist',
    'foot.disc':
      'skipr is an independent product and is not affiliated with, endorsed by, or sponsored by Anthropic. “Claude” and “Claude Code” are products of Anthropic. GitHub, Supabase and Vercel are trademarks of their respective owners.',
    'foot.coming': 'Coming soon — skipr.dev',
    'foot.copy': '© 2026 skipr · made for people who want the keys',
    'foot.notes': 'Field notes →',

    'wl.ok': "You're on the list ✓",
    'wl.invalid': 'Please enter a valid email.',
    'wl.error': 'Something went wrong — try again in a moment.',
    'a11y.skip': 'Skip to content',
    'locale.switch': 'ES',
  },
  es: {
    'deck.left': 'Desde 2026 · Software independiente · Una guía de campo para fundadores',
    'nav.anti': 'la caja negra',
    'nav.how': 'el método',
    'nav.cta': 'Únete a la lista',

    'hero.stamp': 'Muy pronto',
    'hero.vol': 'Vol. 01 — para fundadores que superaron el no-code',
    'hero.h1':
      'Crea software <span class="own">real</span> con IA —<br>y que sea <em>de verdad</em> tuyo.',
    'hero.dek':
      'skipr es una app de escritorio amable que convierte tu idea en un producto real y desplegado — <b>tu código, tu repo de GitHub, tu deploy</b>. Todo el poder de Claude Code, sin la <span class="struck">terminal</span>.',
    'hero.note':
      'Ya lanzaste algo de juguete en Lovable o Base44. Esto es lo de verdad — lo que es tuyo.',
    'hero.email.l': 'Tu email',
    'hero.email': 'tu@tustartup.com',
    'hero.btn': 'Únete a la lista',
    'hero.foot': '✱ No afiliado con Anthropic · skipr.dev',

    'spec.cap': 'Fig. 1 — la entrega',
    'spec.tag': 'ellos se quedan la caja / tú recibes las llaves',
    'spec.crate': 'sellado',
    'spec.key': 'las llaves',
    'spec.folder': 'dueño: tú',

    'slug.0': 'código real',
    'slug.1': 'tu repo',
    'slug.2': 'aprendes',
    'slug.3': 'sin lock-in',
    'slug.x0': 'sin cajas selladas',
    'slug.x1': 'sin terminal',
    'slug.x2': 'sin caja negra',
    'slug.x3': 'sin apps alquiladas',

    'anti.num': 'Lámina 01 — la anti-caja-negra',
    'anti.title':
      'El no-code te dio un pez.<br>Nosotros te damos <em>la caña, el bote</em> y <span class="o">las llaves.</span>',
    'anti.lead':
      'Lovable, Base44 y compañía te entregan algo que funciona — precioso, hasta que necesitas cambiarlo, moverlo o ser su dueño. Eso es la caja negra. Aquí está la diferencia, sobre la mesa:',

    'a.id': 'Pieza A',
    'a.tag': 'plataformas no-code',
    'a.h': 'La caja sellada',
    'a.sub': 'Parece terminada. Intenta abrirla.',
    'a.l1': 'Alquilado — nunca tuyo',
    'a.l2': 'Código que no ves ni te llevas',
    'a.l3': 'Atado a su plataforma',
    'a.l4': 'Sigues dependiendo de ellos',
    'a.l5': 'Llega a un techo, rápido',
    'a.seal': 'propiedad de la plataforma — no abrir',

    'div.lbl': 'la mejora',

    'b.id': 'Pieza B',
    'b.tag': 'skipr',
    'b.h': 'Tu <span class="b">repo</span>',
    'b.sub': 'Ábrelo. Léelo. Lleva tu nombre.',
    'b.l1': 'Código real, en tu máquina',
    'b.l2': 'Tu repo de GitHub, tus commits',
    'b.l3': 'Despliega donde quieras',
    'b.l4': 'Aprendes mientras construyes',
    'b.l5': 'Sin techo, nunca',
    'b.branch': '⎇ main',
    'b.owner': 'dueño: ',
    'b.ownerb': 'tú ✓',
    'b.t1': 'src/',
    'b.t2': 'App.tsx',
    'b.t3': 'components/',
    'b.t4': 'supabase/',
    'b.t5': 'README.md',
    'b.key': 'llaves: entregadas',

    'creed.mk': 'el punto central',
    creed:
      'No te damos un pez. Te enseñamos a pescar — y te dejamos <span class="o">saltarte el dolor de la caña.</span> Te gradúas del <span class="struck">no-code</span> con software que entiendes y es tuyo.',

    'how.num': 'Lámina 02 — el método',
    'how.title': 'De la idea a <em>ser tuyo,</em><br>en cinco pasos.',
    'how.lead':
      'No una lista de funciones — una ruta guiada. Cada paso ocurre dentro de skipr, en lenguaje claro, sin una terminal a la vista.',
    'm1.h': 'Configura',
    'm1.p':
      'Instala skipr, inicia sesión en Claude Code. Sin terminal, sin archivos de config, sin YAML. Listo en unos dos minutos.',
    'm1.tool': 'skipr + Claude Code',
    'm1.when': '~2 minutos',
    'm2.h': 'Define',
    'm2.p':
      'Describe lo que quieres en palabras simples. skipr lo convierte en una spec real que lees, editas y apruebas antes de escribir una línea.',
    'm2.tool': 'skipr',
    'm2.when': 'en tus palabras',
    'm3.h': 'Construye',
    'm3.p':
      'Claude Code escribe código real y legible — y te muestra qué hace y por qué. Ganas comprensión, no solo resultados.',
    'm3.tool': 'Claude Code',
    'm3.when': 'miras y aprendes',
    'm4.h': 'Adueñate',
    'm4.p':
      'Todo llega a tu propio repo de GitHub. Tus commits, tu historial — tuyo para guardar, bifurcar o entregar a un dev luego.',
    'm4.tool': 'GitHub',
    'm4.when': 'tuyo, para siempre',
    'm5.h': 'Despliega',
    'm5.p':
      'Despliega en Vercel con un backend de Supabase. Una app real y en vivo en tu propio dominio — tuya de principio a fin.',
    'm5.tool': 'Vercel + Supabase',
    'm5.when': 'en vivo y tuyo',
    'how.foot': 'Todo el stack, a tu nombre:',

    'stack.h': 'Tu stack, <em>tú decides.</em>',
    'stack.tag': 'sin lock-in, por diseño',
    'stack.lead':
      'skipr arranca con GitHub, Vercel y Supabase — herramientas maduras y aburridas (en el buen sentido) que simplemente funcionan. Son defaults sensatos, no esposas.',
    'stack.c1': 'Control de versiones',
    'stack.c2': 'Despliegue',
    'stack.c3': 'Backend y datos',
    'stack.or': 'o lo que elijas',
    'stack.soon': 'pronto más',
    'stack.foot':
      'Con el tiempo llegan más plataformas de primera — y <span class="o">tú</span> eliges cuál, según tus propios criterios o hablándolo con Claude mientras construyes.',

    'foot.cta': 'Deja de alquilar tu software.<br>Empieza a <em>ser su dueño.</em>',
    'foot.email.l': 'Tu email',
    'foot.email': 'tu@tustartup.com',
    'foot.btn': 'Únete a la lista',
    'foot.disc':
      'skipr es un producto independiente y no está afiliado, respaldado ni patrocinado por Anthropic. “Claude” y “Claude Code” son productos de Anthropic. GitHub, Supabase y Vercel son marcas de sus respectivos dueños.',
    'foot.coming': 'Muy pronto — skipr.dev',
    'foot.copy': '© 2026 skipr · hecho para quienes quieren las llaves',
    'foot.notes': 'Apuntes de campo →',

    'wl.ok': '¡Listo! Estás en la lista ✓',
    'wl.invalid': 'Introduce un email válido.',
    'wl.error': 'Algo salió mal — inténtalo de nuevo en un momento.',
    'a11y.skip': 'Saltar al contenido',
    'locale.switch': 'EN',
  },
} as const;

export type UIKey = keyof (typeof ui)['en'];

export function getLocale(input: string | undefined): Locale {
  return input === 'es' ? 'es' : 'en';
}

export function useTranslations(locale: Locale) {
  return function t(key: UIKey): string {
    return (ui[locale] as Record<string, string>)[key] ?? ui.en[key];
  };
}

export function localizePath(path: string, locale: Locale): string {
  const clean = path.startsWith('/') ? path : `/${path}`;
  if (locale !== 'es') return clean;
  return clean === '/' ? '/es/' : `/es${clean}`;
}

export function basePath(pathname: string): string {
  const stripped = pathname.replace(/^\/es(?=\/|$)/, '');
  return stripped === '' ? '/' : stripped;
}

export function otherLocale(locale: Locale): Locale {
  return locale === 'es' ? 'en' : 'es';
}
