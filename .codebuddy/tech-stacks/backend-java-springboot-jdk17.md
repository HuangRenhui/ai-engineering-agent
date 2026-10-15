# 技术画像：Java 17 + Spring Boot 3.x + MyBatis（backend-java-springboot-jdk17）

## 1. 元信息

| 项 | 值 |
|----|----|
| `id` | `backend-java-springboot-jdk17` |
| 类型 | backend |
| 名称 | Java 17 + Spring Boot 3.x + MyBatis |
| 版本 | v1.0 |
| 适用场景 | 单体/多模块 Java 后端；JDK 17 LTS 工程；0-1 新建后端；Spring Boot 2.x → 3.x 存量升级 |
| 不适用场景 | Spring WebFlux 响应式、Spring Cloud 微服务拆分（需另建画像）、JDK 8 / 11 兼容工程（请用 `backend-java-springboot`） |
| 父画像 | 沿用 `backend-java-springboot.md` §3~§6 通用骨架；本文件**仅记录 JDK 17 + SB 3 差异** |
| JDK 17 / SB 3 迁移要点 | `skills/backend-dev/references/jdk17-springboot3-migration.md` |

## 2. 识别特征

命中任意 2 条即判定：

- 存在 `pom.xml` 或 `build.gradle`（且非 Android）；
- `<java.version>` / `<source>` / `<target>` 为 `17`；
- 依赖中出现 `spring-boot-starter-parent` 版本 `3.x`（如 `3.2.5`）；
- 源码 `import` 出现 `jakarta.*`（如 `jakarta.servlet`、`jakarta.persistence`、`jakarta.validation`）；
- 出现 `@SpringBootApplication`、MyBatis、`@RestController` 等基础注解。

## 3. 目录骨架

与 `backend-java-springboot.md` §3 **完全一致**，**新增** `application-{env}.yml` 多环境拆分：

```
backend/
├── pom.xml              # <java.version>17</java.version>
└── src/
    ├── main/
    │   ├── java/<base-package>/
    │   │   ├── Application.java
    │   │   ├── controller/          # 接口层（import jakarta.servlet.* 等）
    │   │   ├── service/             # 应用/服务层
    │   │   │   └── impl/
    │   │   ├── mapper/              # 仓储/数据层
    │   │   ├── domain/              # 实体（DO，jakarta.persistence.*）
    │   │   ├── dto/                 # 入参 DTO
    │   │   ├── vo/                  # 出参 VO
    │   │   ├── enums/               # 枚举（对齐 contract/enums.md）
    │   │   ├── common/              # 统一响应、错误码、异常、常量
    │   │   └── config/              # 配置类
    │   └── resources/
    │       ├── application.yml           # 公共配置（profiles.active=${SPRING_PROFILES_ACTIVE:prod}）
    │       ├── application-dev.yml       # 开发环境差异
    │       ├── application-staging.yml   # 预发环境差异
    │       ├── application-prod.yml      # 生产环境差异
    │       ├── mapper/                   # MyBatis XML（若使用 XML）
    │       └── db/migration/             # SQL 增量脚本：REQxxx-<描述>-v0.x-YYYYMMDD.sql
    └── test/java/<base-package>/    # 单元测试，JUnit 5（Jupiter）
```

> SQL 脚本命名规则与 `backend-java-springboot.md` §3 完全一致：首版 `REQ001` 全量初始化；后续每个 `REQ` 写增量；**历史脚本不改不删**；字段/类型/索引与 `contract/data-model.md` 逐字一致。

## 4. 分层与职责映射

与 `backend-java-springboot.md` §4 **完全一致**：

| 规约层（`backend-dev-standard.mdc` §二） | 本画像落点 |
|------------------------------------------|------------|
| 接口层 | `controller/` + `@RestController` |
| 应用/服务层 | `service/`（接口）+ `service/impl/`（实现，事务边界） |
| 仓储/数据层 | `mapper/` + `resources/mapper/*.xml` |
| 领域/模型层 | `domain/`（DO）、`dto/`（入参）、`vo/`（出参）、`enums/` |
| 跨层公共 | `common/`（`Result<T>`、`ErrorCode`、`BizException`、`GlobalExceptionHandler`） |

## 5. 依赖清单（候选基线版本，不在画像中锁定小版本）

