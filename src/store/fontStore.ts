import { create } from "zustand";
import { persist } from "zustand/middleware";

type FontMode = "main" | "dot";

interface FontStore {
  fontMode: FontMode;
  toggleFont: () => void;
  setFont: (mode: FontMode) => void;
}

export const useFontStore = create<FontStore>()(
  persist(
    (set) => ({
      fontMode: "main",
      toggleFont: () =>
        set((state) => {
          const next = state.fontMode === "main" ? "dot" : "main";
          if (next === "dot") {
            document.documentElement.setAttribute("data-font", "dot");
          } else {
            document.documentElement.removeAttribute("data-font");
          }
          return { fontMode: next };
        }),
      setFont: (mode) => {
        if (mode === "dot") {
          document.documentElement.setAttribute("data-font", "dot");
        } else {
          document.documentElement.removeAttribute("data-font");
        }
        set({ fontMode: mode });
      },
    }),
    {
      name: "font-mode",
    },
  ),
);
