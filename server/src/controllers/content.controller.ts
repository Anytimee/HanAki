import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import {
  contentDetail,
  episodeServers,
  listContents,
} from '../services/content.service.js';

const listQuery = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(50).default(20),
  search: z.string().max(120).optional(),
  type: z.enum(['ANIME', 'DRAKOR', 'DONGHUA']).optional(),
});

/** GET /api/contents?page=1&limit=20&search=naruto&type=ANIME */
export async function getContents(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const q = listQuery.safeParse(req.query);
  if (!q.success) {
    return reply.code(400).send({
      success: false,
      error: q.error.issues.map((i) => i.message).join('; '),
    });
  }
  const data = await listContents({
    page: q.data.page,
    limit: q.data.limit,
    search: q.data.search,
    type: q.data.type,
  });
  return reply.send({ success: true, data });
}

/** GET /api/contents/:slug */
export async function getContentBySlug(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { slug } = req.params as { slug: string };
  const data = await contentDetail(slug);
  if (!data) {
    return reply
      .code(404)
      .send({ success: false, error: 'Konten tidak ditemukan' });
  }
  return reply.send({ success: true, data });
}

/** GET /api/episodes/:id/servers — PUBLIC.
 * Response: list link EMBED (teks URL, bukan file video).
 * Flutter: WebView bila renderAs=webview, VideoPlayer bila hls (.m3u8).
 */
export async function getServers(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const { id } = req.params as { id: string };
  const rows = await episodeServers(id, true);
  const data = rows.map((s) => ({
    ...s,
    renderAs: s.url.includes('.m3u8') ? 'hls' : 'webview',
  }));
  return reply.send({ success: true, data });
}
