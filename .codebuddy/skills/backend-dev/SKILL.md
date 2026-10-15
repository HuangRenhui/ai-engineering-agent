---
name: backend-dev
description: 后端开发方法论——契约先行的六阶段流水线（基线校验 → 契约生成/冻结 → 架构搭建 → 业务实现 → 单元测试 → 报告回填）、技术栈画像命中序解析、分层落盘边界、事务/幂等/并发实现要点、单测四类必覆盖、契约变更与增量重做、契约产物模板（contract/ 八件套骨架）。当执行 /ai-dev-backend、做后端架构搭建/业务实现/单元测试，或需要判断"实现是否对齐契约""契约文件怎么写"时使用。触发词：后端开发、后端实现、接口实现、架构搭建、单元测试、契约冻结、契约模板、contract-only。
---

# 后端开发

## 目的

把 `prd/` + `contract/` 转化为**可运行、可测试、可追溯**的后端代码与单元测试；同时作为 `contract/` 的**唯一写者**，负责契约的起草、冻结与变更裁决。

## 何时使用

- 执行 `/ai-dev-backend`（含 `--contract-only` 契约先行模式）；
- 需要搭建后端架构、实现业务功能、生成后端单元测试；
- 需要判断"实现是否逐字对齐契约""契约变更影响范围有多大"。

## 前置检查（阶段 1 · 基线校验）

1. **上游产物**：`prd/`（`F` 编号、AC）、`dictionary/`（1+ 的接口/表结构来源）、`prototype/`（页面字段来源，只读）。
2. **契约状态**：读 `contract/README.md` 的 `status` 与 `version`；不存在或 `draft` → 需要生成/冻结。
3. **技术栈**：按四级优先级解析（见下），**未命中即停下询问**，禁止默认。
4. **落点探测**：存在 `pom.xml`/`build.gradle`/`package.json`/`requirements.txt`/`go.mod`/`CMakeLists.txt` → 沿用原结构；无 → 新建 `<目标项目根>/backend/`；多模块取最内层可构建单元，不唯一则询问。
5. 写 `backend/_meta/probe.md` 与 `status.md`（阶段状态、契约版本、开放问题带 `owner`）。

## 工作流（六阶段）

| 阶段 | 名称 | 输入 | 产物 | 可跳过条件 |
|------|------|------|------|------------|
| 1 | 基线校验 | 上游产物、目标工程 | `probe.md`、`status.md` | 不可跳过 |
| 2 | 契约生成/冻结 | `prd/` + `dictionary/` + 用户决策 | `contract/{README.md,api.yaml,api.md,data-model.md,enums.md,error-codes.md}`（`status: frozen`）；骨架见 `templates/contract/` | 已 `frozen` 且无未裁决 `_requests.md` |
| 3 | 架构搭建 | 契约 + 画像 | 骨架代码、`arch.md`、SQL 增量脚本（`REQxxx-<描述>-v0.x-YYYYMMDD.sql`） | 不可跳过 |
| 4 | 业务实现 | 契约 + PRD 规则 | 业务代码、`impl-report.md` | 不可跳过 |
| 5 | 单元测试 | 实现的 `F` 清单 | 测试代码、`unit-test-report.md` | 不可跳过 |
| 6 | 报告与矩阵回填 | 全部产物 | `traceability.md` 的 `接口 API` + `后端实现` 列 | 不可跳过 |

**断点续跑**：每阶段结束更新 `status.md`（`pending`/`in_progress`/`done`/`blocked`），下次运行只做非 `done` 阶段；阻塞必写原因。

## 契约先行模式（`--contract-only`）

- 只执行**阶段 1 + 阶段 2**，产出 `contract/`（`status: frozen`）与 `probe.md`/`status.md` 后**立即停止**；
- `arch.md`/`impl-report.md`/`unit-test-report.md` 记 `pending`，留待无参运行续跑；
- **该模式下不得写任何业务代码**；
- 用途：作为三命令并行的"第 0 棒"（见 `rules/dev-contract.mdc` §五）。
- 1+ 场景可直接把 `dictionary/` 的接口清单核对、补字段与错误码后冻结，成本最低。

## 契约产物模板（`templates/contract/`）

阶段 2 直接复制 `templates/contract/` 下的同名单文件作为骨架，**文件名与数量不得增删**（与 `rules/dev-contract.mdc` §三 的清单一致）：

