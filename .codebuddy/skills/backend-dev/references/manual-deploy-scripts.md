# 手动 jar 上传部署脚本模板（manual-deploy-scripts.md）

> 适用场景：单实例后端服务，**手动 SCP/SFTP 上传 fat jar + `java -jar` 启动**（无 K8s / 无 Docker）。
> 与 `.codebuddy/tech-stack.md` §6 部署形态、`.codebuddy/tech-stacks/backend-java-springboot-jdk17.md` 配套使用。
> 本文件**只提供脚本模板与运维 SOP**，项目侧落地时按需调整路径、端口、用户与日志策略。

## 0. 元信息

| 项 | 值 |
|----|----|
| 适用部署 | 单实例手动 jar 上传（无 K8s / 无 Docker） |
| 关联默认 | `.codebuddy/tech-stack.md` §6 |
| 关联画像 | `tech-stacks/backend-java-springboot-jdk17.md` |
| 脚本落点 | 服务器 `/opt/<app>/{bin,conf,lib,logs,run,backup}` |
| 进程管理 | PID 文件 + 优雅退出（`SIGTERM` + Spring `ApplicationListener` 上下文关闭） |
| 工具链 | JDK 17 + Maven 3.8.x + bash 4+/5+ |

## 1. 部署目录约定

服务器侧统一目录（按 `<app>` 实际名替换，例如 `order-svc`）：

```
/opt/<app>/
├── bin/                   # 启动 / 停止 / 重启脚本
│   ├── start.sh
│   ├── stop.sh
│   ├── restart.sh
│   └── status.sh
├── conf/                  # application.yml / application-{env}.yml
│   ├── application.yml
│   ├── application-dev.yml
│   ├── application-staging.yml
│   └── application-prod.yml
├── lib/                   # 上传的 fat jar（软链或直接放）
│   └── <app>-<version>.jar
├── logs/                  # 日志输出（Logback 配置）
│   ├── app.log            # 当前日志
│   ├── app-error.log      # 错误日志
│   └── app.%d{yyyy-MM-dd}.%i.log.gz  # 归档（Logback 滚动策略）
├── run/                   # 进程元数据
│   └── <app>.pid           # PID 文件
├── backup/                # 历史 jar 备份
│   └── <app>-<v0.1>-20260917-150301.jar
└── README.md              # 本机部署说明（含端口 / 启动用户 / 日志路径）
```

## 2. 脚本模板

> 所有脚本第一行 `#!/usr/bin/env bash`；`set -euo pipefail`；变量化路径便于复用。

### 2.1 start.sh（启动）

```bash
#!/usr/bin/env bash
# 启动 <app> 服务（手动 jar 上传部署场景）
set -euo pipefail

APP_NAME="<app>"                              # 实际服务名替换
APP_PORT="8080"                                # 服务端口
APP_HOME="/opt/${APP_NAME}"
JAR_NAME="${APP_HOME}/lib/${APP_NAME}-${APP_VERSION:-1.0.0}.jar"
PID_FILE="${APP_HOME}/run/${APP_NAME}.pid"
LOG_DIR="${APP_HOME}/logs"
PROFILE="${SPRING_PROFILES_ACTIVE:-prod}"     # 默认 prod
JAVA_OPTS="${JAVA_OPTS:--Xms512m -Xmx512m -XX:+UseG1GC -Dfile.encoding=UTF-8}"

mkdir -p "${LOG_DIR}"

# 已运行则跳过
if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  echo "[${APP_NAME}] already running, pid=$(cat "${PID_FILE}")"
  exit 0
fi

echo "[${APP_NAME}] starting with profile=${PROFILE}, jar=${JAR_NAME}"
nohup java ${JAVA_OPTS} -jar "${JAR_NAME}" \
  --spring.profiles.active="${PROFILE}" \
  --server.port="${APP_PORT}" \
  > "${LOG_DIR}/app.log" 2>&1 &
echo $! > "${PID_FILE}"

# 健康检查（最长等 60s）
for i in {1..30}; do
  sleep 2
  if curl -fsS "http://127.0.0.1:${APP_PORT}/actuator/health" >/dev/null 2>&1; then
    echo "[${APP_NAME}] started, pid=$(cat "${PID_FILE}"), healthy after ${i}x2s"
    exit 0
  fi
done

echo "[${APP_NAME}] start TIMEOUT, check ${LOG_DIR}/app.log"
exit 1
```

