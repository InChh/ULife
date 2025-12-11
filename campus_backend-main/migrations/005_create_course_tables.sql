-- 学期表
CREATE TABLE IF NOT EXISTS semesters (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL COMMENT '学期名称，如"2024-2025学年 第一学期"',
    start_date DATE NOT NULL COMMENT '学期开始日期',
    end_date DATE NOT NULL COMMENT '学期结束日期',
    is_current BOOLEAN NOT NULL DEFAULT FALSE COMMENT '是否为当前学期',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_is_current (is_current)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 插入默认学期
INSERT INTO semesters (name, start_date, end_date, is_current) VALUES
('2024-2025学年 第一学期', '2024-09-01', '2025-01-15', TRUE),
('2024-2025学年 第二学期', '2025-02-15', '2025-07-01', FALSE);

-- 公共课程表（全校课程）
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
    type VARCHAR(20) NOT NULL DEFAULT 'compulsory' COMMENT '课程类型: compulsory(必修), elective(选修)',
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

-- 用户课表表
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

