---
description: 测试用例生成命令。为本次需求生成三级用例（单元 TC-U / 联调 TC-I / UAT TC-A）与覆盖矩阵，保证可客观判定、层级不重叠、AC 全覆盖；只生成用例文件，不执行测试。契约或实现缺失时先产骨架，依赖就绪后增量补齐。
argument-hint: <目标项目目录或项目名> [--out=<产出目录>] [--level=<U|I|A>] [--scope=<功能或模块范围>]
allowed-tools: Read, Write, Glob, Grep, LS, Task, Skill
---

# /ai-test-design · 测试用例生成

> 职责：**本次需求的单元测试 / 联调测试 / UAT 测试用例生成** + 覆盖矩阵。
> 只做用例：**不写后端/前端代码、不修改任何被核验产物、不执行测试**。
> 衔接方式：上游只读 `prd/`（必需，缺失即 `blocked`）、`contract/`、`prototype/`、`permission-matrix.md`、后端 `backend/_meta/impl-report.md` 与 `unit-test-report.md`、`_meta/tech-stack.md`；本命令写 `test/`、`_meta/traceability.md`（`用例 TC` 列）、`contract/_requests.md`（契约问题申请）、`_meta/change-requests.md`；**不依赖对话上下文**。

## 用法

```
/ai-test-design <目标项目目录或项目名> [--out=<产出目录>] [--level=<U|I|A>] [--scope=<功能或模块范围>]
```

参数：`$ARGUMENTS`

| 参数 | 必填 | 说明 |
|------|------|------|
| `<目标项目目录或项目名>` | 是 | 存放 `prd/`、`contract/`、`prototype/` 的项目目录 |
| `--out` | 否 | 覆盖产出根，默认 `<目标项目>/docs/dev/`（`<DEV>`） |
| `--level` | 否 | 只生成指定层级：`U`（单元）/ `I`（联调）/ `A`（UAT）；缺省生成全部三层 |
| `--scope` | 否 | 限定范围（`F` 编号 / `API` 编号 / 模块名） |

## 第一步：参数与前置条件校验

加载 `rules/se-workflow.mdc` §二、`rules/test-case-standard.mdc` 执行：

1. 项目目录合法（存在或可创建、可写）；`--out` 父目录可写。
2. 输入探测（结论写入 `test/_meta/probe.md`）：

| 层级 | 依据产物 | 缺失时的处理 |
|------|----------|--------------|
| `TC-A` | `prd/`（AC、界面要素、文案规范）+ `prototype/` + `permission-matrix.md` | `prd/` 缺失即 `blocked`（提示先执行需求命令）；`prototype/` 缺失时用例只写业务表现并登记偏差 |
| `TC-I` | `contract/api.yaml` + `contract/error-codes.md` | 生成**骨架**（编号 + 名称 + 关联 `F` + 依据列写"待契约补齐"） |
| `TC-U` | 后端 `impl-report.md` + `unit-test-report.md` + `contract/data-model.md` | 生成**骨架**（依据列写"待实现补齐"） |

3. 记录契约 `version`；缺失项与处理方式逐条写明，**不得静默省略**。
4. 校验通过后**回显执行计划**（含各层级可生成范围、契约版本、骨架范围、`--level` 限定）并请用户确认或中止。

## 第二步：状态判定（并行 + 断点续跑）

读 `test/_meta/status.md`，按 `rules/dev-contract.mdc` §五 依赖-并行矩阵判定：

| 阶段 | 能否开工 |
|------|----------|
| 测试策略与计划、`TC-A`（UAT） | **无需契约，立即开工** |
| `TC-I`（联调） | 需 `contract/` `frozen`；未冻结 → 产骨架，冻结后**只补该部分** |
| `TC-U`（单元） | 需后端 `impl-report.md`；未就绪 → 产骨架，就绪后**只补该部分** |

**并行铁律**：依赖缺失**不得停工**——先做可做的层级，缺口在覆盖矩阵中显式可见。

断点续跑：只做 `status.md` 中非 `done` 的阶段；依赖产物补充后按"增量补齐"处理，**不重跑全量**。**不得读取他人 `status.md` 判断**。

## 第三步：流水线（六阶段）

