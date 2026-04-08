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
          document.documentElement.setAttribute(
            "data-font",
            next === "dot" ? "dot" : "",
          );
          return { fontMode: next };
        }),
      setFont: (mode) => {
        document.documentElement.setAttribute(
          "data-font",
          mode === "dot" ? "dot" : "",
        );
        set({ fontMode: mode });
      },
    }),
    {
      name: "font-mode",
    },
  ),
);
