export default function MonsterBallIcon({
  size = 20,
  color = "#9CA3AF",
}: {
  size?: number;
  color?: string;
}) {
  return (
    <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <circle cx="12" cy="12" r="9" stroke={color} strokeWidth="1.8" />
      <line x1="3" y1="12" x2="21" y2="12" stroke={color} strokeWidth="1.8" />
      <circle
        cx="12"
        cy="12"
        r="2.8"
        fill="white"
        stroke={color}
        strokeWidth="1.5"
      />
      <circle cx="12" cy="12" r="1.2" stroke={color} strokeWidth="1.2" />
    </svg>
  );
}
