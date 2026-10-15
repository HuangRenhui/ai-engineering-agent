# 需求决策记录（_decisions）

> 用途：每次需求**拍板确认/变更**时**当场**追加一条。本文件是变更日志 `decision` 来源的唯一输入。
> 严禁事后凭记忆补写。

## 条目格式

```yaml
- time:     "YYYY-MM-DDThh:mm:ss+08:00"   # 必填，真实发生时刻
  type:     decision
  summary:  "一句话变更点（动宾结构）"
  detail:   "变更前 → 变更后"
  source:   "需求分析拍板"
  scope:    "F01 / 页面名 / 模块"
  decider:  "user / 角色名"
  evidence: "对话轮次 / 文档锚点"
```

## 记录

```yaml
# 按发生顺序追加，示例：
- time:     "2026-09-14T10:30:00+08:00"
  type:     decision
  summary:  "新增：订单列表支持按时间范围筛选"
  detail:   "原仅支持按状态筛选 → 增加开始/结束时间筛选，默认近 7 天"
  source:   "需求分析拍板"
  scope:    "F03-订单列表"
  decider:  "user"
  evidence: "对话第 12 轮"
```

## 纪律

- 只追加，不覆盖、不删除；
- 修正错误时新增一条修正条目，保留原记录；
- 时间必须为绝对时间，禁用相对时间。
