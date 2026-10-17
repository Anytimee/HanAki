import 'dotenv/config';

// Validasi env penting saat boot — gagal cepat daripada error misterius.
function required(name: string): string {
  const v = process.env[name];
  if (!v) throw new Error(`ENV ${name} belum diisi (lihat .env.example)`);
  return v;
}

export const env = {
  databaseUrl: required('DATABASE_URL'),
  jwtSecret: required('JWT_SECRET'),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '7d',
  port: Number(process.env.PORT ?? 3000),
};
