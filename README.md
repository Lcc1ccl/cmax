<h1 align="center">Cmax</h1>
<p align="center">面向并行 AI 编程的 project-aware cmux fork。</p>

<p align="center">
  <a href="https://github.com/Lcc1ccl/cmax/releases/latest/download/cmax-macos.dmg">
    <img src="./docs/assets/macos-badge.png" alt="Download Cmax for macOS" width="180" />
  </a>
</p>

<p align="center">
  <a href="https://github.com/Lcc1ccl/cmax/releases/latest">下载最新版</a>
  ·
  <a href="https://github.com/manaflow-ai/cmux">cmux</a>
  ·
  <a href="https://github.com/alumican/cmux-tb">cmux-tb</a>
</p>

## Cmax 是什么

Cmax 是一个个人维护的 macOS 终端分支，基于 [cmux](https://github.com/manaflow-ai/cmux) 演进，保留 Ghostty + Swift/AppKit 的核心体验，同时把重心放到“多线程开发 / 多 agent 协作”的日常工作流上。

当前重点不是做一个“大而全”的上游镜像，而是把常用的并行开发场景做顺：多个项目、多个任务线程、多个自动化 agent 可以在同一个窗口中被稳定地组织、切换和追踪。

## 本项目主要修改方向

### 1. Project-aware 垂直侧边栏

Cmax 将垂直侧边栏从“窗口 / workspace 列表”进一步整理为面向项目的工作台：

- 以 project 作为长期上下文入口，而不是只依赖一次性的终端 tab。
- 优化多线程开发时的 workspace 切换、默认项目恢复和最后窗口关闭后的上下文保留。
- 让多个任务线、多个仓库、多个 agent 会话更容易并排管理，减少在窗口、目录和临时终端之间来回找状态。

品牌上，Cmax 更接近一个 **project command deck for AI coding**：不是替代 IDE，而是把终端、项目上下文和 agent 状态放在一个更清晰的操作面板里。

### 2. 自动化流程适配（进行中）

Cmax 正在针对 [oh-my-codex / OMX](https://github.com/Lcc1ccl/oh-my-codex) 等自动化工作流做适配：

- 更稳定地承载 Codex / Claude / Gemini 等 agent 的长任务输出与通知。
- 为多 agent 并行、任务恢复、上下文切换和项目级自动化留出更明确的 UI 入口。
- 保留 `cmux` CLI / socket 等内部兼容面，避免无意义的大面积改名带来生态断裂。

这部分仍在迭代中，目标是让 Cmax 成为个人自动化开发栈里的“终端控制台”。

## 安装

下载最新 DMG：

<a href="https://github.com/Lcc1ccl/cmax/releases/latest/download/cmax-macos.dmg">
  <img src="./docs/assets/macos-badge.png" alt="Download Cmax for macOS" width="180" />
</a>

打开 `.dmg`，将 `Cmax.app` 拖入 Applications。

Cmax 使用独立 bundle id（`com.cmaxterm.app`）打包，因此不会覆盖本机已有的 cmux 应用。发布包采用开源项目常见的 ad-hoc 签名方式；首次打开时 macOS 可能需要你在 Finder 中右键打开，或在系统设置中允许打开。

## 版本

- 当前 Cmax 版本：`1.0.1`
- 当前上游基线：cmux `0.63.2`
- Release asset：`cmax-macos.dmg`

## 致谢

Cmax 站在这些项目的基础上：

- [manaflow-ai/cmux](https://github.com/manaflow-ai/cmux)：原始 macOS 终端应用与核心代码基础。
- [alumican/cmux-tb](https://github.com/alumican/cmux-tb)：TextBox 输入体验方向的重要参考。

感谢 cmux、cmux-tb 以及 Ghostty 相关开源工作的作者和贡献者。Cmax 只保留本分支相关的说明；上游完整文档请直接跳转到对应项目阅读。

## License

本分支沿用仓库中的开源许可证。
