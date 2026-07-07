"use client";

import { FormEvent, useEffect, useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";
import {
  clearAccessToken,
  getAccessToken,
  getMe,
  isAdminUser,
  requestAdminOtp,
  saveAccessToken,
  verifyAdminOtp
} from "@/lib/auth";

type LoginStep = "phone" | "otp";

export default function LoginPage() {
  const router = useRouter();
  const [phone, setPhone] = useState("");
  const [code, setCode] = useState("");
  const [devCode, setDevCode] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [step, setStep] = useState<LoginStep>("phone");
  const [checkingExistingToken, setCheckingExistingToken] = useState(true);

  useEffect(() => {
    let isMounted = true;

    async function verifyExistingToken() {
      const token = getAccessToken();

      if (!token) {
        setCheckingExistingToken(false);
        return;
      }

      try {
        const response = await getMe(token);

        if (isAdminUser(response.user)) {
          router.replace("/dashboard");
          return;
        }

        clearAccessToken();
      } catch {
        clearAccessToken();
      }

      if (isMounted) {
        setCheckingExistingToken(false);
      }
    }

    void verifyExistingToken();

    return () => {
      isMounted = false;
    };
  }, [router]);

  async function handleRequestOtp() {
    setLoading(true);
    setError(null);
    setMessage(null);
    setDevCode(null);

    try {
      const response = await requestAdminOtp(phone);
      setStep("otp");
      setDevCode(response.devCode ?? null);
      setMessage(response.message || "OTP kod yuborildi.");
    } catch (caughtError) {
      setError(
        caughtError instanceof Error
          ? caughtError.message
          : "OTP yuborishda xatolik yuz berdi."
      );
    } finally {
      setLoading(false);
    }
  }

  async function handleVerifyOtp() {
    setLoading(true);
    setError(null);
    setMessage(null);

    try {
      const response = await verifyAdminOtp({ phone, code });
      saveAccessToken(response.accessToken);

      const me = await getMe(response.accessToken);

      if (!isAdminUser(me.user)) {
        clearAccessToken();
        setError("Bu panelga faqat ADMIN foydalanuvchi kira oladi.");
        return;
      }

      router.push("/dashboard");
    } catch (caughtError) {
      clearAccessToken();
      setError(
        caughtError instanceof Error
          ? caughtError.message
          : "Kirishda xatolik yuz berdi."
      );
    } finally {
      setLoading(false);
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (step === "phone") {
      await handleRequestOtp();
      return;
    }

    await handleVerifyOtp();
  }

  if (checkingExistingToken) {
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

  return (
    <main className="flex min-h-screen items-center justify-center bg-field-50 px-4 py-10">
      <div className="w-full max-w-md">
        <div className="mb-6">
          <p className="text-sm font-medium text-field-700">QISHLOQ AI Admin</p>
          <h1 className="mt-2 text-2xl font-semibold tracking-normal text-field-900">
            Admin kirish
          </h1>
        </div>

        <Card>
          <form className="space-y-5" onSubmit={handleSubmit}>
            <Input
              label="Telefon raqam"
              placeholder="+998901234567"
              inputMode="tel"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
              disabled={loading || step === "otp"}
            />

            {step === "otp" ? (
              <Input
                label="OTP kod"
                placeholder="111111"
                inputMode="numeric"
                value={code}
                onChange={(event) => setCode(event.target.value)}
                disabled={loading}
              />
            ) : null}

            {devCode ? (
              <div className="rounded-lg border border-field-100 bg-field-50 px-3 py-2 text-sm font-medium text-field-700">
                Dev OTP: {devCode}
              </div>
            ) : null}

            {message ? (
              <div className="rounded-lg border border-field-100 bg-white px-3 py-2 text-sm text-field-700">
                {message}
              </div>
            ) : null}

            {error ? (
              <div className="rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-sm text-red-700">
                {error}
              </div>
            ) : null}

            <Button type="submit" className="w-full" disabled={loading}>
              {loading
                ? "Kutilmoqda..."
                : step === "phone"
                  ? "OTP yuborish"
                  : "Kirish"}
            </Button>

            {step === "otp" ? (
              <Button
                type="button"
                variant="secondary"
                className="w-full"
                disabled={loading}
                onClick={() => {
                  setStep("phone");
                  setCode("");
                  setDevCode(null);
                  setError(null);
                  setMessage(null);
                }}
              >
                Telefonni o&apos;zgartirish
              </Button>
            ) : null}
          </form>
        </Card>
      </div>
    </main>
  );
}
