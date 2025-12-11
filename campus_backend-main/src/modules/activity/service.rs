use crate::common::error::AppError;
use crate::modules::activity::entity::*;
use sqlx::MySqlPool;
use uuid::Uuid;

pub struct ActivityService;

impl ActivityService {
    /// 获取活动列表（支持搜索、筛选、分页）
    pub async fn get_activities_list(
        pool: &MySqlPool,
        keyword: Option<String>,
        activity_type: Option<i8>,
        page: i32,
        page_size: i32,
    ) -> Result<(Vec<ActivityListItem>, Pagination), AppError> {
        let offset = (page - 1) * page_size;
        
        // 构建查询条件
        let mut query = String::from(
            "SELECT id, title, cover_url, location, start_time, quota, current_enrollments 
             FROM activities WHERE status = 1"
        );
        
        let mut count_query = String::from("SELECT COUNT(*) as count FROM activities WHERE status = 1");
        
        if keyword.is_some() {
            query.push_str(" AND (title LIKE CONCAT('%', ?, '%') OR content LIKE CONCAT('%', ?, '%'))");
            count_query.push_str(" AND (title LIKE CONCAT('%', ?, '%') OR content LIKE CONCAT('%', ?, '%'))");
        }
        
        if activity_type.is_some() {
            query.push_str(" AND activity_type = ?");
            count_query.push_str(" AND activity_type = ?");
        }
        
        query.push_str(" ORDER BY start_time DESC LIMIT ? OFFSET ?");
        
        // 获取总数
        let mut count_query_builder = sqlx::query_scalar::<_, i64>(&count_query);
        if let Some(ref kw) = keyword {
            count_query_builder = count_query_builder.bind(kw).bind(kw);
        }
        if let Some(at) = activity_type {
            count_query_builder = count_query_builder.bind(at);
        }
        let total = count_query_builder.fetch_one(pool).await?;
        
        // 获取列表
        let mut query_builder = sqlx::query_as::<_, ActivityListItem>(&query);
        if let Some(ref kw) = keyword {
            query_builder = query_builder.bind(kw).bind(kw);
        }
        if let Some(at) = activity_type {
            query_builder = query_builder.bind(at);
        }
        query_builder = query_builder.bind(page_size).bind(offset);
        
        let items = query_builder.fetch_all(pool).await?;
        
        let pagination = Pagination {
            total,
            page,
            page_size,
            pages: ((total as f64) / (page_size as f64)).ceil() as i32,
        };
        
        Ok((items, pagination))
    }

