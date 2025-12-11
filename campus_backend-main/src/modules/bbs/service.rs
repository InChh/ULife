use crate::common::error::AppError;
use crate::modules::bbs::entity::*;
use sqlx::{MySqlPool, Row};
use uuid::Uuid;
use chrono::NaiveDateTime;

pub struct BbsService;

impl BbsService {
    /// 获取板块列表
    pub async fn get_boards(pool: &MySqlPool) -> Result<Vec<Board>, AppError> {
        let boards = sqlx::query_as::<_, Board>(
            "SELECT id, name, icon, description, board_type FROM bbs_boards ORDER BY id"
        )
        .fetch_all(pool)
        .await?;
        
        Ok(boards)
    }
    
    /// 创建帖子
    pub async fn create_post(
        pool: &MySqlPool,
        user_id: &str,
        req: CreatePostRequest,
    ) -> Result<PostDetail, AppError> {
        let post_id = Uuid::new_v4().to_string();
        
        // 将 tags 转换为 JSON 字符串
        let tags_json = serde_json::to_string(&req.tags).unwrap_or_else(|_| "[]".to_string());
        
        // 插入帖子
        sqlx::query(
            "INSERT INTO bbs_posts (id, title, content, board_id, author_id, tags, status)
             VALUES (?, ?, ?, ?, ?, ?, 'approved')"
        )
        .bind(&post_id)
        .bind(&req.title)
        .bind(&req.content)
        .bind(&req.board_id)
        .bind(user_id)
        .bind(&tags_json)
        .execute(pool)
        .await?;
        
        // 获取帖子详情
        Self::get_post_detail(pool, &post_id, Some(user_id)).await
    }
    
