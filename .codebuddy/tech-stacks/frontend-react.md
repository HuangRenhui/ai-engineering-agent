# 技术画像：React 18 + Vite + TypeScript（frontend-react）

## 1. 元信息

| 项 | 值 |
|----|----|
| `id` | `frontend-react` |
| 类型 | frontend |
| 名称 | React 18 + Vite + TypeScript |
| 版本 | v1.0 |
| 适用场景 | 0-1 新建前端；存量 React 工程（CRA / Vite）增量开发 |
| 不适用场景 | Next.js SSR / Remix 等带服务端的框架工程（需另建画像） |

## 2. 识别特征

`package.json` 中存在 `react` 依赖，或源码出现 `createRoot(`、`.tsx` 文件与 `export default function` 组件写法。

## 3. 目录骨架

**已有工程**：沿用原结构（如 `src/pages/`、`src/services/`、`src/components/`），只做增量新增。

**0-1 新建（`<根>/frontend/`）**：

```
frontend/
├── package.json
├── vite.config.ts
├── tsconfig.json
└── src/
    ├── main.tsx
    ├── App.tsx
    ├── services/            # 统一 API 层（契约驱动）
    │   ├── http.ts          # 实例、拦截器、错误码映射
    │   └── <domain>.ts
    ├── types/               # 契约类型定义（对齐 contract/api.yaml）
    ├── router/              # 路由与守卫（react-router）
    ├── store/               # 状态（按工程既有：Redux Toolkit / Zustand / Context）
    ├── pages/               # 页面（与 P01… 一一对应）
    ├── components/          # 可复用组件
    ├── hooks/               # 自定义 hooks
    ├── utils/
    └── assets/
```

## 4. 分层与职责映射

| 规约层（`frontend-dev-standard.mdc` §四） | 本画像落点 |
|------------------------------------------|------------|
| API 层 | `services/http.ts` + `services/*.ts` |
| 页面 | `pages/` |
| 组件 | `components/` |
| 状态 | `store/` |
| 路由与守卫 | `router/` |
| 类型 | `types/` |

## 5. 依赖清单（候选，不锁定小版本）

| 用途 | 依赖 |
|------|------|
| 框架与构建 | `react`、`react-dom`、`vite`、`@vitejs/plugin-react` |
| 类型 | `typescript`、`@types/react`、`@types/react-dom` |
| 路由 | `react-router-dom` |
| 状态 | 沿用工程既有（Redux Toolkit / Zustand / Context）；0-1 缺省 `zustand` |
| 请求 | `axios` |
| UI 组件库 | 优先沿用工程既有（Ant Design / Arco Design / MUI）；0-1 缺省 `antd` |
| 测试（若生成前端用例） | `vitest`、`@testing-library/react` |

## 6. 命名与代码约定

- 组件文件 `PascalCase.tsx`；hook 命名 `useXxx.ts`。
- 接口函数命名对齐契约：`getXxxList` / `getXxxDetail` / `createXxx` / `updateXxx` / `removeXxx`。
- 类型定义与 `contract/api.yaml` 字段名逐字一致。
- 错误处理集中在 `services/http.ts` 拦截器，按 `contract/error-codes.md` 映射文案。
- 五态（加载/空/正常/错误/无权限）在每个数据页面显式实现，可借助调试开关切换。
- 组件遵循函数式 + hooks，避免在渲染期发起请求（置于 `useEffect` 或数据层）。

## 7. 构建与测试命令（白名单内）

| 动作 | 命令 |
|------|------|
| 安装依赖 | `npm install`（或 `pnpm install` / `yarn`，按工程既有锁文件） |
| 类型检查 | `npm run type-check`（`tsc --noEmit`） |
| 构建 | `npm run build` |
| 本地启动 | `npm run dev` |

> 仅使用工程已有脚本名；脚本不存在时先在 `stack.md` 登记拟新增脚本并请用户确认。

## 8. 可引用规约

- `rules/frontend-dev-standard.mdc`
- `rules/prototype-standard.mdc`
- `rules/dev-contract.mdc`

## 变更记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-09-17 | 首次建立 |
