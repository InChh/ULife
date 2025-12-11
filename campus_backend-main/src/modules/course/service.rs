use crate::common::error::AppError;
use crate::modules::course::entity::*;
use sqlx::MySqlPool;

pub struct CourseService;

impl CourseService {
    /// 获取学期列表
    pub async fn get_semesters(pool: &MySqlPool) -> Result<Vec<Semester>, AppError> {
        let semesters = sqlx::query_as::<_, Semester>(
            "SELECT id, name, start_date, end_date, is_current FROM semesters ORDER BY start_date DESC"
        )
        .fetch_all(pool)
        .await?;
        
        Ok(semesters)
    }
    
    /// 获取公共课程列表
    pub async fn get_public_courses(
        pool: &MySqlPool,
        query: GetPublicCoursesQuery,
    ) -> Result<(Vec<PublicCourse>, Pagination), AppError> {
        let offset = (query.page - 1) * query.page_size;
        
        let mut where_clauses = Vec::new();
        let mut params: Vec<String> = Vec::new();
        
        if let Some(semester_id) = query.semester_id {
            where_clauses.push("semester_id = ?");
            params.push(semester_id.to_string());
        }
        
        if let Some(name) = &query.name {
            where_clauses.push("course_name LIKE CONCAT('%', ?, '%')");
            params.push(name.clone());
        }
        
        if let Some(teacher) = &query.teacher {
            where_clauses.push("teacher_name LIKE CONCAT('%', ?, '%')");
            params.push(teacher.clone());
        }
        
        let where_clause = if where_clauses.is_empty() {
            String::new()
        } else {
            format!("WHERE {}", where_clauses.join(" AND "))
        };
        
        // 获取总数
        let count_query = format!("SELECT COUNT(*) FROM public_courses {}", where_clause);
        let mut count_builder = sqlx::query_scalar::<_, i64>(&count_query);
        for param in &params {
            count_builder = count_builder.bind(param);
        }
        let total = count_builder.fetch_one(pool).await?;
        
        // 获取列表 - 将 JSON 类型的 weeks_range 转为字符串
        let list_query = format!(
            "SELECT id, course_name, teacher_name, teacher_id, location, 
                    day_of_week, start_section, end_section,
                    CAST(weeks_range AS CHAR) as weeks_range,
                    type AS course_type, credits, description, semester_id
             FROM public_courses {} ORDER BY day_of_week, start_section LIMIT ? OFFSET ?",
            where_clause
        );
        let mut list_builder = sqlx::query_as::<_, PublicCourse>(&list_query);
        for param in &params {
            list_builder = list_builder.bind(param);
        }
        list_builder = list_builder.bind(query.page_size).bind(offset);
        
        let courses = list_builder.fetch_all(pool).await?;
        
        let pagination = Pagination {
            total,
            page: query.page,
            page_size: query.page_size,
            pages: ((total as f64) / (query.page_size as f64)).ceil() as i32,
        };
        
        Ok((courses, pagination))
    }

    /// 获取用户课表
    pub async fn get_user_schedule(
        pool: &MySqlPool,
        user_id: &str,
        query: GetScheduleQuery,
    ) -> Result<Vec<ScheduleItem>, AppError> {
        // 如果指定了周次，筛选该周的课程
        // 添加 CAST 将 JSON 转为字符串
        let sql_with_cast = format!(
            "SELECT id, source_id, user_id, semester_id, course_name, teacher_name, location,
                    day_of_week, start_section, end_section,
                    CAST(weeks_range AS CHAR) as weeks_range,
                    type AS course_type, credits, description, color_hex, is_custom, created_at
             FROM user_schedule WHERE user_id = ? AND semester_id = ?"
        );
        
        let items = if let Some(week) = query.week {
            let sql_with_week = format!("{} AND JSON_CONTAINS(weeks_range, ?)", sql_with_cast);
            sqlx::query_as::<_, ScheduleItem>(&sql_with_week)
                .bind(user_id)
                .bind(query.semester_id)
                .bind(week.to_string())
                .fetch_all(pool)
                .await?
        } else {
            sqlx::query_as::<_, ScheduleItem>(&sql_with_cast)
                .bind(user_id)
                .bind(query.semester_id)
                .fetch_all(pool)
                .await?
        };
        
        Ok(items)
    }
    
    /// 新增课表项（批量）
    pub async fn add_schedule_items(
        pool: &MySqlPool,
        user_id: &str,
        req: AddScheduleItemsRequest,
    ) -> Result<AddScheduleItemsResponse, AppError> {
        let mut successful_items = Vec::new();
        let mut failed_items = Vec::new();
        
        for item in req.items {
            match Self::add_single_schedule_item(pool, user_id, item.clone()).await {
                Ok(schedule_item) => successful_items.push(schedule_item),
                Err(e) => failed_items.push(FailedItem {
                    course_name: item.course_name,
                    error_message: e.to_string(),
                }),
            }
        }
        
        Ok(AddScheduleItemsResponse {
            successful_items,
            failed_items,
        })
    }
    
    /// 新增单个课表项
    async fn add_single_schedule_item(
        pool: &MySqlPool,
        user_id: &str,
        item: AddScheduleItemRequest,
    ) -> Result<ScheduleItem, AppError> {
        // 检查时间冲突
        let weeks_json = serde_json::to_string(&item.weeks)
            .map_err(|e| AppError::Validation(format!("Invalid weeks format: {}", e)))?;
        
        // 简单的冲突检查（相同学期、星期、时间段有重叠）
        let conflicts: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM user_schedule 
             WHERE user_id = ? 
             AND semester_id = ? 
             AND day_of_week = ?
             AND NOT (end_section < ? OR start_section > ?)"
        )
        .bind(user_id)
        .bind(item.semester_id)
        .bind(item.day_of_week)
        .bind(item.start_section)
        .bind(item.end_section)
        .fetch_one(pool)
        .await?;
        
