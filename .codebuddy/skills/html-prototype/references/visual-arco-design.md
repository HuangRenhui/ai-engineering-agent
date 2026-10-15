# Arco Design 视觉基线（visual-arco-design.md）

> 用途：`html-prototype` 技能在生成单文件 HTML 原型时，按 `_meta/tech-stack.md` 中的 UI 库加载对应的视觉基线。
> 本文件 = Arco Design（字节跳动，React 版）的视觉基线（CSS 变量、组件样式、状态样式），**只含样式骨架**，不含组件逻辑；数据一律占位符。
>
> 红线（沿用 `page-layout-baseline.md`）：单文件自包含、内联 CSS/JS、无 CDN、无构建、双击可打开。

## 0. 元信息

| 项 | 值 |
|----|----|
| UI 库 | Arco Design（React 版，字节跳动） |
| 关联技术栈画像 | `.codebuddy/tech-stacks/frontend-react.md` |
| 系统默认来源 | `.codebuddy/tech-stack.md` §1 |
| 适配形态 | PC 后台（信息密度高 / 中等） |
| 不做（不 1:1 复制 Arco） | 本基线只复刻视觉外观与间距规范；不引入实际组件库；交互反馈用最小化手写实现 |

## 1. 设计 Token（CSS 变量）

```css
:root {
  /* 主色（Arco 默认蓝 rgb(22,93,255)） */
  --arco-primary-1:  #e8f3ff;
  --arco-primary-2:  #c5d8ff;
  --arco-primary-3:  #a3beff;
  --arco-primary-4:  #80a4ff;
  --arco-primary-5:  #5d89ff;
  --arco-primary-6:  #165DFF;   /* 主色（强调色） */
  --arco-primary-7:  #0e4ad9;
  --arco-primary-8:  #0937b3;
  --arco-primary-9:  #05248c;
  --arco-primary-10: #001966;

  /* 辅助色 */
  --arco-success-6: #00B42A;
  --arco-warning-6: #FF7D00;
  --arco-danger-6:  #F53F3F;
  --arco-error-6:   #F53F3F;
  --arco-link-6:    #165DFF;

  /* 中性色（文字） */
  --arco-text-primary:    #1d2129;
  --arco-text-secondary:  #4e5969;
  --arco-text-tertiary:   #86909c;
  --arco-text-quaternary: #c9cdd4;
  --arco-text-disabled:   #c9cdd4;

  /* 边框色 */
  --arco-border-1: #f2f3f5;
  --arco-border-2: #e5e6eb;
  --arco-border-3: #c9cdd4;
  --arco-border-4: #86909c;

  /* 填充色 */
  --arco-fill-1: #f7f8fa;
  --arco-fill-2: #f2f3f5;
  --arco-fill-3: #e5e6eb;
  --arco-fill-4: #c9cdd4;
  --arco-fill-5: #86909c;

  /* 背景色 */
  --arco-bg-1:    #ffffff;            /* 卡片 */
  --arco-bg-2:    #f7f8fa;            /* 页面 */
  --arco-bg-3:    #f2f3f5;
  --arco-bg-4:    #e5e6eb;
  --arco-bg-mask: rgba(0, 0, 0, .6);

  /* 圆角 */
  --arco-border-radius-mini:   2px;
  --arco-border-radius-small:  4px;
  --arco-border-radius-medium: 6px;
  --arco-border-radius-large:  8px;
  --arco-border-radius-circle: 9999px;

  /* 阴影 */
  --arco-shadow-1: 0 2px 5px 0 rgba(0, 0, 0, 0.06);
  --arco-shadow-2: 0 4px 10px 0 rgba(0, 0, 0, 0.08);
  --arco-shadow-3: 0 6px 16px 0 rgba(0, 0, 0, 0.10);
  --arco-shadow-modal: 0 12px 32px 4px rgba(0, 0, 0, 0.10),
                       0 8px 20px rgba(0, 0, 0, 0.06);

  /* 字号 / 行高 */
  --arco-font-size-12: 12px;
  --arco-font-size-14: 14px;    /* 基准 */
  --arco-font-size-16: 16px;
  --arco-font-size-20: 20px;
  --arco-font-size-24: 24px;
  --arco-font-size-30: 30px;
  --arco-line-height-base: 1.5;

  /* 间距（4px 基础栅格） */
  --arco-size-1:  4px;
  --arco-size-2:  8px;
  --arco-size-3:  12px;
  --arco-size-4:  16px;
  --arco-size-5:  20px;
  --arco-size-6:  24px;
  --arco-size-8:  32px;
  --arco-size-10: 40px;
  --arco-size-12: 48px;

  /* 布局 */
  --arco-header-height:   60px;
  --arco-aside-width:     220px;
  --arco-menu-item-height: 40px;
}
```

