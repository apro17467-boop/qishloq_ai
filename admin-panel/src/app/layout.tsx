import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "QISHLOQ AI Admin",
  description: "Admin panel skeleton for QISHLOQ AI"
};

export default function RootLayout({
  children
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="uz">
      <body>{children}</body>
    </html>
  );
}
