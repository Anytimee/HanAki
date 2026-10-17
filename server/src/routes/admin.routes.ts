import type { FastifyInstance } from 'fastify';
import {
  addEpisode,
  addServer,
  createContent,
  dashboard,
  deleteContent,
  deleteServer,
  updateContent,
} from '../controllers/admin.controller.js';
import { adminGuard } from '../middlewares/auth.js';

export async function adminRoutes(app: FastifyInstance) {
  // Semua route di bawah ini wajib login + role ADMIN (403 bila USER).
  app.post('/api/admin/contents', { preHandler: adminGuard }, createContent);
  app.put('/api/admin/contents/:id', { preHandler: adminGuard }, updateContent);
  app.delete(
    '/api/admin/contents/:id',
    { preHandler: adminGuard },
    deleteContent,
  );
  app.post(
    '/api/admin/contents/:id/episodes',
    { preHandler: adminGuard },
    addEpisode,
  );
  app.post(
    '/api/admin/episodes/:id/servers',
    { preHandler: adminGuard },
    addServer,
  );
  app.delete(
    '/api/admin/servers/:id',
    { preHandler: adminGuard },
    deleteServer,
  );
  app.get('/api/admin/dashboard', { preHandler: adminGuard }, dashboard);
}