| 模板 | 落地目标 | 模板要点 |
|------|----------|----------|
| `README.md` | `<DEV>/contract/README.md` | 封面：`version`/`status`/`owner`/`frozen_at`/`based_on`、文件清单、变更摘要、`x-inferred` 登记、消费约定 |
| `api.yaml` | `<DEV>/contract/api.yaml` | OpenAPI 3.0 骨架：分页排序参数、统一响应泛型、`VO`/`CreateDTO`/`UpdateDTO`、鉴权与错误码引用（机器可读唯一源） |
| `api.md` | `<DEV>/contract/api.md` | 接口清单 + 逐接口入参/出参/错误码表 + 全局约定 + 与 `api.yaml` 一一对应自查 |
| `data-model.md` | `<DEV>/contract/data-model.md` | 表清单、字段约束（含 `version`/`is_deleted`/审计列）、状态流转、索引、关联、迁移与回滚 |
| `enums.md` | `<DEV>/contract/enums.md` | 枚举名 / 取值 / 含义 / 前端文案 / 来源、流转约束、实现约定 |
| `error-codes.md` | `<DEV>/contract/error-codes.md` | 编码规则、通用码、业务码、前端映射、异常与日志约定 |
| `_change-log.md` | `<DEV>/contract/_change-log.md` | 变更历史（追加式，含"需重新对齐"列） |
| `_requests.md` | `<DEV>/contract/_requests.md` | 变更申请（追加式，含裁决与裁决结论列） |

用法纪律：

- 模板中的 `<...>` 占位符**必须逐个替换为真实值或整项删除**，不得原样交付；
- 模板只含通用骨架与规则说明，**禁止写入任何项目专属信息**（业务名、真实域名、账号、密钥）；
- 一律以 `api.yaml` 为机器可读唯一源，`api.md` 与之逐条一一对应；两者不一致时先改 `api.yaml` 再同步 `api.md`。

## 技术栈画像解析（五级命中序，权威定义见 `rules/dev-contract.mdc` §七 第 28 条）

| 命中序 | 来源 |
|--------|------|
| 1 | 命令参数 `--stack=<id>`（候选见 `.codebuddy/tech-stacks/README.md` §三） |
| 2 | `<DEV>/_meta/tech-stack.md`（缺失则回退上游 0-1 落档的 `<项目>/_meta/tech-stack.md`；两者均缺失才生成模板请用户确认） |
| 3 | 目标项目特征探测 → 匹配 `.codebuddy/tech-stacks/backend-*.md` 的「识别特征」 |
| 4 | 系统默认 `.codebuddy/tech-stack.md`（仅无工程结构可探测时） |
| 5 | 均未命中 → **停下询问** |

画像提供：目录骨架、分层映射、依赖清单、命名约定、构建与测试命令、代码模板要点、应加载的 `rules`。

## SQL 脚本（按需求迭代增量生成）

表设计的**唯一依据是 `contract/data-model.md`**（表 / 字段 / 类型 / 约束 / 索引 / 关联 / 状态取值），但契约本身**不产出可执行 DDL**（契约 8 文件不增不减）。DDL 脚本属于**阶段 3 架构搭建**的产物，规则如下。

**命名**：`REQ<三位序号>-<描述>-v<主>.<次>-<YYYYMMDD>.sql`，例 `REQ001-user-login-v0.1-20260917.sql`

| 段 | 含义 | 规则 |
|----|------|------|
| `REQxxx` | 需求迭代批次 | `REQ001` 起、三位补零；只增不改、不复用、不跳号；上游 `prd/` 有需求编号时沿用，无则由本命令在 `contract/data-model.md` §5 按序分配 |
| `<描述>` | 需求短描述 | 小写英文短横线短语，2~5 词，≤32 字符；禁中文 / 空格 / 下划线 / 大写 |
| `v0.x` | 脚本版本 | 与 `contract/README.md` 的 `version` 同步递进（首版 `v0.1`） |
| `<YYYYMMDD>` | 生成日期 | 本地时区 |

**位置**：优先技术栈画像 / 既有工程的迁移目录（Java 画像：`src/main/resources/db/migration/`）；无约定时 `<DEV>/backend/sql/`。

**增量铁律**：

1. 首版 `REQ001` 是**全量初始化**（建表 + 索引 + 字典数据）；此后每个 `REQ` 只写**增量**（`CREATE` / `ALTER` / `CREATE INDEX` / 字典 upsert）；
2. **历史脚本一律不改不删**；写错即新增更高版本脚本修正，原文件保留；
3. 一个文件只服务一个 `REQ` 批次；同批次多次修订 → 版本递增、生成新文件；
4. **幂等可重跑**：建表用 `CREATE TABLE IF NOT EXISTS`；字段 / 索引变更先用 `INFORMATION_SCHEMA.COLUMNS` / `INFORMATION_SCHEMA.STATISTICS` 判断存在性再执行（MySQL 无 `DROP INDEX IF EXISTS`）；字典数据用 upsert（`INSERT ... ON DUPLICATE KEY UPDATE`）；禁止 `DROP DATABASE`、禁止 `DROP` / `TRUNCATE` 既有业务表；
5. 脚本头部注释块必含：`REQ` 编号、需求描述、契约版本与日期、生成命令、涉及表、对应 `F`/`API`、执行顺序、可回滚与回滚要点、敏感信息声明；
6. 字段 / 类型 / 默认值 / 索引名与 `contract/data-model.md` **逐字一致**；不一致先改契约（`version`+1）再改脚本；
7. **只生成不执行**：命令白名单无数据库客户端，执行交人工；脚本内禁真实连接串、账号、口令与生产数据；
8. **登记双向一致**：`contract/data-model.md` §5 与 `arch.md` 的「DB 迁移方案」逐条登记 `REQ` ↔ 文件名 ↔ 版本 ↔ 日期 ↔ 涉及表 ↔ 可回滚。

