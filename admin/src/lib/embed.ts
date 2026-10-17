import { z } from "zod";

/**
 * Whitelist host embed — mirror dari EMBED_HOSTS backend
 * (server/src/controllers/admin.controller.ts).
 * Server tetap jadi otoritas; ini mencegah admin salah input lebih awal.
 */
export const EMBED_HOSTS = [
  "dailymotion.com",
  "geo.dailymotion.com",
  "ok.ru",
  "mega.nz",
  "bilibili.com",
  "bilibili.tv",
  "wetv.vip",
  "iqiyi.com",
  "youku.com",
  "streamtape.com",
  "dtube.co",
  "gogoanime",
  "viki.com",
  "bstation.com",
] as const;

const HOST_HINT = EMBED_HOSTS.filter((h) => h !== "geo.dailymotion.com").join(
  ", ",
);

/**
 * Validasi URL EMBED — bukan link halaman biasa, apalagi path file lokal.
 * Tolak: /uploads/abc.mp4, file:, ftp:, host di luar whitelist.
 */
export const embedUrlSchema = z
  .string()
  .trim()
  .min(10, "URL terlalu pendek")
  .max(2000, "URL terlalu panjang")
  .url("URL harus format valid diawali http:// atau https://")
  .refine((u) => u.startsWith("http://") || u.startsWith("https://"), {
    message: "URL wajib diawali http:// atau https://",
  })
  .refine(
    (u) => {
      if (u.startsWith("/") || u.startsWith("file:") || u.startsWith("ftp:")) {
        return false;
      }
      try {
        const host = new URL(u).hostname.toLowerCase();
        return EMBED_HOSTS.some((h) => host.includes(h));
      } catch {
        return false;
      }
    },
    {
      message: `Host belum didukung. Didukung: ${HOST_HINT}`,
    },
  );

/** Provider yang tampil di dropdown — wajib match host whitelist. */
export const PROVIDERS = [
  { label: "Dailymotion", value: "Dailymotion" },
  { label: "OK.ru", value: "OKRU" },
  { label: "Dtube", value: "Dtube" },
  { label: "Mega", value: "Mega" },
  { label: "Bstation", value: "Bstation" },
] as const;

export const QUALITIES = ["360p", "480p", "720p", "1080p"] as const;

export const serverFormSchema = z.object({
  provider: z.string().min(1, "Provider wajib dipilih"),
  quality: z.string().min(1, "Kualitas wajib dipilih"),
  url: embedUrlSchema,
  isPremium: z.boolean(),
});

export type ServerFormValues = z.infer<typeof serverFormSchema>;
