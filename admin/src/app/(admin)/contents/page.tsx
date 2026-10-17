"use client";

import { Loader2, Search } from "lucide-react";
import Image from "next/image";
import Link from "next/link";
import { useState, type FormEvent } from "react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { apiErrorMessage } from "@/lib/api";
import { useContents } from "@/hooks/use-api";
import type { ContentType } from "@/types/api";

const TYPE_LABEL: Record<ContentType, string> = {
  ANIME: "Anime",
  DRAKOR: "Drakor",
  DONGHUA: "Donghua",
};

const PAGE_SIZE = 10;

export default function ContentsPage() {
  const [searchInput, setSearchInput] = useState("");
  const [search, setSearch] = useState("");
  const [type, setType] = useState<"" | "ANIME" | "DRAKOR" | "DONGHUA">("");
  const [page, setPage] = useState(1);

  const { data, isLoading, error } = useContents({
    page,
    limit: PAGE_SIZE,
    search: search || undefined,
    type: (type || undefined) as ContentType | undefined,
  });

  const onSearch = (e: FormEvent) => {
    e.preventDefault();
    setSearch(searchInput.trim());
    setPage(1);
  };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-bold tracking-tight">Kelola Konten</h1>
        <p className="text-sm text-zinc-400">
          Pilih judul untuk mengelola episode & link embed video.
        </p>
      </div>

      <form onSubmit={onSearch} className="flex flex-wrap items-center gap-3">
        <div className="relative w-full max-w-xs">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-zinc-500" />
          <Input
            value={searchInput}
            onChange={(e) => setSearchInput(e.target.value)}
            placeholder="Cari judul…"
            className="pl-9"
          />
        </div>
        <Select
          value={type || "ALL"}
          onValueChange={(v) => {
            setType(v === "ALL" ? "" : (v as typeof type));
            setPage(1);
          }}
        >
          <SelectTrigger className="w-40">
            <SelectValue placeholder="Semua Tipe" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="ALL">Semua Tipe</SelectItem>
            <SelectItem value="ANIME">Anime</SelectItem>
            <SelectItem value="DRAKOR">Drakor</SelectItem>
            <SelectItem value="DONGHUA">Donghua</SelectItem>
          </SelectContent>
        </Select>
        <Button type="submit" variant="secondary">
          Cari
        </Button>
      </form>
      {isLoading ? (
        <div className="flex items-center gap-2 text-zinc-400">
          <Loader2 className="h-4 w-4 animate-spin" /> Memuat konten…
        </div>
      ) : error ? (
        <p className="text-sm text-red-400">{apiErrorMessage(error)}</p>
      ) : (
        <>
          <div className="rounded-lg border border-zinc-800 bg-zinc-900">
            <Table>
              <TableHeader>
                <TableRow className="border-zinc-800 hover:bg-transparent">
                  <TableHead className="text-zinc-400">Judul</TableHead>
                  <TableHead className="text-zinc-400">Tipe</TableHead>
                  <TableHead className="text-zinc-400">Episode</TableHead>
                  <TableHead className="text-right text-zinc-400">
                    Aksi
                  </TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data?.items.length === 0 && (
                  <TableRow className="border-zinc-800">
                    <TableCell
                      colSpan={4}
                      className="py-10 text-center text-zinc-500"
                    >
                      Tidak ada konten ditemukan.
                    </TableCell>
                  </TableRow>
                )}
                {data?.items.map((content) => (
                  <TableRow key={content.id} className="border-zinc-800">
                    <TableCell>
                      <div className="flex items-center gap-3">
                        {content.posterUrl ? (
                          <Image
                            src={content.posterUrl}
                            alt={content.title}
                            width={36}
                            height={50}
                            className="h-[50px] w-[36px] rounded object-cover"
                          />
                        ) : (
                          <div className="h-[50px] w-[36px] rounded bg-zinc-800" />
                        )}
                        <span className="font-medium">{content.title}</span>
                      </div>
                    </TableCell>
                    <TableCell>
                      <Badge variant="secondary">
                        {TYPE_LABEL[content.type] ?? content.type}
                      </Badge>
                    </TableCell>
                    <TableCell className="text-zinc-400">
                      {content._count?.episodes ?? 0}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button asChild size="sm" variant="outline">
                        <Link href={`/contents/${content.slug}`}>
                          Kelola Episode
                        </Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </div>

          <div className="flex items-center justify-between text-sm text-zinc-400">
            <span>
              Halaman {data?.meta.page ?? 1} dari {data?.meta.totalPages ?? 1} ·{" "}
              {data?.meta.total ?? 0} judul
            </span>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={page <= 1}
                onClick={() => setPage((p) => Math.max(1, p - 1))}
              >
                Sebelumnya
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={(data?.meta.page ?? 1) >= (data?.meta.totalPages ?? 1)}
                onClick={() => setPage((p) => p + 1)}
              >
                Berikutnya
              </Button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}

