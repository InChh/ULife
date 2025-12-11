-- 论坛板块表
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

-- 插入默认板块
INSERT INTO bbs_boards (id, name, icon, description, board_type, sort_order) VALUES
('board_1', '校园热议', 'fire', '校园热点话题讨论', 'static', 1),
('board_2', '学习交流', 'book', '学习方法、课程讨论', 'static', 2),
('board_3', '生活分享', 'coffee', '校园生活、美食、趣事', 'static', 3),
('board_4', '求助问答', 'question', '提问和解答', 'static', 4),
('board_5', '二手市场', 'shopping-cart', '闲置物品交易', 'static', 5);

-- 论坛帖子表
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

-- 帖子点赞表
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

-- 帖子收藏表
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

-- 评论表
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

-- 评论点赞表
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

-- 举报表
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

