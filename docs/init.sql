-- MySQL dump 10.13  Distrib 8.0.41, for macos15 (arm64)
--
-- Host: 127.0.0.1    Database: ULife
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activities` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `cover_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activity_type` tinyint NOT NULL COMMENT '1:讲座, 2:社团, 3:竞赛',
  `location` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `organizer` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `quota` int NOT NULL DEFAULT '0',
  `current_enrollments` int NOT NULL DEFAULT '0',
  `need_sign_in` tinyint(1) NOT NULL DEFAULT '0',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '1:已发布/进行中, 2:已结束, 3:已撤销',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_activity_type` (`activity_type`),
  KEY `idx_status` (`status`),
  KEY `idx_start_time` (`start_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
INSERT INTO `activities` VALUES ('550e8400-e29b-41d4-a716-446655440001','AI 前沿讲座：大模型与校园应用','邀请校友分享大模型在学习、科研、生活中的落地案例，并现场 Q&A。本次讲座将深入探讨 ChatGPT、Claude 等大模型在教育领域的应用，包括智能问答、论文写作辅助、代码生成等实用场景。','https://picsum.photos/400/300?random=1',1,'科技楼报告厅 301','计算机学院 / 校友会','2025-12-12 15:45:28','2025-12-12 17:45:28',80,36,1,1,'2025-12-09 15:45:28','2025-12-11 15:45:28'),('550e8400-e29b-41d4-a716-446655440002','校园马拉松志愿者招募','协助赛道秩序维护、物资发放、急救引导，提供志愿者时长证明。这是一次锻炼组织能力、服务意识的绝佳机会，欢迎热心同学报名参加。','https://picsum.photos/400/300?random=2',2,'田径场北门集合','体育部 / 志愿者协会','2025-12-14 15:45:28','2025-12-14 18:45:28',120,95,0,1,'2025-12-10 15:45:28','2025-12-11 15:45:28'),('550e8400-e29b-41d4-a716-446655440003','编程竞赛训练营选拔赛','笔试 + 上机赛，选拔校赛代表队，欢迎 22/23/24 级同学报名。比赛内容涵盖算法设计、数据结构、编程能力等多个方面，优胜者将代表学校参加省级比赛。','https://picsum.photos/400/300?random=3',3,'实验楼机房 502','信息竞赛中心','2025-12-16 15:45:28','2025-12-16 19:45:28',60,59,1,1,'2025-12-08 15:45:28','2025-12-11 07:58:11'),('550e8400-e29b-41d4-a716-446655440004','创业分享会：从校园到创业','邀请优秀校友分享创业经历，探讨大学生创业的机遇与挑战。包括项目孵化、团队组建、融资经验等实战内容。','https://picsum.photos/400/300?random=4',1,'创新创业中心 201','创业学院','2025-12-18 15:45:28','2025-12-18 17:45:28',100,43,1,1,'2025-12-11 15:45:28','2025-12-11 08:01:52'),('550e8400-e29b-41d4-a716-446655440005','摄影社招新活动','摄影社 2025 年春季招新，欢迎对摄影感兴趣的同学加入。社团提供相机租借、外拍活动、技能培训等服务。','https://picsum.photos/400/300?random=5',2,'学生活动中心 3楼','摄影社','2025-12-13 15:45:28','2025-12-13 17:45:28',50,12,0,1,'2025-12-11 15:45:28','2025-12-11 15:45:28'),('550e8400-e29b-41d4-a716-446655440006','数学建模大赛宣讲会','介绍全国大学生数学建模竞赛的赛制、题型、备赛策略。邀请往届获奖团队分享经验。','https://picsum.photos/400/300?random=6',3,'理学院大楼 A105','数学建模协会','2025-12-15 15:45:28','2025-12-15 17:15:28',150,89,0,1,'2025-12-10 15:45:28','2025-12-11 15:45:28'),('550e8400-e29b-41d4-a716-446655440007','英语角周末活动','每周六下午的英语角活动，自由交流、话题讨论、外教陪练。提升口语能力的好机会。','https://picsum.photos/400/300?random=7',2,'图书馆西侧草坪','外语学院','2025-12-17 15:45:28','2025-12-17 17:45:28',30,28,0,1,'2025-12-11 15:45:28','2025-12-11 07:58:02'),('550e8400-e29b-41d4-a716-446655440008','职业规划讲座：互联网求职指南','HR 和技术面试官分享互联网行业求职经验，包括简历撰写、面试技巧、职业发展路径等。','https://picsum.photos/400/300?random=8',1,'就业指导中心报告厅','就业指导中心 / 计算机学院','2025-12-21 15:45:28','2025-12-21 18:15:28',200,156,1,1,'2025-12-11 15:45:28','2025-12-11 08:06:33');
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_collections`
--

DROP TABLE IF EXISTS `activity_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_collections` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activity_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `collected_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_activity_collection` (`user_id`,`activity_id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `activity_collections_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_collections`
--

LOCK TABLES `activity_collections` WRITE;
/*!40000 ALTER TABLE `activity_collections` DISABLE KEYS */;
INSERT INTO `activity_collections` VALUES ('770e8400-e29b-41d4-a716-446655440001','test_user_id','550e8400-e29b-41d4-a716-446655440002','2025-12-11 15:45:28'),('f7f4514b-0b19-4f8a-abd1-805abdb51605','test_user_id','550e8400-e29b-41d4-a716-446655440004','2025-12-11 08:01:58');
/*!40000 ALTER TABLE `activity_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_enrollments`
--

DROP TABLE IF EXISTS `activity_enrollments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `activity_enrollments` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `activity_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `major` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `enroll_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `attendance_status` tinyint NOT NULL DEFAULT '1' COMMENT '1:已报名, 2:已取消',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_activity` (`user_id`,`activity_id`),
  KEY `idx_activity_id` (`activity_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `activity_enrollments_ibfk_1` FOREIGN KEY (`activity_id`) REFERENCES `activities` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_enrollments`
--

LOCK TABLES `activity_enrollments` WRITE;
/*!40000 ALTER TABLE `activity_enrollments` DISABLE KEYS */;
INSERT INTO `activity_enrollments` VALUES ('01b85563-cd97-4ba4-a5b0-405f19710c01','test_user_id','550e8400-e29b-41d4-a716-446655440008','测试用户','2025123456','软件工程',NULL,'2025-12-11 08:06:27',2,'2025-12-11 08:06:27','2025-12-11 08:06:33'),('0cdf0714-d576-43ee-a8da-10c2789e86d4','test_user_id','550e8400-e29b-41d4-a716-446655440004','测试用户','2025123456','软件工程',NULL,'2025-12-11 08:01:52',1,'2025-12-11 08:01:52','2025-12-11 08:01:52'),('660e8400-e29b-41d4-a716-446655440001','test_user_id','550e8400-e29b-41d4-a716-446655440001','测试用户','2025123456','软件工程','13800000000','2025-12-11 15:45:28',1,'2025-12-11 15:45:28','2025-12-11 15:45:28'),('ee1530f0-a333-4865-9b53-eaf18e7e6e3b','test_user_id','550e8400-e29b-41d4-a716-446655440003','测试用户','2025123456','软件工程',NULL,'2025-12-11 07:58:11',1,'2025-12-11 07:58:11','2025-12-11 07:58:11'),('f31d8f6a-f559-439a-b915-9f2ecfdfb8c3','test_user_id','550e8400-e29b-41d4-a716-446655440007','测试用户','2025123456','软件工程','13800000000','2025-12-11 07:52:41',2,'2025-12-11 07:52:41','2025-12-11 07:58:02');
/*!40000 ALTER TABLE `activity_enrollments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_conversations`
--

DROP TABLE IF EXISTS `ai_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_conversations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '关联用户ID',
  `title` varchar(128) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '会话标题',
  `model` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '使用的模型（取自配置）',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_conv_user` (`user_id`,`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_conversations`
--

LOCK TABLES `ai_conversations` WRITE;
/*!40000 ALTER TABLE `ai_conversations` DISABLE KEYS */;
INSERT INTO `ai_conversations` VALUES (1,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:31:06','2025-12-11 11:31:06'),(2,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:36:34','2025-12-11 11:36:34'),(3,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:36:49','2025-12-11 11:36:49'),(4,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:39:47','2025-12-11 11:39:47'),(5,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:50:38','2025-12-11 11:50:38'),(6,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 11:54:28','2025-12-11 11:54:28'),(7,'test_user_id','你好','deepseek-ai/DeepSeek-OCR','2025-12-11 14:20:56','2025-12-11 14:20:56'),(8,'test_user_id','你好','tencent/Hunyuan-MT-7B','2025-12-11 14:30:59','2025-12-11 14:30:59');
/*!40000 ALTER TABLE `ai_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_messages`
--

DROP TABLE IF EXISTS `ai_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint unsigned NOT NULL,
  `role` enum('system','user','assistant') COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokens` int unsigned DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ai_msg_conv_created` (`conversation_id`,`created_at`),
  CONSTRAINT `fk_ai_msg_conv` FOREIGN KEY (`conversation_id`) REFERENCES `ai_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_messages`
--

LOCK TABLES `ai_messages` WRITE;
/*!40000 ALTER TABLE `ai_messages` DISABLE KEYS */;
INSERT INTO `ai_messages` VALUES (1,1,'user','你好',NULL,'2025-12-11 11:31:06'),(2,1,'assistant','，请问您有问题吗？我可以帮忙解答吗？',11,'2025-12-11 11:31:09'),(3,2,'user','你好',NULL,'2025-12-11 11:36:34'),(4,2,'assistant','，你好！请问您需要什么帮助？',9,'2025-12-11 11:36:36'),(5,3,'user','你好',NULL,'2025-12-11 11:36:49'),(6,3,'assistant','你好！请问您有什么可以帮您的吗？',10,'2025-12-11 11:36:49'),(7,4,'user','你好',NULL,'2025-12-11 11:39:47'),(8,4,'assistant','！很抱歉，我是一个人工智能助手，目前无法回答您的问题。如果您有任何其他问题，我会尽力回答。',23,'2025-12-11 11:39:48'),(9,4,'user','A',NULL,'2025-12-11 11:46:11'),(10,4,'assistant',' study on the efficacy of mindfulness and acceptance based interventions for depression among college students: A systematic review\n\nThe efficacy of mindfulness and acceptance based interventions for depression among college students: A systematic review\n\nIntroduction: Depression is a common mental health problem among college students, and there is a need for effective interventions to help them cope with this problem. Mindfulness and acceptance-based interventions have been suggested as promising interventions for depression, but there is a lack of systematic reviews to evaluate their efficacy. This study aims to conduct a systematic review to evaluate the effectiveness of mindfulness and acceptance-based interventions for depression among college students.\n\nMethods: This systematic review followed PRISMA guidelines. Relevant studies published between 2010 and 2020 were identified through a systematic search of electronic databases. Studies were included if they were randomized controlled trials or cluster-randomized controlled trials that evaluated the efficacy of mindfulness or acceptance-based interventions for depression among college students.\n\nResults: A total of 12 studies were included in the review. The results of the review suggest that mindfulness-based interventions may be more effective than other interventions, such as cognitive-behavioral therapy or medication. However, there is limited evidence to suggest that acceptance-based interventions are more effective than mindfulness-based interventions.\n\nConclusion: The results of this systematic review suggest that mindfulness-based interventions may be more effective than other interventions for depression among college students. However, there is limited evidence to suggest that acceptance-based interventions are more effective than mindfulness-based interventions. Further research is needed to evaluate the effectiveness of these interventions and to identify the factors that may influence their efficacy.',311,'2025-12-11 11:46:13'),(11,4,'user','Hello',NULL,'2025-12-11 11:46:28'),(12,4,'assistant','! How can I help you today?',8,'2025-12-11 11:46:29'),(13,4,'user','我是鸭子',NULL,'2025-12-11 11:46:42'),(14,4,'assistant','\n\n2024-04-19 07:01:50\n\n我是鸭子2024-04-19 07:01:50 \n\n### 推荐\n\n- 3月28日笑话大全幽默笑话大全2024-04-19 07:01:50\n- 3月28日冷笑话2024-04-19 07:01:50\n- 3月28日搞笑笑话大全2024-04-19 07:01:50\n- 3月28日最新幽默笑话2024-04-19 07:01:50\n- 3月28日搞笑幽默笑话大全2024-04-19 07:01:50',144,'2025-12-11 11:46:43'),(15,4,'user','我刚才说我是什么',NULL,'2025-12-11 11:46:51'),(16,4,'assistant','是好事还是好事是好事又是好事是好事是好事是好事是好事是好事还是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事是好事',512,'2025-12-11 11:46:55'),(17,5,'user','你好',NULL,'2025-12-11 11:50:38'),(18,5,'assistant','你好！有什么我可以帮助你的吗？',8,'2025-12-11 11:50:38'),(19,5,'user','你好啊',NULL,'2025-12-11 11:50:49'),(20,5,'user','111',NULL,'2025-12-11 11:51:01'),(21,5,'user','hello',NULL,'2025-12-11 11:54:08'),(22,5,'assistant','111hello111hello111 hello111hello111hello111 hello111hello111hello111hello111 hello111hello111hello111 hello111hello111hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello111 hello',512,'2025-12-11 11:54:13'),(23,6,'user','你好',NULL,'2025-12-11 11:54:28'),(24,6,'assistant','！请问你是哪里人？',6,'2025-12-11 11:54:29'),(25,6,'user','你好啊',NULL,'2025-12-11 11:54:40'),(26,6,'assistant','，很高兴认识你！请问你是哪里人？请问你是哪里人？我是来自哪里！请问你是哪里人？我是来自哪里！我是哪里的人呢？希望我的回答能对你有所帮助。',40,'2025-12-11 11:54:41'),(27,6,'user','我是一个北京人',NULL,'2025-12-11 11:54:59'),(28,6,'assistant','我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京人我是一个北京',512,'2025-12-11 11:55:02'),(29,7,'user','你好',NULL,'2025-12-11 14:20:56'),(30,7,'assistant','！当然，我可以回答关于校园AI的信息，但我需要先确保您提供的答案是最准确和最相关的。如果您有任何特定的问题或需要帮助解决，请随时告诉我，我会尽力提供帮助。',40,'2025-12-11 14:20:57'),(31,7,'user','Hello',NULL,'2025-12-11 14:21:06'),(32,7,'assistant',', how can I assist you today?',8,'2025-12-11 14:21:06'),(33,7,'user','你是谁',NULL,'2025-12-11 14:21:19'),(34,7,'assistant','，我可以为您提供帮助？',6,'2025-12-11 14:21:20'),(35,7,'user','我是一个小狗',NULL,'2025-12-11 14:21:32'),(36,7,'assistant','，正在帮助您解决数学问题。你能告诉我这道题的要求是什么吗？',16,'2025-12-11 14:21:33'),(37,7,'user','你好啊',NULL,'2025-12-11 14:21:40'),(38,7,'assistant','，我很高兴能够帮助你解决这个问题。请告诉我这道题的要求是什么？',15,'2025-12-11 14:21:40'),(39,8,'user','你好',NULL,'2025-12-11 14:30:59'),(40,8,'assistant','你好！我是你的校园 AI 助手，有什么可以帮助你的吗？',15,'2025-12-11 14:31:00'),(41,8,'user','你好啊',NULL,'2025-12-11 14:31:09'),(42,8,'assistant','你好！我是你的校园 AI 助手，有什么可以帮助你的吗？',15,'2025-12-11 14:31:10'),(43,8,'user','我是一个苹果',NULL,'2025-12-11 14:31:17'),(44,8,'assistant','你好！我是你的校园 AI 助手，看起来你可能有些困惑。不过，我可以帮你解答一些问题或者提供一些信息。如果你有关于校园生活、学习或者其他方面的问题，请随时告诉我，我会尽力帮助你。',48,'2025-12-11 14:31:18'),(45,8,'user','我刚才说我是什么',NULL,'2025-12-11 14:31:28'),(46,8,'assistant','你刚才说你是一个苹果？这可能是一个有趣的比喻或者玩笑。实际上，你是一个人类用户，正在与我的校园 AI 助手对话。如果你有任何问题或需要帮助，请随时告诉我。',42,'2025-12-11 14:31:29');
/*!40000 ALTER TABLE `ai_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ai_usage_daily`
--

DROP TABLE IF EXISTS `ai_usage_daily`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ai_usage_daily` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date` date NOT NULL,
  `prompt_tokens` int unsigned NOT NULL DEFAULT '0',
  `completion_tokens` int unsigned NOT NULL DEFAULT '0',
  `total_tokens` int unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_ai_usage_user_date` (`user_id`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ai_usage_daily`
--

LOCK TABLES `ai_usage_daily` WRITE;
/*!40000 ALTER TABLE `ai_usage_daily` DISABLE KEYS */;
/*!40000 ALTER TABLE `ai_usage_daily` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_boards`
--

DROP TABLE IF EXISTS `bbs_boards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_boards` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '板块名称',
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '图标',
  `description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '板块描述',
  `board_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'static' COMMENT '板块类型: static, dynamic',
  `sort_order` int NOT NULL DEFAULT '0' COMMENT '排序序号',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_board_type` (`board_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_boards`
--

LOCK TABLES `bbs_boards` WRITE;
/*!40000 ALTER TABLE `bbs_boards` DISABLE KEYS */;
INSERT INTO `bbs_boards` VALUES ('board_1','校园热议','fire','校园热点话题讨论','static',1,'2025-12-11 07:45:22','2025-12-11 07:45:22'),('board_2','学习交流','book','学习方法、课程讨论','static',2,'2025-12-11 07:45:22','2025-12-11 07:45:22'),('board_3','生活分享','coffee','校园生活、美食、趣事','static',3,'2025-12-11 07:45:22','2025-12-11 07:45:22'),('board_4','求助问答','question','提问和解答','static',4,'2025-12-11 07:45:22','2025-12-11 07:45:22'),('board_5','二手市场','shopping-cart','闲置物品交易','static',5,'2025-12-11 07:45:22','2025-12-11 07:45:22');
/*!40000 ALTER TABLE `bbs_boards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_comment_likes`
--

DROP TABLE IF EXISTS `bbs_comment_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_comment_likes` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `comment_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_comment_user` (`comment_id`,`user_id`),
  KEY `idx_comment_id` (`comment_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `bbs_comment_likes_ibfk_1` FOREIGN KEY (`comment_id`) REFERENCES `bbs_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_comment_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_comment_likes`
--

LOCK TABLES `bbs_comment_likes` WRITE;
/*!40000 ALTER TABLE `bbs_comment_likes` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbs_comment_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_comments`
--

DROP TABLE IF EXISTS `bbs_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_comments` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子ID',
  `author_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论者ID',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '评论内容',
  `parent_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '父评论ID（用于二级评论）',
  `reply_to_user_id` varchar(36) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '回复的用户ID',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_created_at` (`created_at`),
  KEY `reply_to_user_id` (`reply_to_user_id`),
  CONSTRAINT `bbs_comments_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `bbs_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_comments_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_comments_ibfk_3` FOREIGN KEY (`parent_id`) REFERENCES `bbs_comments` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_comments_ibfk_4` FOREIGN KEY (`reply_to_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_comments`
--

LOCK TABLES `bbs_comments` WRITE;
/*!40000 ALTER TABLE `bbs_comments` DISABLE KEYS */;
INSERT INTO `bbs_comments` VALUES ('comment_1','post_1','user_2','可以试试早点去，或者在图书馆公众号上预约',NULL,NULL,5,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('comment_2','post_1','user_3','我一般去五楼，那边人相对少一些',NULL,NULL,3,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('comment_3','post_2','test_user_id','在哪个位置？我也想去试试！',NULL,NULL,2,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('e591d3ec-02fc-48f2-8672-fa39706d1a21','post_3','test_user_id','111',NULL,NULL,0,'2025-12-11 08:43:16','2025-12-11 08:43:16'),('e73060b9-5738-4362-a2ed-e53f1a7a8a70','post_1','test_user_id','11',NULL,NULL,0,'2025-12-11 08:16:33','2025-12-11 08:16:33'),('fd8606ab-62ff-4528-805c-467a5b52f15d','post_3','test_user_id','asd',NULL,NULL,0,'2025-12-11 08:25:44','2025-12-11 08:25:44');
/*!40000 ALTER TABLE `bbs_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_post_collections`
--

DROP TABLE IF EXISTS `bbs_post_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_post_collections` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `collected_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_user_collection` (`post_id`,`user_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `bbs_post_collections_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `bbs_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_post_collections_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_post_collections`
--

LOCK TABLES `bbs_post_collections` WRITE;
/*!40000 ALTER TABLE `bbs_post_collections` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbs_post_collections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_post_likes`
--

DROP TABLE IF EXISTS `bbs_post_likes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_post_likes` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `post_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_post_user` (`post_id`,`user_id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  CONSTRAINT `bbs_post_likes_ibfk_1` FOREIGN KEY (`post_id`) REFERENCES `bbs_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_post_likes_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_post_likes`
--

LOCK TABLES `bbs_post_likes` WRITE;
/*!40000 ALTER TABLE `bbs_post_likes` DISABLE KEYS */;
INSERT INTO `bbs_post_likes` VALUES ('2a2c4e95-ee8b-43c2-aa9e-4c9ab8bb1504','post_2','test_user_id','2025-12-11 08:38:59'),('6bbcbd9a-d915-497b-87b0-ed9376b049b1','post_1','test_user_id','2025-12-11 08:38:55');
/*!40000 ALTER TABLE `bbs_post_likes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_posts`
--

DROP TABLE IF EXISTS `bbs_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_posts` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子标题',
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '帖子内容',
  `board_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '所属板块ID',
  `author_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '作者ID',
  `tags` json DEFAULT NULL COMMENT '标签数组',
  `cover_image_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '封面图片URL',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'approved' COMMENT '状态: approved, pending, rejected, hidden',
  `view_count` int NOT NULL DEFAULT '0' COMMENT '浏览数',
  `like_count` int NOT NULL DEFAULT '0' COMMENT '点赞数',
  `comment_count` int NOT NULL DEFAULT '0' COMMENT '评论数',
  `report_count` int NOT NULL DEFAULT '0' COMMENT '举报数',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_replied_at` datetime DEFAULT NULL COMMENT '最后回复时间',
  PRIMARY KEY (`id`),
  KEY `idx_board_id` (`board_id`),
  KEY `idx_author_id` (`author_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_last_replied_at` (`last_replied_at`),
  CONSTRAINT `bbs_posts_ibfk_1` FOREIGN KEY (`board_id`) REFERENCES `bbs_boards` (`id`) ON DELETE CASCADE,
  CONSTRAINT `bbs_posts_ibfk_2` FOREIGN KEY (`author_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_posts`
--

LOCK TABLES `bbs_posts` WRITE;
/*!40000 ALTER TABLE `bbs_posts` DISABLE KEYS */;
INSERT INTO `bbs_posts` VALUES ('1c7dab33-8b02-44be-9748-daa5893c3c90','Fff','Add','board_5','test_user_id','[]',NULL,'approved',1,0,0,0,'2025-12-11 08:10:12','2025-12-11 08:10:12',NULL),('7cad0981-fae2-455c-9cca-0570b79f12ea','Sad ','Add ','board_2','test_user_id','[]',NULL,'approved',1,0,0,0,'2025-12-11 08:09:36','2025-12-11 08:09:36',NULL),('f38839c4-ba11-452a-9f30-e39fbc703ffc','Sdgsdg','Olio','board_5','test_user_id','[]',NULL,'approved',5,0,0,0,'2025-12-11 08:14:41','2025-12-11 09:47:06',NULL),('post_1','今天图书馆的自习座位好难抢啊','每次想去图书馆自习都抢不到座位，大家有什么好的方法吗？','board_1','test_user_id','[\"图书馆\", \"自习\"]',NULL,'approved',136,16,9,0,'2025-12-11 15:45:33','2025-12-11 08:42:57','2025-12-11 08:16:33'),('post_2','推荐一家学校附近的美食店','在学校西门发现了一家超好吃的川菜馆，价格实惠，味道正宗！','board_3','user_2','[\"美食\", \"推荐\"]',NULL,'approved',97,24,12,0,'2025-12-11 15:45:33','2025-12-11 08:43:01',NULL),('post_3','数据结构课程求组队','下周要做数据结构的课程设计，有没有同学一起组队的？','board_2','user_3','[\"学习\", \"组队\"]',NULL,'approved',66,8,7,0,'2025-12-11 15:45:33','2025-12-11 08:43:16','2025-12-11 08:43:16');
/*!40000 ALTER TABLE `bbs_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bbs_reports`
--

DROP TABLE IF EXISTS `bbs_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bbs_reports` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报者ID',
  `target_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报目标类型: post, comment',
  `target_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报目标ID',
  `reason` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '举报原因: ad, politics, abuse, other',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '详细描述',
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending' COMMENT '状态: pending, resolved, rejected',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_target` (`target_type`,`target_id`),
  KEY `idx_status` (`status`),
  CONSTRAINT `bbs_reports_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bbs_reports`
--

LOCK TABLES `bbs_reports` WRITE;
/*!40000 ALTER TABLE `bbs_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `bbs_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `public_courses`
--

DROP TABLE IF EXISTS `public_courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `public_courses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程名称',
  `teacher_name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '教师姓名',
  `teacher_id` bigint DEFAULT NULL COMMENT '教师ID（可选）',
  `location` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '上课地点',
  `day_of_week` tinyint NOT NULL COMMENT '星期几（1-7）',
  `start_section` tinyint NOT NULL COMMENT '开始节次（1-12）',
  `end_section` tinyint NOT NULL COMMENT '结束节次（1-12）',
  `weeks_range` json DEFAULT NULL COMMENT '上课周次范围，如 [1,2,3,4,5]',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'compulsory' COMMENT '课程类型: compulsory(必修), elective(选修)',
  `credits` tinyint NOT NULL DEFAULT '2' COMMENT '学分',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '课程描述',
  `semester_id` int NOT NULL COMMENT '所属学期ID',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_semester_id` (`semester_id`),
  KEY `idx_teacher_name` (`teacher_name`),
  KEY `idx_course_name` (`course_name`),
  CONSTRAINT `public_courses_ibfk_1` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `public_courses`
--

LOCK TABLES `public_courses` WRITE;
/*!40000 ALTER TABLE `public_courses` DISABLE KEYS */;
INSERT INTO `public_courses` VALUES (1,'高等数学','李老师',NULL,'一教-101',1,1,2,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]','compulsory',4,'基础数学课程',1,'2025-12-11 07:45:22','2025-12-11 07:45:22'),(2,'大学英语','王老师',NULL,'二教-203',2,3,4,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]','compulsory',3,'英语听说读写',1,'2025-12-11 07:45:22','2025-12-11 07:45:22'),(3,'数据结构','张老师',NULL,'计算机楼-305',3,5,6,'[3, 4, 5, 6, 7, 8, 9, 10, 11, 12]','compulsory',3,'核心专业课',1,'2025-12-11 07:45:22','2025-12-11 07:45:22'),(4,'高等数学','张教授',NULL,'教学楼A101',1,1,2,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]','compulsory',4,NULL,1,'2025-12-11 15:45:33','2025-12-11 15:45:33'),(5,'大学英语','李教授',NULL,'教学楼B202',2,3,4,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]','compulsory',3,NULL,1,'2025-12-11 15:45:33','2025-12-11 15:45:33'),(6,'数据结构','王教授',NULL,'实验楼C301',3,5,6,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]','compulsory',4,NULL,1,'2025-12-11 15:45:33','2025-12-11 15:45:33'),(7,'计算机网络','赵教授',NULL,'教学楼A203',4,1,2,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]','compulsory',3,NULL,1,'2025-12-11 15:45:33','2025-12-11 15:45:33'),(8,'web开发技术','刘教授',NULL,'实验楼C401',5,7,8,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]','elective',2,NULL,1,'2025-12-11 15:45:33','2025-12-11 15:45:33');
/*!40000 ALTER TABLE `public_courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semesters`
--

DROP TABLE IF EXISTS `semesters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `semesters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学期名称，如"2024-2025学年 第一学期"',
  `start_date` date NOT NULL COMMENT '学期开始日期',
  `end_date` date NOT NULL COMMENT '学期结束日期',
  `is_current` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否为当前学期',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_is_current` (`is_current`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semesters`
--

LOCK TABLES `semesters` WRITE;
/*!40000 ALTER TABLE `semesters` DISABLE KEYS */;
INSERT INTO `semesters` VALUES (1,'2024-2025学年 第一学期','2024-09-01','2025-01-15',1,'2025-12-11 07:45:22','2025-12-11 07:45:22'),(2,'2024-2025学年 第二学期','2025-02-15','2025-07-01',0,'2025-12-11 07:45:22','2025-12-11 07:45:22');
/*!40000 ALTER TABLE `semesters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_schedule`
--

DROP TABLE IF EXISTS `user_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_schedule` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '用户ID',
  `source_id` bigint DEFAULT NULL COMMENT '来源公共课程ID（如果是从公共课程添加）',
  `semester_id` int NOT NULL COMMENT '所属学期ID',
  `course_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '课程名称',
  `teacher_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '教师姓名',
  `location` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '上课地点',
  `day_of_week` tinyint NOT NULL COMMENT '星期几（1-7）',
  `start_section` tinyint NOT NULL COMMENT '开始节次（1-12）',
  `end_section` tinyint NOT NULL COMMENT '结束节次（1-12）',
  `weeks_range` json DEFAULT NULL COMMENT '上课周次范围，如 [1,2,3,4,5]',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '课程类型: compulsory, elective',
  `credits` tinyint DEFAULT NULL COMMENT '学分',
  `description` text COLLATE utf8mb4_unicode_ci COMMENT '备注',
  `color_hex` varchar(7) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '#5E81F4' COMMENT '颜色（用于客户端显示）',
  `is_custom` tinyint(1) NOT NULL DEFAULT '0' COMMENT '是否为自定义课程',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_semester_id` (`semester_id`),
  KEY `idx_source_id` (`source_id`),
  CONSTRAINT `user_schedule_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_schedule_ibfk_2` FOREIGN KEY (`semester_id`) REFERENCES `semesters` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_schedule_ibfk_3` FOREIGN KEY (`source_id`) REFERENCES `public_courses` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_schedule`
--

LOCK TABLES `user_schedule` WRITE;
/*!40000 ALTER TABLE `user_schedule` DISABLE KEYS */;
INSERT INTO `user_schedule` VALUES (1,'test_user_id',1,1,'高等数学','李老师','一教-101',1,1,2,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]','compulsory',4,'基础数学课程','#5E81F4',0,'2025-12-11 15:48:35','2025-12-11 15:48:35'),(2,'test_user_id',2,1,'大学英语','王老师','二教-203',2,3,4,'[1, 2, 3, 4, 5, 6, 7, 8, 9, 10]','compulsory',3,'英语听说读写','#FF8C42',0,'2025-12-11 15:48:35','2025-12-11 15:48:35'),(3,'test_user_id',3,1,'数据结构','张老师','计算机楼-305',3,5,6,'[3, 4, 5, 6, 7, 8, 9, 10, 11, 12]','compulsory',3,'核心专业课','#2ECC71',0,'2025-12-11 15:48:35','2025-12-11 15:48:35');
/*!40000 ALTER TABLE `user_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_tokens`
--

DROP TABLE IF EXISTS `user_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_tokens` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_token` (`token`),
  KEY `idx_expires_at` (`expires_at`),
  CONSTRAINT `user_tokens_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_tokens`
--

LOCK TABLES `user_tokens` WRITE;
/*!40000 ALTER TABLE `user_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` varchar(36) COLLATE utf8mb4_unicode_ci NOT NULL,
  `student_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学号',
  `name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '姓名',
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '密码哈希',
  `avatar_url` varchar(512) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '头像URL',
  `role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'student' COMMENT '角色: student, admin',
  `college` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '学院',
  `major` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '专业',
  `grade` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '年级',
  `class_name` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '班级',
  `bio` text COLLATE utf8mb4_unicode_ci COMMENT '个人简介',
  `phone` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '手机号',
  `email` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '邮箱',
  `wechat_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT '微信号',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `student_id` (`student_id`),
  KEY `idx_student_id` (`student_id`),
  KEY `idx_role` (`role`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('admin_1','9999999','管理员','admin123',NULL,'admin','管理部门','系统管理',NULL,NULL,NULL,'13900139000',NULL,NULL,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('test_user_id','2021001','张三','123456',NULL,'student','计算机学院','软件工程',NULL,NULL,NULL,'13800138000',NULL,NULL,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('user_2','2021002','李四','123456',NULL,'student','计算机学院','计算机科学与技术',NULL,NULL,NULL,'13800138001',NULL,NULL,'2025-12-11 15:45:33','2025-12-11 15:45:33'),('user_3','2021003','王五','123456',NULL,'student','信息学院','信息管理',NULL,NULL,NULL,'13800138002',NULL,NULL,'2025-12-11 15:45:33','2025-12-11 15:45:33');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-12-11 22:32:30
