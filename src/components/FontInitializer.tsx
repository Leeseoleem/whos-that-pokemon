"use client";

import { useEffect } from "react";
import { useFontStore } from "@/store/fontStore";

export default function FontInitializer() {
  const fontMode = useFontStore((state) => state.fontMode);

  useEffect(() => {
    document.documentElement.setAttribute(
      "data-font",
      fontMode === "dot" ? "dot" : "",
    );
  }, [fontMode]);

  return null;
}
