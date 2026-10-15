# 软件工程化智能体套件（ai-engineering-agent）

> English version: [README.en.md](./README.en.md)
>
> **状态说明**：本套件仍在持续打磨中，**可能仍存在未发现的问题**——包括但不限于
> 规约之间口径不一致、命令 / 技能引用失效、产物路径与规约不符、表述歧义等。
> 使用前建议先通读 `rules/` 与你要用的那条命令；发现任何问题或有改进想法，
> 欢迎补充完善（新增技术栈画像、补充规约条款、修正错误引用、沉淀踩坑经验都欢迎）。
> 反馈时附上**文件路径 + 行号 + 现象**最有效。

把软件工程全流程封装为「命令 + 技能 + 角色 + 规约」四层结构，
并用**产物文件**在阶段之间交接，不依赖对话上下文。

覆盖两条主线：

- **0-1 新建**：需求分析 → PRD → HTML 原型 → 契约 → 前后端实现 → 测试用例 → 变更日志 → 一致性核验
- **1+ 存量**：源码逆向 → PRD → HTML 原型 → 变更日志（Git 历史 + 需求拍板双来源）→ 一致性核验

---

## 一、快速开始

1. 把本包内的 `.codebuddy/` 整个目录**拷贝到目标项目的根目录**（与 `.git` 同级）。
2. 用 CodeBuddy 打开该项目，**新建一个会话**——规则只在会话开始时加载，旧会话不会自动生效。
3. 按场景执行入口命令：

| 场景 | 命令 |
| --- | --- |
| 存量项目（读源码出 PRD 与原型） | `/ai-reverse-project` |
| 全新项目（从需求出发） | `/ai-require-design` |
| 后端实现（含契约起草与冻结） | `/ai-dev-backend` |
| 前端实现（对接契约） | `/ai-dev-frontend` |
| 生成三类测试用例（只生成不执行） | `/ai-test-design` |

4. 三条开发侧命令**相互独立**，可任意顺序执行，仅通过 `docs/dev/` 下的产物与规约对齐。
5. 不确定从哪开始就执行 `/ai-reverse-project <仓库目录>`（存量）或 `/ai-require-design <项目名>`（新建），
   命令会先回显执行计划，确认后才落盘。

---

## 二、端到端使用教程（示例）

> 本节以示例项目 `lab-booking` 演示从安装到增量开发的完整流程。

### 2.0 示例背景

`lab-booking` —— 某高校「实验室仪器预约系统」。三年前外包交付，一直只有源码没有文档。
团队接手后有两件事要做：

1. 把已有系统的需求整理成可评审的 PRD 与可交互原型；
2. 在此基础上新增一个功能：**仪器校准到期后自动停用并停止受理预约**。

仓库位置（示例）：`D:\work\lab-booking`

探测到的现状（逆向阶段自动得出）：前端 `vue 2.6.14` + `element-ui 2.15`，
后端 Java 8 + Spring Boot 2.7.5，数据库 MySQL 5.7。

### 2.1 第一步：安装

```text
D:\work\lab-booking\
├── .git\
├── .codebuddy\        ← 把本套件的 .codebuddy 整个拷到这里
├── src\
└── pom.xml
```

拷贝完成后用 CodeBuddy 打开该目录，**新建一个会话**（关键：规则只在会话开始时加载）。

### 2.2 第二步：存量逆向（起点）

```text
/ai-reverse-project D:\work\lab-booking --out=docs/reverse-engineered --scope=reservation,instrument
```

命令会先校验参数、回显执行计划（模式 `evolve`、扫描范围、产出目录、阶段清单），
确认后逐阶段落盘。**全程只读源码**，不修改仓库状态。

产出目录示例：

```text
D:\work\lab-booking\docs\reverse-engineered\
├── _meta\
│   ├── project-profile.md      # 技术栈、模块清单、启动方式
│   ├── traverse-report.md      # 遍历范围与命中文件数
│   ├── open-questions.md       # Q-01 ~ Q-09，每条带 owner
│   └── status.md               # 阶段状态（断点续跑依据）
├── modules\
│   └── reservation.md          # 按业务域的功能分析，结论带证据
├── prd\
│   ├── F01-仪器台账.md
│   ├── F02-预约申请.md
│   └── F03-预约审批.md
├── prototype\
│   ├── index.html              # 导航页，可直接双击打开
│   ├── F02-reservation.html
│   └── prototype-spec.md
├── dictionary\
│   ├── api-inventory.md        # 接口清单
│   ├── table-inventory.md      # 表结构
│   └── field-dictionary.md     # 字段字典
├── permission-matrix.md
├── hidden-logic.md             # 隐藏逻辑与历史遗留
├── changelog\
│   ├── CHANGELOG.md            # 合并后的变更日志
│   ├── _git-log.md             # 来源 A：Git 提交历史
│   └── _decisions.md           # 来源 B：需求拍板记录
└── review\
    └── consistency-report.md   # 一致性核验报告
```

