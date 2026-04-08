"use client";

import { useEffect } from "react";
import { useFontStore } from "@/store/fontStore";

export default function FontInitializer() {
  const fontMode = useFontStore((state) => state.fontMode);

  useEffect(() => {
    if (fontMode === "dot") {
      document.documentElement.setAttribute("data-font", "dot");
    } else {
      document.documentElement.removeAttribute("data-font");
    }
  }, [fontMode]);

  return null;
}
