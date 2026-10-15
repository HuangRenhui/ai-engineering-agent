---
description: 前端开发命令。只做前端：前端框架搭建、页面 UI 实现（对照原型与 PRD）、与后端 API 对接与页面交互。契约未冻结时框架与页面 UI 立即开工，仅 API 绑定阶段等待契约，缺口只登记不改契约。
argument-hint: <目标项目目录或项目名> [--out=<产出目录>] [--stack=<画像 id>] [--scope=<页面或功能范围>]
allowed-tools: Read, Write, Glob, Grep, LS, Task, Skill
---

# /ai-dev-frontend · 前端开发

> 职责：**前端框架搭建 + 页面 UI 实现 + 与后端 API 对接交互**。
> 只做前端：**不写后端代码、不产出测试用例文档、不修改契约**（对 `contract/` 仅有评审权与申请权）。
> 衔接方式：上游只读 `prd/`（必需，缺失即 `blocked`）、`prototype/`（必需，`P` 编号来源）、`permission-matrix.md`（1+）、`dictionary/`、`contract/`（只读）、`_meta/tech-stack.md`；本命令写 `frontend/`、`_meta/traceability.md`（`页面 P`/`前端实现` 两列）、`contract/_requests.md`（契约变更申请）、`_meta/change-requests.md`；**不依赖对话上下文**。

## 用法

```
/ai-dev-frontend <目标项目目录或项目名> [--out=<产出目录>] [--stack=<画像 id>] [--scope=<页面或功能范围>]
```

参数：`$ARGUMENTS`

| 参数 | 必填 | 说明 |
|------|------|------|
| `<目标项目目录或项目名>` | 是 | 存放 `prd/`、`prototype/` 的项目目录；仅项目名时自动新建项目目录 |
| `--out` | 否 | 覆盖产出根，默认 `<目标项目>/docs/dev/`（`<DEV>`） |
| `--stack` | 否 | 显式指定前端技术栈画像 id（如 `frontend-vue3`、`frontend-react`） |
| `--scope` | 否 | 限定页面范围（`P` 编号）或功能范围（`F` 编号） |

## 第一步：参数与前置条件校验

加载 `rules/se-workflow.mdc` §二、`rules/dev-contract.mdc` §一 执行：

1. 项目目录合法（存在或可创建、可写）；`--out` 父目录可写。
2. 上游产物探测：`prd/*.md` 必需（缺失即 `blocked`）；`prototype/*.html` 必需（`P` 编号来源；缺失时提示先执行 `/ai-require-design` 或 `/ai-reverse-project`）；`permission-matrix.md`（1+）可选。
3. **技术栈解析（按命中序，命中即止；权威定义见 `rules/dev-contract.mdc` §七 第 28 条）**：
   1. `--stack=<id>`（命令参数显式指定，候选见 `tech-stacks/README.md` §三）
   2. `<DEV>/_meta/tech-stack.md`（项目级覆盖；缺失时回退读上游 0-1 落档的 `<项目>/_meta/tech-stack.md`）
   3. 特征探测匹配 `tech-stacks/frontend-*.md`
   4. `.codebuddy/tech-stack.md`（系统默认，仅无工程结构可探测时）
   5. **停下询问**，未命中禁止默认
4. 代码落点探测：已有工程（`package.json` 等）→ **沿用原结构**；无 → `<目标项目根>/frontend/`。
5. 校验通过后**回显执行计划**（含页面清单与 `P` 编号、契约状态与版本、技术栈命中序与来源、落点、本轮阶段分配）并请用户确认或中止。

## 第二步：状态判定（契约 + 并行判定 + 断点续跑）

读 `contract/README.md` 与 `frontend/_meta/status.md`，按 `rules/dev-contract.mdc` §五 依赖-并行矩阵判定：

| 契约状态 | 阶段 2 框架搭建 | 阶段 3 页面 UI | 阶段 4 API 绑定 |
|----------|----------------|----------------|-----------------|
| 不存在 / `draft` | **立即开工** | **立即开工**（mock / 类型占位） | 等待冻结，先做其他页面 |
| `frozen` | 立即开工 | 立即开工 | **立即开工** |
| `frozen` 但本命令绑定的 `version` 落后 | 增量重做受影响部分 | 只重做受影响页面 | 只重做受影响绑定，禁止全量重写 |

**并行铁律**：契约未冻结**不得停工**——阶段 2、3 与契约无关，必须先推进；等待期间发现的契约问题登记后继续做其他事。

断点续跑：只执行 `status.md` 中非 `done` 的阶段；**不得读取他人 `status.md` 判断**。

