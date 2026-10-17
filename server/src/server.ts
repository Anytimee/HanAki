import cors from '@fastify/cors';
import Fastify from 'fastify';
import { env } from './config/env.js';
import { adminRoutes } from './routes/admin.routes.js';
import { publicRoutes } from './routes/public.routes.js';

async function main() {
  const app = Fastify({ logger: true });

  await app.register(cors, { origin: true });

  // Format error konsisten: { success: false, error: "..." }.
  app.setErrorHandler((err: Error & { statusCode?: number }, _req, reply) => {
    const status =
      err.statusCode && err.statusCode < 500 ? err.statusCode : 500;
    app.log.error(err);
    return reply.code(status).send({
      success: false,
      error: status === 500 ? 'Internal server error' : err.message,
    });
  });

  app.get('/health', async () => ({ success: true, data: { ok: true } }));

  await app.register(publicRoutes);
  await app.register(adminRoutes);

  await app.listen({ port: env.port, host: '0.0.0.0' });
  console.log(`[hanaki-api] listening on :${env.port}`);
}

main().catch((e) => {
  console.error('[hanaki-api] fatal:', e);
  process.exit(1);
});

