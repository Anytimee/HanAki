"use client";

import {
  useMutation,
  useQuery,
  useQueryClient,
  type UseMutationResult,
} from "@tanstack/react-query";
import axios from "axios";
import { toast } from "sonner";
import { api, apiErrorMessage } from "@/lib/api";
import type {
  ApiResponse,
  Content,
  ContentDetail,
  ContentType,
  DashboardStats,
  EpisodeSummary,
  LoginResponse,
  Paged,
  StreamServer,
} from "@/types/api";

interface ListParams {
  page: number;
  limit: number;
  search?: string;
  type?: ContentType;
}

/* ------------------------------ QUERIES ------------------------------ */

export function useContents(params: ListParams) {
  return useQuery({
    queryKey: ["contents", params],
    queryFn: async () => {
      const res = await api.get<ApiResponse<Paged<Content>>>("/api/contents", {
        params: {
          page: params.page,
          limit: params.limit,
          ...(params.search ? { search: params.search } : {}),
          ...(params.type ? { type: params.type } : {}),
        },
      });
      return res.data.data;
    },
  });
}

export function useContent(slug: string) {
  return useQuery({
    queryKey: ["content", slug],
    enabled: !!slug,
    queryFn: async () => {
      const res = await api.get<ApiResponse<ContentDetail>>(
        `/api/contents/${encodeURIComponent(slug)}`,
      );
      return res.data.data;
    },
  });
}

export function useDashboard() {
  return useQuery({
    queryKey: ["dashboard"],
    queryFn: async () => {
      const res = await api.get<ApiResponse<DashboardStats>>(
        "/api/admin/dashboard",
      );
      return res.data.data;
    },
  });
}

/** List server milik episode (admin lihat semua, termasuk VIP).
 * Console.log respons mentah + error → membantu diagnosa "data kosong"
 * (ID episode salah? token expired? dsb.). */
export function useEpisodeServers(episodeId: string, open: boolean) {
  return useQuery({
    queryKey: ["servers", episodeId],
    enabled: open && !!episodeId,
    queryFn: async () => {
      try {
        const res = await api.get<ApiResponse<StreamServer[]>>(
          `/api/episodes/${episodeId}/servers`,
          { params: { premium: 1 } },
        );
        // eslint-disable-next-line no-console
        console.log(
          `[servers:${episodeId}] GET OK — ${res.data.data?.length ?? 0} link`,
          res.data.data,
        );
        return res.data.data;
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error(`[servers:${episodeId}] GET GAGAL`, error);
        throw error; // → state error query; dialog tampilkan + tombol muat ulang.
      }
    },
  });
}

/* ----------------------------- MUTATIONS ----------------------------- */

export function useLogin(): UseMutationResult<
  LoginResponse,
  unknown,
  { email: string; password: string }
> {
  return useMutation({
    mutationFn: async (body: { email: string; password: string }) => {
      const res = await api.post<ApiResponse<LoginResponse>>(
        "/api/auth/login",
        body,
      );
      return res.data.data;
    },
  });
}

export function useCreateEpisode(
  contentId: string,
  slug: string,
  onSuccess?: () => void,
) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (body: { episodeNum: number; title: string }) => {
      const res = await api.post<ApiResponse<{ id: string }>>(
        `/api/admin/contents/${contentId}/episodes`,
        body,
      );
      return res.data.data;
    },
    onSuccess: () => {
      toast.success("Episode berhasil ditambahkan");
      void qc.invalidateQueries({ queryKey: ["content", slug] });
      onSuccess?.();
    },
    onError: (error) => toast.error(apiErrorMessage(error)),
  });
}

/** POST /api/admin/episodes/:id/servers — simpan link embed.
 * Body: { provider, quality, url, isPremium } — field `url` (bukan `embedUrl`)
 * sesuai `serverSchema` di backend. Console.log body & respons untuk debug;
 * error 400/500 tetap lempar → toast di onError (modal TIDAK ditutup). */
export function useAddServer(
  episodeId: string,
  onSuccess?: () => void,
): UseMutationResult<unknown, unknown, ServerBody> {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (body: {
      provider: string;
      quality: string;
      url: string;
      isPremium: boolean;
    }) => {
      // eslint-disable-next-line no-console
      console.log(`[addServer:${episodeId}] POST body`, body);
      try {
        const res = await api.post<ApiResponse<StreamServer>>(
          `/api/admin/episodes/${episodeId}/servers`,
          body,
        );
        // eslint-disable-next-line no-console
        console.log(`[addServer:${episodeId}] OK`, res.data);
        return res.data.data;
      } catch (error) {
        if (axios.isAxiosError(error)) {
          // eslint-disable-next-line no-console
          console.error(`[addServer:${episodeId}] GAGAL`, {
            status: error.response?.status,
            data: error.response?.data,
            body,
          });
        } else {
          // eslint-disable-next-line no-console
          console.error(`[addServer:${episodeId}] GAGAL (non-axios)`, error);
        }
        throw error; // → onError: toast pesan API (termasuk kode status).
      }
    },
    onSuccess: () => {
      toast.success("Link video berhasil disimpan");
      void qc.invalidateQueries({ queryKey: ["servers", episodeId] });
      void qc.invalidateQueries({ queryKey: ["content"] });
      onSuccess?.();
    },
    onError: (error) => toast.error(apiErrorMessage(error)),
  });
}

export function useDeleteServer(episodeId: string) {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (serverId: string) => {
      const res = await api.delete<ApiResponse<{ deleted: boolean }>>(
        `/api/admin/servers/${serverId}`,
      );
      return res.data.data;
    },
    onSuccess: () => {
      toast.success("Link video dihapus");
      void qc.invalidateQueries({ queryKey: ["servers", episodeId] });
      void qc.invalidateQueries({ queryKey: ["content"] });
    },
    onError: (error) => toast.error(apiErrorMessage(error)),
  });
}

/* ---------------------------- TIPE BANTU ----------------------------- */

export type ServerBody = {
  provider: string;
  quality: string;
  url: string;
  isPremium: boolean;
};