## 第三步：流水线（六阶段）

| 阶段 | 名称 | 依赖契约 | 产物 |
|------|------|----------|------|
| 1 | 基线校验 | 否 | `frontend/_meta/probe.md`、`status.md` |
| 2 | 框架搭建 | **否** | 脚手架、目录骨架、路由与守卫、状态管理、**统一请求层**、组件库 → `frontend/_meta/stack.md` |
| 3 | 页面 UI 实现 | **否** | 逐页面 HTML/组件实现（要素对齐原型、文案逐字取 PRD、字段规则按 PRD、五态齐备）→ `frontend/_meta/page-impl-report.md` |
| 4 | API 绑定与交互 | **是（`frozen`）** | 逐接口替换 mock、错误码映射、分页排序筛选对齐、五态联调 → `frontend/_meta/api-binding-report.md` |
| 5 | 契约缺口处理 | 随时 | `frontend/_meta/contract-gaps.md` + 向 `contract/_requests.md` 追加申请 |
| 6 | 矩阵回填 | — | `traceability.md` 的 `页面 P` + `前端实现` 两列 |

**执行角色**：`frontend-developer`；**主技能**：`frontend-dev`。

### 页面七对齐（阶段 3 逐页核对）

元素（不增不减，确需增减登记 `偏差`）/ 文案（逐字取 PRD 含标点）/ 字段规则（必填、默认值、输入限制、校验时机与失败文案）/ **五态**（加载中、空、正常、错误、无权限，且可触发验证）/ 交互闭环（loading 防连点、成功反馈、失败提示、二次确认、失败后数据保留）/ 权限显隐（禁止只样式隐藏保留可点击）/ 路由守卫（登录态与权限，文案取 PRD）。

### 阶段 4 绑定要求

- 所有调用经**统一 API 层**，页面/组件禁止直接 HTTP；字段逐字对齐 `contract/api.yaml`；
- 错误码统一映射到 `contract/error-codes.md` 文案，未知错误有兜底；
- 完成后给出 **mock 残留清零结论**；契约版本落后时标注"本轮重做范围 / 未受影响范围"。

## 第四步：契约缺口处理（只登记，不修改）

1. 发现契约缺项/不合理 → 追加 `contract/_requests.md`（申请人、时间、`API-xx`、期望变更、理由、影响范围）；
2. 在 `contract-gaps.md` 登记：现象、影响页面、临时适配方式（mock / 本地兜底）、是否已提交申请；
3. 在矩阵 `偏差` 列追加注明；
4. **继续推进不受影响的页面**，等后端裁决后按 `version` 增量补做；
5. 严禁自行修改 `contract/` 任何文件。

## 职责边界（本命令【不允许】做的事）

1. 修改 `contract/`（只写 `contract/_requests.md`）；
2. 写后端代码、DB 脚本、后端单测；
3. 生成测试用例文件（`/ai-test-design` 的职责）；
4. 修改上游需求产物（`prd/`、`prototype/`、`permission-matrix.md`）；
5. 擅自改写 PRD 文案、增删页面元素、用前端校验替代后端校验；
6. 把 mock 数据当作生产逻辑且不清理；
7. 全量重写已有页面/工程；删除既有源码文件；
8. 执行测试、执行白名单外命令、任何 git 写操作；
9. 在矩阵中写后端/测试的列（越权写入即违规）。

## 遵从规约

- `rules/dev-contract.mdc`（总纲，冲突时以此为准：目录、ID、契约三态与权限、列所有权、并行矩阵）
- `rules/frontend-dev-standard.mdc`（请求层、页面元素、五态、权限显隐、产物与自检）
- `.codebuddy/tech-stacks/frontend-*.md`（技术栈画像）

## 结束条件

- [ ] `frontend/_meta/probe.md` + `status.md` 已生成，含页面清单来源、契约版本、技术栈命中序（第几级命中）、命中来源（`--stack` 参数值 / 画像文件路径 / 探测依据文件）、开放问题（带 `owner`）；
- [ ] `stack.md`、`page-impl-report.md`、`api-binding-report.md`、`contract-gaps.md` 齐备；
- [ ] 页面数 = 原型页面数；七对齐逐页成立；五态可验证；文案逐字一致；
- [ ] 全部接口经 API 层且逐字对齐契约；mock 残留清零；草案绑定/待对齐项已显式标注；
- [ ] `traceability.md` 的 `页面 P` + `前端实现` 已回填，偏差已追加；
- [ ] 未修改契约、未越权、未全量重写、产物已脱敏。
