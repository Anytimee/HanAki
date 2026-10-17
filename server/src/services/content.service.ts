import { Prisma, type ContentType } from '@prisma/client';
import { prisma } from '../config/database.js';

export interface ListParams {
  page: number;
  limit: number;
  search?: string;
  type?: ContentType;
}

/** GET /api/contents — pagination + search judul + filter type. */
export async function listContents(p: ListParams) {
  const page = Math.max(1, p.page);
  const limit = Math.min(50, Math.max(1, p.limit));
  const where: Prisma.ContentWhereInput = {
    ...(p.type ? { type: p.type } : {}),
    ...(p.search
      ? {
          OR: [
            { title: { contains: p.search, mode: 'insensitive' } },
            { slug: { contains: p.search, mode: 'insensitive' } },
          ],
        }
      : {}),
  };
  const [total, items] = await prisma.$transaction([
    prisma.content.count({ where }),
    prisma.content.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * limit,
      take: limit,
      include: { _count: { select: { episodes: true } } },
    }),
  ]);
  return {
    items,
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

/** GET /api/contents/:slug — detail + episode list ASC. */
export async function contentDetail(slug: string) {
  return prisma.content.findUnique({
    where: { slug },
    include: {
      episodes: {
        orderBy: { episodeNum: 'asc' },
        select: {
          id: true,
          episodeNum: true,
          title: true,
          _count: { select: { servers: true } },
        },
      },
    },
  });
}

/**
 * GET /api/episodes/:id/servers — list server + link stream.
 * User FREE sebaiknya difilter isPremium=false di client;
 * enforcement ketat bisa ditambah di route (cek langganan).
 */
export async function episodeServers(episodeId: string, includePremium: boolean) {
  return prisma.streamServer.findMany({
    where: { episodeId, ...(includePremium ? {} : { isPremium: false }) },
    orderBy: [{ isPremium: 'asc' }, { provider: 'asc' }],
  });
}
