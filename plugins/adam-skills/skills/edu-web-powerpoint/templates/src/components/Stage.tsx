import type { CSSProperties, ReactNode } from "react";
import { useStageScale } from "../hooks/useStageScale";

interface Props {
  onAdvance(): void;
  children: ReactNode;
}

export function Stage({ onAdvance, children }: Props) {
  const scale = useStageScale();
  const fitterStyle: CSSProperties = {
    width: 1920 * scale,
    height: 1080 * scale,
  };
  const frameStyle: CSSProperties = {
    transform: `scale(${scale})`,
  };
  return (
    <div className="app-shell">
      <div className="stage-fitter" style={fitterStyle}>
        <div
          className="stage-frame"
          style={frameStyle}
          onClick={(e) => {
            const t = e.target as HTMLElement;
            if (t.closest("button, a, input, [data-no-advance]")) return;
            onAdvance();
          }}
        >
          {children}
        </div>
      </div>
    </div>
  );
}
