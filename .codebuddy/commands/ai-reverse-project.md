---
description: 逆向工程专用命令。**逆向工程 = 从 git 仓库或本地仓库深度解析源码，梳理成 PRD 和高保真原型**：全域遍历源码后产出项目画像 + 逆向 10 章 PRD（权限矩阵/数据字典/全局规则/隐藏逻辑）+ 高保真 UI 交互原型（100% 还原、真实感模拟数据）+ 文字原型说明书 + 双来源变更日志 + 一致性核验。**不带参数时默认对当前项目目录执行**。0-1 需求设计请用 /ai-require-design。
argument-hint: [源码根目录] [--scope=<模块或功能>] [--out=<产出目录>]
allowed-tools: Read, Write, Bash(git log:*), Bash(git show:*), Task, Skill, Glob, Grep, LS
---

# /ai-reverse-project · 逆向工程（PRD + 高保真原型）

> **逆向工程专用命令**。**逆向工程 = 从 git 仓库或本地仓库深度解析源码，梳理成 PRD 和高保真原型**。
> 完整产出：项目画像、逐功能标准 PRD、**高保真 UI 交互原型**（100% 还原源码 UI、含交互与真实感模拟数据、状态全覆盖）、双来源变更日志、一致性核验。
> 与 0-1 的分工：0-1（`/ai-require-design`）**从 0 开始**，仅依赖对话澄清或外部引用文件，**不依赖源码**；1+（本命令）**依赖源码**，从源码反向生成 PRD 和高保真原型。

## 用法

```
/ai-reverse-project [源码根目录] [--scope=<模块或功能>] [--out=<产出目录>]
```

参数：`$ARGUMENTS`

| 参数 | 必填 | 说明 |
|------|------|------|
| `[源码根目录]` | 否 | **缺省 = 当前项目目录**（自动定位工作区源码根；存在多个候选项目目录时停下询问一次）。**接受**：git 仓库（含 `.git/`，变更日志可含 `git-commit` 来源）；**本地仓库**（无 `.git/` 的本地源码目录，`git-commit` 来源缺省）。仅接收源代码。**拒绝**：纯需求文档、单文件、设计稿、压缩包。**数据库表结构、接口文档无需提供**：从源码自动发现（实体类注解/Mapper/SQL 脚本/ORM 映射/Controller 注解）；项目目录内若有 SQL/接口文档则自动用作交叉验证证据。 |
| `--scope` | 否 | 限定本次逆向覆盖的模块/功能（菜单 / 子系统 / 页面集合）。 |
| `--out` | 否 | 覆盖默认产出目录 `<目标仓库>/docs/reverse-engineered/`。 |

## 第一步：参数严格校验（不通过即停下询问）

加载 `rules/se-workflow.mdc` §二 执行：

1. 源码根目录：给定了目录则校验存在且为目录；**未给定则默认当前项目目录**（工作区源码根；多个候选项目目录时停下询问一次）。
2. **git 仓库**（含 `.git/` 且 `git log -1 --pretty=oneline` 可读）：变更日志启用 `git-commit` 来源（只读采集）。
3. **本地仓库**（无 `.git/` 的本地源码目录）：同样接受，`git-commit` 来源缺省（仅 `decision`）。
4. `--out` 若给定，父目录可写。
5. 校验通过后**回显执行计划**（输入路径、模式确认、范围、产出目录、阶段列表），让用户确认或中止。

## 第二步：断点续跑判断

1. 读取 `<out>/_meta/status.md`（若存在）。
2. 已 `done` 的阶段默认不重做，从第一个非 `done` 阶段续跑。
3. 用户可显式要求重做某阶段。

## 第三步：流水线编排（每阶段都落盘 + 更新 `_meta/status.md`）

