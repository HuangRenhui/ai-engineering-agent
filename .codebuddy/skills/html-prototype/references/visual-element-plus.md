# Element Plus 视觉基线（visual-element-plus.md）

> 用途：`html-prototype` 技能在生成单文件 HTML 原型时，按 `_meta/tech-stack.md` 中的 UI 库加载对应的视觉基线。
> 本文件 = Element Plus 的视觉基线（CSS 变量、组件样式、状态样式），**只含样式骨架**，不含组件逻辑；数据一律占位符。
>
> 红线（沿用 `page-layout-baseline.md`）：单文件自包含、内联 CSS/JS、无 CDN、无构建、双击可打开。

## 0. 元信息

| 项 | 值 |
|----|----|
| UI 库 | Element Plus（Vue 3） |
| 关联技术栈画像 | `.codebuddy/tech-stacks/frontend-vue3.md` |
| 系统默认来源 | `.codebuddy/tech-stack.md` §1 |
| 适配形态 | PC 后台（信息密度高）/ 自适应（移动端先不推荐） |
| 不做（不 1:1 复制 Element Plus） | 本基线只复刻视觉外观与间距规范；不引入实际组件库；交互反馈用最小化手写实现 |

## 1. 设计 Token（CSS 变量）

```css
:root {
  /* 主色（Element Plus 默认蓝） */
  --el-color-primary: #409EFF;
  --el-color-primary-light-3: #79bbff;
  --el-color-primary-light-5: #a0cfff;
  --el-color-primary-light-7: #c6e2ff;
  --el-color-primary-light-8: #d9ecff;
  --el-color-primary-light-9: #ecf5ff;
  --el-color-primary-dark-2: #337ecc;

  /* 辅助色 */
  --el-color-success: #67c23a;
  --el-color-warning: #e6a23c;
  --el-color-danger:  #f56c6c;
  --el-color-error:   #f56c6c;
  --el-color-info:    #909399;

  /* 中性色 */
  --el-text-color-primary:   #303133;
  --el-text-color-regular:   #606266;
  --el-text-color-secondary: #909399;
  --el-text-color-placeholder:#a8abb2;
  --el-text-color-disabled:  #c0c4cc;

  --el-border-color:        #dcdfe6;
  --el-border-color-light:  #e4e7ed;
  --el-border-color-lighter:#ebeef5;
  --el-border-color-extra-light:#f2f6fc;

  --el-fill-color:         #f0f2f5;
  --el-fill-color-light:   #f5f7fa;
  --el-fill-color-lighter: #fafafa;
  --el-fill-color-blank:   #ffffff;

  --el-bg-color:           #ffffff;
  --el-bg-color-page:      #f2f3f5;
  --el-bg-color-overlay:   #ffffff;

  /* 圆角与阴影 */
  --el-border-radius-base: 4px;
  --el-border-radius-small: 2px;
  --el-border-radius-round: 20px;
  --el-border-radius-circle: 100%;

  --el-box-shadow-light: 0 0 12px rgba(0, 0, 0, 0.06);
  --el-box-shadow:       0 12px 32px 4px rgba(0, 0, 0, 0.04),
                         0 8px 20px rgba(0, 0, 0, 0.08);
  --el-box-shadow-dark:  0 16px 48px 16px rgba(0, 0, 0, 0.08),
                         0 12px 32px rgba(0, 0, 0, 0.12),
                         0 8px 16px -8px rgba(0, 0, 0, 0.16);

  /* 字号 / 行高 / 间距 */
  --el-font-size-extra-large: 20px;
  --el-font-size-large:      16px;
  --el-font-size-medium:     14px;   /* 基准 */
  --el-font-size-base:       14px;
  --el-font-size-small:      13px;
  --el-font-size-extra-small:12px;

  --el-line-height-primary:  24px;
  --el-line-height-base:     1.5;

  /* 布局 */
  --el-header-height: 60px;
  --el-aside-width:   220px;
  --el-menu-item-height: 56px;
}
```

## 2. 通用基础样式

