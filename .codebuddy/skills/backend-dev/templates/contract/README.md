# 接口契约 · <项目名称>

> 产出根：`<DEV>/contract/` ｜ 生成时间：`<YYYY-MM-DD HH:mm>` ｜ 生成命令：`/ai-dev-backend`
> 权限：**起草 / 写 / 冻结 / 裁决 = `/ai-dev-backend`（唯一写者）**；评审 / 申请 = `/ai-dev-frontend`、`/ai-test-design`（只能写 `_requests.md`）；**终裁 = 用户**。

## 1. 契约状态

| 字段 | 值 | 说明 |
|------|-----|------|
| `version` | `<v0.1>` | 每次契约变更 `+1`（`v0.1` → `v0.2`） |
| `status` | `<draft｜frozen｜changed>` | 置位权仅 `/ai-dev-backend`；`frozen` 后方可作为实现与用例的稳定依据 |
| `owner` | `backend-developer` | 契约唯一写者 |
| `frozen_at` | `<YYYY-MM-DD HH:mm>` | 未冻结填 `—` |
| `based_on` | `prd/<文件>`、`dictionary/<文件>`（1+） | 契约字段的来源依据 |
| `tech_stack` | `<画像 id>` | 命中序：1 `--stack` / 2 项目画像 / 3 特征探测 / 4 系统默认（见 `rules/dev-contract.mdc` §七 第 28 条） |

## 2. 文件清单（不增不减）

| 文件 | 内容 | 齐备 |
|------|------|------|
| `README.md` | 本文件：封面、文件清单、变更摘要、`x-inferred` 登记 | [ ] |
| `api.yaml` | 接口契约（OpenAPI 3.0，**机器可读唯一源**） | [ ] |
| `api.md` | 接口人读概览（与 `api.yaml` **逐条一一对应**，供评审） | [ ] |
| `data-model.md` | 数据模型（表 / 字段 / 约束 / 索引 / 关联 / 状态取值） | [ ] |
| `enums.md` | 枚举与字典（枚举名 / 取值 / 含义 / 来源） | [ ] |
| `error-codes.md` | 统一错误码（码 / HTTP / 含义 / 触发条件 / 前端文案） | [ ] |
| `_change-log.md` | 契约变更历史（**追加式**，永不覆盖） | [ ] |
| `_requests.md` | 他命令提交的变更申请（**追加式**） | [ ] |

## 3. 本次变更摘要

| 版本 | 时间 | 变更项 | 原因 | 申请人 | 影响范围 | 需重新对齐 |
|------|------|--------|------|--------|----------|------------|
| `<v0.1>` | `<YYYY-MM-DD HH:mm>` | 首版冻结 | 契约先行（第 0 棒） | `user` | 全量 | 前端 API 绑定、联调用例 `TC-I` |
| | | | | | | |

## 4. `x-inferred` 字段登记（无来源字段）

| 契约位置 | 字段 | 推导依据 | 待确认人 `owner` |
|----------|------|----------|------------------|
| `api.yaml#/components/schemas/<Schema>/<field>` | `<field>` | `<推导说明>` | `<owner>` |

> 无来源即**不得**写入契约；确需写入时必须标 `x-inferred: true` 并在此登记，供后续核验与用户拍板。

## 5. 消费约定

- 任一命令启动时先读本文件，记录 `version`，并把本次产出**绑定到该版本**；
- `frozen` 后**不得静默修改**；变更走「改契约 + `version`+1 + `status: changed` + `_change-log.md` 追加 + 写入 `changelog/CHANGELOG.md`」五步，缺一不可；
- 前端 / 测试发现契约问题 → 追加 `_requests.md` 并在自身报告登记偏差 → **继续推进不依赖该契约的阶段**，不阻塞开发；
- `version` 落后时下游**只重做受影响部分**（受影响页面 / 绑定 / 用例），其余不动。
