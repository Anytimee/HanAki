import axios from "axios";
import { clearToken, getToken } from "./auth";

/** Instance Axios — Bearer token diambil dari localStorage saat request. */
export const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:3000",
  timeout: 15_000,
});

api.interceptors.request.use((config) => {
  const token = getToken();
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

/** 401 → bersihkan sesi, lempar admin ke halaman login. */
api.interceptors.response.use(
  (response) => response,
  (error: AxiosError) => {
    if (
      error.response?.status === 401 &&
      typeof window !== "undefined" &&
      !window.location.pathname.startsWith("/login")
    ) {
      clearToken();
      window.location.href = "/login";
    }
    return Promise.reject(error);
  },
);

type AxiosError = import("axios").AxiosError<{
  success?: boolean;
  error?: string;
}>;

/** Pesan error ramah dari respons API HanAki (`{ success, error }`).
 * Sertakan kode HTTP (mis. `[400]`) agar 400/401/500 langsung terbaca
 * di toast maupun console. */
export function apiErrorMessage(error: unknown): string {
  if (axios.isAxiosError(error)) {
    const status = error.response?.status;
    const message =
      error.response?.data?.error ?? error.message ?? "Gagal memanggil API";
    return status ? `[${status}] ${message}` : message;
  }
  return "Terjadi kesalahan tak terduga";
}