## 2. 通用基础样式

```css
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  font-family: -apple-system, BlinkMacSystemFont, "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
  font-size: var(--arco-font-size-14);
  line-height: var(--arco-line-height-base);
  color: var(--arco-text-primary);
  background: var(--arco-bg-2);
  -webkit-font-smoothing: antialiased;
}
a { color: var(--arco-primary-6); text-decoration: none; }
a:hover { color: var(--arco-primary-5); }

/* 滚动条（极简） */
::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-thumb { background: var(--arco-border-3); border-radius: 4px; }
::-webkit-scrollbar-track { background: transparent; }
```

## 3. 页面骨架（PC 后台）

```
┌───────────────────────────────────────────────────────────┐
│ Header (60px, 白底, 阴影-sm)            Logo / 标题 / 用户 │
├──────────────┬────────────────────────────────────────────┤
│              │ Breadcrumb 面包屑 (分隔符 /)               │
│  Aside       ├────────────────────────────────────────────┤
│  (220px)     │ Page Header 标题 + 描述 + 主操作按钮        │
│  Menu        ├────────────────────────────────────────────┤
│  ─ 一级       │ Toolbar 过滤区 / 批量操作                  │
│  ─ 二级       ├────────────────────────────────────────────┤
│  ─ 三级       │ Content Card 表格 / 表单 / 详情             │
│              ├────────────────────────────────────────────┤
│              │ Pagination 分页 (右对齐)                   │
└──────────────┴────────────────────────────────────────────┘
```

## 4. 关键组件样式

### 4.1 按钮（Button）

```css
.arco-btn {
  display: inline-flex; align-items: center; justify-content: center;
  height: 32px; padding: 0 15px; border: 1px solid var(--arco-border-2);
  border-radius: var(--arco-border-radius-small);
  background: var(--arco-bg-1); color: var(--arco-text-primary);
  font-size: var(--arco-font-size-14); cursor: pointer; transition: .15s;
  white-space: nowrap; user-select: none; gap: 6px;
}
.arco-btn:hover { color: var(--arco-primary-6); border-color: var(--arco-primary-5); }
.arco-btn--primary {
  background: var(--arco-primary-6); color: #fff; border-color: var(--arco-primary-6);
}
.arco-btn--primary:hover {
  background: var(--arco-primary-5); border-color: var(--arco-primary-5); color: #fff;
}
.arco-btn--success {
  background: var(--arco-success-6); color: #fff; border-color: var(--arco-success-6);
}
.arco-btn--warning {
  background: var(--arco-warning-6); color: #fff; border-color: var(--arco-warning-6);
}
.arco-btn--danger {
  background: var(--arco-danger-6); color: #fff; border-color: var(--arco-danger-6);
}
.arco-btn--text {
  border-color: transparent; background: transparent; color: var(--arco-primary-6); padding: 0 4px;
}
.arco-btn--text:hover { background: var(--arco-primary-1); color: var(--arco-primary-6); border-color: transparent; }
.arco-btn--small  { height: 24px; padding: 0 11px; font-size: var(--arco-font-size-12); }
.arco-btn--large  { height: 40px; padding: 0 19px; font-size: var(--arco-font-size-16); }
.arco-btn.is-disabled, .arco-btn[disabled] {
  cursor: not-allowed; opacity: .4; background: var(--arco-fill-1);
  border-color: var(--arco-border-2); color: var(--arco-text-disabled);
}
```

### 4.2 输入框（Input）