    /// 获取帖子列表
    pub async fn get_posts(
        pool: &MySqlPool,
        query: GetPostsQuery,
        user_id: Option<&str>,
    ) -> Result<(Vec<PostListItem>, Pagination), AppError> {
        let offset = (query.page - 1) * query.page_size;
        
        // 构建查询条件
        let mut where_clauses = vec!["p.status IN ('approved', 'pending')"];
        let mut params: Vec<String> = Vec::new();
        
        if let Some(board_id) = &query.board_id {
            where_clauses.push("p.board_id = ?");
            params.push(board_id.clone());
        }
        
        if let Some(keyword) = &query.keyword {
            where_clauses.push("(p.title LIKE CONCAT('%', ?, '%') OR p.content LIKE CONCAT('%', ?, '%'))");
            params.push(keyword.clone());
            params.push(keyword.clone());
        }
        
        let where_clause = where_clauses.join(" AND ");
        
        // 排序
        let order_by = match query.sort.as_deref() {
            Some("hot") => "p.like_count DESC, p.comment_count DESC",
            Some("new") => "p.created_at DESC",
            _ => "p.last_replied_at DESC, p.created_at DESC", // latest (默认)
        };
        
        // 查询总数
        let count_query = format!(
            "SELECT COUNT(*) FROM bbs_posts p WHERE {}",
            where_clause
        );
        let mut count_builder = sqlx::query_scalar::<_, i64>(&count_query);
        for param in &params {
            count_builder = count_builder.bind(param);
        }
        let total = count_builder.fetch_one(pool).await?;
        
        // 查询列表 - 将 JSON 类型的 tags 转为字符串
        let list_query = format!(
            "SELECT p.id, p.title, p.content, p.board_id, p.author_id, 
                    CAST(p.tags AS CHAR) as tags, p.cover_image_url,
                    p.view_count, p.like_count, p.comment_count, p.created_at,
                    b.name as board_name,
                    u.id as user_id, u.student_id, u.name as user_name, u.avatar_url, u.college
             FROM bbs_posts p
             LEFT JOIN bbs_boards b ON p.board_id = b.id
             LEFT JOIN users u ON p.author_id = u.id
             WHERE {}
             ORDER BY {}
             LIMIT ? OFFSET ?",
            where_clause, order_by
        );
        
        let mut list_builder = sqlx::query(&list_query);
        for param in &params {
            list_builder = list_builder.bind(param);
        }
        list_builder = list_builder.bind(query.page_size).bind(offset);
        
        let rows = list_builder.fetch_all(pool).await?;
        
        let mut items = Vec::new();
        for row in rows {
            let post_id: String = row.try_get("id")?;
            let title: String = row.try_get("title")?;
            let content: String = row.try_get("content")?;
            let board_id: String = row.try_get("board_id")?;
            let board_name: String = row.try_get("board_name")?;
            let created_at: NaiveDateTime = row.try_get("created_at")?;
            let tags_json: Option<String> = row.try_get("tags")?;
            let cover_image_url: Option<String> = row.try_get("cover_image_url")?;
            let view_count: i32 = row.try_get("view_count")?;
            let like_count: i32 = row.try_get("like_count")?;
            let comment_count: i32 = row.try_get("comment_count")?;
            
            // 解析 tags
            let tags: Vec<String> = tags_json
                .and_then(|t| serde_json::from_str(&t).ok())
                .unwrap_or_default();
            
            // 构建用户信息
            let author = UserLite {
                id: row.try_get("user_id")?,
                student_id: row.try_get("student_id")?,
                name: row.try_get("user_name")?,
                avatar_url: row.try_get("avatar_url").unwrap_or_else(|_| String::new()),
                college: row.try_get("college")?,
            };
            
            // 检查用户交互
            let (is_liked, is_collected) = if let Some(uid) = user_id {
                let liked = Self::check_user_liked_post(pool, uid, &post_id).await?;
                let collected = Self::check_user_collected_post(pool, uid, &post_id).await?;
                (liked, collected)
            } else {
                (false, false)
            };
            
            // 生成摘要（前50个字符，UTF-8安全）
            let summary = {
                let chars: Vec<char> = content.chars().collect();
                if chars.len() > 50 {
                    let truncated: String = chars.iter().take(50).collect();
                    Some(format!("{}...", truncated))
                } else {
                    Some(content.clone())
                }
            };
            
            items.push(PostListItem {
                id: post_id,
                title,
                author,
                board_id,
                board_name,
                created_at: format!("{}Z", created_at.format("%Y-%m-%dT%H:%M:%S")),
                tags,
                cover_image_url,
                summary,
                stats: Stats {
                    view_count,
                    like_count,
                    comment_count,
                },
                user_interaction: UserInteraction {
                    is_liked,
                    is_collected,
                },
            });
        }
        
        let pagination = Pagination {
            total,
            page: query.page,
            page_size: query.page_size,
            pages: ((total as f64) / (query.page_size as f64)).ceil() as i32,
        };
        
        Ok((items, pagination))
    }
    
