import type { Metadata } from "next";
import type { ReactNode } from "react";
import { Providers } from "@/components/providers";
import "./globals.css";

export const metadata: Metadata = {
  title: "HanAki Admin",
  description: "Panel admin streaming HanAki — Anime, Drakor, Donghua",
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="id" className="dark">
      <body className="min-h-screen bg-zinc-950 font-sans text-zinc-100 antialiased">
        <Providers>{children}</Providers>
      </body>
    </html>
  );
}
