-- 用户表
CREATE TABLE IF NOT EXISTS users (
    id VARCHAR(36) PRIMARY KEY,
    student_id VARCHAR(50) NOT NULL UNIQUE COMMENT '学号',
    name VARCHAR(100) NOT NULL COMMENT '姓名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    avatar_url VARCHAR(512) COMMENT '头像URL',
    role VARCHAR(20) NOT NULL DEFAULT 'student' COMMENT '角色: student, admin',
    college VARCHAR(100) NOT NULL COMMENT '学院',
    major VARCHAR(100) NOT NULL COMMENT '专业',
    grade VARCHAR(10) COMMENT '年级',
    class_name VARCHAR(50) COMMENT '班级',
    bio TEXT COMMENT '个人简介',
    phone VARCHAR(20) COMMENT '手机号',
    email VARCHAR(100) COMMENT '邮箱',
    wechat_id VARCHAR(100) COMMENT '微信号',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_student_id (student_id),
    INDEX idx_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Token 表（用于存储有效的登录 Token）
CREATE TABLE IF NOT EXISTS user_tokens (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at DATETIME NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_token (token),
    INDEX idx_expires_at (expires_at),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

