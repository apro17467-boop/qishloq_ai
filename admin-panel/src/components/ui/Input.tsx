import type { InputHTMLAttributes } from "react";

type InputProps = InputHTMLAttributes<HTMLInputElement> & {
  label: string;
};

export function Input({ className = "", id, label, ...props }: InputProps) {
  const inputId = id ?? label.toLowerCase().replace(/\s+/g, "-");

  return (
    <label htmlFor={inputId} className="block">
      <span className="mb-2 block text-sm font-medium text-slate-700">{label}</span>
      <input
        id={inputId}
        className={[
          "block min-h-11 w-full rounded-lg border border-slate-300 bg-white px-3 text-sm text-slate-950 outline-none transition placeholder:text-slate-400 focus:border-field-600 focus:ring-2 focus:ring-field-100 disabled:cursor-not-allowed disabled:bg-slate-100 disabled:text-slate-500",
          className
        ].join(" ")}
        {...props}
      />
    </label>
  );
}