    /// 获取帖子详情
    pub async fn get_post_detail(
        pool: &MySqlPool,
        post_id: &str,
        user_id: Option<&str>,
    ) -> Result<PostDetail, AppError> {
        let row = sqlx::query(
            "SELECT p.id, p.title, p.content, p.board_id, p.author_id, p.cover_image_url,
                    p.status, p.view_count, p.like_count, p.comment_count, p.report_count,
                    p.created_at, p.last_replied_at,
                    CAST(p.tags AS CHAR) as tags,
                    b.name as board_name,
                    u.id as user_id, u.student_id, u.name as user_name, u.avatar_url, u.college
             FROM bbs_posts p
             LEFT JOIN bbs_boards b ON p.board_id = b.id
             LEFT JOIN users u ON p.author_id = u.id
             WHERE p.id = ?"
        )
        .bind(post_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("Post not found".to_string()))?;
        
        // 增加浏览量
        sqlx::query("UPDATE bbs_posts SET view_count = view_count + 1 WHERE id = ?")
            .bind(post_id)
            .execute(pool)
            .await?;
        
        let title: String = row.try_get("title")?;
        let content: String = row.try_get("content")?;
        let board_id: String = row.try_get("board_id")?;
        let board_name: String = row.try_get("board_name")?;
        let status: String = row.try_get("status")?;
        let report_count: i32 = row.try_get("report_count")?;
        let created_at: NaiveDateTime = row.try_get("created_at")?;
        let last_replied_at: Option<NaiveDateTime> = row.try_get("last_replied_at")?;
        let tags_json: Option<String> = row.try_get("tags")?;
        let view_count: i32 = row.try_get("view_count")?;
        let like_count: i32 = row.try_get("like_count")?;
        let comment_count: i32 = row.try_get("comment_count")?;
        
        let tags: Vec<String> = tags_json
            .and_then(|t| serde_json::from_str(&t).ok())
            .unwrap_or_default();
        
        let author = UserLite {
            id: row.try_get("user_id")?,
            student_id: row.try_get("student_id")?,
            name: row.try_get("user_name")?,
            avatar_url: row.try_get("avatar_url").unwrap_or_else(|_| String::new()),
            college: row.try_get("college")?,
        };
        
        let (is_liked, is_collected) = if let Some(uid) = user_id {
            let liked = Self::check_user_liked_post(pool, uid, post_id).await?;
            let collected = Self::check_user_collected_post(pool, uid, post_id).await?;
            (liked, collected)
        } else {
            (false, false)
        };
        
        Ok(PostDetail {
            id: post_id.to_string(),
            title,
            content,
            board_id,
            board_name,
            author,
            tags,
            media: vec![], // TODO: 实现媒体附件
            stats: Stats {
                view_count,
                like_count,
                comment_count,
            },
            user_interaction: UserInteraction {
                is_liked,
                is_collected,
            },
            status,
            report_count,
            created_at: format!("{}Z", created_at.format("%Y-%m-%dT%H:%M:%S")),
            last_replied_at: last_replied_at.map(|dt| format!("{}Z", dt.format("%Y-%m-%dT%H:%M:%S"))),
        })
    }
    
    /// 删除帖子
    pub async fn delete_post(
        pool: &MySqlPool,
        post_id: &str,
        user_id: &str,
    ) -> Result<(), AppError> {
        // 检查权限（是否是作者或管理员）
        let post: (String, String) = sqlx::query_as(
            "SELECT id, author_id FROM bbs_posts WHERE id = ?"
        )
        .bind(post_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("Post not found".to_string()))?;
        
        if post.1 != user_id {
            // TODO: 检查是否是管理员
            return Err(AppError::Unauthorized("Not authorized".to_string()));
        }
        
        // 删除帖子（软删除）
        sqlx::query("UPDATE bbs_posts SET status = 'hidden' WHERE id = ?")
            .bind(post_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }
    
    /// 点赞/取消点赞帖子
    pub async fn like_post(
        pool: &MySqlPool,
        post_id: &str,
        user_id: &str,
        action: &str,
    ) -> Result<LikeResponse, AppError> {
        let is_like = action == "like";
        
        if is_like {
            // 检查是否已点赞
            let exists: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM bbs_post_likes WHERE post_id = ? AND user_id = ?"
            )
            .bind(post_id)
            .bind(user_id)
            .fetch_one(pool)
            .await?;
            
            if exists == 0 {
                // 添加点赞记录
                let id = Uuid::new_v4().to_string();
                sqlx::query("INSERT INTO bbs_post_likes (id, post_id, user_id) VALUES (?, ?, ?)")
                    .bind(&id)
                    .bind(post_id)
                    .bind(user_id)
                    .execute(pool)
                    .await?;
                
                // 增加点赞数
                sqlx::query("UPDATE bbs_posts SET like_count = like_count + 1 WHERE id = ?")
                    .bind(post_id)
                    .execute(pool)
                    .await?;
            }
        } else {
            // 删除点赞记录
            sqlx::query("DELETE FROM bbs_post_likes WHERE post_id = ? AND user_id = ?")
                .bind(post_id)
                .bind(user_id)
                .execute(pool)
                .await?;
            
            // 减少点赞数
            sqlx::query("UPDATE bbs_posts SET like_count = GREATEST(0, like_count - 1) WHERE id = ?")
                .bind(post_id)
                .execute(pool)
                .await?;
        }
        
        // 获取最新的点赞数
        let like_count: i32 = sqlx::query_scalar(
            "SELECT like_count FROM bbs_posts WHERE id = ?"
        )
        .bind(post_id)
        .fetch_one(pool)
        .await?;
        
        Ok(LikeResponse {
            current_like_count: like_count,
            is_liked: is_like,
        })
    }
    
