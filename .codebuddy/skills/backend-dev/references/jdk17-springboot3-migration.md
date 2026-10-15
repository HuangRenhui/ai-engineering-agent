# JDK 17 + Spring Boot 3.x 迁移要点（jdk17-springboot3-migration.md）

> 适用：从 Spring Boot 2.x（Java 8/11）升级到 Spring Boot 3.x（Java 17）的工程；也可作为**新建 JDK 17 + SB 3 项目**的避坑参考。
> 引用入口：`.codebuddy/tech-stack.md` §2 后端节 / `.codebuddy/tech-stacks/backend-java-springboot-jdk17.md` §8。

## 1. 核心差异总览

| 项 | SB 2.x + JDK 8/11 | SB 3.x + JDK 17 |
|----|-------------------|------------------|
| JDK 基线 | 8 / 11 | **17 (LTS)** |
| Servlet API | `javax.servlet.*` | `jakarta.servlet.*` |
| JPA / Bean Validation | `javax.persistence.*` / `javax.validation.*` | `jakarta.persistence.*` / `jakarta.validation.*` |
| Spring Boot 版本 | 2.7.x（已停止 OSS 支持） | **3.2.x**（推荐，最低 3.0） |
| Lombok | 1.18.20 即可 | **≥ 1.18.30**（必须） |
| API 文档 | springfox（已停维护） | `springdoc-openapi-starter-webmvc-ui` 2.0+ |
| 单元测试 | JUnit 4 / 5 混用 | **JUnit 5 Jupiter** 强制 |
| Java 语法 | lambda / Stream | + Text Blocks / `var` / `switch` 表达式 / `record` / 模式匹配 |

## 2. 命名空间迁移（javax → jakarta）

### 2.1 必须迁移的包

| SB 2.x（javax） | SB 3.x（jakarta） |
|------------------|-------------------|
| `javax.servlet.*` | `jakarta.servlet.*` |
| `javax.servlet.http.*` | `jakarta.servlet.http.*` |
| `javax.persistence.*` | `jakarta.persistence.*` |
| `javax.validation.*` | `jakarta.validation.*` |
| `javax.annotation.*` | `jakarta.annotation.*` |
| `javax.transaction.*` | `jakarta.transaction.*` |
| `javax.inject.*` | `jakarta.inject.*` |
| `javax.mail.*`（如使用） | `jakarta.mail.*` |

### 2.2 常见报错与修复

| 报错关键词 | 原因 | 修复 |
|-----------|------|------|
| `package javax.servlet does not exist` | 仍有 javax 导入 | 全局替换 `javax.servlet` → `jakarta.servlet` |
| `ClassNotFoundException: javax.servlet.ServletException` | 第三方依赖未升级 | 升级该依赖到 SB 3 兼容版本 |
| `NoClassDefFoundError: javax/servlet/...` | 部署容器（Tomcat 等）未升级 | 嵌入式 Tomcat 已由 SB 3 传递，无需额外处理；外置 Tomcat 须升级到 10.x |
| `springfox` 类找不到 | springfox 不支持 SB 3 | 替换为 `springdoc-openapi-starter-webmvc-ui` 2.0+ |

### 2.3 批量迁移工具

- **IntelliJ IDEA**（2023.2+）：菜单 `Refactor → Migrate Packages and Classes → javax to jakarta`。
- **OpenRewrite 配方**：`org.openrewrite.java.migrate.JavaxToJakarta`（Maven / Gradle 插件）。
- **Eclipse**：全局 `Search & Replace` regex `^import javax\.(servlet|persistence|validation|annotation|transaction|inject|mail)` → `import jakarta.$1`。

## 3. 依赖版本基线

> 以下是**建议基线**（非锁定），项目级可按需微调小版本，**禁止跨大版本**。

| 用途 | 依赖 | SB 3.x 推荐基线 |
|------|------|------------------|
| Spring Boot | `spring-boot-starter-parent` | **3.2.5+**（LTS 节奏） |
| Java | `<java.version>` | **17** |
| 持久化 | `mybatis-spring-boot-starter` | **3.0.3+** |
| ORM 增强 | MyBatis-Plus | **3.5.3.2+**（兼容 JDK 17） |
| API 文档 | `springdoc-openapi-starter-webmvc-ui` | **2.0.6+** |
| Lombok | `lombok` | **1.18.30+**（必须） |
| MySQL 驱动 | `com.mysql:mysql-connector-j` | **8.0.33+** |
| 测试 | `spring-boot-starter-test` | 与 SB 同版（默认 JUnit 5 Jupiter） |
| JSON | Jackson | 2.15.x（SB 3 传递） |
| 连接池 | HikariCP | 由 SB 3 传递 |

## 4. pom.xml 关键改动（diff 形态）

```xml
<properties>
-  <!-- 旧 -->
-  <java.version>1.8</java.version>
+  <!-- 新 -->
+  <java.version>17</java.version>
</properties>

<parent>
-  <!-- 旧 -->
-  <version>2.7.18</version>
+  <!-- 新 -->
+  <version>3.2.5</version>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-parent</artifactId>
</parent>
```

`application.yml` 关键节：

```yaml
spring:
-  # 旧（springfox，已删除）
-  # springfox:
-  #   documentation:
-  #     swagger-ui: ...
+  # 新（springdoc-openapi）
+  springdoc:
+    api-docs:
+      path: /v3/api-docs
+    swagger-ui:
+      path: /swagger-ui.html
```

