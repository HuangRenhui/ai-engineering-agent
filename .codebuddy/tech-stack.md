# 系统默认技术栈（0-1 单点预定义）

> **单点定义原则**：本文件是 0-1 新建项目默认技术栈的**唯一预定义源**。
>
> 其他命令 / 技能 / 角色 / 规约 / 画像**仅引用本文件**，不在自身文件内重复声明技术栈内容（避免分散维护）。
>
> 运行时解析（命中序，权威定义见 `rules/dev-contract.mdc` §七 第 28 条）：`--stack=<id>` → `<DEV>/_meta/tech-stack.md`（缺失时回退 `<项目>/_meta/tech-stack.md`）→ 目标项目特征探测 → **本文件**（仅在无任何工程结构可探测时）→ 停下询问。
>
> 注意：本文件是**"从零新建"的默认值**，不是存量工程的兜底答案——存量工程以特征探测结果为准（见 `dev-contract.mdc` §七 第 28 条说明）。

## 0. 元信息

| 项 | 值 |
|----|----|
| 适用模式 | `new`（0-1 新建）；`evolve`（1+ 存量）按项目侧覆盖文件 |
| 解析时机 | `/ai-require-design` 阶段 0；`/ai-dev-backend` / `/ai-dev-frontend` 阶段 1（命中即止） |
| 关联文件 | `.codebuddy/tech-stacks/README.md`（画像库） |
| 调整方式 | 直接编辑本文件（系统默认变更）；运行期项目覆盖写一份 `<DEV>/_meta/tech-stack.md`（0-1 阶段由 `/ai-require-design` 阶段 0 落档到 `<项目>/_meta/tech-stack.md`，dev 阶段按其回退规则读取） |

## 1. 前端

| 维度 | 选择 | 关联画像 / 视觉基线 |
|------|------|---------------------|
| 框架 | React 18（函数组件 + Hooks） | `tech-stacks/frontend-react.md` |
| 构建 | Vite + TypeScript | `tech-stacks/frontend-react.md` |
| UI 库 | Arco Design（React 版，字节跳动） | `skills/html-prototype/references/visual-arco-design.md` |
| 路由 | React Router 6（createBrowserRouter） | 默认包含 |
| 状态管理 | Redux Toolkit（含 RTK Query） | 默认包含；项目级可改 Zustand |
| HTTP | axios + 统一请求层（拦截器 / 错误码映射） | 默认包含 |
| 包管理 | pnpm | 白名单内命令 |
| Node | LTS ≥ 18 | 与 `.nvmrc` 同步 |
| 目录 | `<项目根>/frontend/`（0-1 新建） | tech-stacks/frontend-react.md §3 |

## 2. 后端

| 维度 | 选择 | 关联画像 |
|------|------|----------|
| 语言 | Java 17 (LTS) | — |
| 框架 | Spring Boot 3.2.x（最低 3.0） | `tech-stacks/backend-java-springboot-jdk17.md`；JDK 17 / SB 3 迁移要点见 `skills/backend-dev/references/jdk17-springboot3-migration.md` |
| ORM | MyBatis | 同上 |
| 构建 | Maven | 同上 |
| 接口风格 | REST + JSON（统一响应 `code/message/data/traceId`） | 同上 |
| 鉴权 | JWT（无状态；登录态走 Header） | 默认 |
| 文档 | springdoc-openapi（生成 OpenAPI 3.0，对齐 `contract/api.yaml`） | 默认 |
| 包结构 | `controller / service / mapper / domain / dto / vo / config / common` | `tech-stacks/backend-java-springboot-jdk17.md` §3 |
| 命名 | 阿里巴巴 Java 嵩山版（`rules/java/java-coding-basics.mdc`、`rules/java/java-oop-collection.mdc` 已置 `alwaysApply: true`，随会话常驻加载） | — |
| 目录 | `<项目根>/backend/`（0-1 新建） | `tech-stacks/backend-java-springboot-jdk17.md` §3 |

> **JDK 17 + Spring Boot 3.x 适配要点**：详见 `skills/backend-dev/references/jdk17-springboot3-migration.md`（含 `javax.* → jakarta.*` 命名空间迁移、依赖版本基线、语法限制、迁移工具、检查清单）。

## 3. 数据

