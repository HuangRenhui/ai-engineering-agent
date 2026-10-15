---
description: 后端开发命令。只做后端：契约起草与冻结（contract/ 唯一写者）、后端架构搭建、业务功能实现、单元测试生成与落盘。支持 --contract-only 契约先行模式（只冻结契约后停止），作为三命令并行开发的"第 0 棒"。
argument-hint: <目标项目目录或项目名> [--out=<产出目录>] [--stack=<画像 id>] [--contract-only] [--scope=<功能范围>]
allowed-tools: Read, Write, Glob, Grep, LS, Task, Skill
---

# /ai-dev-backend · 后端开发

> 职责：**后端架构搭建 + 业务功能实现 + 单元测试代码**，并作为 `contract/` 的**唯一写者**负责契约起草、冻结与变更裁决（用户在冻结与变更上保有**终裁权**）。
> 只做后端：**不写前端页面；不产出测试用例文档**（`TC-U`/`TC-I`/`TC-A` 用例文件归 `/ai-test-design`，本命令只写单元测试**代码**，阶段 5）。
> 衔接方式：上游只读 `prd/`（必需，缺失即 `blocked`）、`prototype/`、`dictionary/`、`permission-matrix.md`、`_meta/tech-stack.md`；本命令写 `contract/`（唯一写者）、`_meta/traceability.md`（`接口 API`/`后端实现` 两列）、`_meta/change-requests.md`，并按 `dev-contract.mdc` 第 13 条第 4 步以 append-only 方式追加 `changelog/CHANGELOG.md`；**不依赖对话上下文**。

## 用法

```
/ai-dev-backend <目标项目目录或项目名> [--out=<产出目录>] [--stack=<画像 id>] [--contract-only] [--scope=<功能范围>]
```

参数：`$ARGUMENTS`

| 参数 | 必填 | 说明 |
|------|------|------|
| `<目标项目目录或项目名>` | 是 | 存放 `prd/`（及 1+ 的 `dictionary/`）的项目目录；仅项目名时自动新建项目目录 |
| `--out` | 否 | 覆盖产出根。默认 `<目标项目>/docs/dev/`（`<DEV>`） |
| `--stack` | 否 | 显式指定技术栈画像 id（如 `backend-java-springboot` / `backend-java-springboot-jdk17`），最高优先级 |
| `--contract-only` | 否 | **契约先行模式**：只执行阶段 1~2，产出冻结契约后立即停止，不写任何业务代码 |
| `--scope` | 否 | 限定功能范围（`F` 编号或模块名），便于增量迭代 |

## 第一步：参数与前置条件校验

加载 `rules/se-workflow.mdc` §二、`rules/dev-contract.mdc` §一 执行：

1. 项目目录合法（存在或可创建、可写）；`--out` 父目录可写。
2. 上游产物存在性探测：`prd/*.md` 必需（缺失即 `blocked`，提示先执行 `/ai-require-design` 或 `/ai-reverse-project`）；`dictionary/`、`prototype/` 可选只读。
3. **技术栈解析（按命中序，命中即止；权威定义见 `rules/dev-contract.mdc` §七 第 28 条）**：
   1. `--stack=<id>`（命令参数显式指定，候选见 `tech-stacks/README.md` §三）
   2. `<DEV>/_meta/tech-stack.md`（项目级覆盖；缺失时回退读上游 0-1 落档的 `<项目>/_meta/tech-stack.md`）
   3. 特征探测匹配 `tech-stacks/backend-*.md`
   4. `.codebuddy/tech-stack.md`（系统默认，仅无工程结构可探测时）
   5. **停下询问**，未命中禁止默认
4. 代码落点探测：已有工程结构（`pom.xml`/`build.gradle`/`requirements.txt`/`go.mod`/`CMakeLists.txt` 等）→ **沿用原结构**；无 → `<目标项目根>/backend/`；多模块取最内层可构建单元，不唯一则询问。
5. 校验通过后**回显执行计划**（含契约状态、技术栈命中序与来源、落点、阶段清单）并请用户确认或中止。
6. `--contract-only` 时明确告知：本次**只冻结契约**，不产生任何业务代码。

## 第二步：状态判定（契约 + 断点续跑）

读 `contract/README.md` 与 `backend/_meta/status.md`：

| 契约状态 | 行为 |
|----------|------|
| 不存在 / `draft` | 生成或提升为正式契约并冻结（`status: frozen`，记 `version`、`frozen_at`） |
| `frozen` 且无未裁决 `_requests.md` | **跳过契约阶段**，直接进入架构搭建 |
| `frozen` 但 `_requests.md` 有未裁决项 | 先裁决变更（见第五步），再继续 |
| 已有 `_draft/`（前端降级推导） | 读草案 → 修订 → 提升为正式契约并冻结，草案目录保留为历史 |

断点续跑：只执行 `status.md` 中非 `done` 的阶段；已 `done` 阶段不重做。**不得读取他人 `status.md` 判断**。

## 第三步：流水线（六阶段）