    /// 获取活动详情
    pub async fn get_activity_detail(
        pool: &MySqlPool,
        activity_id: &str,
        user_id: Option<&str>,
    ) -> Result<ActivityDetail, AppError> {
        let activity = sqlx::query_as::<_, Activity>(
            "SELECT * FROM activities WHERE id = ?"
        )
        .bind(activity_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("Activity not found".to_string()))?;
        
        let mut is_enrolled = false;
        let mut is_collected = false;
        
        if let Some(uid) = user_id {
            // 检查是否已报名
            let enrollment_count: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM activity_enrollments 
                 WHERE user_id = ? AND activity_id = ? AND attendance_status = 1"
            )
            .bind(uid)
            .bind(activity_id)
            .fetch_one(pool)
            .await?;
            is_enrolled = enrollment_count > 0;
            
            // 检查是否已收藏
            let collection_count: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM activity_collections WHERE user_id = ? AND activity_id = ?"
            )
            .bind(uid)
            .bind(activity_id)
            .fetch_one(pool)
            .await?;
            is_collected = collection_count > 0;
        }
        
        Ok(ActivityDetail {
            activity,
            is_enrolled,
            is_collected,
        })
    }

    /// 创建活动
    pub async fn create_activity(
        pool: &MySqlPool,
        req: CreateActivityRequest,
    ) -> Result<Activity, AppError> {
        let id = Uuid::new_v4().to_string();
        
        sqlx::query(
            "INSERT INTO activities (id, title, content, location, organizer, start_time, end_time, activity_type, quota, need_sign_in, status)
             VALUES (?, ?, ?, ?, ?, ?, ?, 1, 100, false, 1)"
        )
        .bind(&id)
        .bind(&req.title)
        .bind(&req.content)
        .bind(&req.location)
        .bind(&req.organizer)
        .bind(&req.start_time)
        .bind(&req.end_time)
        .execute(pool)
        .await?;
        
        let activity = sqlx::query_as::<_, Activity>("SELECT * FROM activities WHERE id = ?")
            .bind(&id)
            .fetch_one(pool)
            .await?;
        
        Ok(activity)
    }

    /// 更新活动
    pub async fn update_activity(
        pool: &MySqlPool,
        activity_id: &str,
        req: PatchActivityRequest,
    ) -> Result<(), AppError> {
        let mut updates = Vec::new();
        let mut params: Vec<String> = Vec::new();
        
        if let Some(title) = req.title {
            updates.push("title = ?");
            params.push(title);
        }
        if let Some(content) = req.content {
            updates.push("content = ?");
            params.push(content);
        }
        if let Some(cover_url) = req.cover_url {
            updates.push("cover_url = ?");
            params.push(cover_url);
        }
        if let Some(location) = req.location {
            updates.push("location = ?");
            params.push(location);
        }
        if let Some(organizer) = req.organizer {
            updates.push("organizer = ?");
            params.push(organizer);
        }
        if let Some(start_time) = req.start_time {
            updates.push("start_time = ?");
            params.push(start_time);
        }
        if let Some(end_time) = req.end_time {
            updates.push("end_time = ?");
            params.push(end_time);
        }
        
        if updates.is_empty() {
            return Ok(());
        }
        
        let query = format!("UPDATE activities SET {} WHERE id = ?", updates.join(", "));
        let mut query_builder = sqlx::query(&query);
        for param in params {
            query_builder = query_builder.bind(param);
        }
        query_builder = query_builder.bind(activity_id);
        
        query_builder.execute(pool).await?;
        Ok(())
    }

    /// 报名活动
    pub async fn enroll_activity(
        pool: &MySqlPool,
        user_id: &str,
        activity_id: &str,
        req: EnrollActivityRequest,
    ) -> Result<(), AppError> {
        // 检查活动是否存在
        let activity: Activity = sqlx::query_as("SELECT * FROM activities WHERE id = ?")
            .bind(activity_id)
            .fetch_optional(pool)
            .await?
            .ok_or_else(|| AppError::NotFound("Activity not found".to_string()))?;
        
        // 检查是否已报名
        let existing_count: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM activity_enrollments WHERE user_id = ? AND activity_id = ? AND attendance_status = 1"
        )
        .bind(user_id)
        .bind(activity_id)
        .fetch_one(pool)
        .await?;
        
        if existing_count > 0 {
            return Err(AppError::Conflict("Already enrolled".to_string()));
        }
        
        // 检查是否已满员
        if activity.current_enrollments >= activity.quota {
            return Err(AppError::Conflict("Activity is full".to_string()));
        }
        
        // 创建报名记录
        let enrollment_id = Uuid::new_v4().to_string();
        sqlx::query(
            "INSERT INTO activity_enrollments (id, user_id, activity_id, user_name, student_id, major, phone_number, attendance_status)
             VALUES (?, ?, ?, ?, ?, ?, ?, 1)"
        )
        .bind(&enrollment_id)
        .bind(user_id)
        .bind(activity_id)
        .bind(&req.user_name)
        .bind(&req.student_id)
        .bind(&req.major)
        .bind(&req.phone_number)
        .execute(pool)
        .await?;
        
        // 更新报名人数
        sqlx::query("UPDATE activities SET current_enrollments = current_enrollments + 1 WHERE id = ?")
            .bind(activity_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }

    /// 取消报名
    pub async fn cancel_enrollment(
        pool: &MySqlPool,
        user_id: &str,
        activity_id: &str,
    ) -> Result<(), AppError> {
        // 检查是否已报名
        let existing: Option<(String,)> = sqlx::query_as(
            "SELECT id FROM activity_enrollments WHERE user_id = ? AND activity_id = ? AND attendance_status = 1"
        )
        .bind(user_id)
        .bind(activity_id)
        .fetch_optional(pool)
        .await?;
        
        if existing.is_none() {
            return Err(AppError::NotFound("Enrollment not found".to_string()));
        }
        
        // 更新报名状态
        sqlx::query("UPDATE activity_enrollments SET attendance_status = 2 WHERE user_id = ? AND activity_id = ?")
            .bind(user_id)
            .bind(activity_id)
            .execute(pool)
            .await?;
        
        // 减少报名人数
        sqlx::query("UPDATE activities SET current_enrollments = current_enrollments - 1 WHERE id = ?")
            .bind(activity_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }

    /// 收藏活动
    pub async fn collect_activity(
        pool: &MySqlPool,
        user_id: &str,
        activity_id: &str,
    ) -> Result<(), AppError> {
        // 检查活动是否存在
        let exists: i64 = sqlx::query_scalar("SELECT COUNT(*) FROM activities WHERE id = ?")
            .bind(activity_id)
            .fetch_one(pool)
            .await?;
        
        if exists == 0 {
            return Err(AppError::NotFound("Activity not found".to_string()));
        }
        
        // 检查是否已收藏
        let already_collected: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM activity_collections WHERE user_id = ? AND activity_id = ?"
        )
        .bind(user_id)
        .bind(activity_id)
        .fetch_one(pool)
        .await?;
        
        if already_collected > 0 {
            return Ok(()); // 已收藏，直接返回成功
        }
        
        // 创建收藏记录
        let id = Uuid::new_v4().to_string();
        sqlx::query("INSERT INTO activity_collections (id, user_id, activity_id) VALUES (?, ?, ?)")
            .bind(&id)
            .bind(user_id)
            .bind(activity_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }

    /// 取消收藏
    pub async fn uncollect_activity(
        pool: &MySqlPool,
        user_id: &str,
        activity_id: &str,
    ) -> Result<(), AppError> {
        sqlx::query("DELETE FROM activity_collections WHERE user_id = ? AND activity_id = ?")
            .bind(user_id)
            .bind(activity_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }

    /// 获取活动报名列表（管理员）
    pub async fn get_enrollments(
        pool: &MySqlPool,
        activity_id: &str,
    ) -> Result<(i32, Vec<EnrollmentRecord>), AppError> {
        let enrollments = sqlx::query_as::<_, EnrollmentRecord>(
            "SELECT user_id, user_name, student_id, major, phone_number, activity_id, enroll_time, attendance_status
             FROM activity_enrollments WHERE activity_id = ? AND attendance_status = 1
             ORDER BY enroll_time DESC"
        )
        .bind(activity_id)
        .fetch_all(pool)
        .await?;
        
        let total = enrollments.len() as i32;
        Ok((total, enrollments))
    }

    /// 获取我的活动（报名和收藏）
    pub async fn get_my_activities(
        pool: &MySqlPool,
        user_id: &str,
        include_enrollments: bool,
        include_collections: bool,
        page: i32,
        page_size: i32,
    ) -> Result<(Option<(Vec<MyEnrollmentItem>, Pagination)>, Option<(Vec<MyCollectionItem>, Pagination)>), AppError> {
        let mut enrolled_data = None;
        let mut collected_data = None;
        
        if include_enrollments {
            let offset = (page - 1) * page_size;
            
            let total: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM activity_enrollments e 
                 INNER JOIN activities a ON e.activity_id = a.id 
                 WHERE e.user_id = ? AND e.attendance_status = 1"
            )
            .bind(user_id)
            .fetch_one(pool)
            .await?;
            
            let items = sqlx::query_as::<_, MyEnrollmentItem>(
                "SELECT a.id as activity_id, a.title, a.cover_url, a.start_time, a.end_time, e.attendance_status as my_status
                 FROM activity_enrollments e
                 INNER JOIN activities a ON e.activity_id = a.id
                 WHERE e.user_id = ?
                 ORDER BY e.enroll_time DESC
                 LIMIT ? OFFSET ?"
            )
            .bind(user_id)
            .bind(page_size)
            .bind(offset)
            .fetch_all(pool)
            .await?;
            
            enrolled_data = Some((items, Pagination {
                total,
                page,
                page_size,
                pages: ((total as f64) / (page_size as f64)).ceil() as i32,
            }));
        }
        
        if include_collections {
            let offset = (page - 1) * page_size;
            
            let total: i64 = sqlx::query_scalar(
                "SELECT COUNT(*) FROM activity_collections c 
                 INNER JOIN activities a ON c.activity_id = a.id 
                 WHERE c.user_id = ?"
            )
            .bind(user_id)
            .fetch_one(pool)
            .await?;
            
            let items = sqlx::query_as::<_, MyCollectionItem>(
                "SELECT a.id as activity_id, a.title, a.cover_url, a.start_time, a.end_time
                 FROM activity_collections c
                 INNER JOIN activities a ON c.activity_id = a.id
                 WHERE c.user_id = ?
                 ORDER BY c.collected_at DESC
                 LIMIT ? OFFSET ?"
            )
            .bind(user_id)
            .bind(page_size)
            .bind(offset)
            .fetch_all(pool)
            .await?;
            
            collected_data = Some((items, Pagination {
                total,
                page,
                page_size,
                pages: ((total as f64) / (page_size as f64)).ceil() as i32,
            }));
        }
        
        Ok((enrolled_data, collected_data))
    }
}