| 阶段 | 名称 | 产物 |
|------|------|------|
| 1 | 基线校验 | `test/_meta/probe.md`、`status.md` |
| 2 | 测试计划 | `test/_meta/test-plan.md`（范围/不测范围、三级用例数量与优先级分布、环境与数据准备、风险与依赖、执行方式说明） |
| 3 | UAT 用例 | `test/uat/TC-A-*.md` |
| 4 | 联调用例 | `test/integration/TC-I-*.md` |
| 5 | 单元用例 | `test/unit/TC-U-*.md` |
| 6 | 覆盖矩阵 + 矩阵回填 | `test/_meta/coverage-matrix.md`、`traceability.md` 的 `用例 TC` 列 |

**执行角色**：`test-case-designer`；**主技能**：`test-case-design`。

### 三级分工与不重叠

| 层级 | 关注点 | 目录 |
|------|--------|------|
| `TC-U01`… | 方法/类级：分支、边界、异常、幂等、事务回滚 | `test/unit/` |
| `TC-I01`… | 接口级：参数校验、鉴权、分页排序、错误码、时序与幂等 | `test/integration/` |
| `TC-A01`… | 业务级：端到端闭环、角色差异、文案与页面表现 | `test/uat/` |

同一关注点只写一层；跨层重复须删除或标注"验证角度不同"并说明差异。

### 质量硬约束

- 每用例字段齐全：编号 / 名称 / 关联标识（`F` 必填，`TC-I` 必填 `API`，`TC-A` 必填 `P` + 角色）/ 关联 AC / 优先级 / 前置条件 / 测试数据（具体取值含边界）/ 步骤 / 预期结果（页面表现 + 数据变化 + 接口返回含错误码与逐字文案）/ 清理后置 / 备注；
- 预期结果**可客观判定**（Given-When-Then 或"条件→操作→预期"）；
- 模糊词黑名单命中 **0**：支持、优化、适当、可能、大概、智能、相关、友好、合理、尽快、流畅、良好、正常显示、正确返回；
- 文案类预期逐字取自 PRD 文案规范（含标点）；
- 覆盖：`TC-U` 每 `F` 四类；`TC-I` 每 `API` 七项；`TC-A` 每 `F` 主闭环 + 分支 + 异常六类 + 角色差异。

### 覆盖矩阵（五张表）

`F × 层级` / `AC 覆盖` / `API 覆盖` / `页面 × 角色` / `异常六类`；未覆盖项禁止留空，须写"未覆盖 + 原因 + 风险等级 + `owner` + 建议动作"。

## 第四步：契约相关问题

- 错误码不可测、缺参数约束、字段类型无法构造边界值 → 追加 `contract/_requests.md`（**只申请，不修改契约**）；
- 在 `probe.md`、`coverage-matrix.md` 登记该缺口的**已有用例范围**与"待契约补齐"范围。

## 职责边界（本命令【不允许】做的事）

1. 执行测试（本命令**只生成用例文件**）；
2. 修改 `prd/`、`contract/`、`prototype/`、后端/前端代码（被核验对象一律只读）；
3. 写后端或前端代码；生成单元测试**代码**（后端单测代码由 `/ai-dev-backend` 负责，本命令生成的是用例文档）；
4. 凭空造接口字段/错误码——以契约为唯一依据；
5. 用 TBD 占位替代风险登记；省略异常六类与权限差异；
6. 在矩阵中写后端/前端的列（越权写入即违规）；
7. 执行白名单外命令、任何 git 写操作。

## 遵从规约

- `rules/dev-contract.mdc`（总纲：ID 体系、契约权限、列所有权、并行矩阵）
- `rules/test-case-standard.mdc`（三级字段契约、最低覆盖、覆盖矩阵、只生成不执行）
- `rules/prd-standard.mdc`（AC 与文案规范为预期结果的依据）

## 结束条件

- [ ] `test/_meta/probe.md` + `status.md` 已生成，含输入齐备度、契约版本、骨架范围、开放问题（带 `owner`）；
- [ ] `test-plan.md`、`coverage-matrix.md` 齐备，五张表无空项；
- [ ] 三级用例编号连续无重复、字段齐全、模糊词命中 0、预期结果均可判定；
- [ ] 每条 AC 有归属；`TC-I` ↔ `API` 一一可查；`TC-A` 覆盖 `P × 角色`；
- [ ] `traceability.md` 的 `用例 TC` 列已回填，偏差已追加；
- [ ] 未执行测试、未修改被核验产物、未越权、产物已脱敏。
