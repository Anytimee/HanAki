import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { prisma } from '../config/database.js';

const zodErr = (e: z.ZodError) =>
  e.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join('; ');

const createContentSchema = z.object({
  slug: z
    .string()
    .min(2)
    .max(120)
    .regex(/^[a-z0-9-]+$/, 'Slug hanya huruf kecil, angka, strip'),
  title: z.string().min(1).max(200),
  synopsis: z.string().min(1).max(10000),
  posterUrl: z.string().url('posterUrl harus URL valid'),
  type: z.enum(['ANIME', 'DRAKOR', 'DONGHUA']),
  status: z.enum(['ONGOING', 'COMPLETED', 'UPCOMING']).default('ONGOING'),
});

/**
 * POST /api/admin/contents (ADMIN)
 * Request:  { slug, title, synopsis, posterUrl, type, status }
 * Response: 201 { success: true, data: content }
 */
export async function createContent(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const parsed = createContentSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  try {
    const data = await prisma.content.create({ data: parsed.data });
    return reply.code(201).send({ success: true, data });
  } catch (e: unknown) {
    // P2002 = unique constraint (slug kembar).
    if (
      typeof e === 'object' &&
      e !== null &&
      'code' in e &&
      (e as { code: string }).code === 'P2002'
    ) {
      return reply
        .code(409)
        .send({ success: false, error: 'Slug sudah dipakai' });
    }
    throw e;
  }
}

/** PUT /api/admin/contents/:id (ADMIN) */
export async function updateContent(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  const parsed = createContentSchema.partial().safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  try {
    const data = await prisma.content.update({
      where: { id },
      data: parsed.data,
    });
    return reply.send({ success: true, data });
  } catch {
    return reply
      .code(404)
      .send({ success: false, error: 'Konten tidak ditemukan' });
  }
}

/** DELETE /api/admin/contents/:id (ADMIN, cascade episode+server) */
export async function deleteContent(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  try {
    await prisma.content.delete({ where: { id } });
    return reply.send({ success: true, data: { deleted: true } });
  } catch {
    return reply
      .code(404)
      .send({ success: false, error: 'Konten tidak ditemukan' });
  }
}

const episodeSchema = z.object({
  episodeNum: z.number().int().min(1).max(5000),
  title: z.string().max(200).default(''),
});

/** POST /api/admin/contents/:id/episodes (ADMIN) */
export async function addEpisode(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  const parsed = episodeSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  const content = await prisma.content.findUnique({
    where: { id },
    select: { id: true },
  });
  if (!content) {
    return reply
      .code(404)
      .send({ success: false, error: 'Konten tidak ditemukan' });
  }
  try {
    const data = await prisma.episode.create({
      data: { contentId: content.id, ...parsed.data },
    });
    return reply.code(201).send({ success: true, data });
  } catch (e: unknown) {
    if (
      typeof e === 'object' &&
      e !== null &&
      'code' in e &&
      (e as { code: string }).code === 'P2002'
    ) {
      return reply.code(409).send({
        success: false,
        error: 'Nomor episode sudah ada untuk konten ini',
      });
    }
    throw e;
  }
}

// Whitelist provider embed yang didukung — tolak path lokal / skema aneh.
// Embed-only: url WAJIB http(s) publik, BUKAN /uploads/xxx.mp4 atau file://.
const EMBED_HOSTS = [
  'dailymotion.com',
  'geo.dailymotion.com',
  'ok.ru',
  'mega.nz',
  'bilibili.com',
  'bilibili.tv',
  'wetv.vip',
  'iqiyi.com',
  'youku.com',
  'streamtape.com',
  'dtube.co',
  'gogoanime',
  'viki.com',
  'bstation.com',
] as const;

const embedUrlSchema = z
  .string()
  .min(10, 'URL terlalu pendek')
  .max(2000, 'URL terlalu panjang')
  .url('URL harus format valid diawali http:// atau https://')
  .refine((u) => u.startsWith('http://') || u.startsWith('https://'), {
    message: 'URL wajib diawali http:// atau https://',
  })
  .refine(
    (u) => {
      try {
        const host = new URL(u).hostname.toLowerCase();
        // Tolak path lokal & skema non-web.
        if (u.startsWith('/') || u.startsWith('file:') || u.startsWith('ftp:')) {
          return false;
        }
        return EMBED_HOSTS.some((h) => host.includes(h));
      } catch {
        return false;
      }
    },
    {
      message: `Host belum didukung. Didukung: ${EMBED_HOSTS.join(', ')}`,
    },
  );

const serverSchema = z.object({
  provider: z.string().min(1).max(60), // "Dailymotion" | "Bilibili" | ...
  quality: z.enum(['360p', '480p', '720p', '1080p']).default('720p'),
  url: embedUrlSchema, // link embed publik — bukan file lokal
  isPremium: z.boolean().default(false),
});

/**
 * POST /api/admin/episodes/:id/servers (ADMIN)
 * Request:  { provider, quality, url, isPremium }
 * Response: 201 { success: true, data: server }
 */
export async function addServer(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  const parsed = serverSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  const ep = await prisma.episode.findUnique({
    where: { id },
    select: { id: true },
  });
  if (!ep) {
    return reply
      .code(404)
      .send({ success: false, error: 'Episode tidak ditemukan' });
  }
  const data = await prisma.streamServer.create({
    data: { episodeId: ep.id, ...parsed.data },
  });
  return reply.code(201).send({ success: true, data });
}

/** DELETE /api/admin/servers/:id (ADMIN) */
export async function deleteServer(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  try {
    await prisma.streamServer.delete({ where: { id } });
    return reply.send({ success: true, data: { deleted: true } });
  } catch {
    return reply
      .code(404)
      .send({ success: false, error: 'Server tidak ditemukan' });
  }
}

/** GET /api/admin/dashboard (ADMIN) — statistik ringkas. */
export async function dashboard(
  _req: FastifyRequest,
  reply: FastifyReply,
) {
  const [contents, episodes, users, servers] = await prisma.$transaction([
    prisma.content.count(),
    prisma.episode.count(),
    prisma.user.count(),
    prisma.streamServer.count(),
  ]);
  return reply.send({
    success: true,
    data: { contents, episodes, users, servers },
  });
}
