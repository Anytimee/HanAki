export type ContentType = "ANIME" | "DRAKOR" | "DONGHUA";

export interface User {
  id: string;
  email: string;
  role: "ADMIN" | "USER";
  createdAt: string;
}

export interface Content {
  id: string;
  title: string;
  slug: string;
  type: ContentType;
  synopsis: string | null;
  posterUrl: string | null;
  status: string;
  createdAt: string;
  _count?: { episodes: number };
}

export interface EpisodeSummary {
  id: string;
  episodeNum: number;
  title: string;
  _count: { servers: number };
}

export interface ContentDetail extends Omit<Content, "_count"> {
  episodes: EpisodeSummary[];
}

export interface PageMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

export interface Paged<T> {
  items: T[];
  meta: PageMeta;
}

export interface StreamServer {
  id: string;
  episodeId: string;
  provider: string;
  quality: string;
  url: string;
  isPremium: boolean;
  createdAt: string;
  renderAs?: "webview" | "hls";
}

export interface DashboardStats {
  contents: number;
  episodes: number;
  users: number;
  servers: number;
}

export interface LoginResponse {
  user: User;
  token: string;
}

export interface ApiResponse<T> {
  success: boolean;
  data: T;
  error?: string;
}
