import Link from "next/link";

const menuItems = [
  { label: "Dashboard", href: "/dashboard", active: true },
  { label: "Listings", href: "#", active: false },
  { label: "Complaints", href: "#", active: false },
  { label: "Users", href: "#", active: false },
  { label: "AI Questions", href: "#", active: false },
  { label: "Settings", href: "#", active: false }
];

export function Sidebar() {
  return (
    <aside className="hidden w-64 shrink-0 border-r border-slate-200 bg-white px-4 py-5 md:block">
      <div className="mb-8">
        <p className="text-lg font-semibold tracking-normal text-field-900">QISHLOQ AI</p>
        <p className="mt-1 text-xs font-medium uppercase tracking-wide text-slate-500">
          Admin panel
        </p>
      </div>

      <nav className="space-y-1">
        {menuItems.map((item) => (
          <Link
            key={item.label}
            href={item.href}
            className={[
              "block rounded-lg px-3 py-2 text-sm font-medium transition",
              item.active
                ? "bg-field-100 text-field-900"
                : "text-slate-600 hover:bg-slate-100 hover:text-slate-950"
            ].join(" ")}
          >
            {item.label}
          </Link>
        ))}
      </nav>
    </aside>
  );
}