产出内容片段（示意）：

`modules/reservation.md` 中的一条结论——每条都必须带证据，不得臆造：

```markdown
- 预约冲突判定只比较时间区间，**未比较实验室房间号**，因此同一时段的不同房间
  会被误判为冲突。
  证据：`ReservationServiceImpl#checkConflict`
       （`src/main/java/.../ReservationServiceImpl.java:118-146`）
  置信度：高（代码直读）
```

`prd/F03-预约审批.md` 中的功能与验收标准：

```markdown
### F03 预约审批

- 前置：仅「仪器负责人」可审批本人负责仪器的预约单
- 规则 3.2：同一仪器在同一时间段只允许存在一条「已通过」的预约单
- 规则 3.4：审批通过后不可直接改时间，须先撤回再重新提交

- AC-03-2：填写驳回原因后提交 → 单据状态为「已驳回」，
  并向申请人发出站内通知（含原因全文）；原因超过 200 字时给出截断提示
```

`_meta/open-questions.md` 中的待确认项（带 owner，不阻塞已确认部分）：

```markdown
| 编号 | 问题 | owner | 影响 |
| --- | --- | --- | --- |
| Q-07 | 单次预约最长时长是否有硬上限？代码中未见校验 | 教务-王 | F02 规则 2.5 |
```

此时 `_meta/status.md` 中五个阶段均为 `done`，文档可交付评审。

### 2.3 第三步：技术栈与套件默认不一致怎么办

本套件默认技术栈是 React 18 + Java 17 + Spring Boot 3.2，
而本示例是 Vue 2.6 + Java 8 + Spring Boot 2.7，**必须先声明**，否则后续命令会：
探测到 `vue@2.6` 不匹配任何已登记画像（`frontend-vue3` 要求 vue ≥ 3）→ 走「停下询问」。

两种做法，任选其一：

**做法 A（推荐，只影响当前项目）**——在项目内写一份覆盖文件：

```text
D:\work\lab-booking\docs\dev\_meta\tech-stack.md
```

在其中写明前端 Vue 2.6 + Element UI、后端 Java 8 + Spring Boot 2.7，
并引用已有的后端画像 `tech-stacks/backend-java-springboot.md`。
运行时按**命中序**解析（权威定义见 `rules/dev-contract.mdc` §七 第 28 条）：
`--stack` → 本文件 → 特征探测 → 套件默认 `.codebuddy/tech-stack.md` → 停下询问。
注意**套件默认排在特征探测之后**，因此不会被套用到存量工程上。

**做法 B（新增画像，可跨项目复用）**——参照 `tech-stacks/README.md` §四：

1. 复制 `tech-stacks/frontend-vue3.md` 为 `tech-stacks/frontend-vue2.md`；
2. 按其 §二 的 8 节契约改写（元信息 / 识别特征 / 目录骨架 / 分层职责 / 依赖清单 /
   命名约定 / 构建测试命令 / 可引用规约）；
3. 在 `tech-stacks/README.md` §三 登记一行；
4. 之后用 `--stack=frontend-vue2` 显式指定。

### 2.4 第四步：契约先行（开发侧的「第 0 棒」）

开发侧产物根统一用 `--out=docs/dev`，三个命令共用同一个根，靠产物对齐：

```text
/ai-dev-backend D:\work\lab-booking --out=docs/dev --contract-only --stack=backend-java-springboot
```

`--contract-only` 只做「契约生成 + 冻结」，**不写任何业务代码**，适合前后端并行前的对齐：

```text
D:\work\lab-booking\docs\dev\
├── contract\
│   ├── README.md        # status: frozen，version: v1.0
│   ├── api.yaml         # 机器可读契约（API-01 …）
│   ├── api.md           # 人读接口文档
│   ├── data-model.md
│   ├── enums.md
│   └── error-codes.md
└── _meta\
    ├── status.md
    ├── traceability.md      # 需求追溯矩阵
    └── change-requests.md   # 对他人产物的变更申请（追加式）
