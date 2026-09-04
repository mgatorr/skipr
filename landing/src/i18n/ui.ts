// i18n strings (copy from the Claude Design "field guide" zine). English primary, Spanish secondary.
export const defaultLocale = 'en' as const;
export const locales = ['en', 'es'] as const;
export type Locale = (typeof locales)[number];

export const ui = {
  en: {
    'deck.left': 'Est. 2026 · Independent software · A field guide for builders escaping AI chaos',
    'nav.anti': 'the black box',
    'nav.how': 'the method',
    'nav.cta': 'Get started',
    'nav.docs': 'docs',

    'hero.stamp': 'Available now',
    'hero.vol': 'Vol. 01 — escape AI complexity',
    'hero.h1':
      'Escape <span class="own">AI complexity</span> —<br>few tools, a harness that can say <em>no</em>.',
    'hero.dek':
      'skipr helps creators and builders drowning in skills set up a <b>lean CLI + harness + Claude Code</b> path you understand. Terminal (Ghostty) is taught, not hidden. Rails, not 400 skills.',
    'hero.note':
      "You don't need another sealed AI stack. You need a folder, a harness, and a CLI you can read.",
    'hero.email.l': 'Your email',
    'hero.email': 'you@yourstartup.com',
    'hero.btn': 'Get started',
    'hero.secondary': 'Harness guide',
    'hero.foot': '✱ Not affiliated with Anthropic · skipr.dev',

    'spec.cap': 'Fig. 1 — the hand-off',
    'spec.tag': 'they keep the chaos / you get a lean path',
    'spec.crate': 'sealed',
    'spec.key': 'the rails',
    'spec.folder': 'owner: you',

    'slug.0': 'lean tools',
    'slug.1': 'your folder',
    'slug.2': 'harness says no',
    'slug.3': 'Claude Code first',
    'slug.x0': 'no skill hoards',
    'slug.x1': 'no black-box AI',
    'slug.x2': 'no 400 skills',
    'slug.x3': 'no rented boxes',

    'anti.num': 'Plate 01 — the anti-black-box',
    'anti.title':
      'AI chaos handed you a sealed box.<br>We hand you <em>a folder, a harness,</em> and <span class="o">a CLI you understand.</span>',
    'anti.lead':
      "Rented no-code platforms and opaque AI setups with 400 skills look finished — until you need to change them, trust them, or actually own them. That's the black box. Here is the difference, on the table:",

    'a.id': 'Exhibit A',
    'a.tag': 'rented no-code · opaque AI',
    'a.h': 'The sealed box',
    'a.sub': 'Looks powerful. Try to understand it.',
    'a.l1': '400 skills, zero rails',
    'a.l2': 'Rented platforms or opaque stacks',
    'a.l3': "You can't see why it works",
    'a.l4': 'Cognitive load spirals',
    'a.l5': 'Fails when you need control',
    'a.seal': 'property of the stack — do not open',

    'div.lbl': 'the escape',

    'b.id': 'Exhibit B',
    'b.tag': 'skipr',
    'b.h': 'Your <span class="b">folder</span>',
    'b.sub': 'Lean harness. Real CLI. You understand it.',
    'b.l1': 'Project folder, not a generic vault',
    'b.l2': 'Short CLAUDE.md + checks that can fail',
    'b.l3': 'Ghostty + Claude Code — taught, not hidden',
    'b.l4': 'Guides by level (L0 → L2)',
    'b.l5': 'Own what you build',
    'b.branch': '⎇ main',
    'b.owner': 'owner: ',
    'b.ownerb': 'you ✓',
    'b.t1': 'project/',
    'b.t2': 'CLAUDE.md',
    'b.t3': 'checks/',
    'b.t4': 'setup-harness',
    'b.t5': 'README.md',
    'b.key': 'rails: in place',

    'creed.mk': 'the whole point',
    creed:
      'We don\'t hide the terminal. We teach a <span class="o">lean path</span> — few good tools, a harness that can say no, Claude Code first. You escape <span class="struck">AI complexity</span> owning a setup you understand.',

    'how.num': 'Plate 02 — the method',
    'how.title': 'From chaos to <em>clarity,</em><br>in five moves.',
    'how.lead':
      'Not a feature list — a guided route. Install lean, open the project folder, add a harness that can fail, build with Claude Code, level up when you are ready.',
    'm1.h': 'Set up',
    'm1.p':
      'Ghostty (or the terminal you already have) plus Claude Code CLI. Step-by-step in Docs — the terminal is taught, not hidden.',
    'm1.tool': 'Ghostty + Claude Code',
    'm1.when': 'docs · now',
    'm2.h': 'Open the folder',
    'm2.p':
      'Work in the project itself — not a generic vault of prompts. The folder is the product surface.',
    'm2.tool': 'your project',
    'm2.when': 'your folder',
    'm3.h': 'Harness',
    'm3.p':
      'A short CLAUDE.md plus checks that can fail (setup-harness). Rails that say no when the model drifts.',
    'm3.tool': 'setup-harness',
    'm3.when': 'setup-harness',
    'm4.h': 'Build with Claude Code',
    'm4.p':
      'Claude Code on rails — not 400 skills. You ship understanding while you ship the work.',
    'm4.tool': 'Claude Code',
    'm4.when': 'rails, not hoards',
    'm5.h': 'Level up later',
    'm5.p':
      'L0/L1 are usable now. When they feel solid, add Cursor, OpenCode, or Hermes (L2) — an honest growth track, not a product gate.',
    'm5.tool': 'Cursor · OpenCode · Hermes',
    'm5.when': 'grows with you',
    'how.foot': 'The lean path, in your name:',
    'how.docs': 'Full novice path in Docs →',
    'how.grow': 'This grows with you — L2 tracks later, optional.',

    'stack.h': 'Your tools, <em>few and clear.</em>',
    'stack.tag': 'lean by design',
    'stack.lead':
      'skipr starts with a real terminal, Claude Code, and a harness that can say no — mature pieces you can see and change. Sensible defaults, not another sealed stack.',
    'stack.c1': 'Terminal',
    'stack.c2': 'Agent',
    'stack.c3': 'Harness',
    'stack.or': 'or your choice',
    'stack.soon': 'L2 later',
    'stack.foot':
      'Level up when you are ready — and <span class="o">you</span> decide which tools join the path, by your criteria or by talking it through with Claude as you build.',

    'foot.cta': 'Unlock the guide with your email.<br>Optional: get <em>notes</em> when guides grow.',
    'foot.email.l': 'Your email',
    'foot.email': 'you@yourstartup.com',
    'foot.btn': 'Get updates',
    'foot.disc':
      'skipr is an independent product and is not affiliated with, endorsed by, or sponsored by Anthropic. “Claude” and “Claude Code” are products of Anthropic. Ghostty, GitHub, Cursor, OpenCode and Hermes are trademarks of their respective owners.',
    'foot.coming': 'Available now — skipr.dev',
    'foot.copy': '© 2026 skipr · made for people who want the rails',
    'foot.notes': 'Field notes →',
    'foot.avisos': 'Same email unlocks the novice guide in Docs.',
    'docs.nav.start': 'Get started',
    'docs.nav.harness': 'Harness',
    'docs.nav.levels': 'Levels',
    'gate.plate': 'Plate 03 — the guide',
    'gate.title': 'Enter email to read the guide',
    'gate.lead': 'The full novice guide is ready — install, harness, and levels. Leave your email and <b>unlock it</b>. Same list as updates; no spam theater.',
    'gate.btn': 'Unlock the guide',
    'gate.note': 'One email unlocks /docs, /docs/harness, and /docs/levels on this browser.',
    'article.cta.h': 'Ready to escape AI complexity?',
    'article.cta.lead': 'The novice guide is ready — enter your email on Docs to unlock the full path. Optional updates also live in the footer.',
    'article.cta.btn': 'Get started',

    'wl.ok': "You're on the list ✓",
    'wl.invalid': 'Please enter a valid email.',
    'wl.error': 'Something went wrong — try again in a moment.',
    'a11y.skip': 'Skip to content',
    'locale.switch': 'ES',
  },
  es: {
    'deck.left': 'Desde 2026 · Software independiente · Guía de campo para builders que escapan del caos de la IA',
    'nav.anti': 'la caja negra',
    'nav.how': 'el método',
    'nav.cta': 'Empieza',
    'nav.docs': 'docs',

    'hero.stamp': 'Disponible ya',
    'hero.vol': 'Vol. 01 — escapar de la complejidad de la IA',
    'hero.h1':
      'Escapa de la <span class="own">complejidad de la IA</span> —<br>pocas tools, un harness que puede decir <em>no</em>.',
    'hero.dek':
      'skipr ayuda a creadores y builders ahogados en skills a montar un camino <b>CLI lean + harness + Claude Code</b> que entiendes. La terminal (Ghostty) se enseña, no se esconde. Rieles, no 400 skills.',
    'hero.note':
      'No necesitas otro stack de IA sellado. Necesitas una carpeta, un harness y un CLI que puedas leer.',
    'hero.email.l': 'Tu email',
    'hero.email': 'tu@tustartup.com',
    'hero.btn': 'Empieza',
    'hero.secondary': 'Guía del harness',
    'hero.foot': '✱ No afiliado con Anthropic · skipr.dev',

    'spec.cap': 'Fig. 1 — la entrega',
    'spec.tag': 'ellos se quedan el caos / tú recibes un camino lean',
    'spec.crate': 'sellado',
    'spec.key': 'los rieles',
    'spec.folder': 'dueño: tú',

    'slug.0': 'tools lean',
    'slug.1': 'tu carpeta',
    'slug.2': 'el harness dice no',
    'slug.3': 'Claude Code primero',
    'slug.x0': 'sin acopio de skills',
    'slug.x1': 'sin IA caja negra',
    'slug.x2': 'sin 400 skills',
    'slug.x3': 'sin cajas alquiladas',

    'anti.num': 'Lámina 01 — la anti-caja-negra',
    'anti.title':
      'El caos de la IA te dio una caja sellada.<br>Nosotros te damos <em>una carpeta, un harness</em> y <span class="o">un CLI que entiendes.</span>',
    'anti.lead':
      'Las plataformas no-code alquiladas y los setups opacos de IA con 400 skills parecen terminados — hasta que necesitas cambiarlos, confiar en ellos o ser su dueño. Eso es la caja negra. Aquí está la diferencia, sobre la mesa:',

    'a.id': 'Pieza A',
    'a.tag': 'no-code alquilado · IA opaca',
    'a.h': 'La caja sellada',
    'a.sub': 'Parece potente. Intenta entenderla.',
    'a.l1': '400 skills, cero rieles',
    'a.l2': 'Plataformas alquiladas o stacks opacos',
    'a.l3': 'No ves por qué funciona',
    'a.l4': 'La carga cognitiva se dispara',
    'a.l5': 'Falla cuando necesitas control',
    'a.seal': 'propiedad del stack — no abrir',

    'div.lbl': 'la salida',

    'b.id': 'Pieza B',
    'b.tag': 'skipr',
    'b.h': 'Tu <span class="b">carpeta</span>',
    'b.sub': 'Harness lean. CLI real. Lo entiendes.',
    'b.l1': 'Carpeta de proyecto, no un vault genérico',
    'b.l2': 'CLAUDE.md corto + checks que pueden fallar',
    'b.l3': 'Ghostty + Claude Code — se enseña, no se esconde',
    'b.l4': 'Guías por nivel (L0 → L2)',
    'b.l5': 'Eres dueño de lo que construyes',
    'b.branch': '⎇ main',
    'b.owner': 'dueño: ',
    'b.ownerb': 'tú ✓',
    'b.t1': 'project/',
    'b.t2': 'CLAUDE.md',
    'b.t3': 'checks/',
    'b.t4': 'setup-harness',
    'b.t5': 'README.md',
    'b.key': 'rieles: listos',

    'creed.mk': 'el punto central',
    creed:
      'No escondemos la terminal. Enseñamos un <span class="o">camino lean</span> — pocas tools buenas, un harness que puede decir no, Claude Code primero. Escapas de la <span class="struck">complejidad de la IA</span> con un setup que entiendes.',

    'how.num': 'Lámina 02 — el método',
    'how.title': 'Del caos a la <em>claridad,</em><br>en cinco pasos.',
    'how.lead':
      'No una lista de funciones — una ruta guiada. Instala lean, abre la carpeta del proyecto, añade un harness que puede fallar, construye con Claude Code, sube de nivel cuando estés listo.',
    'm1.h': 'Configura',
    'm1.p':
      'Ghostty (o la terminal que ya tengas) más Claude Code CLI. Paso a paso en Docs — la terminal se enseña, no se esconde.',
    'm1.tool': 'Ghostty + Claude Code',
    'm1.when': 'docs · ya',
    'm2.h': 'Abre la carpeta',
    'm2.p':
      'Trabaja en el proyecto mismo — no en un vault genérico de prompts. La carpeta es la superficie del producto.',
    'm2.tool': 'tu proyecto',
    'm2.when': 'tu carpeta',
    'm3.h': 'Harness',
    'm3.p':
      'Un CLAUDE.md corto más checks que pueden fallar (setup-harness). Rieles que dicen no cuando el modelo se desvía.',
    'm3.tool': 'setup-harness',
    'm3.when': 'setup-harness',
    'm4.h': 'Construye con Claude Code',
    'm4.p':
      'Claude Code con rieles — no 400 skills. Envías comprensión mientras envías el trabajo.',
    'm4.tool': 'Claude Code',
    'm4.when': 'rieles, no acopio',
    'm5.h': 'Sube de nivel después',
    'm5.p':
      'L0/L1 son usables ya. Cuando estén sólidos, añade Cursor, OpenCode o Hermes (L2) — crecimiento honesto, no una puerta al producto.',
    'm5.tool': 'Cursor · OpenCode · Hermes',
    'm5.when': 'crece contigo',
    'how.foot': 'El camino lean, a tu nombre:',
    'how.docs': 'Camino novato completo en Docs →',
    'how.grow': 'Crece contigo — tracks L2 después, opcionales.',

    'stack.h': 'Tus tools, <em>pocas y claras.</em>',
    'stack.tag': 'lean por diseño',
    'stack.lead':
      'skipr arranca con una terminal real, Claude Code y un harness que puede decir no — piezas maduras que ves y puedes cambiar. Defaults sensatos, no otro stack sellado.',
    'stack.c1': 'Terminal',
    'stack.c2': 'Agente',
    'stack.c3': 'Harness',
    'stack.or': 'o lo que elijas',
    'stack.soon': 'L2 después',
    'stack.foot':
      'Sube de nivel cuando estés listo — y <span class="o">tú</span> decides qué tools se unen al camino, según tus criterios o hablándolo con Claude mientras construyes.',

    'foot.cta': 'Desbloquea la guía con tu email.<br>Opcional: recibe <em>avisos</em> cuando crezcan las guías.',
    'foot.email.l': 'Tu email',
    'foot.email': 'tu@tustartup.com',
    'foot.btn': 'Recibir avisos',
    'foot.disc':
      'skipr es un producto independiente y no está afiliado, respaldado ni patrocinado por Anthropic. “Claude” y “Claude Code” son productos de Anthropic. Ghostty, GitHub, Cursor, OpenCode y Hermes son marcas de sus respectivos dueños.',
    'foot.coming': 'Disponible ya — skipr.dev',
    'foot.copy': '© 2026 skipr · hecho para quienes quieren los rieles',
    'foot.notes': 'Apuntes de campo →',
    'foot.avisos': 'El mismo email desbloquea la guía novata en Docs.',
    'docs.nav.start': 'Empieza',
    'docs.nav.harness': 'Harness',
    'docs.nav.levels': 'Niveles',
    'gate.plate': 'Lámina 03 — la guía',
    'gate.title': 'Pon tu email para ver la guía',
    'gate.lead': 'La guía completa para novatos está lista — instalación, harness y niveles. Deja tu email y <b>desbloquéala</b>. Misma lista que los avisos; sin teatro de spam.',
    'gate.btn': 'Desbloquear la guía',
    'gate.note': 'Un email desbloquea /es/docs, /es/docs/harness y /es/docs/levels en este navegador.',
    'article.cta.h': '¿Listo para escapar de la complejidad de la IA?',
    'article.cta.lead': 'La guía novata está lista — pon tu email en Docs para desbloquear el camino completo. Los avisos del pie también siguen disponibles.',
    'article.cta.btn': 'Empieza',

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
