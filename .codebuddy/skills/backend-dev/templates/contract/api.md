# 接口人读概览 · <项目名称>

> 与 `api.yaml` **逐条一一对应**（路径 / 方法 / 字段 / 类型 / 必填 / 错误码），供人工与前端 / 测试评审。
> 两者不一致时以 `api.yaml` 为准，并立即补齐本文件（或修正 `api.yaml` 后 `version`+1）。
> 版本：`<v0.1>` ｜ 状态：`<draft｜frozen｜changed>` ｜ 生成时间：`<YYYY-MM-DD HH:mm>`

## 1. 接口清单

| 接口标识 | 方法 | 路径 | 功能 F | 鉴权 | 幂等 / 事务 | 备注 |
|----------|------|------|--------|------|-------------|------|
| `API-01` | GET | `/<resources>` | `F01-<功能名>` | 是 | 只读 | 分页 + 排序 |
| `API-02` | POST | `/<resources>` | `F02-<功能名>` | 是 | 幂等（`idempotentKey`） | 写操作 |
| `API-03` | GET | `/<resources>/{id}` | `F03-<功能名>` | 是 | 只读 | |
| `API-04` | PUT | `/<resources>/{id}` | `F04-<功能名>` | 是 | 事务 + 乐观锁 | |
| `API-05` | DELETE | `/<resources>/{id}` | `F05-<功能名>` | 是 | 事务 | 逻辑删除见 `data-model.md` |

## 2. 逐接口明细

### `API-01` 查询列表（GET `/<resources>`）

**入参**

| 参数 | 位置 | 类型 | 必填 | 默认 | 约束 | 说明 |
|------|------|------|------|------|------|------|
| `page` | query | integer | 否 | 1 | ≥ 1 | 页码 |
| `pageSize` | query | integer | 否 | 20 | 1~100 | 每页条数 |
| `<筛选字段>` | query | string | 否 | — | ≤ 64 | <筛选口径> |
| `sortBy` | query | string | 否 | `createdAt` | 枚举 | 排序字段 |
| `order` | query | string | 否 | `desc` | 枚举 | 排序方向 |

**出参**（`data`）

| 字段 | 类型 | 必返 | 说明 |
|------|------|------|------|
| `total` | integer(int64) | 是 | 总条数 |
| `page` | integer | 是 | 当前页 |
| `pageSize` | integer | 是 | 每页条数 |
| `list[].id` | integer(int64) | 是 | 主键 |
| `list[].<字段名>` | string | 否 | <业务含义> |
| `list[].status` | integer | 是 | <取值见 `enums.md`> |
| `list[].createdAt` | string(date-time) | 是 | 创建时间 |

**错误码**：`<40001 参数校验失败>`、`<40100 未登录>`、`<40300 无权限>`

### `API-02` 新建（POST `/<resources>`）

**入参**

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| `<必填字段名>` | string | 是 | ≤ 64 | <校验规则> |
| `<可选字段名>` | string | 否 | ≤ 255 | <业务含义> |
| `idempotentKey` | string | 否 | ≤ 64 | 幂等键，重复提交返回首次结果 |

**出参**：`data` = 新建对象主键（integer(int64)）

**错误码**：`<40001 参数校验失败>`、`<40901 唯一键冲突>`

### `API-03` 查询详情（GET `/<resources>/{id}`）

**入参**：`id`（path，integer(int64)，必填，≥ 1）

**出参**：`data` = 单对象（字段同 `list[]`，另含 `updatedAt`）

**错误码**：`<40401 目标不存在>`

### `API-04` 更新（PUT `/<resources>/{id}`）

**入参**

| 字段 | 类型 | 必填 | 约束 | 说明 |
|------|------|------|------|------|
| `id` | integer(int64) | 是 | ≥ 1 | 与路径 `id` 一致 |
| `<字段名>` | string | 否 | ≤ 64 | <业务含义> |
| `version` | integer | 否 | — | 乐观锁版本号 |

**错误码**：`<40001 参数校验失败>`、`<40902 并发更新冲突>`

### `API-05` 删除（DELETE `/<resources>/{id}`）

**入参**：`id`（path，integer(int64)，必填）

**错误码**：`<40401 目标不存在>`、`<40903 状态不允许删除>`

## 3. 全局约定

| 项 | 约定 |
|----|------|
| 响应结构 | `{ code, message, data, traceId }`，成功 `code = 0` |
| 鉴权 | `Authorization: Bearer <token>`（JWT），失败返回 401 + 对应错误码 |
| 分页 | query 传 `page` / `pageSize`，响应 `data.{total,page,pageSize,list}` |
| 排序 | query 传 `sortBy` + `order`，未传按 `createdAt desc` |
| 时间 | `date-time`，ISO 8601 含时区（如 `2026-09-17T10:30:00+08:00`） |
| 编码 | 请求与响应均为 `application/json; charset=UTF-8` |
| 幂等 | 写操作以 `idempotentKey` 去重；未传时按业务键去重（在 `data-model.md` 说明） |
| 错误码 | 统一见 `error-codes.md`，禁止在实现中新增"临时码" |

## 4. 一致性校验（冻结前自查）

- [ ] 本文件每条接口在 `api.yaml` 均有 `paths` 对应项，反向亦然（**无多无少**）；
- [ ] 字段名、类型、必填、默认值、枚举取值与 `api.yaml` 完全一致（含大小写）；
- [ ] 每个 `API-xx` 至少关联一个 `F` 编号，且 `F` 存在于 `prd/`；
- [ ] 列举的错误码全部存在于 `error-codes.md`；
- [ ] 无真实域名、账号、密钥、PII。
