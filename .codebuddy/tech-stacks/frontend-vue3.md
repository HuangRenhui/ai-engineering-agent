# 技术画像：Vue 3 + Vite + TypeScript（frontend-vue3）

## 1. 元信息

| 项 | 值 |
|----|----|
| `id` | `frontend-vue3` |
| 类型 | frontend |
| 名称 | Vue 3（Composition API）+ Vite + TypeScript |
| 版本 | v1.0 |
| 适用场景 | 0-1 新建前端；存量 Vue 3 工程增量开发 |
| 不适用场景 | Vue 2（Options API + webpack，需另建 `frontend-vue2` 画像）、Nuxt SSR 工程 |

## 2. 识别特征

`package.json` 中存在 `vue` 且主版本为 3（`vue` 依赖版本以 `^3` 开头），或源码出现 `createApp(`、`<script setup`。

## 3. 目录骨架

**已有工程**：沿用原结构（如 `src/`、`src/pages/`、`src/api/`），只做增量新增。

**0-1 新建（`<根>/frontend/`）**：

```
frontend/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── src/
    ├── main.ts
    ├── App.vue
    ├── api/                 # 统一 API 层（契约驱动，禁止页面直接请求）
    │   ├── request.ts       # 实例、拦截器、错误码映射
    │   └── <domain>.ts      # 按契约模块划分的接口函数与类型
    ├── types/               # 契约类型定义（对齐 contract/api.yaml）
    ├── router/index.ts      # 路由与守卫
    ├── store/               # Pinia，按域拆分
    ├── views/               # 页面（与 P01… 一一对应）
    ├── components/          # 可复用组件
    ├── composables/         # 组合式函数
    ├── utils/               # 纯工具
    └── assets/              # 样式与静态资源
```

## 4. 分层与职责映射

| 规约层（`frontend-dev-standard.mdc` §四） | 本画像落点 |
|------------------------------------------|------------|
| API 层 | `api/request.ts`（实例/拦截器/错误映射）+ `api/*.ts`（按模块） |
| 页面 | `views/` （每页对应一个 `P` 标识，文件名含 `P` 编号或在 `page-impl-report.md` 登记） |
| 组件 | `components/` |
| 状态 | `store/`（Pinia） |
| 路由与守卫 | `router/index.ts` |
| 类型 | `types/`（与契约字段一一对应） |

## 5. 依赖清单（候选，不锁定小版本）

| 用途 | 依赖 |
|------|------|
| 框架与构建 | `vue`、`vite`、`@vitejs/plugin-vue` |
| 类型 | `typescript`、`vue-tsc` |
| 路由 | `vue-router` |
| 状态 | `pinia` |
| 请求 | `axios` |
| UI 组件库 | 优先沿用工程既有（Element Plus / Ant Design Vue / Arco Design Vue）；0-1 缺省 `element-plus` |
| 测试（若生成前端用例） | `vitest`、`@vue/test-utils` |

## 6. 命名与代码约定

- 组件文件 `PascalCase.vue`，页面按业务名 + 页面标识；组合式函数 `useXxx.ts`。
- 接口函数命名对齐契约：`getXxxList` / `getXxxDetail` / `createXxx` / `updateXxx` / `removeXxx`。
- 类型定义与 `contract/api.yaml` 字段名逐字一致，禁止 camelCase/snake_case 混用不一致。
- 统一错误处理：拦截器内按 `contract/error-codes.md` 映射文案，页面只处理业务分支。
- 五态（加载/空/正常/错误/无权限）在每个数据页面显式实现，可借助调试开关切换。

## 7. 构建与测试命令（白名单内）

| 动作 | 命令 |
|------|------|
| 安装依赖 | `npm install`（或 `pnpm install` / `yarn`，按工程既有锁文件） |
| 类型检查 | `npm run type-check`（`vue-tsc --noEmit`） |
| 构建 | `npm run build` |
| 本地启动 | `npm run dev` |

> 仅使用工程已有脚本名；脚本不存在时先在 `stack.md` 登记拟新增脚本并请用户确认。

## 8. 可引用规约

- `rules/frontend-dev-standard.mdc`
- `rules/prototype-standard.mdc`（元素一一对应、五态、文案逐字）
- `rules/dev-contract.mdc`（契约只读、缺口登记、列所有权）

## 变更记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-09-17 | 首次建立 |
