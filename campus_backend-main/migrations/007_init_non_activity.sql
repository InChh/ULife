-- Non-Activity modules initialization (User / Forum / Course)
-- Note: excludes any Activity-related tables. Run after 000_init_database.sql.

-- ==== User Module ====
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

-- ==== Forum/BBS Module ====
CREATE TABLE IF NOT EXISTS bbs_boards (
    id VARCHAR(36) PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '板块名称',
    icon VARCHAR(50) NOT NULL COMMENT '图标',
    description VARCHAR(255) COMMENT '板块描述',
    board_type VARCHAR(20) NOT NULL DEFAULT 'static' COMMENT '板块类型: static, dynamic',
    sort_order INT NOT NULL DEFAULT 0 COMMENT '排序序号',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_board_type (board_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO bbs_boards (id, name, icon, description, board_type, sort_order) VALUES
('board_1', '校园热议', 'fire', '校园热点话题讨论', 'static', 1),
('board_2', '学习交流', 'book', '学习方法、课程讨论', 'static', 2),
('board_3', '生活分享', 'coffee', '校园生活、美食、趣事', 'static', 3),
('board_4', '求助问答', 'question', '提问和解答', 'static', 4),
('board_5', '二手市场', 'shopping-cart', '闲置物品交易', 'static', 5)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    icon = VALUES(icon),
    description = VALUES(description),
    board_type = VALUES(board_type),
    sort_order = VALUES(sort_order);

CREATE TABLE IF NOT EXISTS bbs_posts (
    id VARCHAR(36) PRIMARY KEY,
    title VARCHAR(255) NOT NULL COMMENT '帖子标题',
    content TEXT NOT NULL COMMENT '帖子内容',
    board_id VARCHAR(36) NOT NULL COMMENT '所属板块ID',
    author_id VARCHAR(36) NOT NULL COMMENT '作者ID',
    tags JSON COMMENT '标签数组',
    cover_image_url VARCHAR(512) COMMENT '封面图片URL',
    status VARCHAR(20) NOT NULL DEFAULT 'approved' COMMENT '状态: approved, pending, rejected, hidden',
    view_count INT NOT NULL DEFAULT 0 COMMENT '浏览数',
    like_count INT NOT NULL DEFAULT 0 COMMENT '点赞数',
    comment_count INT NOT NULL DEFAULT 0 COMMENT '评论数',
    report_count INT NOT NULL DEFAULT 0 COMMENT '举报数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_replied_at DATETIME COMMENT '最后回复时间',
    INDEX idx_board_id (board_id),
    INDEX idx_author_id (author_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    INDEX idx_last_replied_at (last_replied_at),
    FOREIGN KEY (board_id) REFERENCES bbs_boards(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bbs_post_likes (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (post_id) REFERENCES bbs_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bbs_post_collections (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    collected_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_post_user_collection (post_id, user_id),
    INDEX idx_post_id (post_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (post_id) REFERENCES bbs_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bbs_comments (
    id VARCHAR(36) PRIMARY KEY,
    post_id VARCHAR(36) NOT NULL COMMENT '帖子ID',
    author_id VARCHAR(36) NOT NULL COMMENT '评论者ID',
    content TEXT NOT NULL COMMENT '评论内容',
    parent_id VARCHAR(36) COMMENT '父评论ID（用于二级评论）',
    reply_to_user_id VARCHAR(36) COMMENT '回复的用户ID',
    like_count INT NOT NULL DEFAULT 0 COMMENT '点赞数',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_post_id (post_id),
    INDEX idx_author_id (author_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (post_id) REFERENCES bbs_posts(id) ON DELETE CASCADE,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES bbs_comments(id) ON DELETE CASCADE,
    FOREIGN KEY (reply_to_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bbs_comment_likes (
    id VARCHAR(36) PRIMARY KEY,
    comment_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_comment_user (comment_id, user_id),
    INDEX idx_comment_id (comment_id),
    INDEX idx_user_id (user_id),
    FOREIGN KEY (comment_id) REFERENCES bbs_comments(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS bbs_reports (
    id VARCHAR(36) PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '举报者ID',
    target_type VARCHAR(20) NOT NULL COMMENT '举报目标类型: post, comment',
    target_id VARCHAR(36) NOT NULL COMMENT '举报目标ID',
    reason VARCHAR(50) NOT NULL COMMENT '举报原因: ad, politics, abuse, other',
    description TEXT COMMENT '详细描述',
    status VARCHAR(20) NOT NULL DEFAULT 'pending' COMMENT '状态: pending, resolved, rejected',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_target (target_type, target_id),
    INDEX idx_status (status),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==== Course/Schedule Module ====
CREATE TABLE IF NOT EXISTS semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '学期名称，如\"2024-2025学年 第一学期\"',
    start_date DATE NOT NULL COMMENT '学期开始日期',
    end_date DATE NOT NULL COMMENT '学期结束日期',
    is_current BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否为当前学期',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_current (is_current)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO semesters (id, name, start_date, end_date, is_current) VALUES
(1, '2024-2025学年 第一学期', '2024-09-01', '2025-01-15', TRUE),
(2, '2024-2025学年 第二学期', '2025-02-15', '2025-07-01', FALSE)
ON DUPLICATE KEY UPDATE
    name = VALUES(name),
    start_date = VALUES(start_date),
    end_date = VALUES(end_date),
    is_current = VALUES(is_current);

CREATE TABLE IF NOT EXISTS public_courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    teacher_name VARCHAR(50) NOT NULL COMMENT '教师姓名',
    teacher_id BIGINT COMMENT '教师ID（可选）',
    location VARCHAR(100) NOT NULL COMMENT '上课地点',
    day_of_week TINYINT NOT NULL COMMENT '星期几（1-7）',
    start_section TINYINT NOT NULL COMMENT '开始节次（1-12）',
    end_section TINYINT NOT NULL COMMENT '结束节次（1-12）',
    weeks_range JSON COMMENT '上课周次范围，如 [1,2,3,4,5]',
    type VARCHAR(20) NOT NULL DEFAULT 'compulsory' COMMENT '课程类型: compulsory, elective',
    credits TINYINT NOT NULL DEFAULT 2 COMMENT '学分',
    description TEXT COMMENT '课程描述',
    semester_id INT NOT NULL COMMENT '所属学期ID',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_semester_id (semester_id),
    INDEX idx_teacher_name (teacher_name),
    INDEX idx_course_name (course_name),
    FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_schedule (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(36) NOT NULL COMMENT '用户ID',
    source_id BIGINT COMMENT '来源公共课程ID（如果是从公共课程添加）',
    semester_id INT NOT NULL COMMENT '所属学期ID',
    course_name VARCHAR(100) NOT NULL COMMENT '课程名称',
    teacher_name VARCHAR(50) COMMENT '教师姓名',
    location VARCHAR(100) COMMENT '上课地点',
    day_of_week TINYINT NOT NULL COMMENT '星期几（1-7）',
    start_section TINYINT NOT NULL COMMENT '开始节次（1-12）',
    end_section TINYINT NOT NULL COMMENT '结束节次（1-12）',
    weeks_range JSON COMMENT '上课周次范围，如 [1,2,3,4,5]',
    type VARCHAR(20) COMMENT '课程类型: compulsory, elective',
    credits TINYINT COMMENT '学分',
    description TEXT COMMENT '备注',
    color_hex VARCHAR(7) NOT NULL DEFAULT '#5E81F4' COMMENT '颜色（用于客户端显示）',
    is_custom BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否为自定义课程',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_semester_id (semester_id),
    INDEX idx_source_id (source_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE,
    FOREIGN KEY (source_id) REFERENCES public_courses(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

