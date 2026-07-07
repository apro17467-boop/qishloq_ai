import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/app/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{js,ts,jsx,tsx,mdx}",
    "./src/lib/**/*.{js,ts,jsx,tsx,mdx}"
  ],
  theme: {
    extend: {
      colors: {
        field: {
          50: "#f4fbf5",
          100: "#e5f5e8",
          600: "#2f7d46",
          700: "#246338",
          900: "#14351f"
        }
      },
      boxShadow: {
        soft: "0 1px 2px rgba(16, 24, 40, 0.06), 0 1px 3px rgba(16, 24, 40, 0.1)"
      }
    }
  },
  plugins: []
};

export default config;
