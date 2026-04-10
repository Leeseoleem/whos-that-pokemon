export default function MonsterBallIcon({
  size = 20,
  color = "#111827",
}: {
  size?: number;
  color?: string;
}) {
  return (
    <svg
      width={size}
      height={size}
      viewBox="0 0 100 100"
      xmlns="http://www.w3.org/2000/svg"
      fill="none"
    >
      <defs>
        <mask id="pokeball-cutout">
          <rect width="100" height="100" fill="white" />
          {/* 가로 밴드 */}
          <rect x="0" y="43" width="100" height="14" fill="black" />
          {/* 중앙 원 */}
          <circle cx="50" cy="50" r="16" fill="black" />
        </mask>
      </defs>
      {/* 빨간 원 (나머지 투명) */}
      <circle
        cx="50"
        cy="50"
        r="45"
        fill={color}
        mask="url(#pokeball-cutout)"
      />
    </svg>
  );
}
