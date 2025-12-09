use crate::{ApiClient, error::Result};

#[derive(uniffi::Record, ::prost::Message)]
pub struct CurrentUser {
    #[prost(string, tag = "1")]
    pub token: String,
    #[prost(string, tag = "2")]
    pub user: String,
}

/// 登录请求模型
#[derive(Debug, Clone, uniffi::Record, serde::Serialize)]
struct LoginRequest {
    student_id: String,
    password: String,
}

/// 注册请求模型
#[derive(Debug, Clone, uniffi::Record, serde::Serialize)]
struct RegisterRequest {
    student_id: String,
    password: String,
    name: String,
    college: String,
    major: String,
    grade: String,
    class_name: String,
    email: String,
    phone: String,
}

/// 用户信息更新模型
#[derive(Debug, Clone, uniffi::Record, serde::Serialize)]
struct UserUpdateRequest {
    name: Option<String>,
    avatar: Option<String>,
    bio: Option<String>,
    qq: Option<String>,
    wechat: Option<String>,
    email: Option<String>,
    phone: Option<String>,
}

#[uniffi::export]
impl ApiClient {
    /// 用户登录
    /// 学号+密码登录，返回 Token 和用户信息
    pub async fn login(&self, student_id: String, password: String) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self.send(self.build_request(method, "auth/login")).await?;

        todo!()
    }

    /// 退出登录
    pub async fn logout(&self) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self
            .send(self.build_auth_request(method, "auth/logout")?)
            .await?;
        todo!()
    }

    /// 用户注册
    pub async fn register(
        &self,
        student_id: String,
        password: String,
        name: String,
        college: String,
        major: String,
        phone: String,
    ) -> Result<u64> {
        let method = reqwest::Method::POST;
        let resp = self
            .send(self.build_request(method, "auth/register"))
            .await?;
        todo!()
    }

    /// 获取当前用户信息
    /// 获取登录用户的完整档案和统计数据
    pub async fn get_current_user_profile(&self) -> Result<()> {
        let method = reqwest::Method::GET;
        let resp = self
            .send(self.build_auth_request(method, "users/me")?)
            .await?;

        todo!()
    }

    /// 更新个人资料
    /// 修改头像、简介、联系方式等
    pub async fn update_current_user_profile(&self) -> Result<()> {
        let method = reqwest::Method::PUT;
        let resp = self
            .send(self.build_auth_request(method, "users/me")?)
            .await?;

        todo!()
    }

    /// 修改密码
    /// 已登录用户在知道当前密码的情况下修改密码
    /// 前端检查新密码的合法性：与旧密码不一致，密码非空，密码强度非过弱小
    pub async fn change_password(&self, old_password: String, new_password: String) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self
            .send(self.build_auth_request(method, "auth/change-password")?)
            .await?;

        todo!()
    }
}
