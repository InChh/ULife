-- 测试数据脚本
-- USE ULife; -- 数据库已在命令行指定，不需要 USE

-- 插入测试用户
INSERT INTO users (id, student_id, name, password_hash, college, major, phone, role) VALUES
('test_user_id', '2021001', '张三', '123456', '计算机学院', '软件工程', '13800138000', 'student'),
('user_2', '2021002', '李四', '123456', '计算机学院', '计算机科学与技术', '13800138001', 'student'),
('user_3', '2021003', '王五', '123456', '信息学院', '信息管理', '13800138002', 'student'),
('admin_1', '9999999', '管理员', 'admin123', '管理部门', '系统管理', '13900139000', 'admin')
ON DUPLICATE KEY UPDATE id=id;

-- 插入测试公共课程
INSERT INTO public_courses (course_name, teacher_name, location, day_of_week, start_section, end_section, weeks_range, type, credits, semester_id) VALUES
('高等数学', '张教授', '教学楼A101', 1, 1, 2, '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]', 'compulsory', 4, 1),
('大学英语', '李教授', '教学楼B202', 2, 3, 4, '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]', 'compulsory', 3, 1),
('数据结构', '王教授', '实验楼C301', 3, 5, 6, '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]', 'compulsory', 4, 1),
('计算机网络', '赵教授', '教学楼A203', 4, 1, 2, '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]', 'compulsory', 3, 1),
('web开发技术', '刘教授', '实验楼C401', 5, 7, 8, '[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]', 'elective', 2, 1);

-- 插入测试帖子
INSERT INTO bbs_posts (id, title, content, board_id, author_id, tags, status, view_count, like_count, comment_count) VALUES
('post_1', '今天图书馆的自习座位好难抢啊', '每次想去图书馆自习都抢不到座位，大家有什么好的方法吗？', 'board_1', 'test_user_id', '["图书馆", "自习"]', 'approved', 128, 15, 8),
('post_2', '推荐一家学校附近的美食店', '在学校西门发现了一家超好吃的川菜馆，价格实惠，味道正宗！', 'board_3', 'user_2', '["美食", "推荐"]', 'approved', 89, 23, 12),
('post_3', '数据结构课程求组队', '下周要做数据结构的课程设计，有没有同学一起组队的？', 'board_2', 'user_3', '["学习", "组队"]', 'approved', 56, 8, 5);

-- 插入测试评论
INSERT INTO bbs_comments (id, post_id, author_id, content, like_count) VALUES
('comment_1', 'post_1', 'user_2', '可以试试早点去，或者在图书馆公众号上预约', 5),
('comment_2', 'post_1', 'user_3', '我一般去五楼，那边人相对少一些', 3),
('comment_3', 'post_2', 'test_user_id', '在哪个位置？我也想去试试！', 2);

SELECT '测试数据插入完成！' AS status;
SELECT CONCAT('用户数: ', COUNT(*)) AS info FROM users;
SELECT CONCAT('帖子数: ', COUNT(*)) AS info FROM bbs_posts;
SELECT CONCAT('公共课程数: ', COUNT(*)) AS info FROM public_courses;

