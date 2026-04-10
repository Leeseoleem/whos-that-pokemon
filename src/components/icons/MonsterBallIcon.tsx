import { useId } from "react";

export default function MonsterBallIcon({
  size = 20,
  color = "#111827",
}: {
  size?: number;
  color?: string;
}) {
  const maskId = `pokeball-cutout-${useId()}`;

  return (
    <svg
      aria-hidden="true"
      width={size}
      height={size}
      viewBox="0 0 100 100"
      fill="none"
    >
      <defs>
        <mask id={maskId}>
          <rect width="100" height="100" fill="white" />
          <rect x="0" y="43" width="100" height="14" fill="black" />
          <circle cx="50" cy="50" r="16" fill="black" />
        </mask>
      </defs>
      <circle cx="50" cy="50" r="45" fill={color} mask={`url(#${maskId})`} />
    </svg>
  );
}
