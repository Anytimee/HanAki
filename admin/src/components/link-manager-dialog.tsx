"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { ExternalLink, Loader2, Trash2 } from "lucide-react";
import { useEffect } from "react";
import { useForm } from "react-hook-form";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  PROVIDERS,
  QUALITIES,
  serverFormSchema,
  type ServerFormValues,
} from "@/lib/embed";
import { useAddServer, useDeleteServer, useEpisodeServers } from "@/hooks/use-api";
import { apiErrorMessage } from "@/lib/api";
import type { EpisodeSummary } from "@/types/api";

const DEFAULTS: ServerFormValues = {
  provider: "Dailymotion",
  quality: "720p",
  url: "",
  isPremium: false,
};

interface Props {
  episode: EpisodeSummary | null;
  onOpenChange: (open: boolean) => void;
}

/**
 * MODAL KELOLA LINK VIDEO — fitur inti panel admin.
 * Menampilkan list link embed per episode + form tambah
 * (POST /api/admin/episodes/:id/servers).
 */
export function LinkManagerDialog({ episode, onOpenChange }: Props) {
  const open = episode !== null;
  const episodeId = episode?.id ?? "";

  const {
    data: servers,
    isLoading,
    isError: isListError,
    error: listError,
    refetch,
    isRefetching,
  } = useEpisodeServers(episodeId, open);
  const deleteServer = useDeleteServer(episodeId);

  const form = useForm<ServerFormValues>({
    resolver: zodResolver(serverFormSchema),
    defaultValues: DEFAULTS,
  });

  const addServer = useAddServer(episodeId, () => form.reset(DEFAULTS));

  // Ganti episode → bersihkan form agar sisa input tidak "bocor".
  useEffect(() => {
    form.reset(DEFAULTS);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [episodeId]);

  const onSubmit = (values: ServerFormValues) => {
    // Log payload yang dikirim — bantu diagnosa "tidak tersimpan".
    // eslint-disable-next-line no-console
    console.log("[LinkManager] submit", { episodeId, ...values });
    addServer.mutate(values);
  };

  const onDelete = (serverId: string) => {
    if (window.confirm("Hapus link video ini?")) {
      deleteServer.mutate(serverId);
    }
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="max-h-[85vh] overflow-y-auto border-zinc-800 bg-zinc-900 sm:max-w-2xl">
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            Kelola Link Video
            {episode && (
              <Badge variant="secondary">EP {episode.episodeNum}</Badge>
            )}
          </DialogTitle>
          <DialogDescription className="text-zinc-400">
            {episode
              ? `Episode "${episode.title}" — tempel URL EMBED dari provider (bukan link halaman biasa).`
              : ""}
          </DialogDescription>
        </DialogHeader>

        {isListError ? (
          // Error memuat list JANGAN disembunyikan sebagai "Belum ada link" —
          // tampilkan pesan API + tombol coba ulang.
          <div className="space-y-3 rounded-lg border border-red-500/30 bg-red-500/10 p-4">
            <p className="text-sm text-red-400">
              Gagal memuat link video: {apiErrorMessage(listError)}
            </p>
            <Button
              size="sm"
              variant="outline"
              disabled={isRefetching}
              onClick={() => refetch()}
            >
              {isRefetching ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : null}
              Muat Ulang
            </Button>
          </div>
        ) : isLoading ? (
          <div className="flex items-center gap-2 py-6 text-sm text-zinc-400">
            <Loader2 className="h-4 w-4 animate-spin" /> Memuat link…
          </div>
        ) : !servers || servers.length === 0 ? (
          <p className="py-6 text-center text-sm text-zinc-500">
            Belum ada link video untuk episode ini.
          </p>
        ) : (
          <Table>
            <TableHeader>
              <TableRow className="border-zinc-800 hover:bg-transparent">
                <TableHead className="text-zinc-400">Provider</TableHead>
                <TableHead className="text-zinc-400">Kualitas</TableHead>
                <TableHead className="text-zinc-400">URL Embed</TableHead>
                <TableHead className="text-zinc-400">VIP</TableHead>
                <TableHead className="text-right text-zinc-400">
                  Aksi
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {servers.map((server) => (
                <TableRow key={server.id} className="border-zinc-800">
                  <TableCell className="font-medium">
                    {server.provider}
                  </TableCell>
                  <TableCell>
                    <Badge variant="outline">{server.quality}</Badge>
                  </TableCell>
                  <TableCell>
                    <a
                      href={server.url}
                      target="_blank"
                      rel="noreferrer"
                      className="flex max-w-[240px] items-center gap-1 truncate text-xs text-emerald-400 hover:underline"
                    >
                      <ExternalLink className="h-3 w-3 shrink-0" />
                      <span className="truncate">{server.url}</span>
                    </a>
                  </TableCell>
                  <TableCell>
                    {server.isPremium ? (
                      <Badge className="bg-amber-500/20 text-amber-400">
                        VIP
                      </Badge>
                    ) : (
                      <span className="text-xs text-zinc-500">Free</span>
                    )}
                  </TableCell>
                  <TableCell className="text-right">
                    <Button
                      size="icon"
                      variant="ghost"
                      className="h-8 w-8 text-zinc-400 hover:text-red-400"
                      disabled={deleteServer.isPending}
                      onClick={() => onDelete(server.id)}
                    >
                      <Trash2 className="h-4 w-4" />
                    </Button>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}

        <div className="space-y-1 border-t border-zinc-800 pt-4">
          <p className="text-sm font-semibold">Tambah Link</p>
          <p className="text-xs text-zinc-500">
            URL harus link EMBED (mis. https://www.dailymotion.com/embed/video/
            …). Path lokal & host di luar whitelist akan ditolak.
          </p>
        </div>

        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="grid gap-4 sm:grid-cols-2"
            noValidate
          >
            <FormField
              control={form.control}
              name="provider"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Provider</FormLabel>
                  <Select onValueChange={field.onChange} value={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Pilih provider" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {PROVIDERS.map((p) => (
                        <SelectItem key={p.value} value={p.value}>
                          {p.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="quality"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Kualitas</FormLabel>
                  <Select onValueChange={field.onChange} value={field.value}>
                    <FormControl>
                      <SelectTrigger>
                        <SelectValue placeholder="Pilih kualitas" />
                      </SelectTrigger>
                    </FormControl>
                    <SelectContent>
                      {QUALITIES.map((q) => (
                        <SelectItem key={q} value={q}>
                          {q}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="url"
              render={({ field }) => (
                <FormItem className="sm:col-span-2">
                  <FormLabel>URL Embed</FormLabel>
                  <FormControl>
                    <Input
                      placeholder="https://www.dailymotion.com/embed/video/x8abcde"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription className="text-xs text-zinc-500">
                    Didukung: {PROVIDERS.map((p) => p.label).join(", ")}, Mega,
                    dll. Bukan link halaman biasa.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="isPremium"
              render={({ field }) => (
                <FormItem className="flex flex-row items-center justify-between rounded-lg border border-zinc-800 p-3 sm:col-span-2">
                  <div className="space-y-0.5">
                    <FormLabel>VIP (Premium)</FormLabel>
                    <FormDescription className="text-xs text-zinc-500">
                      Hanya user berlangganan premium yang boleh menonton link
                      ini.
                    </FormDescription>
                  </div>
                  <FormControl>
                    <Switch
                      checked={field.value}
                      onCheckedChange={field.onChange}
                    />
                  </FormControl>
                </FormItem>
              )}
            />

            <div className="flex justify-end sm:col-span-2">
              <Button type="submit" disabled={addServer.isPending}>
                {addServer.isPending ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : null}
                Simpan Link
              </Button>
            </div>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}

