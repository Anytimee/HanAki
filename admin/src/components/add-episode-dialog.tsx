"use client";

import { zodResolver } from "@hookform/resolvers/zod";
import { Loader2 } from "lucide-react";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { useCreateEpisode } from "@/hooks/use-api";

const episodeSchema = z.object({
  episodeNum: z.coerce
    .number({ invalid_type_error: "Nomor episode harus angka" })
    .int("Nomor episode harus bilangan bulat")
    .min(1, "Nomor episode minimal 1"),
  title: z.string().trim().min(1, "Judul episode wajib diisi"),
});

type EpisodeValues = z.infer<typeof episodeSchema>;

interface Props {
  contentId: string;
  slug: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

export function AddEpisodeDialog({ contentId, slug, open, onOpenChange }: Props) {
  const createEpisode = useCreateEpisode(contentId, slug, () =>
    onOpenChange(false),
  );

  const form = useForm<EpisodeValues>({
    resolver: zodResolver(episodeSchema),
    defaultValues: { episodeNum: 1, title: "" },
  });

  const onSubmit = (values: EpisodeValues) =>
    createEpisode.mutate({
      episodeNum: values.episodeNum,
      title: values.title,
    });

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="border-zinc-800 bg-zinc-900 sm:max-w-md">
        <DialogHeader>
          <DialogTitle>Tambah Episode</DialogTitle>
          <DialogDescription className="text-zinc-400">
            Tambahkan episode baru ke judul ini. Link video menyusul lewat
            tombol “Kelola Link Video”.
          </DialogDescription>
        </DialogHeader>
        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-4"
            noValidate
          >
            <FormField
              control={form.control}
              name="episodeNum"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Nomor Episode</FormLabel>
                  <FormControl>
                    <Input
                      type="number"
                      min={1}
                      placeholder="1"
                      {...field}
                    />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="title"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Judul Episode</FormLabel>
                  <FormControl>
                    <Input placeholder="Awal dari Segalanya" {...field} />
                  </FormControl>
                  <FormMessage />
                </FormItem>
              )}
            />
            <DialogFooter>
              <Button
                type="button"
                variant="ghost"
                onClick={() => onOpenChange(false)}
              >
                Batal
              </Button>
              <Button type="submit" disabled={createEpisode.isPending}>
                {createEpisode.isPending && (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                )}
                Simpan Episode
              </Button>
            </DialogFooter>
          </form>
        </Form>
      </DialogContent>
    </Dialog>
  );
}