```

> `contract/` 的**唯一写者**是 `/ai-dev-backend`。前端与测试侧发现契约缺项时，
> 不是自己补字段，而是写入 `contract/_requests.md`（契约变更申请，追加式）；
> 对他人其它产物的变更申请记入 `_meta/change-requests.md`。两者都由后端裁决。

### 2.5 第五步：前端实现与测试用例（可并行）

契约冻结后，两条命令互不依赖、可同时跑：

```text
/ai-dev-frontend D:\work\lab-booking --out=docs/dev --stack=frontend-vue2
/ai-test-design   D:\work\lab-booking --out=docs/dev
```

产出：

```text
docs\dev\frontend\_meta\{probe.md,page-impl-report.md,api-binding-report.md,contract-gaps.md,status.md}
docs\dev\test\
├── _meta\{test-plan.md,coverage-matrix.md,status.md}
├── unit\TC-U01-....md          # 单元测试用例
├── integration\TC-I01-....md   # 联调测试用例
└── uat\TC-A01-....md           # UAT 用例
```

前端必须**逐字对齐契约**（路径、方法、字段名、类型、错误码），页面对应原型页面编号 `P01…`；
测试**只生成用例、不执行**，执行交人工或外部工具。

### 2.6 第六步：增量开发一条新功能

承接 §2.0 的目标 2，新增 `F08-校准到期自动停用`：

```text
/ai-dev-backend D:\work\lab-booking --out=docs/dev --scope=F08
```

该命令会读到 `F08` 尚未在契约中体现，于是走**契约变更流程**：

- `contract/version` 由 `v1.0` → `v1.1`，状态 `frozen` → `changed` → 再次 `frozen`；
- 契约变更申请追加到 `contract/_requests.md`（谁提出、影响哪些 `API-xx`、裁决结果）；
- 实现完成后回填 `_meta/traceability.md` 的「接口 API」与「后端实现」两列。

追溯矩阵示例（列所有权：谁定义谁写，别人只读）：

```markdown
| 功能 | 需求来源 | 接口 API | 前端页面 | 后端实现 | 测试用例 |
| --- | --- | --- | --- | --- | --- |
| F03-预约审批 | prd/F03 §3.2 | API-07@v1.0 | P04 | ReservationApprovalServiceImpl | TC-U03 / TC-I02 |
| F08-校准到期自动停用 | prd/F08 | API-19@v1.1 | P11 | CalibrationGuardTask | TC-U11 / TC-A04 |
```

### 2.7 第七步：中断与续跑

任何阶段中断（关会话、断网、改需求）后，**重跑同一条命令即可**：
命令读各产物目录的 `_meta/status.md`，跳过已 `done` 的阶段，从 `in_progress` 继续；
`blocked` 的阶段会明确打印缺什么（例如「缺少 `prd/F08` 的 AC，无法冻结契约」）。

`--scope` 也支持缩小范围重跑，例如只重做 `--scope=reservation`。

### 2.8 示例小结

```text
/ai-reverse-project   → docs/reverse-engineered/   （PRD、原型、字典、变更日志、核验报告）
/ai-dev-backend       → docs/dev/contract/ + backend/
/ai-dev-frontend      → docs/dev/frontend/
/ai-test-design       → docs/dev/test/
                       ↑ 三命令共用 --out=docs/dev，只靠产物与规约对齐