    /// 收藏/取消收藏帖子
    pub async fn collect_post(
        pool: &MySqlPool,
        post_id: &str,
        user_id: &str,
        action: &str,
    ) -> Result<CollectResponse, AppError> {
        let is_collect = action == "collect";
        
        if is_collect {
            // 检查是否已收藏
            let exists: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM bbs_post_collections WHERE post_id = ? AND user_id = ?"
            )
            .bind(post_id)
            .bind(user_id)
            .fetch_one(pool)
            .await?;
            
            if exists == 0 {
                let id = Uuid::new_v4().to_string();
                sqlx::query("INSERT INTO bbs_post_collections (id, post_id, user_id) VALUES (?, ?, ?)")
                    .bind(&id)
                    .bind(post_id)
                    .bind(user_id)
                    .execute(pool)
                    .await?;
            }
        } else {
            sqlx::query("DELETE FROM bbs_post_collections WHERE post_id = ? AND user_id = ?")
                .bind(post_id)
                .bind(user_id)
                .execute(pool)
                .await?;
        }
        
        Ok(CollectResponse {
            is_collected: is_collect,
        })
    }
    
    /// 创建评论
    pub async fn create_comment(
        pool: &MySqlPool,
        post_id: &str,
        user_id: &str,
        req: CreateCommentRequest,
    ) -> Result<CreateCommentResponse, AppError> {
        let comment_id = Uuid::new_v4().to_string();
        
        // 获取 parent_id 和 reply_to_user_id
        let (parent_id, reply_to_user_id) = if let Some(reply_to_id) = &req.reply_to_comment_id {
            // 获取被回复的评论信息
            let comment: (Option<String>, String) = sqlx::query_as(
                "SELECT parent_id, author_id FROM bbs_comments WHERE id = ?"
            )
            .bind(reply_to_id)
            .fetch_optional(pool)
            .await?
            .ok_or_else(|| AppError::NotFound("Comment not found".to_string()))?;
            
            // 如果被回复的评论有 parent_id，说明是二级回复，使用其 parent_id
            // 否则，被回复的评论就是父评论
            let parent = comment.0.unwrap_or_else(|| reply_to_id.clone());
            (Some(parent), Some(comment.1))
        } else {
            (None, None)
        };
        
        // 插入评论
        sqlx::query(
            "INSERT INTO bbs_comments (id, post_id, author_id, content, parent_id, reply_to_user_id)
             VALUES (?, ?, ?, ?, ?, ?)"
        )
        .bind(&comment_id)
        .bind(post_id)
        .bind(user_id)
        .bind(&req.content)
        .bind(&parent_id)
        .bind(&reply_to_user_id)
        .execute(pool)
        .await?;
        
        // 更新帖子的评论数和最后回复时间
        sqlx::query("UPDATE bbs_posts SET comment_count = comment_count + 1, last_replied_at = NOW() WHERE id = ?")
            .bind(post_id)
            .execute(pool)
            .await?;
        
        // 获取评论详情
        let comment_detail = Self::get_comment_detail(pool, &comment_id, Some(user_id)).await?;
        
        Ok(CreateCommentResponse {
            comment_id,
            comment: comment_detail,
        })
    }
    
    /// 获取评论列表
    pub async fn get_comments(
        pool: &MySqlPool,
        post_id: &str,
        page: i32,
        page_size: i32,
        user_id: Option<&str>,
    ) -> Result<(Vec<CommentDetail>, Pagination), AppError> {
        let offset = (page - 1) * page_size;
        
        // 获取总数
        let total: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM bbs_comments WHERE post_id = ?"
        )
        .bind(post_id)
        .fetch_one(pool)
        .await?;
        
        // 获取评论列表
        let comments = sqlx::query_as::<_, Comment>(
            "SELECT * FROM bbs_comments WHERE post_id = ? ORDER BY created_at ASC LIMIT ? OFFSET ?"
        )
        .bind(post_id)
        .bind(page_size)
        .bind(offset)
        .fetch_all(pool)
        .await?;
        
        let mut details = Vec::new();
        for comment in comments {
            let detail = Self::get_comment_detail(pool, &comment.id, user_id).await?;
            details.push(detail);
        }
        
        let pagination = Pagination {
            total,
            page,
            page_size,
            pages: ((total as f64) / (page_size as f64)).ceil() as i32,
        };
        
        Ok((details, pagination))
    }
    
    /// 获取评论详情
    async fn get_comment_detail(
        pool: &MySqlPool,
        comment_id: &str,
        user_id: Option<&str>,
    ) -> Result<CommentDetail, AppError> {
        let row = sqlx::query(
            "SELECT c.*, u.id as user_id, u.student_id, u.name as user_name, u.avatar_url, u.college
             FROM bbs_comments c
             LEFT JOIN users u ON c.author_id = u.id
             WHERE c.id = ?"
        )
        .bind(comment_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("Comment not found".to_string()))?;
        
        let post_id: String = row.try_get("post_id")?;
        let content: String = row.try_get("content")?;
        let parent_id: Option<String> = row.try_get("parent_id")?;
        let reply_to_user_id: Option<String> = row.try_get("reply_to_user_id")?;
        let like_count: i32 = row.try_get("like_count")?;
        let created_at: NaiveDateTime = row.try_get("created_at")?;
        
        let author = UserLite {
            id: row.try_get("user_id")?,
            student_id: row.try_get("student_id")?,
            name: row.try_get("user_name")?,
            avatar_url: row.try_get("avatar_url").unwrap_or_else(|_| String::new()),
            college: row.try_get("college")?,
        };
        
        // 获取被回复用户信息
        let reply_to = if let Some(reply_to_id) = reply_to_user_id {
            let user: Option<(String, String, String, Option<String>, String)> = sqlx::query_as(
                "SELECT id, student_id, name, avatar_url, college FROM users WHERE id = ?"
            )
            .bind(&reply_to_id)
            .fetch_optional(pool)
            .await?;
            
            user.map(|(id, student_id, name, avatar_url, college)| UserLite {
                id,
                student_id,
                name,
                avatar_url: avatar_url.unwrap_or_default(),
                college,
            })
        } else {
            None
        };
        
        let is_liked = if let Some(uid) = user_id {
            Self::check_user_liked_comment(pool, uid, comment_id).await?
        } else {
            false
        };
        
        Ok(CommentDetail {
            id: comment_id.to_string(),
            post_id,
            author,
            content,
            parent_id,
            reply_to,
            stats: CommentStats { like_count },
            user_interaction: CommentUserInteraction { is_liked },
            created_at: format!("{}Z", created_at.format("%Y-%m-%dT%H:%M:%S")),
        })
    }
    
    /// 删除评论
    pub async fn delete_comment(
        pool: &MySqlPool,
        comment_id: &str,
        user_id: &str,
    ) -> Result<(), AppError> {
        // 检查权限
        let comment: (String, String) = sqlx::query_as(
            "SELECT id, author_id FROM bbs_comments WHERE id = ?"
        )
        .bind(comment_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("Comment not found".to_string()))?;
        
        if comment.1 != user_id {
            // TODO: 检查是否是管理员
            return Err(AppError::Unauthorized("Not authorized".to_string()));
        }
        
        // 删除评论及其所有子评论
        sqlx::query("DELETE FROM bbs_comments WHERE id = ? OR parent_id = ?")
            .bind(comment_id)
            .bind(comment_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }
    
    /// 点赞/取消点赞评论
    pub async fn like_comment(
        pool: &MySqlPool,
        comment_id: &str,
        user_id: &str,
        action: &str,
    ) -> Result<LikeResponse, AppError> {
        let is_like = action == "like";
        
        if is_like {
            let exists: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM bbs_comment_likes WHERE comment_id = ? AND user_id = ?"
            )
            .bind(comment_id)
            .bind(user_id)
            .fetch_one(pool)
            .await?;
            
            if exists == 0 {
                let id = Uuid::new_v4().to_string();
                sqlx::query("INSERT INTO bbs_comment_likes (id, comment_id, user_id) VALUES (?, ?, ?)")
                    .bind(&id)
                    .bind(comment_id)
                    .bind(user_id)
                    .execute(pool)
                    .await?;
                
                sqlx::query("UPDATE bbs_comments SET like_count = like_count + 1 WHERE id = ?")
                    .bind(comment_id)
                    .execute(pool)
                    .await?;
            }
        } else {
            sqlx::query("DELETE FROM bbs_comment_likes WHERE comment_id = ? AND user_id = ?")
                .bind(comment_id)
                .bind(user_id)
                .execute(pool)
                .await?;
            
            sqlx::query("UPDATE bbs_comments SET like_count = GREATEST(0, like_count - 1) WHERE id = ?")
                .bind(comment_id)
                .execute(pool)
                .await?;
        }
        
        let like_count: i32 = sqlx::query_scalar(
            "SELECT like_count FROM bbs_comments WHERE id = ?"
        )
        .bind(comment_id)
        .fetch_one(pool)
        .await?;
        
        Ok(LikeResponse {
            current_like_count: like_count,
            is_liked: is_like,
        })
    }
    
    /// 举报
    pub async fn report(
        pool: &MySqlPool,
        user_id: &str,
        req: ReportRequest,
    ) -> Result<ReportResponse, AppError> {
        // 检查是否已举报
        let exists: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM bbs_reports WHERE user_id = ? AND target_type = ? AND target_id = ?"
        )
        .bind(user_id)
        .bind(&req.target_type)
        .bind(&req.target_id)
        .fetch_one(pool)
        .await?;
        
        if exists > 0 {
            return Err(AppError::Conflict("Already reported".to_string()));
        }
        
        let report_id = Uuid::new_v4().to_string();
        
        sqlx::query(
            "INSERT INTO bbs_reports (id, user_id, target_type, target_id, reason, description, status)
             VALUES (?, ?, ?, ?, ?, ?, 'pending')"
        )
        .bind(&report_id)
        .bind(user_id)
        .bind(&req.target_type)
        .bind(&req.target_id)
        .bind(&req.reason)
        .bind(&req.description)
        .execute(pool)
        .await?;
        
        // 增加被举报次数
        if req.target_type == "post" {
            sqlx::query("UPDATE bbs_posts SET report_count = report_count + 1 WHERE id = ?")
                .bind(&req.target_id)
                .execute(pool)
                .await?;
        }
        
        Ok(ReportResponse { report_id })
    }
    
    // 辅助方法
    
    async fn check_user_liked_post(
        pool: &MySqlPool,
        user_id: &str,
        post_id: &str,
    ) -> Result<bool, AppError> {
        let count: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM bbs_post_likes WHERE user_id = ? AND post_id = ?"
        )
        .bind(user_id)
        .bind(post_id)
        .fetch_one(pool)
        .await?;
        
        Ok(count > 0)
    }
    
    async fn check_user_collected_post(
        pool: &MySqlPool,
        user_id: &str,
        post_id: &str,
    ) -> Result<bool, AppError> {
        let count: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM bbs_post_collections WHERE user_id = ? AND post_id = ?"
        )
        .bind(user_id)
        .bind(post_id)
        .fetch_one(pool)
        .await?;
        
        Ok(count > 0)
    }
    
    async fn check_user_liked_comment(
        pool: &MySqlPool,
        user_id: &str,
        comment_id: &str,
    ) -> Result<bool, AppError> {
        let count: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM bbs_comment_likes WHERE user_id = ? AND comment_id = ?"
        )
        .bind(user_id)
        .bind(comment_id)
        .fetch_one(pool)
        .await?;
        
        Ok(count > 0)
    }
}