```css
.arco-input {
  display: inline-flex; align-items: center;
  height: 32px; padding: 0 12px;
  border: 1px solid var(--arco-border-2); border-radius: var(--arco-border-radius-small);
  background: var(--arco-bg-1); transition: border-color .15s, box-shadow .15s;
  width: 100%;
}
.arco-input:focus-within {
  outline: none; border-color: var(--arco-primary-6);
  box-shadow: 0 0 0 2px rgba(22, 93, 255, 0.15);
}
.arco-input input {
  flex: 1; border: 0; outline: 0; background: transparent;
  font-size: var(--arco-font-size-14); color: var(--arco-text-primary);
  height: 100%;
}
.arco-input input::placeholder { color: var(--arco-text-quaternary); }
.arco-input.is-error { border-color: var(--arco-danger-6); }
.arco-input.is-error:focus-within { box-shadow: 0 0 0 2px rgba(245, 63, 63, 0.15); }
.arco-input.is-disabled {
  background: var(--arco-fill-1); color: var(--arco-text-disabled);
  cursor: not-allowed; border-color: var(--arco-border-1);
}
.arco-textarea {
  min-height: 64px; padding: 6px 12px; resize: vertical;
  border: 1px solid var(--arco-border-2); border-radius: var(--arco-border-radius-small);
  background: var(--arco-bg-1); width: 100%;
  font-family: inherit; font-size: var(--arco-font-size-14);
}
.arco-textarea:focus { outline: none; border-color: var(--arco-primary-6);
                       box-shadow: 0 0 0 2px rgba(22, 93, 255, 0.15); }
```

### 4.3 表单（Form）

```css
.arco-form { display: flex; flex-direction: column; gap: 20px; }
.arco-form-item { display: flex; flex-direction: column; gap: 6px; }
.arco-form-item__label {
  font-size: var(--arco-font-size-14); color: var(--arco-text-primary);
  line-height: 1.5;
}
.arco-form-item__label.is-required::before {
  content: "*"; color: var(--arco-danger-6); margin-right: 4px;
}
.arco-form-item__error {
  font-size: var(--arco-font-size-12); color: var(--arco-danger-6);
  line-height: 1.5; min-height: 18px;
}
.arco-form-item__help {
  font-size: var(--arco-font-size-12); color: var(--arco-text-tertiary);
  line-height: 1.5;
}
```

### 4.4 表格（Table）

```css
.arco-table {
  width: 100%; border-collapse: separate; border-spacing: 0;
  border: 1px solid var(--arco-border-2); border-radius: var(--arco-border-radius-small);
  overflow: hidden; background: var(--arco-bg-1);
}
.arco-table th {
  background: var(--arco-fill-1); color: var(--arco-text-primary);
  font-weight: 500; text-align: left; padding: 10px 16px;
  border-bottom: 1px solid var(--arco-border-2);
  font-size: var(--arco-font-size-14);
}
.arco-table td {
  padding: 10px 16px; color: var(--arco-text-secondary);
  border-bottom: 1px solid var(--arco-border-1); font-size: var(--arco-font-size-14);
}
.arco-table tbody tr:last-child td { border-bottom: 0; }
.arco-table tbody tr:hover td { background: var(--arco-fill-1); }
.arco-table__empty {
  padding: 48px 0; text-align: center; color: var(--arco-text-tertiary);
  font-size: var(--arco-font-size-14);
}

/* 分页 */
.arco-pagination {
  display: flex; justify-content: flex-end; align-items: center; gap: 8px;
  padding: 16px 0; color: var(--arco-text-secondary); font-size: var(--arco-font-size-14);
}
.arco-pagination .arco-pager { display: inline-flex; gap: 6px; list-style: none; padding: 0; margin: 0; }
.arco-pagination .arco-pager li {
  min-width: 32px; height: 32px; line-height: 30px; text-align: center;
  border: 1px solid var(--arco-border-2); border-radius: var(--arco-border-radius-small);
  cursor: pointer; padding: 0 8px;
}
.arco-pagination .arco-pager li.is-active {
  background: var(--arco-primary-6); color: #fff; border-color: var(--arco-primary-6);
}
.arco-pagination .arco-pager li:hover:not(.is-active):not(.is-disabled) {
  color: var(--arco-primary-6); border-color: var(--arco-primary-6);
}
.arco-pagination .arco-pager li.is-disabled { color: var(--arco-text-disabled); cursor: not-allowed; }
```

### 4.5 标签（Tag）