## 5. JDK 17 语法限制（新增避免）

### 5.1 必须避免

- **`sun.misc.Unsafe`**：JDK 17 部分方法已限制访问（`Unsafe.putAddress` 等反射路径）。如非必要改用 `VarHandle`。
- **`finalize()`**：JDK 18 起正式弃用，JDK 17 仍可用但编译警告。改用 `AutoCloseable` + try-with-resources。
- **反射访问 JDK 内部 API**：`--add-opens` 必须显式声明；尽量避免深度反射。
- **Nashorn JavaScript 引擎**：JDK 15 起已删除；如需用 JS 改用 GraalVM / 外部服务。

### 5.2 推荐启用（语法糖）

- **Text Blocks**（JDK 15+）：长字符串 / SQL / JSON 可读性大幅提升。
  ```java
  String sql = """
      SELECT id, name, status
      FROM t_user
      WHERE deleted = 0
      """;
  ```
- **record 类**（JDK 16+）：用于 DTO / VO 不可变对象，自动生成 `equals`/`hashCode`/`toString`。
  ```java
  public record UserVO(Long id, String name, String email) {}
  ```
- **`var` 局部变量**（JDK 10+）：复杂类型左侧可省略，但**禁止**用于公共方法签名 / 字段。
- **`switch` 表达式**（JDK 14+）：替代 `break` 链式写法。
  ```java
  String label = switch (status) {
      case 0 -> "草稿";
      case 1 -> "已发布";
      default -> "未知";
  };
  ```
- **instanceof 模式匹配**（JDK 16+）：
  ```java
  if (obj instanceof UserDO user) {
      return user.getName();
  }
  ```

## 6. 单元测试迁移（JUnit 4 → JUnit 5）

| 旧（JUnit 4） | 新（JUnit 5 Jupiter） |
|----------------|------------------------|
| `org.junit.Test` | `org.junit.jupiter.api.Test` |
| `@RunWith(SpringRunner.class)` | `@ExtendWith(SpringExtension.class)`（spring-boot-starter-test 已默认） |
| `@Before` / `@After` | `@BeforeEach` / `@AfterEach` |
| `@BeforeClass` / `@AfterClass` | `@BeforeAll` / `@AfterAll` |
| `org.junit.Assert.*` | `org.junit.jupiter.api.Assertions.*` |
| `@Ignore` | `@Disabled` |
| `@Mock`（Mockito） | `@Mock`（Mockito-Jupiter） |
| `assertThrows` | `org.junit.jupiter.api.Assertions.assertThrows` |
| `assertEquals(expected, actual)` | 同名（包变了） |

`spring-boot-starter-test`（SB 3.x）默认包含 **JUnit 5 + Mockito + AssertJ + Hamcrest**，开箱即用。

## 7. 常见升级检查清单

- [ ] `pom.xml` / `build.gradle` 中 SB 版本改为 3.2.x+；`<java.version>` = 17
- [ ] 全部 `javax.servlet` / `javax.persistence` / `javax.validation` 等替换为 `jakarta.*`
- [ ] 删除 springfox，引入 `springdoc-openapi-starter-webmvc-ui` 2.0+
- [ ] Lombok 升级到 ≥ 1.18.30
- [ ] MyBatis / MyBatis-Plus 升级到兼容版本
- [ ] 测试类全部迁移到 JUnit 5（`import` 替换 + 注解替换）
- [ ] 服务器 / 容器运行时 JDK = 17（`java -version`）
- [ ] 启动日志无 `WARN` 关键项（如反射警告、Nashorn 弃用等）
- [ ] `mvn clean package` 产出 fat jar 可直接 `java -jar` 启动
- [ ] `actuator/health` 返回 `{"status":"UP"}`
- [ ] 与现有契约（`contract/api.yaml`）字段逐一比对（特别是响应结构、错误码）

## 8. 升级工具（推荐）

- **OpenRewrite**（Maven 插件）：
  ```xml
  <plugin>
    <groupId>org.openrewrite.maven</groupId>
    <artifactId>rewrite-maven-plugin</artifactId>
    <version>5.34.0</version>
  </plugin>
  ```
  配方：`org.openrewrite.java.migrate.JavaxToJakarta`、`org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_2`。
- **spring-boot-properties-migrator**（运行时工具）：SB 2.7 内置，运行期打印已弃用配置项；SB 3 不再需要。
- **IntelliJ IDEA**：内置 `Migrate Packages` + 注解检查；建议在 IDE 内先行 batch fix。
- **Eclipse**：配合 OpenRewrite 配方使用。

## 9. 验证步骤

1. **编译**：`mvn -q clean compile`，应零 ERROR。
2. **打包**：`mvn -q clean package -DskipTests`，产物 `target/<app>-<version>.jar`。
3. **启动**：`java -jar target/<app>-<version>.jar --spring.profiles.active=dev`，日志无致命 ERROR。
4. **健康检查**：`curl -fsS http://127.0.0.1:8080/actuator/health`，返回 `{"status":"UP"}`。
5. **契约一致性**：对照 `contract/api.yaml` 用例逐一调用，错误码 / 字段名 / 类型逐字一致。
6. **单测**：`mvn -q test`，覆盖率 ≥ 80%（按 `rules/backend-dev-standard.mdc` 要求）。

## 变更记录

| 日期 | 变更 | 决策人 |
|------|------|--------|
| 2026-09-17 | 首版：随系统默认技术栈变更新增 | 当前会话用户 |