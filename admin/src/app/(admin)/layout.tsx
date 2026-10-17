"use client";

import { Loader2 } from "lucide-react";
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useState, type ReactNode } from "react";
import { Sidebar } from "@/components/sidebar";
import { getToken } from "@/lib/auth";

/** Guard: tanpa token admin → tendang ke /login. */
export default function AdminLayout({ children }: { children: ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const [authorized, setAuthorized] = useState(false);

  useEffect(() => {
    if (!getToken()) {
      router.replace("/login");
      return;
    }
    setAuthorized(true);
  }, [router, pathname]);

  if (!authorized) {
    return (
      <div className="flex min-h-screen items-center justify-center bg-zinc-950 text-zinc-400">
        <Loader2 className="mr-2 h-5 w-5 animate-spin" />
        Memuat panel admin…
      </div>
    );
  }

  return (
    <div className="flex min-h-screen bg-zinc-950">
      <Sidebar />
      <main className="min-w-0 flex-1 p-6 md:p-8">{children}</main>
    </div>
  );
}
