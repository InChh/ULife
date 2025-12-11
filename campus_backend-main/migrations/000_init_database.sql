-- 创建数据库（如果不存在）
CREATE DATABASE IF NOT EXISTS campus_db 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE campus_db;

-- 提示信息
SELECT '数据库初始化开始...' AS status;
SELECT '请按顺序执行以下迁移脚本：' AS info;
SELECT '1. 003_create_user_tables.sql' AS step;
SELECT '2. 004_create_bbs_tables.sql' AS step;
SELECT '3. 005_create_course_tables.sql' AS step;
SELECT '4. 001_create_activities_tables.sql (已有)' AS step;
SELECT '5. 006_seed_test_data.sql (测试数据)' AS step;

