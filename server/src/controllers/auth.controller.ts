import type { FastifyReply, FastifyRequest } from 'fastify';
import { z } from 'zod';
import { prisma } from '../config/database.js';
import { hashPassword, verifyPassword } from '../utils/hash.js';
import { signToken } from '../utils/jwt.js';

const registerSchema = z.object({
  email: z.string().email('Email tidak valid').max(160),
  password: z.string().min(8, 'Password minimal 8 karakter').max(128),
});

const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(1),
});

const zodErr = (e: z.ZodError) =>
  e.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join('; ');

/** POST /api/auth/register — selalu USER. Admin hanya via seed/DB. */
export async function register(
  req: FastifyRequest,
  reply: FastifyReply,
) {
  const parsed = registerSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  const { email, password } = parsed.data;

  const exists = await prisma.user.findUnique({ where: { email } });
  if (exists) {
    return reply
      .code(409)
      .send({ success: false, error: 'Email sudah terdaftar' });
  }

  // CRUCIAL: role TIDAK diambil dari body — cegah privilege escalation.
  const user = await prisma.user.create({
    data: { email, password: await hashPassword(password), role: 'USER' },
    select: { id: true, email: true, role: true, createdAt: true },
  });
  return reply.code(201).send({
    success: true,
    data: { user, token: signToken({ sub: user.id, email, role: 'USER' }) },
  });
}

/** POST /api/auth/login — return JWT. */
export async function login(req: FastifyRequest, reply: FastifyReply) {
  const parsed = loginSchema.safeParse(req.body);
  if (!parsed.success) {
    return reply
      .code(400)
      .send({ success: false, error: zodErr(parsed.error) });
  }
  const { email, password } = parsed.data;

  const user = await prisma.user.findUnique({ where: { email } });
  // Pesan generik: jangan bocorkan email mana yang terdaftar.
  if (!user || !(await verifyPassword(password, user.password))) {
    return reply
      .code(401)
      .send({ success: false, error: 'Email atau password salah' });
  }
  return reply.send({
    success: true,
    data: {
      user: { id: user.id, email: user.email, role: user.role },
      token: signToken({ sub: user.id, email: user.email, role: user.role }),
    },
  });
}
