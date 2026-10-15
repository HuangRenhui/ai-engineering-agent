# 技术画像：Java 8 + Spring Boot + MyBatis（backend-java-springboot）

## 1. 元信息

| 项 | 值 |
|----|----|
| `id` | `backend-java-springboot` |
| 类型 | backend |
| 名称 | Java 8 + Spring Boot 2.x + MyBatis |
| 版本 | v1.0 |
| 适用场景 | 单体/多模块 Java 后端；已有 `pom.xml` 的存量工程；0-1 新建后端 |
| 不适用场景 | Spring WebFlux 响应式、Spring Cloud 微服务拆分（需另建画像）、JDK 17+ 新语法工程 |

## 2. 识别特征

命中任意 2 条即判定：

- 存在 `pom.xml` 或 `build.gradle`（且非 Android）；
- 存在 `src/main/java` 目录；
- 依赖中出现 `spring-boot-starter-web`、`mybatis`、`mybatis-spring-boot-starter`；
- 源码出现 `@RestController`、`@Service`、`@Mapper` 注解。

## 3. 目录骨架

**已有工程**：沿用原结构（如 `src/main/java/<base-package>/...`），只做增量新增。

**0-1 新建（`<根>/backend/`）**：

```
backend/
├── pom.xml
└── src/
    ├── main/
    │   ├── java/<base-package>/
    │   │   ├── Application.java
    │   │   ├── controller/          # 接口层
    │   │   ├── service/             # 应用/服务层
    │   │   │   └── impl/
    │   │   ├── mapper/              # 仓储/数据层
    │   │   ├── domain/              # 实体（DO）
    │   │   ├── dto/                 # 入参 DTO
    │   │   ├── vo/                  # 出参 VO
    │   │   ├── enums/               # 枚举（对齐 contract/enums.md）
    │   │   ├── common/              # 统一响应、错误码、异常、常量
    │   │   └── config/              # 配置类
    │   └── resources/
    │       ├── application.yml
    │       ├── mapper/              # MyBatis XML（若使用 XML）
    │       └── db/migration/        # SQL 增量脚本：REQxxx-<描述>-v0.x-YYYYMMDD.sql
    └── test/java/<base-package>/    # 单元测试，包路径与主代码镜像
```

SQL 脚本命名 `REQ001-user-login-v0.1-20260917.sql`（`REQ` + 描述 + 版本 + 日期，见 `dev-contract.mdc` 第 22.1 条）：首版 `REQ001` 为全量初始化，此后每个 `REQ` 只写增量，**历史脚本不改不删**；脚本字段/类型/索引与 `contract/data-model.md` 逐字一致，并登记到 `arch.md` 的「DB 迁移方案」。

## 4. 分层与职责映射

| 规约层（`backend-dev-standard.mdc` §二） | 本画像落点 |
|------------------------------------------|------------|
| 接口层 | `controller/` + `@RestController` |
| 应用/服务层 | `service/`（接口）+ `service/impl/`（实现，事务边界） |
| 仓储/数据层 | `mapper/` + `resources/mapper/*.xml` |
| 领域/模型层 | `domain/`（DO）、`dto/`（入参）、`vo/`（出参）、`enums/` |
| 跨层公共 | `common/`（`Result<T>`、`ErrorCode`、`BizException`、`GlobalExceptionHandler`） |

## 5. 依赖清单（候选，不在画像中锁定小版本）

| 用途 | 依赖 |
|------|------|
| Web | `spring-boot-starter-web` |
| 参数校验 | `spring-boot-starter-validation` |
| 持久化 | `mybatis-spring-boot-starter`、数据库驱动（按项目） |
| 分页 | 项目既有分页方案（PageHelper 等），无既有则用 SQL `LIMIT` |
| 测试 | `spring-boot-starter-test`、`junit`、`mockito` |
| 可选 | `lombok`（若工程已用）、连接池（HikariCP / Druid，按工程既有） |

## 6. 命名与代码约定

- 包名全小写、单数、无下划线；类名 `UpperCamelCase`，方法/变量 `lowerCamelCase`，常量全大写下划线分隔。
- `Controller` 以 `Controller` 结尾，`Service` 接口 `XxxService`、实现 `XxxServiceImpl`，`Mapper` 以 `Mapper` 结尾。
- 出参一律 `VO`，入参一律 `DTO`，实体一律 `DO`；禁止用 DO 直接作为出入参。
- 统一响应：`Result<T>{ code, message, data, traceId }`；`code` 取值必须来自 `contract/error-codes.md`。
- 全文遵循 `rules/java/java-coding-basics.mdc`、`rules/java/java-oop-collection.mdc`。

## 7. 构建与测试命令（白名单内）

| 动作 | 命令 |
|------|------|
| 编译 | `mvn -q -DskipTests compile` |
| 编译并跑单测 | `mvn -q test`（**仅在用户明确要求执行时**） |
| 打包 | `mvn -q -DskipTests package` |
| 指定单测类 | `mvn -q -Dtest=<ClassName> test` |

> 工具链绝对路径按用户环境配置（Maven / `JAVA_HOME`），命令执行失败按 `dev-contract.mdc` 第 33 条记 `blocked`。

## 8. 可引用规约

- `rules/java/java-coding-basics.mdc`（命名、常量、格式）
- `rules/java/java-oop-collection.mdc`（面向对象、集合）
- `rules/java/java-concurrency-log.mdc`（并发、异常、日志、错误码）
- `rules/java/java-database.mdc`（建表、索引、SQL、ORM 映射）
- `rules/java/java-security-arch.mdc`（接口、安全、分层、单元测试）

## 变更记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-09-17 | 首次建立 |