        if conflicts > 0 {
            return Err(AppError::Conflict("Time conflict with existing course".to_string()));
        }
        
        // 插入课表项
        let result = sqlx::query(
            "INSERT INTO user_schedule (user_id, source_id, semester_id, course_name, teacher_name, location, 
             day_of_week, start_section, end_section, weeks_range, type, credits, description, color_hex, is_custom)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
        )
        .bind(user_id)
        .bind(item.source_id)
        .bind(item.semester_id)
        .bind(&item.course_name)
        .bind(&item.teacher_name)
        .bind(&item.location)
        .bind(item.day_of_week)
        .bind(item.start_section)
        .bind(item.end_section)
        .bind(&weeks_json)
        .bind(&item.course_type)
        .bind(item.credits)
        .bind(&item.description)
        .bind(&item.color_hex)
        .bind(item.is_custom)
        .execute(pool)
        .await?;
        
        let item_id = result.last_insert_id() as i64;
        
        // 获取刚插入的课表项
        let schedule_item = sqlx::query_as::<_, ScheduleItem>(
            "SELECT id, source_id, user_id, semester_id, course_name, teacher_name, location,
                    day_of_week, start_section, end_section,
                    CAST(weeks_range AS CHAR) as weeks_range,
                    type AS course_type, credits, description, color_hex, is_custom, created_at
             FROM user_schedule WHERE id = ?"
        )
        .bind(item_id)
        .fetch_one(pool)
        .await?;
        
        Ok(schedule_item)
    }

    /// 删除课表项
    pub async fn delete_schedule_item(
        pool: &MySqlPool,
        user_id: &str,
        item_id: i64,
    ) -> Result<(), AppError> {
        let result = sqlx::query(
            "DELETE FROM user_schedule WHERE id = ? AND user_id = ?"
        )
        .bind(item_id)
        .bind(user_id)
        .execute(pool)
        .await?;
        
        if result.rows_affected() == 0 {
            return Err(AppError::NotFound("Schedule item not found".to_string()));
        }
        
        Ok(())
    }
    
    /// 更新课表项
    pub async fn update_schedule_item(
        pool: &MySqlPool,
        user_id: &str,
        item_id: i64,
        req: UpdateScheduleItemRequest,
    ) -> Result<ScheduleItem, AppError> {
        // 检查课表项是否属于该用户
        let exists: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM user_schedule WHERE id = ? AND user_id = ?"
        )
        .bind(item_id)
        .bind(user_id)
        .fetch_one(pool)
        .await?;
        
        if exists == 0 {
            return Err(AppError::NotFound("Schedule item not found".to_string()));
        }
        
        let mut updates = Vec::new();
        let mut params: Vec<String> = Vec::new();
        
        if let Some(course_name) = req.course_name {
            updates.push("course_name = ?");
            params.push(course_name);
        }
        if let Some(teacher_name) = req.teacher_name {
            updates.push("teacher_name = ?");
            params.push(teacher_name);
        }
        if let Some(location) = req.location {
            updates.push("location = ?");
            params.push(location);
        }
        if let Some(color_hex) = req.color_hex {
            updates.push("color_hex = ?");
            params.push(color_hex);
        }
        if let Some(description) = req.description {
            updates.push("description = ?");
            params.push(description);
        }
        
        // 处理数值类型字段
        if let Some(day_of_week) = req.day_of_week {
            updates.push("day_of_week = ?");
            params.push(day_of_week.to_string());
        }
        if let Some(start_section) = req.start_section {
            updates.push("start_section = ?");
            params.push(start_section.to_string());
        }
        if let Some(end_section) = req.end_section {
            updates.push("end_section = ?");
            params.push(end_section.to_string());
        }
        if let Some(credits) = req.credits {
            updates.push("credits = ?");
            params.push(credits.to_string());
        }
        
        if let Some(weeks) = req.weeks {
            let weeks_json = serde_json::to_string(&weeks)
                .map_err(|e| AppError::Validation(format!("Invalid weeks format: {}", e)))?;
            updates.push("weeks_range = ?");
            params.push(weeks_json);
        }
        
        if updates.is_empty() {
            // 没有要更新的字段，直接返回
            let item = sqlx::query_as::<_, ScheduleItem>(
                "SELECT id, source_id, user_id, semester_id, course_name, teacher_name, location,
                        day_of_week, start_section, end_section,
                        CAST(weeks_range AS CHAR) as weeks_range,
                        type AS course_type, credits, description, color_hex, is_custom, created_at
                 FROM user_schedule WHERE id = ?"
            )
            .bind(item_id)
            .fetch_one(pool)
            .await?;
            return Ok(item);
        }
        
        let query = format!("UPDATE user_schedule SET {} WHERE id = ? AND user_id = ?", updates.join(", "));
        let mut query_builder = sqlx::query(&query);
        for param in params {
            query_builder = query_builder.bind(param);
        }
        query_builder = query_builder.bind(item_id).bind(user_id);
        
        query_builder.execute(pool).await?;
        
        // 返回更新后的课表项
        let item = sqlx::query_as::<_, ScheduleItem>(
            "SELECT id, source_id, user_id, semester_id, course_name, teacher_name, location,
                    day_of_week, start_section, end_section,
                    CAST(weeks_range AS CHAR) as weeks_range,
                    type AS course_type, credits, description, color_hex, is_custom, created_at
             FROM user_schedule WHERE id = ?"
        )
        .bind(item_id)
        .fetch_one(pool)
        .await?;
        
        Ok(item)
    }
}
