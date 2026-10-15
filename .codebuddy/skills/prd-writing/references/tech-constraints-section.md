# PRD §技术选型与 UI 约束节 · 模板

> 本模板为 PRD 文档级 12 项中**新增的固定节**（new 模式专用；evolve 模式按项目覆盖文件填空）。
>
> 数据来源：`<项目>/_meta/tech-stack.md`（系统默认来自 `.codebuddy/tech-stack.md`）。
>
> 写作纪律：**逐字对齐 `_meta/tech-stack.md`**，禁止自行改写或扩写；如需变更，须先改 `_meta/tech-stack.md` 再回头同步本节。

---

## §技术选型与 UI 约束

### 元信息

| 项 | 值 |
|----|----|
| 填充时间 | （YYYY-MM-DD） |
| 数据来源 | `<项目>/_meta/tech-stack.md`（系统默认来自 `.codebuddy/tech-stack.md`） |
| 变更方式 | 改 `_meta/tech-stack.md` → 同步本节（禁止直接改本节） |

### 1. 前端栈

| 维度 | 选择 | 对 PRD 的约束 |
|------|------|---------------|
| 框架 | （Vue 3 / React 18） | 组件模型 / 状态管理 / 路由形态 |
| 构建 | （Vite + TypeScript） | 包大小 / 构建时长约束 |
| UI 库 | （Element Plus / Ant Design / Vant 等） | 控件外观 / 文案 / 校验反馈对齐此库规范 |
| 路由 | （Vue Router 4 / React Router 6） | 路由守卫文案取 PRD 文案规范 |
| 状态管理 | （Pinia / Redux Toolkit） | 全局态字段在契约中标注 |
| HTTP | axios + 统一请求层 | 接口字段名 / 错误码映射写死 |
| 目录 | `<项目根>/frontend/` | 0-1 默认；存量项目沿用原结构 |

### 2. 后端栈

| 维度 | 选择 | 对 PRD 的约束 |
|------|------|---------------|
| 语言 / 框架 | （Java 8 + Spring Boot 2.7 / 其他） | 接口形态（路径/方法/参数风格） |
| ORM | （MyBatis / 其他） | 字段类型映射 / 软删除 / 审计字段约定 |
| 鉴权 | （JWT / Session） | 登录态语义 / 鉴权字段约定 |
| 接口风格 | REST + JSON（统一 `code/message/data/traceId`） | 响应结构文案取 PRD 文案规范 |
| 包结构 | （`controller / service / mapper / domain / dto / vo / config / common`） | — |

### 4. 数据规则

| 维度 | 选择 | 对 PRD 的约束 |
|------|------|---------------|
| 主库 | （MySQL 8 / PostgreSQL 等） | 字符集 / 排序规则 / 字段类型 |
| DDL 命名 | `REQxxx-<描述>-v0.x-YYYYMMDD.sql` | 首版 `REQ001` 全量；后续每 `REQ` 增量；幂等可重跑；历史不改不删 |
| 缓存 | （Redis 7 / 其他 / 不启用） | 缓存 key 命名 / 失效策略 |
| MQ | （不启用 / RabbitMQ / Kafka） | 消息 topic / 重试策略 |

### 5. 接口契约约束

| 维度 | 选择 |
|------|------|
| 契约格式 | OpenAPI 3.0（`contract/api.yaml` 机器可读 + `api.md` 人读） |
| 状态机 | `draft` → `frozen` → `changed`（`version`+1） |
| 错误码 | `contract/error-codes.md` 集中维护；禁止散落 |
| 字段约束 | 路径/方法/字段名/类型/错误码**逐字对齐契约** |

### 6. 部署形态

| 维度 | 选择 |
|------|------|
| 目标 | 容器化（Docker） |
| 编排 | Kubernetes（最小 2 副本） |
| CI/CD | （GitLab CI / GitHub Actions） |
| 环境 | dev / staging / prod |

### 7. 不在范围内（需登记开放问题）

- （国际化、移动端、高并发、等保、信创、第三方 SDK 等，按 `.codebuddy/tech-stack.md` §7 抄录）

### 8. 视觉基线引用

- 前端 UI 库视觉基线：`skills/html-prototype/references/visual-<ui-lib>.md`
  - 例：`.codebuddy/skills/html-prototype/references/visual-element-plus.md`
- 页面布局与样式基线：`skills/html-prototype/references/page-layout-baseline.md`

---

## 自检清单

- [ ] 数据来源明确标注（`<项目>/_meta/tech-stack.md`）
- [ ] 内容**逐字对齐** `_meta/tech-stack.md`，无自行改写
- [ ] 各层维度（前端 / 后端 / 数据 / 契约 / 部署）齐备
- [ ] "不在范围内"段已抄录并具化到本项目
- [ ] 视觉基线引用指向正确文件