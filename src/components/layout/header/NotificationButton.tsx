import { Bell } from "lucide-react";
import clsx from "clsx";

export interface NotificationButtonProps {
  onClick?: () => void;
  count?: number;
  isActive?: boolean;
}

export default function NotificationButton({
  onClick,
  count = 0,
  isActive = false,
}: NotificationButtonProps) {
  return (
    <button
      onClick={onClick}
      type="button"
      aria-pressed={isActive}
      className={clsx(
        "relative flex rounded-full p-2 transition-colors duration-200 ease-in-out",
        isActive ? "bg-gray-10/30" : "hover:bg-gray-10/20 active:bg-gray-10/30",
      )}
    >
      <span className="sr-only">알림 보기</span>
      <Bell className="text-gray-30" />
      {count > 0 && (
        <span className="absolute top-0 -right-1 inline-flex h-4 w-4 items-center justify-center rounded-full bg-status-unsolved-main text-[8px] text-gray-10">
          {count > 9 ? "9+" : count}
        </span>
      )}
    </button>
  );
}