### 2.2 stop.sh（停止）

```bash
#!/usr/bin/env bash
# 优雅停止 <app> 服务（先 SIGTERM，最多等 30s 升级 SIGKILL）
set -euo pipefail

APP_NAME="<app>"
PID_FILE="/opt/${APP_NAME}/run/${APP_NAME}.pid"

if [[ ! -f "${PID_FILE}" ]]; then
  echo "[${APP_NAME}] not running (no pid file)"
  exit 0
fi

PID="$(cat "${PID_FILE}")"
if ! kill -0 "${PID}" 2>/dev/null; then
  echo "[${APP_NAME}] pid=${PID} not alive, cleaning pid file"
  rm -f "${PID_FILE}"; exit 0
fi

echo "[${APP_NAME}] stopping pid=${PID} (SIGTERM)"
kill -TERM "${PID}"
for i in {1..15}; do
  sleep 2
  if ! kill -0 "${PID}" 2>/dev/null; then
    echo "[${APP_NAME}] stopped gracefully after ${i}x2s"
    rm -f "${PID_FILE}"; exit 0
  fi
done

echo "[${APP_NAME}] SIGKILL pid=${PID}"
kill -KILL "${PID}" 2>/dev/null || true
rm -f "${PID_FILE}"
```

### 2.3 restart.sh（重启）

```bash
#!/usr/bin/env bash
set -euo pipefail
APP_NAME="<app>"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/stop.sh" && sleep 2 && "${SCRIPT_DIR}/start.sh"
```

### 2.4 status.sh（状态查询）

```bash
#!/usr/bin/env bash
set -euo pipefail
APP_NAME="<app>"
APP_PORT="8080"
PID_FILE="/opt/${APP_NAME}/run/${APP_NAME}.pid"

if [[ -f "${PID_FILE}" ]] && kill -0 "$(cat "${PID_FILE}")" 2>/dev/null; then
  PID="$(cat "${PID_FILE}")"
  echo "[${APP_NAME}] RUNNING pid=${PID}"
  echo "  port: ${APP_PORT}"
  echo "  mem:  $(ps -p ${PID} -o rss= 2>/dev/null | awk '{print $1/1024" MB"}')"
  echo "  cpu:  $(ps -p ${PID} -o %cpu= 2>/dev/null)"
  curl -fsS "http://127.0.0.1:${APP_PORT}/actuator/health" 2>/dev/null && echo
else
  echo "[${APP_NAME}] STOPPED"
fi
```

## 3. 部署流程 SOP

### 3.1 首次部署

```bash
# 1. 本机构建 fat jar（与 tech-stack.md §6 配套）
cd <repo>/backend
mvn clean package -DskipTests
ls target/<app>-<version>.jar

# 2. 上传到服务器
scp target/<app>-<version>.jar user@server:/tmp/

# 3. 服务器侧落盘
ssh user@server << 'EOF'
APP=<app>; VER=1.0.0
mkdir -p /opt/${APP}/{bin,conf,lib,logs,run,backup}
mv /tmp/<app>-${VER}.jar /opt/${APP}/lib/
cp <repo>/backend/src/main/resources/application*.yml /opt/${APP}/conf/   # 首次
chmod +x /opt/${APP}/bin/*.sh
EOF

# 4. 启动
ssh user@server "/opt/<app>/bin/start.sh"

# 5. 验证
ssh user@server "/opt/<app>/bin/status.sh"
curl -fsS http://server:8080/actuator/health
```

### 3.2 滚动升级

```bash
# 1. 本机构建新版本
mvn clean package -DskipTests -Drevision=1.0.1
ls target/<app>-1.0.1.jar

# 2. 备份当前版本 + 上传新版本
ssh user@server << 'EOF'
APP=<app>; OLD_VER=1.0.0
cp /opt/${APP}/lib/<app>-${OLD_VER}.jar /opt/${APP}/backup/<app>-${OLD_VER}-$(date +%Y%m%d-%H%M%S).jar
EOF
scp target/<app>-1.0.1.jar user@server:/tmp/

# 3. 替换 + 重启
ssh user@server << 'EOF'
APP=<app>; NEW_VER=1.0.1
mv /tmp/<app>-${NEW_VER}.jar /opt/${APP}/lib/
export APP_VERSION=${NEW_VER}
/opt/${APP}/bin/restart.sh
EOF

# 4. 验证
ssh user@server "/opt/<app>/bin/status.sh"
```

