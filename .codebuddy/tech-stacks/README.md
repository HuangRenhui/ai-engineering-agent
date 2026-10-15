# 技术栈画像库（tech-stacks）

> **当前系统默认**（2026-09-17 第二版）：前端 React 18 + Arco Design；后端 Java 17 + Spring Boot 3.2.x；部署手动 jar 上传。
> 完整默认见 `.codebuddy/tech-stack.md`。

> 用途：为 `/ai-dev-backend`、`/ai-dev-frontend` 提供**技术栈相关的骨架与方法论**，使命令本身**技术栈无关**。
> 新增技术栈（Python / C++ / React / 内部框架）= **只新增一份画像文件**，不改命令、不改角色、不改规约。

## 一、解析顺序（权威定义：`rules/dev-contract.mdc` §七 第 28 条，命中即止）

下表"命中序"即求值顺序，**不是**优先级递减的编号；本表仅为便于查画像取值，口径以规约为准。

| 命中序 | 来源 | 说明 |
|--------|------|------|
| 1 | 命令参数 `--stack=<id>` | 显式指定，最高优先；取值见 §三 |
| 2 | 项目侧画像 `<DEV>/_meta/tech-stack.md` | 项目特有框架 / 内部规范写这里；缺失时回退读上游 0-1 落档的 `<项目>/_meta/tech-stack.md`；两者均缺失才生成模板并请用户确认 |
| 3 | 目标项目特征探测 | 读构建文件与目录特征，匹配下方画像的「识别特征」；**存量工程以探测结果为准** |
| 4 | 系统默认 `.codebuddy/tech-stack.md` | 仅在无任何工程结构可探测时作为基准（见 §五） |
| 5 | 均未命中 | **停下询问**，不默认、不猜测 |

> `<DEV>` = `<目标项目>/docs/dev/`（见 `dev-contract.mdc` §一）。

## 二、画像文件契约（每份画像必须含 8 节）

1. **元信息**：`id`、`类型`（backend/frontend）、`名称`、`版本`、`适用场景`、`不适用场景`
2. **识别特征**：文件与目录级判据（用于命中序 3 的自动探测）
3. **目录骨架**：默认落盘结构（对齐 `dev-contract.mdc` 第 22~23 条：已有工程沿用原结构，新项目 `backend/` / `frontend/`）
4. **分层与职责映射**：如何对应 `backend-dev-standard.mdc` §二 / `frontend-dev-standard.mdc` §四 的职责表
5. **依赖清单**：核心依赖与其用途（给出候选，不锁定具体小版本）
6. **命名与代码约定**：包/模块/文件/类/方法/组件命名
7. **构建与测试命令**：白名单内的命令（`dev-contract.mdc` 第 32 条）
8. **可引用规约**：本画像应配合加载的 rules（如 `rules/java/*`）

## 三、已登记画像

| id | 类型 | 名称 | 文件 | 识别特征（摘要） |
|----|------|------|------|------------------|
| `backend-java-springboot` | backend | Java 8 + Spring Boot + MyBatis | `backend-java-springboot.md` | `pom.xml` / `build.gradle` + `src/main/java` |
| `frontend-vue3` | frontend | Vue 3 + Vite + TypeScript | `frontend-vue3.md` | `package.json` 含 `vue` 且 `vue` ≥ 3 |
| `frontend-react` | frontend | React 18 + Vite + TypeScript | `frontend-react.md` | `package.json` 含 `react` |
| `backend-java-springboot-jdk17` | backend | Java 17 + Spring Boot 3.x + MyBatis | `backend-java-springboot-jdk17.md` | `<java.version>17` + SB ≥ 3.0 + `import jakarta.*` |

> 待扩展（按需新增）：`backend-python-fastapi`、`backend-python-django`、`backend-cpp-cmake`、`frontend-vue2`、`frontend-angular` 等。

## 四、新增画像的步骤

1. 复制任一同类型画像为模板，改 `id` 与 8 节内容；
2. 在上表「已登记画像」追加一行；
3. 在对应命令的 `--stack` 候选清单中追加 `id`（命令的候选清单以本 README §三 为准，无需改命令逻辑）；
4. 校验：画像全文**不得出现**项目专属信息（业务名、真实域名、账号、密钥、内网地址）。

## 五、系统默认技术栈声明

0-1 新建项目的**默认技术栈由 `.codebuddy/tech-stack.md` 单点声明**，本目录（`tech-stacks/`）仅提供可选画像；命令 / 技能 / 角色 / 规约文件**不重复声明**技术栈内容，仅在 §一 的命中序解析中按命中即止原则引用该文件。

| 引用方 | 引用方式 |
|--------|----------|
| `/ai-require-design`（0-1 需求设计） | 阶段 0 自动加载；项目级 `<项目>/_meta/tech-stack.md` 优先 |
| `/ai-dev-backend` / `/ai-dev-frontend`（开发实现） | 命中序第 4 级参与解析（排在前三级之后）；命中即止 |
| PRD 编写（`prd-author`） | 必含 §技术选型与 UI 约束节，逐字对齐 `_meta/tech-stack.md` |
| 原型生成（`prototype-designer`） | 按 UI 库加载 `skills/html-prototype/references/visual-<ui-lib>.md` |

调整默认：直接编辑 `.codebuddy/tech-stack.md`；新增可选用画像在本目录新增文件并在 §三 登记。

## 六、红线

- 【强制】画像只描述**通用技术方法论**，禁止写入任何具体项目内容；
- 【强制】画像中给出的命令必须落在 `dev-contract.mdc` 第 32 条白名单内；
- 【强制】画像不得与 `dev-contract.mdc` / `backend-dev-standard.mdc` / `frontend-dev-standard.mdc` 冲突；冲突时以规约为准；
- 【推荐】画像版本变更时在文件末尾维护「变更记录」表。
