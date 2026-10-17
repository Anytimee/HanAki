"use client";

import { Clapperboard, LayoutDashboard, Library, LogOut } from "lucide-react";
import Link from "next/link";
import { usePathname, useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { clearToken, getStoredUser } from "@/lib/auth";
import { cn } from "@/lib/utils";

const NAV_ITEMS = [
  { href: "/", label: "Dashboard", icon: LayoutDashboard },
  { href: "/contents", label: "Kelola Anime", icon: Library },
] as const;

export function Sidebar() {
  const pathname = usePathname();
  const router = useRouter();
  const user = getStoredUser();

  const logout = () => {
    clearToken();
    router.replace("/login");
  };

  return (
    <aside className="flex w-60 shrink-0 flex-col border-r border-zinc-800 bg-zinc-900">
      <div className="flex items-center gap-2 border-b border-zinc-800 px-6 py-5">
        <Clapperboard className="h-6 w-6 text-emerald-400" />
        <div>
          <p className="text-base font-bold leading-tight">HanAki</p>
          <p className="text-xs text-zinc-500">Admin Panel</p>
        </div>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {NAV_ITEMS.map(({ href, label, icon: Icon }) => {
          const active =
            href === "/" ? pathname === "/" : pathname.startsWith(href);
          return (
            <Link
              key={href}
              href={href}
              className={cn(
                "flex items-center gap-3 rounded-md px-3 py-2 text-sm font-medium transition-colors",
                active
                  ? "bg-zinc-800 text-white"
                  : "text-zinc-400 hover:bg-zinc-800/60 hover:text-zinc-100",
              )}
            >
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          );
        })}
      </nav>

      <div className="border-t border-zinc-800 p-3">
        <p className="truncate px-3 pb-2 text-xs text-zinc-500">
          {user?.email ?? "admin"}
        </p>
        <Button
          variant="ghost"
          className="w-full justify-start gap-3 text-zinc-400 hover:text-red-400"
          onClick={logout}
        >
          <LogOut className="h-4 w-4" />
          Logout
        </Button>
      </div>
    </aside>
  );
}
