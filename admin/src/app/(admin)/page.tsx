"use client";

import { Film, Library, Link2, Loader2, Users } from "lucide-react";
import {
  Card,
  CardContent,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { apiErrorMessage } from "@/lib/api";
import { useDashboard } from "@/hooks/use-api";

const CARDS = [
  { key: "contents" as const, label: "Total Konten", icon: Library },
  { key: "episodes" as const, label: "Total Episode", icon: Film },
  { key: "servers" as const, label: "Link Embed", icon: Link2 },
  { key: "users" as const, label: "Pengguna", icon: Users },
];

export default function DashboardPage() {
  const { data, isLoading, error } = useDashboard();

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-sm text-zinc-400">
          Ringkasan data HanAki — kelola link embed video di halaman Konten.
        </p>
      </div>

      {isLoading ? (
        <div className="flex items-center gap-2 text-zinc-400">
          <Loader2 className="h-4 w-4 animate-spin" /> Memuat statistik…
        </div>
      ) : error ? (
        <p className="text-sm text-red-400">{apiErrorMessage(error)}</p>
      ) : (
        <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
          {CARDS.map(({ key, label, icon: Icon }) => (
            <Card key={key} className="border-zinc-800 bg-zinc-900">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium text-zinc-400">
                  {label}
                </CardTitle>
                <Icon className="h-4 w-4 text-zinc-500" />
              </CardHeader>
              <CardContent>
                <div className="text-3xl font-bold">
                  {data ? data[key] : 0}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