| 阶段 | 执行角色 | 使用技能 | 强制产物 | 关键约束 |
|------|----------|----------|----------|----------|
| 1 源码扫描 | `source-analyst` | `legacy-source-digging` + `code-explorer` | `_meta/project-profile.md`、`_meta/traverse-report.md` | 只读；**全域遍历三层清单**（前端路由/页面/弹窗/按钮事件，后端 Controller/Service/定时任务/监听/MQ/拦截器，数据层表/关联/状态字段）；产出技术栈、模块拓扑、菜单/路由/接口全量索引、**用户角色与鉴权逻辑** |
| 2 逆向挖掘 | `source-analyst` | `legacy-source-digging` + `code-explorer` | `modules/*.md`、`permission-matrix.md`（角色-页面-功能-操作权限矩阵）、`dictionary/`（接口清单+表结构+字段字典）、`hidden-logic.md`（隐藏逻辑/历史遗留）、`_meta/analysis-summary.md` | **四层流程拆解**（主动操作/页面联动/系统自动/后台异步）+ **分支全量抓取**（每个 if/else 独立成流程，禁止合并简化）+ **闭环校验**；每条结论带 `文件:行号` + 三级置信度 |
| 3 PRD 编写 | `prd-author` | `prd-writing` | `prd/F*.md`、`prd/README.md` | 按 `rules/prd-standard.mdc` §九 **逆向 10 章结构**：纯还原声明、产品整体概述、角色与权限体系、产品架构、全局通用规则、各模块 8 项格式、全量业务流程体系、接口与数据字典、异常边界清单、隐藏逻辑备注；禁模糊词、规则四段式、与代码 100% 匹配、**禁止概括性描述** |
| 4 **高保真原型** | `prototype-designer` | `html-prototype` | `prototype/prototype-spec.md`（全页面文字说明书）、`prototype/*.html`、`prototype/index.html` | **先产出文字说明书**（页面结构五区/控件规则/弹窗逻辑/状态规则），再渲染 100% 还原 HTML（见下文「100% UI 还原定义」全清单） |
| 5 变更日志 | `changelog-curator` | `changelog-tracking` | `changelog/CHANGELOG.md`、`changelog/_git-log.md`、`changelog/_decisions.md` | git 仓库：双来源（Git 提交只读 + 需求拍板追加）；本地仓库：仅 `decision` |
| 6 一致性核验 | `consistency-reviewer` | — | `review/review-report.md` | 纯还原声明、概括性描述 0、**权限矩阵↔代码、数据字典↔代码逐条对照**、遗漏路由/未使用组件/隐藏逻辑兜底自查复核；PRD↔源码证据、原型↔PRD 页面清单、日志↔事实 |

## 100% UI 还原定义

> 这是 `/ai-reverse-project` 与简单"逆向生成原型"的**核心差异**。
> 100% 还原 = 菜单/路由全覆盖 + 元素一一对应 + 真实感模拟数据 + 可交互 + 状态全覆盖 + 导航闭环 + 与 PRD 对齐。

【强制】逐项落实：

