import { AdminShell } from "@/components/layout/AdminShell";
import { ProtectedAdminRoute } from "@/components/auth/ProtectedAdminRoute";
import { Badge } from "@/components/ui/Badge";
import { Card } from "@/components/ui/Card";

const stats = [
  { label: "Listings", value: "128", status: "Active" },
  { label: "Pending moderation", value: "12", status: "Review" },
  { label: "Complaints", value: "4", status: "Open" },
  { label: "Users", value: "86", status: "Verified" }
];

export default function DashboardPage() {
  // TODO: connect dashboard stats endpoint later.
  return (
    <ProtectedAdminRoute>
      <AdminShell>
        <div className="space-y-6">
          <div>
            <p className="text-sm font-medium text-field-700">Overview</p>
            <h1 className="mt-1 text-2xl font-semibold tracking-normal text-slate-950">
              Dashboard
            </h1>
          </div>

          <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
            {stats.map((stat) => (
              <Card key={stat.label} className="min-h-32">
                <div className="flex items-start justify-between gap-3">
                  <div>
                    <p className="text-sm font-medium text-slate-600">{stat.label}</p>
                    <p className="mt-4 text-3xl font-semibold tracking-normal text-slate-950">
                      {stat.value}
                    </p>
                  </div>
                  <Badge>{stat.status}</Badge>
                </div>
              </Card>
            ))}
          </div>
        </div>
      </AdminShell>
    </ProtectedAdminRoute>
  );
}