```css
.arco-tag {
  display: inline-flex; align-items: center; height: 22px; padding: 0 8px;
  border-radius: var(--arco-border-radius-small);
  font-size: var(--arco-font-size-12); line-height: 20px;
  background: var(--arco-primary-1); color: var(--arco-primary-6);
  border: 1px solid transparent;
}
.arco-tag--success { background: rgba(0, 180, 42, 0.10); color: var(--arco-success-6); }
.arco-tag--warning { background: rgba(255, 125, 0, 0.10); color: var(--arco-warning-6); }
.arco-tag--danger  { background: rgba(245, 63, 63, 0.10); color: var(--arco-danger-6); }
.arco-tag--info    { background: var(--arco-fill-2); color: var(--arco-text-secondary);
                     border-color: var(--arco-border-2); }
```

### 4.6 模态框（Modal）

```css
.arco-modal-mask {
  position: fixed; inset: 0; background: var(--arco-bg-mask); z-index: 1000;
  animation: arco-fade-in .2s ease;
}
.arco-modal {
  position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
  background: var(--arco-bg-1); border-radius: var(--arco-border-radius-medium);
  box-shadow: var(--arco-shadow-modal); min-width: 480px; max-width: 90vw; z-index: 1001;
}
.arco-modal__header {
  padding: 16px 20px; border-bottom: 1px solid var(--arco-border-1);
  display: flex; justify-content: space-between; align-items: center;
}
.arco-modal__title {
  font-size: var(--arco-font-size-16); color: var(--arco-text-primary); font-weight: 500;
}
.arco-modal__close {
  width: 24px; height: 24px; line-height: 22px; text-align: center;
  border-radius: var(--arco-border-radius-small); cursor: pointer;
  color: var(--arco-text-tertiary); background: transparent; border: 0;
}
.arco-modal__close:hover { background: var(--arco-fill-2); color: var(--arco-text-secondary); }
.arco-modal__body    { padding: 20px; color: var(--arco-text-secondary); font-size: var(--arco-font-size-14); }
.arco-modal__footer  { padding: 12px 20px; border-top: 1px solid var(--arco-border-1);
                       text-align: right; display: flex; gap: 8px; justify-content: flex-end; }

@keyframes arco-fade-in { from { opacity: 0; } to { opacity: 1; } }

/* 抽屉 */
.arco-drawer {
  position: fixed; top: 0; right: 0; bottom: 0; width: 480px;
  background: var(--arco-bg-1); box-shadow: var(--arco-shadow-modal);
  z-index: 1001; display: flex; flex-direction: column;
}
.arco-drawer__header {
  padding: 16px 20px; border-bottom: 1px solid var(--arco-border-1);
  display: flex; justify-content: space-between; align-items: center;
}
.arco-drawer__body { flex: 1; padding: 20px; overflow: auto; }
```

### 4.7 全局提示（Message）

```css
.arco-message {
  position: fixed; top: 24px; left: 50%; transform: translateX(-50%);
  padding: 10px 16px; border-radius: var(--arco-border-radius-small);
  background: var(--arco-bg-1); box-shadow: var(--arco-shadow-2);
  color: var(--arco-text-primary); z-index: 3000;
  display: flex; gap: 8px; align-items: center; min-width: 200px;
  font-size: var(--arco-font-size-14); border: 1px solid var(--arco-border-1);
}
.arco-message--success { color: var(--arco-success-6); }
.arco-message--success .arco-icon { color: var(--arco-success-6); }
.arco-message--warning { color: var(--arco-warning-6); }
.arco-message--warning .arco-icon { color: var(--arco-warning-6); }
.arco-message--error   { color: var(--arco-danger-6); }
.arco-message--error .arco-icon { color: var(--arco-danger-6); }
.arco-message--info    { color: var(--arco-text-secondary); }
.arco-message--info .arco-icon { color: var(--arco-text-tertiary); }
```

### 4.8 菜单（Menu / Aside）

```css
.arco-menu {
  background: var(--arco-bg-1); border-right: 1px solid var(--arco-border-1);
  list-style: none; margin: 0; padding: 8px 0;
}
.arco-menu-item, .arco-sub-menu__title {
  display: flex; align-items: center; height: var(--arco-menu-item-height);
  padding: 0 20px; color: var(--arco-text-secondary); cursor: pointer;
  transition: background .15s, color .15s; gap: 10px;
  border-radius: 0;
}
.arco-menu-item:hover, .arco-sub-menu__title:hover {
  background: var(--arco-fill-2); color: var(--arco-text-primary);
}
.arco-menu-item.is-active {
  color: var(--arco-primary-6); background: var(--arco-primary-1);
  font-weight: 500;
  border-right: 3px solid var(--arco-primary-6);
}
.arco-sub-menu .arco-menu { background: var(--arco-bg-2); }
```

