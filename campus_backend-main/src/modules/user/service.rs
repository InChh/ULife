use crate::common::error::AppError;
use crate::modules::user::entity::*;
use sqlx::MySqlPool;
use uuid::Uuid;

pub struct UserService;

impl UserService {
    /// 用户登录
    pub async fn login(
        pool: &MySqlPool,
        req: LoginRequest,
    ) -> Result<LoginResponse, AppError> {
        // 查询用户
        let user = sqlx::query_as::<_, User>(
            "SELECT * FROM users WHERE student_id = ?"
        )
        .bind(&req.student_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::Unauthorized("Invalid credentials".to_string()))?;
        
        // 验证密码（实际项目中应使用 bcrypt 等哈希算法）
        // 这里简化处理，直接比较
        if user.password_hash != req.password {
            return Err(AppError::Unauthorized("Invalid credentials".to_string()));
        }
        
        // 生成 Token（实际项目中应使用 JWT）
        let token = format!("token_{}", Uuid::new_v4());
        
        // 获取用户统计信息
        let user_info = Self::get_user_info(pool, &user.id).await?;
        
        Ok(LoginResponse {
            token,
            user: user_info,
        })
    }
    
    /// 用户注册
    pub async fn register(
        pool: &MySqlPool,
        req: RegisterRequest,
    ) -> Result<RegisterResponse, AppError> {
        // 检查学号是否已存在
        let existing: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM users WHERE student_id = ?"
        )
        .bind(&req.student_id)
        .fetch_one(pool)
        .await?;
        
        if existing > 0 {
            return Err(AppError::Conflict("Student ID already exists".to_string()));
        }
        
        // 创建用户
        let user_id = Uuid::new_v4().to_string();
        
        sqlx::query(
            "INSERT INTO users (id, student_id, name, password_hash, college, major, phone, role)
             VALUES (?, ?, ?, ?, ?, ?, ?, 'student')"
        )
        .bind(&user_id)
        .bind(&req.student_id)
        .bind(&req.name)
        .bind(&req.password) // 实际应该哈希
        .bind(&req.college)
        .bind(&req.major)
        .bind(&req.phone)
        .execute(pool)
        .await?;
        
        Ok(RegisterResponse { user_id })
    }
    
    /// 获取用户完整信息
    pub async fn get_user_info(
        pool: &MySqlPool,
        user_id: &str,
    ) -> Result<UserInfo, AppError> {
        let user = sqlx::query_as::<_, User>(
            "SELECT * FROM users WHERE id = ?"
        )
        .bind(user_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("User not found".to_string()))?;
        
        // 获取统计信息
        let weekly_course_count = Self::get_weekly_course_count(pool, user_id).await?;
        let forum_activity_score = Self::get_forum_activity_score(pool, user_id).await?;
        let collection_count = Self::get_collection_count(pool, user_id).await?;
        
        Ok(UserInfo {
            id: user.id,
            student_id: user.student_id,
            name: user.name,
            avatar_url: user.avatar_url,
            role: user.role,
            college: user.college,
            major: user.major,
            grade: user.grade,
            class_name: user.class_name,
            bio: user.bio,
            phone: user.phone,
            email: user.email,
            wechat_id: user.wechat_id,
            weekly_course_count,
            forum_activity_score,
            collection_count,
            setting_privacy_course: "all".to_string(), // 默认值
            setting_notification_switch: true, // 默认值
        })
    }

    /// 更新用户资料
    pub async fn update_profile(
        pool: &MySqlPool,
        user_id: &str,
        req: UpdateProfileRequest,
    ) -> Result<(), AppError> {
        let mut updates = Vec::new();
        let mut params: Vec<String> = Vec::new();
        
        if let Some(name) = req.name {
            updates.push("name = ?");
            params.push(name);
        }
        if let Some(avatar_url) = req.avatar_url {
            updates.push("avatar_url = ?");
            params.push(avatar_url);
        }
        if let Some(bio) = req.bio {
            updates.push("bio = ?");
            params.push(bio);
        }
        if let Some(phone) = req.phone {
            updates.push("phone = ?");
            params.push(phone);
        }
        if let Some(email) = req.email {
            updates.push("email = ?");
            params.push(email);
        }
        if let Some(wechat_id) = req.wechat_id {
            updates.push("wechat_id = ?");
            params.push(wechat_id);
        }
        
        if updates.is_empty() {
            return Ok(());
        }
        
        let query = format!("UPDATE users SET {} WHERE id = ?", updates.join(", "));
        let mut query_builder = sqlx::query(&query);
        for param in params {
            query_builder = query_builder.bind(param);
        }
        query_builder = query_builder.bind(user_id);
        
        query_builder.execute(pool).await?;
        Ok(())
    }
    
    /// 修改密码
    pub async fn change_password(
        pool: &MySqlPool,
        user_id: &str,
        req: ChangePasswordRequest,
    ) -> Result<(), AppError> {
        // 获取用户
        let user = sqlx::query_as::<_, User>(
            "SELECT * FROM users WHERE id = ?"
        )
        .bind(user_id)
        .fetch_optional(pool)
        .await?
        .ok_or_else(|| AppError::NotFound("User not found".to_string()))?;
        
        // 验证旧密码
        if user.password_hash != req.old_password {
            return Err(AppError::Validation("Old password is incorrect".to_string()));
        }
        
        // 更新密码
        sqlx::query("UPDATE users SET password_hash = ? WHERE id = ?")
            .bind(&req.new_password) // 实际应该哈希
            .bind(user_id)
            .execute(pool)
            .await?;
        
        Ok(())
    }
    
    /// 删除用户（管理员）
    pub async fn delete_user(
        pool: &MySqlPool,
        user_id: &str,
    ) -> Result<(), AppError> {
        let result = sqlx::query("DELETE FROM users WHERE id = ?")
            .bind(user_id)
            .execute(pool)
            .await?;
        
        if result.rows_affected() == 0 {
            return Err(AppError::NotFound("User not found".to_string()));
        }
        
        Ok(())
    }
    
    // 辅助方法：获取本周课时数
    async fn get_weekly_course_count(
        _pool: &MySqlPool,
        _user_id: &str,
    ) -> Result<i32, AppError> {
        // TODO: 实际应该查询课表数据库
        // 这里返回模拟数据
        Ok(18)
    }
    
    // 辅助方法：获取论坛活跃度
    async fn get_forum_activity_score(
        _pool: &MySqlPool,
        _user_id: &str,
    ) -> Result<i32, AppError> {
        // TODO: 实际应该根据发帖、评论数计算
        // 这里返回模拟数据
        Ok(85)
    }
    
    // 辅助方法：获取收藏数
    async fn get_collection_count(
        pool: &MySqlPool,
        user_id: &str,
    ) -> Result<i32, AppError> {
        let count: i64 = sqlx::query_scalar(
            "SELECT COUNT(*) FROM activity_collections WHERE user_id = ?"
        )
        .bind(user_id)
        .fetch_one(pool)
        .await?;
        
        Ok(count as i32)
    }
}