**模板**：`templates/sql/REQxxx-desc-v0.x-YYYYMMDD.sql`（复制后重命名并替换全部 `<...>` 占位符）。

> 1+ 存量项目：默认**只新增**表 / 字段；改动既有表结构须先登记 `_meta/change-requests.md` 并经用户确认。

## 落盘与实现纪律

- **先登记后落盘**：写代码前先在 `impl-report.md` 登记（标识、路径、动作：新增/修改）；
- 修改既有文件须先在 `_meta/change-requests.md` 登记；1+ 默认**只新增**，改既有文件需用户确认；
- 禁止删除既有源码文件、禁止改动目标仓库 git 状态；
- **逐字对齐契约**：路径、方法、字段名、类型、错误码不得"顺手改名"；错误码一律常量/枚举，禁魔法值；
- 分层不得跨层直连；对外响应结构统一（`code`/`message`/`data`/`traceId`）；禁止把持久化实体当出参；
- 写操作必须幂等或事务保护，并在 `impl-report.md` 说明并发控制方式；
- 日志含入参与关键分支，**禁止**打印密钥/令牌/口令/完整身份证号手机号银行卡。

## 单元测试方法论

1. **四类必覆盖**：主流程成功、边界值（最大/最小/零/空）、异常路径（校验失败/依赖失败/权限不足）、幂等或并发（若适用）。
2. **不依赖真实外部资源**：DB/缓存/第三方一律测试替身，用例可重复、结果稳定。
3. **断言结果与副作用**：返回值 + 数据变更 + 抛出错误码，禁止只断言"不抛异常"。
4. **命名**：`标识_场景_预期`；报告建立 `F ↔ 测试类/方法 ↔ TC-U` 对照。
5. **覆盖率**：按画像约定（缺省服务层行 ≥70%、核心 `F` 分支 ≥80%），未达标逐项写明原因与风险。
6. **只生成不执行**：是否执行由用户决定；执行失败记 `blocked`，不静默重试。

## 契约变更（本命令是唯一写者）

发现契约不合理 → **先改契约再改代码**，一次提交内保持一致，四步不得跳：

1. 修改契约文件 + `version` +1 + `status: changed`；
2. `_change-log.md` 追加（时间、版本、变更项、原因、申请人、影响范围、需重新对齐的范围）；
3. 写入 `changelog/CHANGELOG.md`（`decision` 来源，scope 为 `API-xx`）；
4. 在矩阵 `偏差` 列与 `impl-report.md` 登记受影响范围，供前端/测试**增量重做**。

## 产物清单

`backend/_meta/{probe.md, arch.md, impl-report.md, unit-test-report.md, status.md}` + `contract/` + 后端代码与测试代码 + SQL 增量脚本（`REQxxx-<描述>-v0.x-YYYYMMDD.sql`）。

| 产物 | 必含 |
|------|------|
| `arch.md` | 画像版本、目录骨架、分层映射、依赖清单、统一响应/异常/错误码/日志方案、DB 迁移方案（脚本目录 + 命名规则 + 执行顺序 + 回滚方式 + `REQ` 脚本登记） |
| `impl-report.md` | `F ↔ API ↔ 文件:行号 ↔ 状态`、契约偏离说明、修改既有文件清单、定时任务/监听器清单、`x-inferred` 字段复述、SQL 脚本清单（`REQ` ↔ 文件 ↔ 表 ↔ `F`） |
| `unit-test-report.md` | `F ↔ 测试位置 ↔ TC-U` 对照、覆盖率、未覆盖项与原因 |

## 自检清单

- [ ] 契约 `frozen` 且版本已记录；`x-inferred` 字段已复述；
- [ ] 每个 `F` 有实现且路径可定位；每个 `API` 逐字对齐契约；
- [ ] SQL 脚本按 `REQxxx-<描述>-v0.x-YYYYMMDD.sql` 命名、按需求迭代增量生成；历史脚本未被修改；与 `data-model.md` 逐字一致且已登记；
- [ ] 单测四类覆盖齐备，断言检查副作用；
- [ ] `traceability.md` 的 `接口 API` 与 `后端实现` 两列已回填，**未越权写他人列**；
- [ ] `status.md` 已更新；开放问题带 `owner`；
- [ ] 产物已脱敏（无真实密钥/连接串/PII）。

## 红线

- 契约未 `frozen` 不得进入业务实现（唯一例外：`--contract-only` 模式本身）；
- 禁止绕过契约自造字段、路径、错误码；禁止静默修改已冻结契约；
- 禁止删除既有源码、禁止 git 写操作；
- 禁止执行白名单外命令（`rules/dev-contract.mdc` 第 32 条）；
- 禁止把技术栈默认成"我以为的框架"——未命中必须询问。
