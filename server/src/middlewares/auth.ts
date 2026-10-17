import type { FastifyReply, FastifyRequest } from 'fastify';
import { verifyToken, type JwtPayload } from '../utils/jwt.js';

// Daftarkan tipe req.user ke Fastify agar TypeScript strict lolos.
declare module 'fastify' {
  interface FastifyRequest {
    user?: JwtPayload;
  }
}

/** Ambil token dari `Authorization: Bearer <token>`. */
function bearerToken(req: FastifyRequest): string | null {
  const h = req.headers.authorization;
  if (!h?.startsWith('Bearer ')) return null;
  const token = h.slice(7).trim();
  return token.length > 0 ? token : null;
}

/**
 * authGuard — validasi JWT, simpan payload ke req.user.
 * 401 bila header hilang / token invalid / expired.
 */
export async function authGuard(
  req: FastifyRequest,
  reply: FastifyReply,
): Promise<void> {
  const token = bearerToken(req);
  if (!token) {
    return reply.code(401).send({
      success: false,
      error: 'Unauthorized: header Authorization Bearer <token> wajib',
    });
  }
  try {
    req.user = verifyToken(token);
  } catch {
    return reply.code(401).send({
      success: false,
      error: 'Unauthorized: token invalid atau expired',
    });
  }
}

/**
 * adminGuard — authGuard + cek role ADMIN.
 * Dipakai sebagai preHandler route /api/admin/*. 403 bila role USER.
 */
export async function adminGuard(
  req: FastifyRequest,
  reply: FastifyReply,
): Promise<void> {
  await authGuard(req, reply);
  if (reply.sent) return; // authGuard sudah balas 401, stop.
  if (req.user?.role !== 'ADMIN') {
    return reply.code(403).send({
      success: false,
      error: 'Forbidden: hanya ADMIN yang boleh akses endpoint ini',
    });
  }
}
