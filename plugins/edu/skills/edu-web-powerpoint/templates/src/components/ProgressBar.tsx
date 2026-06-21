import type { ChapterDef } from "../registry/types";
import type { Cursor } from "../hooks/useStepper";
import "./ProgressBar.css";

interface Props {
  chapters: ChapterDef[];
  cursor: Cursor;
  onJumpChapter(idx: number, step?: number): void;
}

export function ProgressBar({ chapters, cursor, onJumpChapter }: Props) {
  return (
    <div className="ewp-progress">
      <div className="ewp-progress-inner">
        {chapters.map((ch, i) => {
          const isActive = i === cursor.chapter;
          return (
            <button
              key={ch.id}
              className={`ewp-progress-ch ${isActive ? "active" : ""}`}
              onClick={() => onJumpChapter(i, 0)}
              title={ch.title}
            >
              <span className="ewp-progress-dot" />
              <span className="ewp-progress-label">{ch.title}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
