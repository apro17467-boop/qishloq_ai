import type { HTMLAttributes } from "react";

type BadgeVariant = "primary" | "secondary";

type BadgeProps = HTMLAttributes<HTMLSpanElement> & {
  variant?: BadgeVariant;
};

const variants: Record<BadgeVariant, string> = {
  primary: "bg-field-100 text-field-700 ring-field-100",
  secondary: "bg-amber-50 text-amber-700 ring-amber-100"
};

export function Badge({
  className = "",
  variant = "primary",
  ...props
}: BadgeProps) {
  return (
    <span
      className={[
        "inline-flex min-h-6 items-center rounded-full px-2.5 text-xs font-semibold ring-1",
        variants[variant],
        className
      ].join(" ")}
      {...props}
    />
  );
}