```css
* { box-sizing: border-box; }
html, body { margin: 0; padding: 0; }
body {
  font-family: "Helvetica Neue", Helvetica, "PingFang SC", "Microsoft YaHei", Arial, sans-serif;
  font-size: var(--el-font-size-base);
  line-height: var(--el-line-height-base);
  color: var(--el-text-color-primary);
  background: var(--el-bg-color-page);
  -webkit-font-smoothing: antialiased;
}
a { color: var(--el-color-primary); text-decoration: none; }
a:hover { color: var(--el-color-primary-light-3); }

/* 滚动条（极简） */
::-webkit-scrollbar { width: 8px; height: 8px; }
::-webkit-scrollbar-thumb { background: var(--el-border-color); border-radius: 4px; }
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
.el-btn {
  display: inline-flex; align-items: center; justify-content: center;
  height: 32px; padding: 0 15px; border: 1px solid var(--el-border-color);
  border-radius: var(--el-border-radius-base);
  background: var(--el-bg-color-overlay); color: var(--el-text-color-regular);
  font-size: var(--el-font-size-base); cursor: pointer; transition: .15s;
  white-space: nowrap;
}
.el-btn:hover { color: var(--el-color-primary); border-color: var(--el-color-primary-light-7);
                        background: var(--el-color-primary-light-9); }
.el-btn--primary { background: var(--el-color-primary); color: #fff; border-color: var(--el-color-primary); }
.el-btn--primary:hover { background: var(--el-color-primary-light-3); border-color: var(--el-color-primary-light-3); color: #fff; }
.el-btn--success { background: var(--el-color-success); color: #fff; border-color: var(--el-color-success); }
.el-btn--warning { background: var(--el-color-warning); color: #fff; border-color: var(--el-color-warning); }
.el-btn--danger  { background: var(--el-color-danger);  color: #fff; border-color: var(--el-color-danger);  }
.el-btn--text    { border-color: transparent; background: transparent; color: var(--el-color-primary); padding: 0 4px; }
.el-btn--small    { height: 24px; padding: 0 11px; font-size: var(--el-font-size-extra-small); }
.el-btn--large    { height: 40px; padding: 0 19px; font-size: var(--el-font-size-large); }
.el-btn.is-disabled, .el-btn[disabled] { cursor: not-allowed; opacity: .6; }
```

### 4.2 输入框（Input）

```css
.el-input {
  display: inline-flex; align-items: center;
  height: 32px; padding: 0 11px;
  border: 1px solid var(--el-border-color); border-radius: var(--el-border-radius-base);
  background: var(--el-bg-color-overlay); transition: border-color .15s;
  width: 100%;
}
.el-input:focus-within { outline: none; border-color: var(--el-color-primary); box-shadow: 0 0 0 2px var(--el-color-primary-light-9); }
.el-input input { flex: 1; border: 0; outline: 0; background: transparent;
                  font-size: var(--el-font-size-base); color: var(--el-text-color-primary); }
.el-input input::placeholder { color: var(--el-text-color-placeholder); }
.el-textarea { min-height: 64px; padding: 5px 11px; }
```

### 4.3 表单（Form）

```css
.el-form { display: flex; flex-direction: column; gap: 18px; }
.el-form-item { display: flex; flex-direction: column; gap: 6px; }
.el-form-item__label { font-size: var(--el-font-size-base); color: var(--el-text-color-regular);
                       line-height: var(--el-line-height-primary); }
.el-form-item__label.is-required::before {
  content: "*"; color: var(--el-color-danger); margin-right: 4px;
}
.el-form-item__error { font-size: var(--el-font-size-extra-small); color: var(--el-color-danger);
                       line-height: var(--el-line-height-primary); min-height: 18px; }
```

### 4.4 表格（Table）

```css
.el-table { width: 100%; border-collapse: collapse;
            border: 1px solid var(--el-border-color-lighter);
            border-radius: var(--el-border-radius-base); overflow: hidden;
            background: var(--el-bg-color-overlay); }
.el-table th { background: var(--el-fill-color-light); color: var(--el-text-color-regular);
               font-weight: 500; text-align: left; padding: 12px 0;
               border-bottom: 1px solid var(--el-border-color-lighter); }
.el-table td { padding: 12px 0; color: var(--el-text-color-regular);
               border-bottom: 1px solid var(--el-border-color-lighter); }
.el-table tr:hover td { background: var(--el-fill-color-lighter); }
.el-table .cell { padding: 0 12px; }
.el-table .el-table__empty { padding: 40px 0; text-align: center; color: var(--el-text-color-secondary); }

/* 分页 */
.el-pagination { display: flex; justify-content: flex-end; align-items: center; gap: 8px;
                 padding: 16px 0; color: var(--el-text-color-regular); }
.el-pagination .el-pager { display: inline-flex; gap: 4px; }
.el-pagination .el-pager li { min-width: 30px; height: 30px; line-height: 28px; text-align: center;
                              border: 1px solid var(--el-border-color); border-radius: var(--el-border-radius-base);
                              cursor: pointer; padding: 0 6px; }
.el-pagination .el-pager li.is-active { background: var(--el-color-primary); color: #fff;
                                        border-color: var(--el-color-primary); }
```

### 4.5 标签（Tag）

```css
.el-tag { display: inline-flex; align-items: center; height: 22px; padding: 0 8px;
          border-radius: var(--el-border-radius-base);
          font-size: var(--el-font-size-extra-small); line-height: 20px;
          background: var(--el-color-primary-light-9);
          color: var(--el-color-primary);
          border: 1px solid var(--el-color-primary-light-7); }
.el-tag--success { background: #f0f9eb; color: var(--el-color-success); border-color: #c2e7b0; }
.el-tag--warning { background: #fdf6ec; color: var(--el-color-warning); border-color: #faecd8; }
.el-tag--danger  { background: #fef0f0; color: var(--el-color-danger);  border-color: #fbc4c4; }
.el-tag--info    { background: #f4f4f5; color: var(--el-color-info);    border-color: #d9d9d9; }
```

