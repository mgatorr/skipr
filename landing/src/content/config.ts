import { defineCollection, z } from 'astro:content';
import { glob } from 'astro/loaders';

// Articles are plain Markdown files — adding one is a single content file with
// no code change (FR-009 / SC-005). The schema enforces the metadata SEO needs.
const articles = defineCollection({
  loader: glob({ pattern: '**/*.{md,mdx}', base: './src/content/articles' }),
  schema: z.object({
    title: z.string(),
    description: z.string(),
    publishDate: z.coerce.date(),
    ogImage: z.string().optional(),
    draft: z.boolean().default(false),
    canonical: z.string().url().optional(),
  }),
});

export const collections = { articles };
