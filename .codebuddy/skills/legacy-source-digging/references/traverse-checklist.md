# 全域遍历清单（兜底不遗漏）

逆向梳理第一步：按下述三层清单**逐一遍历**，任何一项未覆盖即视为本次梳理不完整。遍历结果登记到 `_meta/traverse-report.md`（命中数 vs 覆盖数）。

## 1. 前端层

- 所有路由（route 配置、动态路由、菜单表驱动路由）
- 所有页面文件（vue/react/jsp/thymeleaf/html 页面组件）
- 所有弹窗组件（modal/dialog/drawer/popover）
- 所有按钮及点击事件（@click/onClick/事件绑定）
- 所有表单及校验规则（rules/validators/schema）
- 所有接口调用点（axios/fetch/request 封装的调用处）

## 2. 后端层

- 所有 Controller 接口（@Controller/@RestController/@RequestMapping 及等价注解）
- 所有 Service 业务方法与实现类
- 所有定时任务（@Scheduled/cron/quartz/xxl-job 及等价机制）
- 所有监听事件与消息消费（@EventListener/MQ consumer/Kafka listener）
- 所有拦截器/过滤器/AOP 切面（鉴权、日志、限流、数据权限）
- 所有状态机/状态字段更新点（谁在什么条件下把什么状态改成什么）

## 3. 数据层

- 所有数据表/集合（实体类注解、SQL 脚本、ORM 映射文件）
- 所有表关联关系（外键/逻辑外键/join 条件）
- 所有状态字段及其取值枚举（含字典表）
- 所有更新触发条件（触发更新业务的方法与条件）

## 兜底自查（梳理完成后必查，结果写入 `hidden-logic.md`）

- [ ] 遍历到的路由数 == PRD 页面清单数（逐条对照）
- [ ] 遍历到的接口数 == 接口清单数（逐条对照）
- [ ] 未被任何页面/接口引用的组件、方法、接口 → 列入隐藏逻辑备注
- [ ] 代码中存在但流程清单未覆盖的 if/else 分支 → 补流程
- [ ] 配置文件中的定时任务/开关/特性开关 → 逐项登记
- [ ] 注释掉但保留的代码块、TODO/FIXME → 列入历史遗留