### 3.3 回滚

```bash
ssh user@server << 'EOF'
APP=<app>
LATEST_BACKUP=$(ls -t /opt/${APP}/backup/ | head -1)
cp /opt/${APP}/backup/${LATEST_BACKUP} /opt/${APP}/lib/<app>-${APP_VERSION:-1.0.0}.jar
/opt/${APP}/bin/restart.sh
EOF
```

## 4. application-{env}.yml 切换规范

`application.yml`（公共配置）：

```yaml
spring:
  application:
    name: <app>
  profiles:
    active: ${SPRING_PROFILES_ACTIVE:prod}      # 由 start.sh 传入

server:
  port: ${SERVER_PORT:8080}

# 项目内通用配置 ...
```

`application-prod.yml`（仅生产差异）：

```yaml
spring:
  datasource:
    url: jdbc:mysql://<prod-host>:3306/<db>?useSSL=true&serverTimezone=Asia/Shanghai&useUnicode=true&characterEncoding=utf8
    username: ${DB_USER}
    password: ${DB_PWD}
logging:
  level:
    root: INFO
    <base-package>: INFO
```

> **【强制】** 密码 / 密钥等敏感信息**不写入 yml**，通过环境变量或启动参数注入；按 `rules/dev-contract.mdc` 与 `rules/se-workflow.mdc` 脱敏。

## 5. 日志滚动（logback-spring.xml 关键节）

```xml
<configuration scan="true" scanPeriod="30 seconds">
  <property name="LOG_DIR" value="${LOG_DIR:-/opt/<app>/logs}"/>

  <appender name="APP" class="ch.qos.logback.core.rolling.RollingFileAppender">
    <file>${LOG_DIR}/app.log</file>
    <rollingPolicy class="ch.qos.logback.core.rolling.SizeAndTimeBasedRollingPolicy">
      <fileNamePattern>${LOG_DIR}/app.%d{yyyy-MM-dd}.%i.log.gz</fileNamePattern>
      <maxFileSize>100MB</maxFileSize>
      <maxHistory>30</maxHistory>
      <totalSizeCap>10GB</totalSizeCap>
    </rollingPolicy>
    <encoder>
      <pattern>%d{yyyy-MM-dd HH:mm:ss.SSS} [%thread] %-5level [traceId=%X{traceId:-}] %logger{36} - %msg%n</pattern>
    </encoder>
  </appender>

  <root level="INFO">
    <appender-ref ref="APP"/>
  </root>
</configuration>
```

## 6. 常见运维命令速查

| 动作 | 命令 |
|------|------|
| 查实时日志 | `tail -f /opt/<app>/logs/app.log` |
| 查错误日志 | `grep -E "ERROR\|Exception" /opt/<app>/logs/app.log \| tail -100` |
| 查 PID | `cat /opt/<app>/run/<app>.pid` |
| 查进程 | `ps -ef \| grep $(cat /opt/<app>/run/<app>.pid)` |
| 查端口 | `ss -tlnp \| grep <pid>` |
| 查 JVM 内存 | `jstat -gcutil <pid> 1000` |
| 查线程栈 | `jstack <pid> \| less` |
| 健康检查 | `curl -fsS http://127.0.0.1:8080/actuator/health` |
| 优雅停机 | `/opt/<app>/bin/stop.sh` |
| 强杀 | `kill -9 $(cat /opt/<app>/run/<app>.pid)` |

## 7. 自检清单（项目部署前）

- [ ] 服务器 JDK 版本 = 17（`java -version`）
- [ ] 服务器端口未占用（`ss -tlnp | grep 8080`）
- [ ] `/opt/<app>/` 目录结构齐备（§1）
- [ ] `conf/application*.yml` 三套环境齐备；敏感信息走环境变量
- [ ] `bin/*.sh` 有可执行权限（`chmod +x`）
- [ ] 健康检查端点可访问（`actuator/health` 返回 `{"status":"UP"}`）
- [ ] 备份策略已生效（`backup/` 目录可写）
- [ ] 日志滚动策略已生效（`logs/` 目录可写）
- [ ] 回滚脚本演练过（保留 ≥ 1 个历史版本）
- [ ] 进程以非 root 用户运行（避免权限风险）