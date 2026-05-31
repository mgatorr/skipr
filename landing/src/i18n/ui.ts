// i18n strings. English is primary; Spanish is secondary. Missing es keys fall back to en.
export const defaultLocale = 'en' as const;
export const locales = ['en', 'es'] as const;
export type Locale = (typeof locales)[number];

export const ui = {
  en: {
    'nav.articles': 'articles',
    'hero.badge': '▲ coming soon',
    'hero.titleLead': 'Build real software with AI —',
    'hero.titleAccent': 'and actually own it.',
    'hero.lede':
      'skipr guides you from idea to a shipped app — Claude Code, your files on your machine, your GitHub, your deploy — without living in the terminal. For founders who want to build for real, not just prototype.',
    'hero.cta': 'Join the waitlist',
    'abb.title': 'Not a black box.',
    'abb.lede':
      "Tools like Lovable or Base44 hand you an app you can't see inside. skipr is the opposite: you keep the code, the repo, and the control — and you learn as you go.",
    'abb.you': 'With skipr',
    'abb.them': 'No-code black boxes',
    'abb.you1': 'The code lives on your machine',
    'abb.you2': 'Your own GitHub repo',
    'abb.you3': 'A deploy you understand',
    'abb.you4': 'You learn and level up',
    'abb.them1': "Code you can't see or move",
    'abb.them2': 'Locked into their platform',
    'abb.them3': 'A black-box deploy',
    'abb.them4': 'You stay dependent',
    'how.title': 'How it works',
    'how.lede': 'Five guided steps from idea to shipped — no terminal required.',
    'how.s1t': 'Set up',
    'how.s1d': 'Get Claude Code running, guided — no terminal commands.',
    'how.s2t': 'Spec',
    'how.s2d': "Turn your idea into a clear plan so the AI doesn't drift.",
    'how.s3t': 'Code',
    'how.s3d': 'skipr drives Claude Code; you watch and stay in control.',
    'how.s4t': 'GitHub',
    'how.s4d': 'Your code, in your own repo. We explain every step.',
    'how.s5t': 'Deploy',
    'how.s5d': 'Ship a real, live app on Vercel + Supabase — that you own.',
    'wl.button': 'Join the waitlist',
    'wl.ok': "You're on the list — we'll email you at launch.",
    'wl.invalid': 'Please enter a valid email address.',
    'wl.error': 'Something went wrong. Please try again in a moment.',
    disclaimer: 'skipr is an independent tool and is not affiliated with Anthropic.',
    'footer.tagline': 'built for founders who want to own what they build',
    'locale.switch': 'Español',
  },
  es: {
    'nav.articles': 'artículos',
    'hero.badge': '▲ próximamente',
    'hero.titleLead': 'Crea software real con IA —',
    'hero.titleAccent': 'y hazlo de verdad tuyo.',
    'hero.lede':
      'skipr te guía de la idea a una app publicada — Claude Code, tus archivos en tu ordenador, tu GitHub, tu deploy — sin vivir en la terminal. Para founders que quieren construir de verdad, no solo prototipos.',
    'hero.cta': 'Únete a la waitlist',
    'abb.title': 'No es una caja negra.',
    'abb.lede':
      'Herramientas como Lovable o Base44 te dan una app que no puedes ver por dentro. skipr es lo contrario: te quedas el código, el repo y el control — y aprendes por el camino.',
    'abb.you': 'Con skipr',
    'abb.them': 'Cajas negras no-code',
    'abb.you1': 'El código vive en tu ordenador',
    'abb.you2': 'Tu propio repo de GitHub',
    'abb.you3': 'Un deploy que entiendes',
    'abb.you4': 'Aprendes y subes de nivel',
    'abb.them1': 'Código que no ves ni mueves',
    'abb.them2': 'Atado a su plataforma',
    'abb.them3': 'Un deploy de caja negra',
    'abb.them4': 'Sigues dependiendo de ellos',
    'how.title': 'Cómo funciona',
    'how.lede': 'Cinco pasos guiados de la idea a publicado — sin terminal.',
    'how.s1t': 'Configura',
    'how.s1d': 'Pon Claude Code en marcha, guiado — sin comandos de terminal.',
    'how.s2t': 'Spec',
    'how.s2d': 'Convierte tu idea en un plan claro para que la IA no se desvíe.',
    'how.s3t': 'Código',
    'how.s3d': 'skipr maneja Claude Code; tú observas y mantienes el control.',
    'how.s4t': 'GitHub',
    'how.s4d': 'Tu código, en tu propio repo. Te explicamos cada paso.',
    'how.s5t': 'Deploy',
    'how.s5d': 'Publica una app real en Vercel + Supabase — que es tuya.',
    'wl.button': 'Únete a la waitlist',
    'wl.ok': 'Estás en la lista — te escribiremos en el lanzamiento.',
    'wl.invalid': 'Introduce un email válido.',
    'wl.error': 'Algo salió mal. Inténtalo de nuevo en un momento.',
    disclaimer: 'skipr es una herramienta independiente y no está afiliada a Anthropic.',
    'footer.tagline': 'hecho para founders que quieren ser dueños de lo que construyen',
    'locale.switch': 'English',
  },
} as const;

export type UIKey = keyof (typeof ui)['en'];

export function getLocale(input: string | undefined): Locale {
  return input === 'es' ? 'es' : 'en';
}

export function useTranslations(locale: Locale) {
  return function t(key: UIKey): string {
    return ui[locale][key] ?? ui.en[key];
  };
}

/** English has no prefix; Spanish lives under /es/. */
export function localizePath(path: string, locale: Locale): string {
  const clean = path.startsWith('/') ? path : `/${path}`;
  if (locale !== 'es') return clean;
  return clean === '/' ? '/es/' : `/es${clean}`;
}

/** Strip a leading /es so we can rebuild a path in either locale. */
export function basePath(pathname: string): string {
  const stripped = pathname.replace(/^\/es(?=\/|$)/, '');
  return stripped === '' ? '/' : stripped;
}

export function otherLocale(locale: Locale): Locale {
  return locale === 'es' ? 'en' : 'es';
}
