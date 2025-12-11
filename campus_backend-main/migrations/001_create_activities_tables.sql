-- 活动表
CREATE TABLE IF NOT EXISTS activities (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    cover_url VARCHAR(512),
    activity_type TINYINT NOT NULL COMMENT '1:讲座, 2:社团, 3:竞赛',
    location VARCHAR(255) NOT NULL,
    organizer VARCHAR(255) NOT NULL,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    quota INT NOT NULL DEFAULT 0,
    current_enrollments INT NOT NULL DEFAULT 0,
    need_sign_in BOOLEAN NOT NULL DEFAULT FALSE,
    status TINYINT NOT NULL DEFAULT 1 COMMENT '1:已发布/进行中, 2:已结束, 3:已撤销',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_activity_type (activity_type),
    INDEX idx_status (status),
    INDEX idx_start_time (start_time)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 活动报名表
CREATE TABLE IF NOT EXISTS activity_enrollments (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    activity_id VARCHAR(36) NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    student_id VARCHAR(50) NOT NULL,
    major VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20),
    enroll_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    attendance_status TINYINT NOT NULL DEFAULT 1 COMMENT '1:已报名, 2:已取消',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_activity (user_id, activity_id),
    INDEX idx_activity_id (activity_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 活动收藏表
CREATE TABLE IF NOT EXISTS activity_collections (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL,
    activity_id VARCHAR(36) NOT NULL,
    collected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_activity_collection (user_id, activity_id),
    INDEX idx_activity_id (activity_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

