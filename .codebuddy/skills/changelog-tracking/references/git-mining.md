# Git 历史挖掘方法

只读方式从目标仓库提取提交历史，归一化为变更条目。

## 一、原则

1. **只读**：仅使用 `git log` / `git show` / `git shortlog` 等只读命令，禁止 checkout/commit/clean。
2. **限量**：按 `--scope` 过滤路径，并限定条数或时间窗，避免全量历史造成超长输出。
3. **可追溯**：保留 short-sha 作为 `evidence`。

## 二、推荐命令（git 只读命令，跨平台通用）

> 下列命令均为 `git` 原生命令，Windows（PowerShell / cmd）、macOS、Linux 下写法一致；
> 只需按当前 shell 的引号转义规则书写即可（示例为 PowerShell 风格）。

```powershell
# 基础：最近 N 条提交，含时间、作者、说明
git -C "<repo>" log -n 100 --date=iso --pretty=format:"%h|%ad|%an|%s"

# 按范围过滤（模块/目录）
git -C "<repo>" log -n 100 --date=iso --pretty=format:"%h|%ad|%an|%s" -- "<scope-path>"

# 含变更文件清单（用于推算影响范围 scope）
git -C "<repo>" log -n 50 --date=iso --name-status --pretty=format:"===%h|%ad|%s"

# 时间窗
git -C "<repo>" log --since="<YYYY-MM-DD>" --until="<YYYY-MM-DD>" --date=iso --pretty=format:"%h|%ad|%s"
```

> 说明：`%h` short-sha、`%ad` 作者日期（ISO）、`%an` 作者、`%s` 提交说明；`--name-status` 给出变更文件与状态（A/M/D）。

## 三、归一化映射

| 变更日志字段 | 来源 |
|--------------|------|
| `time` | `%ad`（ISO，含时区） |
| `type` | 固定 `git-commit` |
| `summary` | 精炼自 `%s`（如"新增：xxx"/"修复：xxx"） |
| `detail` | `--name-status` 汇总（新增/修改/删除的文件数）或提交 body |
| `source` | `git:<%h>` |
| `scope` | 变更文件所属模块/目录 |
| `evidence` | `git show <%h>` 链接/引用 |

## 四、注意事项

1. 提交说明质量参差：`summary` 需精炼为动宾结构，语义不明的提交标注 `[推断]` 并入开放问题。
2. 合并提交（merge）默认跳过，除非含明确业务变更。
3. 提交信息/差异中若含密钥、口令、个人隐私，落盘前以占位符替代。
4. 输出条数超过上限时分页/分批，不要一次性全量拉取。
5. 无 Git 仓库时，改为在新旧版本对比或人工提供的变更清单上采集，并在日志中说明来源。
