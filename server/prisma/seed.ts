import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

// Seed idempotent: aman dijalankan berulang (upsert, bukan create).
async function main() {
  const admin = await prisma.user.upsert({
    where: { email: 'admin@hanaki.com' },
    update: {}, // jangan reset password bila admin sudah ada
    create: {
      email: 'admin@hanaki.com',
      password: await bcrypt.hash('admin123', 12),
      role: 'ADMIN',
    },
  });
  console.log(`[seed] admin OK: ${admin.email} (${admin.role})`);
}

main()
  .catch((e) => {
    console.error('[seed] gagal:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
