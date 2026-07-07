"use client";

import { useRouter } from "next/navigation";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { clearAccessToken } from "@/lib/auth";

export function Header() {
  const router = useRouter();

  function handleLogout() {
    clearAccessToken();
    router.replace("/login");
  }

  return (
    <header className="border-b border-slate-200 bg-white">
      <div className="flex min-h-16 flex-col justify-center gap-3 px-4 py-4 sm:flex-row sm:items-center sm:justify-between sm:px-6 lg:px-8">
        <div>
          <p className="text-base font-semibold text-field-900">QISHLOQ AI Admin</p>
          <p className="mt-1 text-sm text-slate-500">Backend MVP v0.1</p>
        </div>

        <div className="flex items-center gap-3">
          <Badge variant="secondary">Admin</Badge>
          <div className="text-right">
            <p className="text-sm font-medium text-slate-900">Admin User</p>
            <p className="text-xs text-slate-500">admin@example.local</p>
          </div>
          <Button type="button" variant="secondary" onClick={handleLogout}>
            Chiqish
          </Button>
        </div>
      </div>
    </header>
  );
}
