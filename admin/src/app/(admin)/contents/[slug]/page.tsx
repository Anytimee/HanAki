"use client";

import { Loader2, PlusCircle } from "lucide-react";
import { useState } from "react";
import { AddEpisodeDialog } from "@/components/add-episode-dialog";
import { LinkManagerDialog } from "@/components/link-manager-dialog";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { apiErrorMessage } from "@/lib/api";
import { useContent } from "@/hooks/use-api";
import type { EpisodeSummary } from "@/types/api";

const TYPE_LABEL: Record<string, string> = {
  ANIME: "Anime",
  DRAKOR: "Drakor",
  DONGHUA: "Donghua",
};

export default function ContentDetailPage({
  params,
}: {
  params: { slug: string };
}) {
  const slug = decodeURIComponent(params.slug);
  const { data: content, isLoading, error } = useContent(slug);

  const [addOpen, setAddOpen] = useState(false);
  const [activeEpisode, setActiveEpisode] = useState<EpisodeSummary | null>(
    null,
  );

  if (isLoading) {
    return (
      <div className="animate-pulse space-y-4">
        <div className="h-8 w-64 rounded bg-zinc-800" />
        <div className="h-40 w-full rounded bg-zinc-800" />
      </div>
    );
  }

  if (error || !content) {
    return (
      <p className="text-sm text-red-400">
        {error ? apiErrorMessage(error) : "Konten tidak ditemukan."}
      </p>
    );
  }

  return (
    <div className="space-y-6">
      <Card className="border-zinc-800 bg-zinc-900">
        <CardHeader>
          <div className="flex flex-wrap items-center gap-2">
            <CardTitle className="text-xl">{content.title}</CardTitle>
            <Badge variant="secondary">
              {TYPE_LABEL[content.type] ?? content.type}
            </Badge>
            <Badge variant="outline">{content.status}</Badge>
          </div>
          <CardDescription className="text-zinc-400">
            {content.slug}
          </CardDescription>
        </CardHeader>
        {content.synopsis && (
          <CardContent>
            <p className="line-clamp-3 text-sm text-zinc-300">
              {content.synopsis}
            </p>
          </CardContent>
        )}
      </Card>

      <Card className="border-zinc-800 bg-zinc-900">
        <CardHeader className="flex flex-row items-center justify-between">
          <div>
            <CardTitle>Daftar Episode</CardTitle>
            <CardDescription className="text-zinc-400">
              Klik “Kelola Link Video” untuk menambah/menghapus link embed.
            </CardDescription>
          </div>
          <Button onClick={() => setAddOpen(true)}>
            <PlusCircle className="mr-2 h-4 w-4" />
            Tambah Episode
          </Button>
        </CardHeader>
        <CardContent>
          {content.episodes.length === 0 ? (
            <p className="py-8 text-center text-sm text-zinc-500">
              Belum ada episode. Klik “Tambah Episode” untuk memulai.
            </p>
          ) : (
            <ul className="divide-y divide-zinc-800">
              {content.episodes.map((ep) => (
                <li
                  key={ep.id}
                  className="flex flex-wrap items-center justify-between gap-3 py-3"
                >
                  <div>
                    <p className="font-medium">
                      EP {ep.episodeNum} — {ep.title}
                    </p>
                    <p className="text-xs text-zinc-500">
                      {ep._count.servers} link video
                    </p>
                  </div>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setActiveEpisode(ep)}
                  >
                    Kelola Link Video
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>

      <AddEpisodeDialog
        contentId={content.id}
        slug={slug}
        open={addOpen}
        onOpenChange={setAddOpen}
      />
      <LinkManagerDialog
        episode={activeEpisode}
        onOpenChange={(o) => {
          if (!o) setActiveEpisode(null);
        }}
      />
    </div>
  );
}
