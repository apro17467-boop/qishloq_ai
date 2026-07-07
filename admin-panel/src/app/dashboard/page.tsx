"use client";

import { useCallback, useEffect, useMemo, useState } from "react";
import { AdminShell } from "@/components/layout/AdminShell";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { Badge } from "@/components/ui/Badge";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { getDashboardStats } from "@/lib/dashboard";
import { getAccessToken } from "@/lib/auth";
import type { DashboardStats } from "@/types/api";

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const cards = useMemo(
    () => [
      {
        label: "Foydalanuvchilar",
        value: stats?.usersTotal,
        status: "Users"
      },
      {
        label: "Moderatsiya kutilmoqda",
        value: stats?.pendingListings,
        status: "Review"
      },
      {
        label: "Faol e'lonlar",
        value: stats?.activeListings,
        status: "Active"
      },
      {
        label: "Ochiq shikoyatlar",
        value: stats?.openComplaints,
        status: "Open"
      }
    ],
    [stats]
  );

  const loadStats = useCallback(async () => {
    const token = getAccessToken();

    if (!token) {
      setLoading(false);
      return;
    }

    setLoading(true);
    setError(null);

    try {
      const response = await getDashboardStats(token);
      setStats(response);
    } catch {
      setError("Dashboard ma'lumotlarini yuklashda xatolik yuz berdi");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadStats();
  }, [loadStats]);

  return (
    <ProtectedAdminRoute>
      <AdminShell>
        <div className="space-y-6">
          <div className="flex flex-col gap-2 sm:flex-row sm:items-end sm:justify-between">
            <div>
              <p className="text-sm font-medium text-field-700">Overview</p>
              <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
                Dashboard
              </h1>
            </div>
            <p className="text-sm text-slate-500">
              Ma&apos;lumotlar backend API&apos;dan olinmoqda.
            </p>
          </div>

          {error ? (
            <Card className="flex flex-col gap-4 border-red-200 bg-red-50 sm:flex-row sm:items-center sm:justify-between">
              <p className="text-sm font-medium text-red-700">{error}</p>
              <Button type="button" variant="secondary" onClick={loadStats}>
                Qayta urinish
              </Button>
            </Card>
          ) : null}

          {loading ? (
            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
              {["users", "pending", "active", "complaints"].map((item) => (
                <Card key={item} className="min-h-32">
                  <div className="space-y-4">
                    <div className="h-4 w-32 rounded bg-slate-100" />
                    <div className="h-8 w-16 rounded bg-slate-100" />
                    <p className="text-sm text-slate-500">Yuklanmoqda...</p>
                  </div>
                </Card>
              ))}
            </div>
          ) : (
            <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
              {cards.map((card) => (
                <Card key={card.label} className="min-h-32">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <p className="text-sm font-medium text-slate-600">
                        {card.label}
                      </p>
                      <p className="mt-4 text-3xl font-semibold tracking-normal text-slate-950">
                        {card.value ?? 0}
                      </p>
                    </div>
                    <Badge>{card.status}</Badge>
                  </div>
                </Card>
              ))}
            </div>
          )}
        </div>
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
