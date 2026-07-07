"use client";

import { useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import {
  clearAccessToken,
  getAccessToken,
  getMe,
  isAdminUser
} from "@/lib/auth";

type ProtectedAdminRouteProps = {
  children: React.ReactNode;
};

export function ProtectedAdminRoute({ children }: ProtectedAdminRouteProps) {
  const router = useRouter();
  const [isAllowed, setIsAllowed] = useState(false);

  useEffect(() => {
    let isMounted = true;

    async function verifyAdminAccess() {
      const token = getAccessToken();

      if (!token) {
        router.replace("/login");
        return;
      }

      try {
        const response = await getMe(token);

        if (!isAdminUser(response.user)) {
          clearAccessToken();
          router.replace("/login");
          return;
        }

        if (isMounted) {
          setIsAllowed(true);
        }
      } catch {
        clearAccessToken();
        router.replace("/login");
      }
    }

    void verifyAdminAccess();

    return () => {
      isMounted = false;
    };
  }, [router]);

  if (!isAllowed) {
    return (
      <main className="flex min-h-screen items-center justify-center bg-field-50 px-4 py-10">
        <div className="w-full max-w-md rounded-lg border border-slate-200 bg-white p-5 text-center shadow-soft">
          <p className="text-sm font-medium text-field-700">
            Admin huquqlari tekshirilmoqda...
          </p>
        </div>
      </main>
    );
  }

  return children;
}