### 4.9 卡片（Card）

```css
.arco-card {
  background: var(--arco-bg-1); border: 1px solid var(--arco-border-1);
  border-radius: var(--arco-border-radius-small); box-shadow: var(--arco-shadow-1);
  overflow: hidden;
}
.arco-card__header {
  padding: 16px 20px; border-bottom: 1px solid var(--arco-border-1);
  font-size: var(--arco-font-size-16); font-weight: 500;
  color: var(--arco-text-primary);
  display: flex; justify-content: space-between; align-items: center;
}
.arco-card__body { padding: 20px; color: var(--arco-text-secondary); font-size: var(--arco-font-size-14); }
```

## 5. 状态样式（五态）

| 状态 | 视觉特征 | 适用场景 |
|------|----------|----------|
| 加载中 | 骨架屏（占位灰条 + 闪烁）或 Spinner | 表格/卡片/页面级 |
| 空数据 | 居中插画占位 + 文案 + 主操作按钮 | 列表/搜索结果 |
| 正常 | 正常展示 | — |
| 错误 | 顶部红色 Message 横幅 + 错误详情 | 表单提交/接口失败 |
| 无权限 | 全屏占位（图标 + "无访问权限" + 返回） | 路由级 / 操作级 |

```css
/* 加载骨架 */
.arco-skeleton { display: flex; flex-direction: column; gap: 12px; padding: 16px; }
.arco-skeleton__item {
  background: linear-gradient(90deg, var(--arco-fill-2) 25%, var(--arco-fill-1) 50%, var(--arco-fill-2) 75%);
  background-size: 200% 100%; animation: arco-skeleton-loading 1.4s ease infinite;
  height: 16px; border-radius: var(--arco-border-radius-small);
}
@keyframes arco-skeleton-loading {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* 空数据 */
.arco-empty {
  padding: 48px 0; text-align: center; color: var(--arco-text-tertiary);
  font-size: var(--arco-font-size-14);
}
.arco-empty__text { margin-top: 12px; }

/* 无权限 */
.arco-no-perm {
  min-height: 360px; display: flex; flex-direction: column;
  align-items: center; justify-content: center; gap: 12px;
  color: var(--arco-text-tertiary); font-size: var(--arco-font-size-14);
}
```

## 6. 文案规范（与 PRD 文案一致）

- **空状态文案**：`暂无数据` / `暂无相关记录`（按 PRD 文案规范逐字取）
- **加载文案**：`加载中…`
- **错误提示**：使用 PRD 错误码文案，格式 `[{code}] {message}`
- **确认弹窗**：标题 + 描述 + 确认/取消按钮；按钮文案取 PRD 文案规范
- **二次确认**：危险操作前必经；按钮文案带"确认"二字（如 `确认删除`）

## 7. 单文件原型集成约定

1. 每个原型 HTML 必须把 §1 + §2 + 实际用到的 §4 子节内联进 `<style>`；
2. 不引用任何 CDN（包括 arco.design CDN，**禁止**）；
3. JS 只做最小化交互（弹窗、Toast、状态切换、过滤）；
4. 真实感假数据按 PRD 业务命名（`test`/`aaa`/`示例1` 禁止）；
5. 文案逐字取自 PRD 文案规范（弹窗/Toast/空状态/报错）；
6. 五态可用页面右上角"状态切换器"切换显示（仅原型演示用）。

## 8. 自检清单

- [ ] §1 CSS 变量全部内联；
- [ ] §2 基础样式内联；
- [ ] 本页面用到的 §4 子节全部内联；
- [ ] §5 五态样式齐备（页面适用的）；
- [ ] 颜色 / 间距 / 字号与 PRD §技术选型与 UI 约束节一致；
- [ ] 文案逐字取自 PRD 文案规范；
- [ ] 单文件自包含，无 CDN、无构建。

## 9. 变更记录

| 日期 | 变更 | 决策人 |
|------|------|--------|
| 2026-09-17 | 首版：随系统默认技术栈调整新增（替代 Element Plus 版基线） | 当前会话用户 |