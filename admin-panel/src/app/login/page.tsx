import { Button } from "@/components/ui/Button";
import { Card } from "@/components/ui/Card";
import { Input } from "@/components/ui/Input";

export default function LoginPage() {
  // TODO: connect to `/auth/request-otp` and `/auth/verify-otp`.
  return (
    <main className="flex min-h-screen items-center justify-center bg-field-50 px-4 py-10">
      <div className="w-full max-w-md">
        <div className="mb-6">
          <p className="text-sm font-medium text-field-700">QISHLOQ AI Admin</p>
          <h1 className="mt-2 text-2xl font-semibold tracking-normal text-field-900">
            Admin kirish
          </h1>
        </div>

        <Card className="space-y-5">
          <Input label="Telefon raqam" placeholder="+998901234567" inputMode="tel" />
          <Input label="OTP kod" placeholder="111111" inputMode="numeric" />
          <Button type="button" className="w-full">
            Kirish
          </Button>
        </Card>
      </div>
    </main>
  );
}
