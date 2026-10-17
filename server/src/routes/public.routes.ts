import type { FastifyInstance } from 'fastify';
import { login, register } from '../controllers/auth.controller.js';
import {
  getContentBySlug,
  getContents,
  getServers,
} from '../controllers/content.controller.js';

export async function publicRoutes(app: FastifyInstance) {
  app.post('/api/auth/register', register);
  app.post('/api/auth/login', login);
  app.get('/api/contents', getContents);
  app.get('/api/contents/:slug', getContentBySlug);
  app.get('/api/episodes/:id/servers', getServers);
}
