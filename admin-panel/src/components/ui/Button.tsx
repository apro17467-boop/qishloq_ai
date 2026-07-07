import type { ButtonHTMLAttributes } from "react";

type ButtonVariant = "primary" | "secondary";

type ButtonProps = ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: ButtonVariant;
};

const variants: Record<ButtonVariant, string> = {
  primary:
    "bg-field-700 text-white hover:bg-field-600 focus-visible:outline-field-700",
  secondary:
    "border border-slate-300 bg-white text-slate-800 hover:bg-slate-50 focus-visible:outline-slate-500"
};

export function Button({
  className = "",
  variant = "primary",
  disabled,
  ...props
}: ButtonProps) {
  return (
    <button
      className={[
        "inline-flex min-h-10 items-center justify-center rounded-lg px-4 text-sm font-semibold shadow-sm transition focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 disabled:cursor-not-allowed disabled:opacity-60",
        variants[variant],
        className
      ].join(" ")}
      disabled={disabled}
      {...props}
    />
  );
}
