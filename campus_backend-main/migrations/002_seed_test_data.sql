-- 测试数据：活动

INSERT INTO activities (id, title, content, cover_url, activity_type, location, organizer, start_time, end_time, quota, current_enrollments, need_sign_in, status, created_at)
VALUES 
(
    '550e8400-e29b-41d4-a716-446655440001',
    'AI 前沿讲座：大模型与校园应用',
    '邀请校友分享大模型在学习、科研、生活中的落地案例，并现场 Q&A。本次讲座将深入探讨 ChatGPT、Claude 等大模型在教育领域的应用，包括智能问答、论文写作辅助、代码生成等实用场景。',
    'https://picsum.photos/400/300?random=1',
    1,
    '科技楼报告厅 301',
    '计算机学院 / 校友会',
    DATE_ADD(NOW(), INTERVAL 1 DAY),
    DATE_ADD(NOW(), INTERVAL 1 DAY) + INTERVAL 2 HOUR,
    80,
    36,
    true,
    1,
    DATE_SUB(NOW(), INTERVAL 2 DAY)
),
(
    '550e8400-e29b-41d4-a716-446655440002',
    '校园马拉松志愿者招募',
    '协助赛道秩序维护、物资发放、急救引导，提供志愿者时长证明。这是一次锻炼组织能力、服务意识的绝佳机会，欢迎热心同学报名参加。',
    'https://picsum.photos/400/300?random=2',
    2,
    '田径场北门集合',
    '体育部 / 志愿者协会',
    DATE_ADD(NOW(), INTERVAL 3 DAY),
    DATE_ADD(NOW(), INTERVAL 3 DAY) + INTERVAL 3 HOUR,
    120,
    95,
    false,
    1,
    DATE_SUB(NOW(), INTERVAL 1 DAY)
),
(
    '550e8400-e29b-41d4-a716-446655440003',
    '编程竞赛训练营选拔赛',
    '笔试 + 上机赛，选拔校赛代表队，欢迎 22/23/24 级同学报名。比赛内容涵盖算法设计、数据结构、编程能力等多个方面，优胜者将代表学校参加省级比赛。',
    'https://picsum.photos/400/300?random=3',
    3,
    '实验楼机房 502',
    '信息竞赛中心',
    DATE_ADD(NOW(), INTERVAL 5 DAY),
    DATE_ADD(NOW(), INTERVAL 5 DAY) + INTERVAL 4 HOUR,
    60,
    58,
    true,
    1,
    DATE_SUB(NOW(), INTERVAL 3 DAY)
),
(
    '550e8400-e29b-41d4-a716-446655440004',
    '创业分享会：从校园到创业',
    '邀请优秀校友分享创业经历，探讨大学生创业的机遇与挑战。包括项目孵化、团队组建、融资经验等实战内容。',
    'https://picsum.photos/400/300?random=4',
    1,
    '创新创业中心 201',
    '创业学院',
    DATE_ADD(NOW(), INTERVAL 7 DAY),
    DATE_ADD(NOW(), INTERVAL 7 DAY) + INTERVAL 2 HOUR,
    100,
    42,
    true,
    1,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440005',
    '摄影社招新活动',
    '摄影社 2025 年春季招新，欢迎对摄影感兴趣的同学加入。社团提供相机租借、外拍活动、技能培训等服务。',
    'https://picsum.photos/400/300?random=5',
    2,
    '学生活动中心 3楼',
    '摄影社',
    DATE_ADD(NOW(), INTERVAL 2 DAY),
    DATE_ADD(NOW(), INTERVAL 2 DAY) + INTERVAL 2 HOUR,
    50,
    12,
    false,
    1,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440006',
    '数学建模大赛宣讲会',
    '介绍全国大学生数学建模竞赛的赛制、题型、备赛策略。邀请往届获奖团队分享经验。',
    'https://picsum.photos/400/300?random=6',
    3,
    '理学院大楼 A105',
    '数学建模协会',
    DATE_ADD(NOW(), INTERVAL 4 DAY),
    DATE_ADD(NOW(), INTERVAL 4 DAY) + INTERVAL 1 HOUR + INTERVAL 30 MINUTE,
    150,
    89,
    false,
    1,
    DATE_SUB(NOW(), INTERVAL 1 DAY)
),
(
    '550e8400-e29b-41d4-a716-446655440007',
    '英语角周末活动',
    '每周六下午的英语角活动，自由交流、话题讨论、外教陪练。提升口语能力的好机会。',
    'https://picsum.photos/400/300?random=7',
    2,
    '图书馆西侧草坪',
    '外语学院',
    DATE_ADD(NOW(), INTERVAL 6 DAY),
    DATE_ADD(NOW(), INTERVAL 6 DAY) + INTERVAL 2 HOUR,
    30,
    28,
    false,
    1,
    NOW()
),
(
    '550e8400-e29b-41d4-a716-446655440008',
    '职业规划讲座：互联网求职指南',
    'HR 和技术面试官分享互联网行业求职经验，包括简历撰写、面试技巧、职业发展路径等。',
    'https://picsum.photos/400/300?random=8',
    1,
    '就业指导中心报告厅',
    '就业指导中心 / 计算机学院',
    DATE_ADD(NOW(), INTERVAL 10 DAY),
    DATE_ADD(NOW(), INTERVAL 10 DAY) + INTERVAL 2 HOUR + INTERVAL 30 MINUTE,
    200,
    156,
    true,
    1,
    NOW()
);

-- 测试数据：报名记录（为测试用户创建一些报名记录）
INSERT INTO activity_enrollments (id, user_id, activity_id, user_name, student_id, major, phone_number, attendance_status, created_at)
VALUES 
(
    '660e8400-e29b-41d4-a716-446655440001',
    'test_user_id',
    '550e8400-e29b-41d4-a716-446655440001',
    '测试用户',
    '2025123456',
    '软件工程',
    '13800000000',
    1,
    NOW()
);

-- 测试数据：收藏记录
INSERT INTO activity_collections (id, user_id, activity_id, collected_at)
VALUES 
(
    '770e8400-e29b-41d4-a716-446655440001',
    'test_user_id',
    '550e8400-e29b-41d4-a716-446655440002',
    NOW()
),
(
    '770e8400-e29b-41d4-a716-446655440002',
    'test_user_id',
    '550e8400-e29b-41d4-a716-446655440003',
    NOW()
);

