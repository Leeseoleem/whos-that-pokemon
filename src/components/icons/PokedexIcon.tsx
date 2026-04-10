export default function PokedexIcon({
  size = 20,
  color = "#111827",
}: {
  size?: number;
  color?: string;
}) {
  return (
    <svg
      aria-hidden="true"
      width={size * 0.85}
      height={size}
      viewBox="0 0 17 20"
      fill="none"
    >
      <path
        fillRule="evenodd"
        fill={color}
        d={`
          M 2.4 0 H 14.6 Q 17 0 17 2.4
          V 17.6 Q 17 20 14.6 20
          H 2.4 Q 0 20 0 17.6
          V 2.4 Q 0 0 2.4 0 Z
          M 4.25 3 A 2 2 0 1 0 4.25 7 A 2 2 0 1 0 4.25 3 Z
          M 0 9.8 H 8.5 V 8 H 17 V 10 H 8.5 V 11.8 H 0 Z
        `}
      />
    </svg>
  );
}
