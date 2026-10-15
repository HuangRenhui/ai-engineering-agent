-- =============================================================================
-- 文件命名 : REQxxx-<描述>-v0.x-YYYYMMDD.sql（复制本模板后重命名为真实编号/描述/版本/日期）
-- REQ 编号 : <REQ001，三位补零，只增不改、不复用、不跳号>
-- 需求描述 : <一句话需求描述，与文件名描述段一致>
-- 契约版本 : <v0.1>（与 contract/README.md 的 version 一致）
-- 生成日期 : <YYYY-MM-DD>
-- 生成命令 : /ai-dev-backend（阶段 3 架构搭建 · 只生成不执行）
-- 涉及表   : <t_xxx>, <t_yyy>
-- 对应标识 : <F01-功能名>；<API-01>, <API-02>
-- 执行顺序 : 按 REQ 序号 + 日期升序执行；本文件须在 <REQ000> 之后执行
-- 可回滚   : <是 / 否>（回滚要点见文件末尾第 5 段）
-- 幂等性   : 可重复执行（IF NOT EXISTS / INFORMATION_SCHEMA 判断 / upsert）
-- 敏感声明 : 本文件不含真实域名、连接串、账号、口令与生产数据；样例数据均为占位符
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. 前置检查（可选）：确认依赖的上游对象已存在
-- -----------------------------------------------------------------------------
-- SELECT 1 FROM INFORMATION_SCHEMA.TABLES
--  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '<t_xxx>';   -- 应返回 1 行

-- -----------------------------------------------------------------------------
-- 1. 建表
--    首版 REQ001 = 全量初始化（本段写全）；此后每个 REQ 仅按需新增表，无新增可整段删除
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `<t_xxx>` (
    `id`         bigint(20)  NOT NULL AUTO_INCREMENT COMMENT '主键',
    `<字段名>`   varchar(64) NOT NULL DEFAULT ''                COMMENT '<业务含义>',
    `<状态字段>` tinyint(4)  NOT NULL DEFAULT 0                 COMMENT '<状态含义，取值见 contract/enums.md>',
    `is_deleted` tinyint(1)  NOT NULL DEFAULT 0                 COMMENT '0 正常 / 1 删除',
    `version`    int(11)     NOT NULL DEFAULT 0                 COMMENT '乐观锁版本号',
    `created_by` bigint(20)  NOT NULL DEFAULT 0                 COMMENT '创建人',
    `created_at` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `updated_by` bigint(20)  NOT NULL DEFAULT 0                 COMMENT '更新人',
    `updated_at` datetime    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_<字段名>` (`<字段名>`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '<表业务名>';

-- -----------------------------------------------------------------------------
-- 2. 增量变更（后续 REQ 使用；字段/类型/默认值须与 contract/data-model.md 逐字一致）
--    新增字段：先用 INFORMATION_SCHEMA.COLUMNS 判断，避免重复执行报错
-- -----------------------------------------------------------------------------
-- SET @exist_col := (SELECT COUNT(1) FROM INFORMATION_SCHEMA.COLUMNS
--                     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '<t_xxx>'
--                       AND COLUMN_NAME = '<新字段>');
-- SET @sql_col := IF(@exist_col = 0,
--   'ALTER TABLE `<t_xxx>` ADD COLUMN `<新字段>` varchar(32) NOT NULL DEFAULT '''' COMMENT ''<业务含义>''',
--   'SELECT 1');
-- PREPARE stmt_col FROM @sql_col; EXECUTE stmt_col; DEALLOCATE PREPARE stmt_col;
--
-- 修改列（慎用，须评估数据丢失与回滚）：<仅在必要时使用，并在 data-model.md §5 登记>

-- -----------------------------------------------------------------------------
-- 3. 索引
--    MySQL 不支持 DROP INDEX IF EXISTS，故用 INFORMATION_SCHEMA.STATISTICS 判断后创建
--    索引名须与 contract/data-model.md §3 完全一致
-- -----------------------------------------------------------------------------
-- SET @exist_idx := (SELECT COUNT(1) FROM INFORMATION_SCHEMA.STATISTICS
--                     WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = '<t_xxx>'
--                       AND INDEX_NAME = 'idx_<字段名>_created_at');
-- SET @sql_idx := IF(@exist_idx = 0,
--   'CREATE INDEX `idx_<字段名>_created_at` ON `<t_xxx>` (`<字段名>`, `created_at`)',
--   'SELECT 1');
-- PREPARE stmt_idx FROM @sql_idx; EXECUTE stmt_idx; DEALLOCATE PREPARE stmt_idx;

-- -----------------------------------------------------------------------------
-- 4. 字典 / 初始化数据（幂等 upsert；样例数据一律占位符）
-- -----------------------------------------------------------------------------
-- INSERT INTO `<t_dict_xxx>` (`code`, `name`, `sort_no`) VALUES
--     ('<A>', '<含义A>', 1),
--     ('<B>', '<含义B>', 2)
-- ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `sort_no` = VALUES(`sort_no`);

-- -----------------------------------------------------------------------------
-- 5. 回滚要点（人工执行，本目录不生成独立 rollback 文件）
--    5.1 本 REQ 新建的表  : DROP TABLE IF EXISTS `<t_new_xxx>`;
--    5.2 本 REQ 新增的字段: ALTER TABLE `<t_xxx>` DROP COLUMN `<新字段>`;
--    5.3 本 REQ 新增的索引: DROP INDEX `idx_<字段名>_created_at` ON `<t_xxx>`;
--    5.4 数据类变更       : <给出反向语句；不可逆时在此写明，并在 data-model.md §5 标"可回滚 = 否">
-- -----------------------------------------------------------------------------

-- =============================================================================
-- 生成时自查（禁止事项）
--   1) 禁止 DROP DATABASE；禁止 DROP / TRUNCATE 既有业务表；禁止无 WHERE 的 DELETE / UPDATE；
--   2) 禁止写入真实域名、连接串、账号、口令、PII 与生产数据；
--   3) 禁止修改历史 REQ 脚本：修正一律新增更高版本文件（版本与 contract version 同步递增）；
--   4) 禁止把本文件当契约使用：字段/类型/索引的唯一依据是 contract/data-model.md；
--   5) 本文件只生成不执行：执行前须人工复核，并在非生产环境验证。
-- =============================================================================
