import { MaskReveal } from "../../components/MaskReveal";
import type { ChapterStepProps } from "../../registry/types";
import "./Example.css";

export default function ExampleChapter({ step }: ChapterStepProps) {
  if (step === 0) {
    return (
      <div className="ex-scene scene-pad">
        <header className="masthead">
          <span className="brand">Edu PPT</span>
          <span className="issue">Chapter 01 — Example</span>
        </header>
        <hr className="rule" style={{ marginTop: "var(--space-5)" }} />

        <div className="ex-cover-body">
          <div className="kicker">示例章节</div>
          <h1 className="ex-cover-h">
            <MaskReveal show duration={900}>
              <span className="serif-cn">这是&nbsp;</span>
            </MaskReveal>
            <MaskReveal show delay={300} duration={900}>
              <span className="serif-it ex-em">第一步</span>
            </MaskReveal>
          </h1>
          <div className="ex-cover-foot label-mono">
            <span className="dot-accent" /> &nbsp;点击任意位置继续
          </div>
        </div>
      </div>
    );
  }

  if (step === 1) {
    return (
      <div className="ex-scene scene-pad">
        <header className="masthead">
          <span className="brand">Edu PPT</span>
          <span className="issue">Chapter 01</span>
        </header>
        <hr className="rule" style={{ marginTop: "var(--space-5)" }} />

        <div className="ex-split">
          <div className="ex-split-num hero-num">02</div>
          <div className="ex-split-body">
            <div className="kicker">每一步</div>
            <h2 className="ex-split-h">
              <MaskReveal show duration={900}>
                <span className="serif-cn">独占&nbsp;</span>
              </MaskReveal>
              <MaskReveal show delay={300} duration={900}>
                <span className="serif-it ex-em">整个屏幕</span>
              </MaskReveal>
            </h2>
            <p className="ex-split-p">
              主题控制所有视觉细节 —— 调色板、字体、hero 数字风格、
              分割线粗细、装饰、动效。章节代码与主题无关。
            </p>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="ex-scene scene-pad ex-close">
      <div className="ex-close-inner">
        <div className="kicker">开始</div>
        <div className="pull-quote ex-quote">
          <MaskReveal show duration={1100}>
            <span className="serif-cn">替换这个 </span>
          </MaskReveal>
          <MaskReveal show delay={400} duration={1100}>
            <span className="serif-it ex-em">示例章节</span>
          </MaskReveal>
          <MaskReveal show delay={760} duration={1100}>
            <span className="serif-cn">为你自己的内容。</span>
          </MaskReveal>
        </div>
        <div className="ex-close-foot label-mono">
          参考 SKILL.md / CHAPTER-CRAFT.md / THEMES.md
        </div>
      </div>
    </div>
  );
}
