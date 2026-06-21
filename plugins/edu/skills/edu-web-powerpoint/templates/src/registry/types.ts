import type { ComponentType } from "react";

export interface ChapterStepProps {
  step: number; // 0..(narrations.length - 1)
}

export type Narration = string;

export interface ChapterDef {
  id: string;
  title: string;
  narrations: Narration[];
  Component: ComponentType<ChapterStepProps>;
}