```

一条主线的完整走法就是：**逆向或澄清需求 → 出 PRD 与原型 → 冻结契约 → 前后端并行实现 →
生成测试用例 → 回填追溯矩阵**；中途随时可中断续跑，新增需求走契约变更流程。

---

## 三、目录结构

| 路径 | 内容 | 说明 |
| --- | --- | --- |
| `.codebuddy/tech-stack.md` | 系统默认技术栈 | **唯一**默认声明源，首次使用前建议先看这里 |
| `.codebuddy/tech-stacks/` | 技术栈画像库（5 个文件） | Java+SB2 / Java+SB3+JDK17 / Vue3 / React + 登记说明 |
| `.codebuddy/rules/` | 规约（9 份 + Java 组 5 份 + 1 份术语表） | 逆向铁律、PRD、原型、变更日志、工作流、开发契约、前后端/测试规约 |
| `.codebuddy/agents/` | 子角色（9 个） | 需求分析、PRD、原型、源码分析、变更日志、前后端开发、测试设计、一致性核验 |
| `.codebuddy/commands/` | 斜杠命令（5 条） | 见快速开始表 |
| `.codebuddy/skills/` | 技能（8 个） | 每个技能含 `SKILL.md`，部分带 `references/`、`templates/`、`assets/` |

---

## 四、前置依赖

| 依赖 | 必需性 | 说明 |
| --- | --- | --- |
| `code-explorer` 子代理 | 必需 | CodeBuddy 内置；源码逆向依赖它做语义导航 |
| `git` | 必需 | 变更日志来源 A（仅用 `log` / `show` 等**只读**命令） |
| `docx` / `pdf` 技能 | 可选 | 需要导入 Word / PDF 需求文档时安装 |
| `security-sensitive-filter` 技能 | 可选 | 若未安装，产物脱敏按 `rules/se-workflow.mdc` 第 18 条人工执行（同一套红线：密钥、口令、连接串、真实域名、内网地址、PII 一律占位符） |

---

## 五、默认技术栈与如何覆盖

默认值（见 `tech-stack.md`）：前端 React 18 + Vite + TypeScript + Arco Design；
后端 Java 17 + Spring Boot 3.2.x + MyBatis + Maven；MySQL 8 + Redis 7；
部署为 Maven fat jar 手动上传，**默认不引入 Docker / K8s / CI / 配置中心 / 网关**。

覆盖**命中序**（运行时逐级求值，1 命中即止；权威定义见 `rules/dev-contract.mdc` §七 第 28 条）：

1. `/ai-dev-*` 命令参数 `--stack=<画像 id>`
2. 项目级 `<DEV>/_meta/tech-stack.md`（`<DEV>` = `<目标项目>/docs/dev/`，**推荐**，不动本套件）；
   缺失时回退读 0-1 阶段落档的 `<项目>/_meta/tech-stack.md`
3. 特征探测（读 `pom.xml` / `package.json` 等，匹配画像库的「识别特征」）
4. `.codebuddy/tech-stack.md`（本套件默认，**仅在无任何工程结构可探测时**使用）
5. 均未命中 → **停下询问**，不猜测

第 4 级排在第 3 级之后是有意为之：默认值面向「从零新建」，若让它先命中，
Java 8 + Spring Boot 2.7 这类存量工程会被误判成 Java 17 + Spring Boot 3.2。

新增技术栈画像只需新增一份画像文件并在 `tech-stacks/README.md` §三 登记，
**不改命令、不改角色、不改规约**，步骤见该文件 §四。

---

## 六、生效与排障

- **规则改动后必须新建会话**才会加载，当前会话不会热更新。
- 规则文件扩展名统一为 **`.mdc`**（与官方规则约定一致），平铺于 `rules/` 与
  `rules/java/` 两个目录；其中 `rules/java/java-glossary.md` 是术语参考表，
  无 frontmatter、不参与规则加载，因此保持 `.md`。
- 若新建会话后询问「当前应用了哪些规则」发现规则未加载，可把 `rules/*.mdc`
  改回 `rules/*.md` 再试（部分版本对扩展名的宽容度不同）；无论采用哪种命名，
  都必须同步替换其它文件中的 `rules/<规则名>` 引用，否则会出现指向
  不存在文件的悬空引用（本包的引用已全部对齐 `.mdc`）。
- 命令没出现在斜杠菜单：确认 `.codebuddy/commands/*.md` 的 frontmatter 完整
  （`description` / `argument-hint` / `allowed-tools`）。
- `alwaysApply: true` 的规则会**常驻上下文**。本套件目前是 2 份 Java 基础规约
  （`java-coding-basics.mdc`、`java-oop-collection.mdc`，合计约 50KB）。若上下文
  紧张，可改为 `false` 走按需加载（但会牺牲「写 Java 时必生效」的保障）。
- 子角色的可调用技能写在其「可调用 Skill」小节；技能名以 `[skill:xxx]` 或
  反引号形式引用（如 `[skill:docx]`、`` `security-sensitive-filter` ``），
  未安装时该步骤会降级或跳过。
- `rules/java/java-database.mdc` 额外用了 `globs` 字段（按文件类型限定加载）。部分版本
  的规则 frontmatter 只认 `description` / `alwaysApply` / `enabled` / `updatedAt` / `provider`，
  此时 `globs` 被忽略、该规则不会自动加载——需要时在会话中显式引用该文件路径即可。

---

## 七、产物落盘位置

产物一律写入**目标项目内**，不写入本套件目录：

| 模式 | 落盘位置 | 内容 |
| --- | --- | --- |
| 0-1 | `<项目>/docs/forward-engineered/` | `_meta/`、`prd/`、`prototype/`、`changelog/`、`review/` |
| 1+ | `<目标仓库>/docs/reverse-engineered/` | 上述内容，外加 `modules/`、`dictionary/`、`permission-matrix.md`、`hidden-logic.md` |
| 开发侧 | `<目标项目>/docs/dev/` | `contract/`、`_meta/`（追溯矩阵等）、`backend/`、`frontend/`、`test/` |

均可用 `--out=<目录>` 覆盖默认位置。阶段状态写入各产物目录的 `_meta/status.md`，
中断后重跑会据此**断点续跑**，已 `done` 的阶段不重做。

---

## 八、使用纪律（红线摘要）

- **脱敏**：落盘前过滤密钥、令牌、口令、数据库连接串、真实域名、内网地址与个人隐私，一律占位符。
- **只读**：逆向模式严禁执行任何修改目标源码或仓库状态的命令。
- **追加式**：变更日志不覆盖、不删除历史条目，修正只能新增条目。
- **契约先行**：实现前先冻结契约；PRD 只描述 What，实现层信息一律以 `contract/` 为准，缺项登记为缺口，不得臆造。
- **可追溯**：逆向结论必须带「文件路径 + 行号」证据，禁止臆造，置信度分三级。