### 4.6 对话框（Dialog）+ 抽屉（Drawer）

```css
.el-overlay { position: fixed; inset: 0; background: rgba(0, 0, 0, .5); z-index: 2000; }
.el-dialog { position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
             background: var(--el-bg-color-overlay); border-radius: var(--el-border-radius-base);
             box-shadow: var(--el-box-shadow); min-width: 420px; max-width: 90vw; z-index: 2001; }
.el-dialog__header { padding: 16px 20px; border-bottom: 1px solid var(--el-border-color-lighter); }
.el-dialog__title { font-size: var(--el-font-size-large); color: var(--el-text-color-primary); }
.el-dialog__body  { padding: 20px; color: var(--el-text-color-regular); }
.el-dialog__footer { padding: 12px 20px; border-top: 1px solid var(--el-border-color-lighter);
                     text-align: right; display: flex; gap: 8px; justify-content: flex-end; }

.el-drawer { position: fixed; top: 0; right: 0; bottom: 0; width: 420px;
             background: var(--el-bg-color-overlay); box-shadow: var(--el-box-shadow);
             z-index: 2001; display: flex; flex-direction: column; }
.el-drawer__header { padding: 16px 20px; border-bottom: 1px solid var(--el-border-color-lighter);
                     display: flex; justify-content: space-between; align-items: center; }
.el-drawer__body   { flex: 1; padding: 20px; overflow: auto; }
```

### 4.7 消息提示（Message）

```css
.el-message { position: fixed; top: 20px; left: 50%; transform: translateX(-50%);
              padding: 10px 16px; border-radius: var(--el-border-radius-base);
              background: var(--el-bg-color-overlay); box-shadow: var(--el-box-shadow);
              color: var(--el-text-color-primary); z-index: 3000;
              display: flex; gap: 8px; align-items: center; min-width: 200px; }
.el-message--success { background: var(--el-color-success); color: #fff; }
.el-message--warning { background: var(--el-color-warning); color: #fff; }
.el-message--error   { background: var(--el-color-danger);  color: #fff; }
.el-message--info    { background: var(--el-color-info);    color: #fff; }
```

### 4.8 菜单（Menu / Aside）

```css
.el-menu { background: var(--el-bg-color-overlay); border-right: 1px solid var(--el-border-color-lighter);
           list-style: none; margin: 0; padding: 0; }
.el-menu-item, .el-sub-menu__title {
  display: flex; align-items: center; height: var(--el-menu-item-height);
  padding: 0 20px; color: var(--el-text-color-regular); cursor: pointer;
  transition: background .15s;
}
.el-menu-item:hover, .el-sub-menu__title:hover {
  background: var(--el-color-primary-light-9); color: var(--el-color-primary);
}
.el-menu-item.is-active {
  color: #fff; background: var(--el-color-primary);
}
.el-sub-menu .el-menu { background: #fafafa; }
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
.el-skeleton { display: flex; flex-direction: column; gap: 12px; padding: 16px; }
.el-skeleton__item {
  background: linear-gradient(90deg, var(--el-fill-color) 25%, var(--el-fill-color-light) 50%, var(--el-fill-color) 75%);
  background-size: 200% 100%; animation: el-skeleton-loading 1.4s ease infinite;
  height: 16px; border-radius: var(--el-border-radius-small);
}
@keyframes el-skeleton-loading {
  0%   { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}

/* 空数据 */
.el-empty { padding: 40px 0; text-align: center; color: var(--el-text-color-secondary); }
.el-empty__text { margin-top: 8px; font-size: var(--el-font-size-base); }

/* 无权限 */
.el-no-perm { min-height: 360px; display: flex; flex-direction: column;
              align-items: center; justify-content: center; gap: 12px;
              color: var(--el-text-color-secondary); }
```

## 6. 文案规范（与 PRD 文案一致）

- **空状态文案**：`暂无数据` / `暂无相关记录`（按 PRD 文案规范逐字取）
- **加载文案**：`加载中…`
- **错误提示**：使用 PRD 错误码文案，格式 `[{code}] {message}`
- **确认弹窗**：标题 + 描述 + 确认/取消按钮；按钮文案取 PRD 文案规范
- **二次确认**：危险操作前必经；按钮文案带"确认"二字（如 `确认删除`）

## 7. 单文件原型集成约定

1. 每个原型 HTML 必须把 §1 + §2 + 实际用到的 §4 子节内联进 `<style>`；
2. 不引用任何 CDN；
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