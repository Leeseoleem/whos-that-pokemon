export default function QuestionMarkIcon({
  size = 20,
  color = "#9CA3AF",
}: {
  size?: number;
  color?: string;
}) {
  return (
    <svg
      aria-hidden="true"
      width={size}
      height={size}
      viewBox="0 0 24 24"
      fill="none"
    >
      <defs>
        <mask id="qmark-mask">
          <circle cx="12" cy="12" r="12" fill="white" />
          <path
            d="M 12 13.5 v -0.8 c 0 -0.8 2.2 -1.3 2.2 -3.2 C 14.2 7.5 13.2 6.5 12 6.5 c -1.2 0 -2.2 0.9 -2.2 2.2"
            stroke="black"
            strokeWidth="1.6"
            strokeLinecap="round"
          />
          <circle cx="12" cy="17" r="1.2" fill="black" />
        </mask>
      </defs>
      <circle cx="12" cy="12" r="12" fill={color} mask="url(#qmark-mask)" />
    </svg>
  );
}