1. **菜单/路由全覆盖**：扫描得到的**每一个**菜单项、Router、Controller 路径都必须**逐项**生成对应原型页面。禁止合并、抽样、省略、未发现则显式列入"待确认清单"。
2. **页面元素一一对应**：原型页面上的字段、按钮、表格列、表单项、对话框、Tab 与源码模板/控制器中的 UI 元素保持**一一对应**——不发明、不省略（参见 `rules/prototype-standard.mdc` §四）。
3. **真实感模拟数据**：从源码枚举、字典表、状态机、真实命名风格中抽取**与生产一致**的命名与取值，构造贴近业务的假数据（参见 `rules/prototype-standard.mdc` §二）。**禁止** `test` / `aaa` / `示例1` 等无意义占位，必须覆盖关键取值形态（含边界值与异常值）。
4. **可交互**：表单校验、按钮 disabled/loading、Toast 提示、确认弹窗、列表→详情→编辑→保存→回列表的关键流程**点击可走通**，禁止仅为静态截图。
5. **状态全覆盖**：每页覆盖 **加载中 / 空 / 正常 / 错误 / 无权限** 五态，并通过状态切换器、Tab、按钮等可在界面切换（参见 `rules/prototype-standard.mdc` §三）。
6. **导航闭环**：`prototype/index.html` 导航页列出**全部**原型页面并按模块分组；每个原型页面都有"返回导航"入口（参见 `rules/prototype-standard.mdc` §五）。
7. **与 PRD 页面清单对齐**：原型页面数 = PRD「界面要素」页面数。多→少（缺）必补；少→多（越界）必删或回填 PRD（参见 `rules/prototype-standard.mdc` §四）。
8. **文案逐字一致**：全部弹窗、Toast、空状态、报错文案**逐字取自 PRD 文案规范**（含标点），禁止自行改写或新造文案。
9. **样式贴近原 UI 框架**：若源码里出现 Element / Ant Design / Vue / Bootstrap / Tailwind / iView / Arco Design 等痕迹，原型应贴近对应风格，使"100% 还原"在视觉上也可被审视（参见 `rules/prototype-standard.mdc` §一）。
10. **落盘前脱敏**：原型内接口地址、账号、令牌一律占位符，不出现真实密钥或 PII（参见 `rules/prototype-standard.mdc` §六）。
11. **文字说明书先行**：先产出 `prototype/prototype-spec.md`（每页含页面名称/用途/访问权限/入口路径、页面结构五区、控件清单与规则、弹窗逻辑、无数据/加载/报错/空状态规则），经与 PRD 三方一致后再渲染 HTML（参见 `rules/prototype-standard.mdc` §七）。

【核验指标】（一致性核验员必须逐项判定）：

- [ ] 原型页面数 == PRD 界面要素清单数
- [ ] 每个原型页面都有 `Fxx` 标识与 PRD 对应
- [ ] 关键流程可点击走通至少一条完整闭环
- [ ] 每页至少可在界面上看到 5 态切换

## 职责边界（本命令【不允许】做的事）

1. **0-1 需求定义**（从 0 开始，仅依赖对话澄清或外部引用文件 `--doc`，不依赖源码）——应使用 `/ai-require-design`。
2. **对逆向工程产物（源码）做任何写操作**（写入/删除/改名源码文件、改其 `.git/`）——1+ 全程只读，产物写到独立 `<out>` 目录。
3. **需求文档导入**并自动跑 0-1 流水线（这是 0-1 路径）——应使用 `/ai-require-design --doc=<路径>`。
4. **修改目标源码或 git 状态**（任何 `git commit` / `git push` / 写入源码树）——只读，所有产物写到独立 `<out>` 目录。
5. 在原型中**发明**源码不存在的字段、状态、按钮——不臆造。

## 遵从规约

- `rules/reverse-engineering.mdc`（逆向铁律：溯源、不臆造、三级置信度、只读）
- `rules/prd-standard.mdc`
- `rules/prototype-standard.mdc`（**尤其 §一 自包含 / §二 真实假数据 / §三 状态覆盖 / §四 PRD 对齐 / §五 导航组织 / §六 脱敏**）
- `rules/changelog-standard.mdc`
- `rules/se-workflow.mdc`

## 结束条件

- [ ] 源码扫描 → 逆向挖掘 → PRD → 高保真原型 → 变更日志 → 一致性核验 6 个阶段全部 `done`；未通过的须写明 `blocked` 原因。
- [ ] 产物目录与 `rules/se-workflow.mdc` §四 一致。
- [ ] 全域遍历完成且兜底自查通过：遗漏路由、未使用组件、隐藏逻辑全部登记（`_meta/traverse-report.md` + `hidden-logic.md`）。
- [ ] 权限矩阵（`permission-matrix.md`）、数据字典（`dictionary/`）、文字原型说明书（`prototype/prototype-spec.md`）已产出，并与代码/PRD/HTML 三方一致。
- [ ] 核验报告确认：纯还原声明存在、概括性描述 0；原型页面数 = PRD 页面清单数 = 遍历路由数；关键流程可点击走通。
- [ ] PRD 保真自检已写入 `prd/README.md`：业务逻辑匹配 ≥95%、场景覆盖 ≥95%、模糊词命中 0、遗漏 ≤5%、主流程 100% 落地。
