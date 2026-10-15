# Git 提交素材（_git-log）

> 由 `references/git-mining.md` 中的只读命令采集，作为变更日志 `git-commit` 来源的原始素材。
> 采集参数：仓库 `<repo>` ｜ 范围 `<scope>` ｜ 条数上限 `<n>` ｜ 时间窗 `<since>~<until>`

## 原始输出（示例）

```
===a1b2c3d|2026-09-13T18:05:00+08:00|zhangsan|fix: 订单金额计算错误
M  src/main/java/com/demo/order/OrderService.java
M  src/main/java/com/demo/order/OrderCalculator.java
===b2c3d4e|2026-09-12T09:20:00+08:00|lisi|feat: 新增订单导出
A  src/main/java/com/demo/order/export/OrderExportService.java
```

## 归一化结果

| time | summary | scope | evidence |
|------|---------|-------|----------|
| 2026-09-13T18:05:00+08:00 | 修复：订单金额计算错误 | 订单模块 | git:a1b2c3d |
| 2026-09-12T09:20:00+08:00 | 新增：订单导出功能 | 订单模块/导出 | git:b2c3d4e |