| 阶段 | 名称 | 产物 | `--contract-only` |
|------|------|------|-------------------|
| 1 | 基线校验 | `backend/_meta/probe.md`、`status.md` | 执行 |
| 2 | 契约生成/冻结 | `contract/{README.md, api.yaml, api.md, data-model.md, enums.md, error-codes.md}`（+ 首条 `_change-log.md`） | 执行后**停止** |
| 3 | 架构搭建 | 骨架代码、SQL 增量脚本（`REQxxx-<描述>-v0.x-YYYYMMDD.sql`）、`backend/_meta/arch.md` | 跳过 |
| 4 | 业务实现 | 业务代码、`backend/_meta/impl-report.md` | 跳过 |
| 5 | 单元测试 | 测试代码、`backend/_meta/unit-test-report.md` | 跳过 |
| 6 | 矩阵回填 | `traceability.md` 的 `接口 API` + `后端实现` 两列 | 跳过（仅回填 `接口 API`） |

**执行角色**：`backend-developer`；**主技能**：`backend-dev`。

### 阶段 2 契约冻结要求

- 每字段可回溯到 `prd/`（业务要求）/ `dictionary/`（1+ 现存接口）/ 用户明确决策；无来源字段标 `x-inferred: true` 并在 `README.md` 变更摘要登记；
- `api.yaml`（OpenAPI 3.0，机器可读唯一源）与 `api.md`（人读概览）**逐条一一对应**；
- 冻结即宣布**基线**：各方后续按 `version` 消费，变更走 `version`+1 流程；
- 结束后提示用户：可先由人工/前端评审 `contract/api.yaml`，再并行启动前端与测试命令。

### 阶段 3~5 实现纪律

- 路径/方法/字段名/类型/错误码**逐字对齐契约**；错误码用常量或枚举，禁魔法值；
- 分层不得跨层直连；响应统一 `code`/`message`/`data`/`traceId`；禁止持久化实体直接出参；
- DB 脚本按 `rules/dev-contract.mdc` 第 22.1/22.2 条命名与增量生成（`REQxxx-<描述>-v0.x-YYYYMMDD.sql`：首版 `REQ001` 全量初始化、后续每个 `REQ` 只写增量、历史脚本不改不删、幂等可重跑）；字段/类型/索引名与 `contract/data-model.md` 逐字一致，并登记到 `data-model.md` §5 与 `arch.md`；**只生成不执行**；
- 写操作幂等或事务保护；并发敏感逻辑在 `impl-report.md` 说明控制方式并配单测；
- 单测四类必覆盖（主流程/边界/异常/幂等并发），隔离外部资源，断言结果与副作用；只生成不执行；
- **先在 `impl-report.md` 登记（标识、路径、动作）再落盘代码**；修改既有文件须先登记 `_meta/change-requests.md`；1+ 默认只新增。

## 第四步：并行协作（三棒）

```
第 0 棒（串行）  /ai-dev-backend --contract-only        ← 本命令
第 1 棒（并行）  /ai-dev-backend ‖ /ai-dev-frontend ‖ /ai-test-design
第 2 棒（收敛）  契约变更 → version+1 → 各方增量重做 → consistency-reviewer 核验
```

- 契约冻结后**不得静默修改**：变更须完成「改契约 + `version`+1 + `_change-log.md` + `changelog/`」四步，并在矩阵 `偏差` 列与 `impl-report.md` 登记受影响范围，供前端/测试增量重做；
- 前端/测试的契约申请写入 `contract/_requests.md`，由本命令裁决；未裁决项不阻塞对方开发。

## 职责边界（本命令【不允许】做的事）

1. 生成前端页面或前端工程（`/ai-dev-frontend` 的职责）；
2. 生成测试用例文件（`TC-U`/`TC-I`/`TC-A`，`/ai-test-design` 的职责）——本命令只写**单元测试代码**；
3. 修改上游需求产物（`prd/`、`prototype/`、`dictionary/`、`permission-matrix.md`、`changelog/`）；
4. 执行测试；执行白名单外命令；任何 git 写操作（`commit`/`push`/`reset`/`checkout`/`stash`）；
5. 删除既有源码文件；
6. 在矩阵中写前端/测试的列（越权写入即违规）；
7. `--contract-only` 模式下写任何业务代码。

## 遵从规约

- `rules/dev-contract.mdc`（总纲：目录、ID、契约三态与权限、列所有权、执行序与并行、白名单）
- `rules/backend-dev-standard.mdc`（分层、错误码、事务幂等并发、单测要求）
- `rules/java/*`（画像命中时加载）
- `.codebuddy/tech-stacks/backend-*.md`（技术栈画像）

## 结束条件

- [ ] `backend/_meta/probe.md` + `status.md` 已生成，含契约状态/版本、技术栈命中序（第几级命中）、命中来源（`--stack` 参数值 / 画像文件路径 / 探测依据文件）、落点、开放问题（带 `owner`）；
- [ ] `contract/` 已 `frozen`，`version` 与 `_change-log.md` 完整，`x-inferred` 字段已登记；
- [ ] `--contract-only`：契约已冻结、**零业务代码**、`arch/impl/unit-test` 记 `pending`、仅回填 `接口 API` 列；
- [ ] 常规运行：`arch.md`、`impl-report.md`、`unit-test-report.md` 齐备，单测四类覆盖；
- [ ] `traceability.md` 的 `接口 API` + `后端实现` 已回填，偏差已追加；
- [ ] SQL 增量脚本已按 `REQxxx-<描述>-v0.x-YYYYMMDD.sql` 落盘并登记（`data-model.md` §5 + `arch.md`），历史脚本未被修改；
- [ ] 未越权、未删源码、未执行白名单外命令、产物已脱敏。