| 维度 | 选择 | 说明 |
|------|------|------|
| 主库 | MySQL 8（utf8mb4 / utf8mb4_unicode_ci） | DB 脚本位置 `<项目根>/backend/src/main/resources/db/migration/`（与 `tech-stacks/backend-java-springboot-jdk17.md` §3 一致；无画像约定时用 `<DEV>/backend/sql/`，见 `rules/dev-contract.mdc` 第 22.1 条） |
| DDL 命名 | `REQxxx-<描述>-v0.x-YYYYMMDD.sql` | 增量脚本；首版 `REQ001` 全量初始化；后续每 `REQ` 写增量；幂等可重跑；历史脚本不改不删 |
| 缓存 | Redis 7 | 默认包含 |
| MQ | 不启用 | 需启用时登记为开放问题 |
| 存储 | 暂不引入对象存储 | 需引入时登记为开放问题 |

## 4. 中间件与基础组件（手动 jar 部署场景，**默认不引入分布式组件**）

| 维度 | 选择 | 说明 |
|------|------|------|
| 配置中心 | 应用内 `application-{env}.yml`（无需 Nacos） | 单实例部署，环境差异通过 profile 隔离 |
| 注册中心 | 不启用 | 单实例无需服务注册 |
| 网关 | 不引入 | 直接暴露服务端口（默认 8080）；需前置网关时再补充 |
| 链路追踪 | Micrometer + traceId 日志贯通（不上 Zipkin） | 单实例足够 |
| 日志 | Logback（JSON 输出）+ traceId 贯通 | 默认 |

## 5. 接口契约

| 维度 | 选择 | 关联规约 |
|------|------|----------|
| 契约格式 | OpenAPI 3.0 + `api.yaml`（机器可读）+ `api.md`（人读） | `rules/dev-contract.mdc` §三 |
| 状态机 | `draft` → `frozen` → `changed`（`version`+1） | 同上 |
| 错误码 | `contract/error-codes.md` 集中维护；常量/枚举，禁止散落 | `rules/backend-dev-standard.mdc` |
| 字段约束 | 路径/方法/字段名/类型/错误码**逐字对齐契约**；无来源字段标 `x-inferred: true` | 同上 |

## 6. 部署形态

| 维度 | 选择 |
|------|------|
| 打包 | Maven fat jar（`mvn clean package -DskipTests`，产物 `<artifactId>-<version>.jar`） |
| 启动 | `java -jar <jar> --spring.profiles.active=prod`（需 JDK 17 运行时） |
| 上传 | 手动 SCP/SFTP 上传到目标服务器（运维操作，不在脚本内） |
| 环境 | dev / staging / prod 三套；差异由 `application-{env}.yml` 隔离 |
| 不引入 | Docker / Kubernetes / CI/CD 流水线 / 配置中心 / 网关 |

> **部署脚本与运维 SOP 模板**：见 `skills/backend-dev/references/manual-deploy-scripts.md`（含 `start.sh` / `stop.sh` / `restart.sh` / `status.sh`、应用目录结构、`application-{env}.yml` 切换、日志滚动、健康检查、回滚演练）。

## 7. 不在本默认范围内（需登记开放问题）

- 国际化（i18n）
- 移动端 / 小程序
- 高并发 / 大数据量场景
- 等保 / 信创合规
- 第三方 SDK（短信、支付、地图、OSS 等）

## 8. 红线

- 【强制】本文件是**唯一**系统级默认技术栈声明；命令 / 技能 / 角色文件**禁止**在自身文件内重定义技术栈内容（避免多源不一致）。
- 【强制】运行时解析与权威定义以 `rules/dev-contract.mdc` §七 第 28 条为准（命中序）；本文件只声明"从零新建"的默认值，不得被当作存量工程的兜底。
- 【推荐】每次重大调整记录一行到本文件末尾"变更记录"表。

## 9. 变更记录

| 日期 | 变更 | 决策人 |
|------|------|--------|
| 2026-09-17 | 首版：Vue3 + Element Plus + Java 8 + Spring Boot 2.7 + MySQL 8 + Redis | 当前会话用户 |
| 2026-09-17 | 第二版：React 18 + Arco Design + Java 17 + Spring Boot 3.2 + 手动 jar 上传部署；§4 中间件精简（移除 Nacos/Gateway/Sleuth/Zipkin） | 当前会话用户 |
| 2026-10-16 | 第三版：修正后端关联画像为 `backend-java-springboot-jdk17.md`（原误指 Java 8 画像）；DB 脚本目录统一为 `src/main/resources/db/migration/`；解析顺序改为命中序表述并与 `dev-contract.mdc` §七 对齐；§5 契约引用改指 §三 | 当前会话用户 |