| 用途 | 依赖 | 建议基线 |
|------|------|----------|
| Web | `spring-boot-starter-web` | SB 3.2.x |
| 参数校验 | `spring-boot-starter-validation` | 与 SB 同版（jakarta.validation） |
| 持久化 | `mybatis-spring-boot-starter` | 3.0.3+（兼容 SB 3） |
| 数据库驱动 | `com.mysql:mysql-connector-j` | 8.0.33+（JDBC 类名 `com.mysql.cj.jdbc.Driver`） |
| ORM 增强（可选） | MyBatis-Plus | 3.5.3.2+（兼容 JDK 17） |
| 测试 | `spring-boot-starter-test` | SB 3.2.x（默认 JUnit 5 Jupiter） |
| 工具 | Lombok | **≥ 1.18.30**（必须，1.18.30 之前不支持 JDK 17） |
| API 文档 | `springdoc-openapi-starter-webmvc-ui` | **2.0.x+**（替代 springfox，已停维护） |
| JSON | Jackson | 由 SB 3 传递依赖（2.15.x） |
| 连接池 | HikariCP（默认） | 由 SB 3 传递依赖 |

> **基线不锁定**：项目级可微调小版本；锁定须在 `pom.xml` 注释中说明。**禁止跨大版本**。

## 6. 命名与代码约定

与 `backend-java-springboot.md` §6 **基本一致**，新增 / 强化项：

- 包名全小写、单数、无下划线；类名 `UpperCamelCase`，方法/变量 `lowerCamelCase`，常量全大写下划线分隔。
- `Controller` 以 `Controller` 结尾，`Service` 接口 `XxxService`、实现 `XxxServiceImpl`，`Mapper` 以 `Mapper` 结尾。
- 出参一律 `VO`，入参一律 `DTO`，实体一律 `DO`；禁止用 DO 直接作为出入参。
- 统一响应：`Result<T>{ code, message, data, traceId }`；`code` 取值必须来自 `contract/error-codes.md`。
- **【JDK 17 强制】** 所有 `javax.*` 导入替换为 `jakarta.*`（`javax.servlet.http.HttpServletRequest` → `jakarta.servlet.http.HttpServletRequest`）。
- **【JDK 17 推荐】** 文本块（Text Blocks）可用于 SQL / JSON 长字符串：`String sql = """SELECT ...""";`
- **【JDK 17 推荐】** `record` 类用于 DTO / VO 不可变对象（自动生成 `equals`/`hashCode`/`toString`）。
- **【JDK 17 推荐】** `switch` 表达式、`var` 局部变量；**禁止**把 `var` 用于公共方法签名 / 字段。
- 全文遵循 `rules/java/java-coding-basics.mdc`、`rules/java/java-oop-collection.mdc`。

## 7. 构建与测试命令（白名单内）

| 动作 | 命令 |
|------|------|
| 编译 | `mvn -q -DskipTests compile` |
| 编译并跑单测 | `mvn -q test`（**仅在用户明确要求执行时**） |
| 打包（fat jar） | `mvn -q -DskipTests package`（产物 `target/<artifactId>-<version>.jar`，含 `BOOT-INF/lib/*`，可直接 `java -jar` 启动） |
| 指定单测类 | `mvn -q -Dtest=<ClassName> test` |
| 启动（开发） | `mvn -q spring-boot:run` |
| 启动（生产） | `java -jar target/<artifactId>-<version>.jar --spring.profiles.active=prod`（需 JDK 17 运行时） |
| 升级版本 | `mvn -q versions:set -DnewVersion=<ver> versions:commit` |

> 工具链绝对路径按用户环境配置（Maven / `JAVA_HOME`），命令执行失败按 `dev-contract.mdc` 第 33 条记 `blocked`。

## 8. 可引用规约

- `rules/java/java-coding-basics.mdc`（命名、常量、格式）
- `rules/java/java-oop-collection.mdc`（面向对象、集合）
- `rules/java/java-concurrency-log.mdc`（并发、异常、日志、错误码）
- `rules/java/java-database.mdc`（建表、索引、SQL、ORM 映射）
- `rules/java/java-security-arch.mdc`（接口、安全、分层、单元测试）
- **【本画像专属】** `skills/backend-dev/references/jdk17-springboot3-migration.md`（JDK 17 + SB 3.x 迁移要点：`javax.* → jakarta.*`、版本基线、语法限制、迁移工具、检查清单）
- **【配套部署】** `skills/backend-dev/references/manual-deploy-scripts.md`（手动 jar 上传部署脚本与 SOP）

## 变更记录

| 版本 | 日期 | 变更 |
|------|------|------|
| v1.0 | 2026-09-17 | 首次建立（随系统默认技术栈变更） |