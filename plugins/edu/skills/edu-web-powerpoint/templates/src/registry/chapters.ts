import type { ChapterDef } from "./types";
import ExampleChapter from "../chapters/01-example/Example";
import { narrations as exampleNarrations } from "../chapters/01-example/narrations";

export const CHAPTERS: ChapterDef[] = [
  {
    id: "example",
    title: "示例章节",
    narrations: exampleNarrations,
    Component: ExampleChapter,
  },
];
