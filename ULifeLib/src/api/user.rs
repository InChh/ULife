use prost::Message;

use crate::{
    api::ApiClient,
    error::{Error, Result},
    pb::{
        self,
        user::{
            ChangePasswordRequest, GetUserInfoRequest, LoginData, LoginRequest, LogoutRequest,
            RegisterData, RegisterRequest, UpdateProfileRequest, User,
        },
    },
};

#[uniffi::export]
impl ApiClient {
    /// 用户登录
    /// 学号+密码登录，返回 Token 和用户信息
    pub async fn login(&self, student_id: String, password: String) -> Result<LoginData> {
        let input = LoginRequest {
            student_id,
            password,
        };
        let req = self
            .build_request(reqwest::Method::POST, "auth/login")
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;

        let body_bytes = resp.bytes().await?;
        let login_resp = pb::user::LoginResponse::decode(body_bytes.as_ref())?;
        login_resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 退出登录
    pub async fn logout(&self) -> Result<()> {
        let method = reqwest::Method::POST;
        let input = LogoutRequest {};
        let _resp = self
            .send(
                self.build_auth_request(method, "auth/logout")?
                    .body(input.encode_to_vec()),
            )
            .await?;
        Ok(())
    }

    /// 用户注册
    pub async fn register(&self, input: RegisterRequest) -> Result<RegisterData> {
        let req = self
            .build_request(reqwest::Method::POST, "auth/register")
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let register_resp = pb::user::RegisterResponse::decode(body_bytes.as_ref())?;
        register_resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 获取当前用户信息
    /// 获取登录用户的完整档案和统计数据
    pub async fn get_user_profile(&self) -> Result<User> {
        let input = GetUserInfoRequest {};
        let resp = self
            .send(
                self.build_auth_request(reqwest::Method::GET, "users/me")?
                    .body(input.encode_to_vec()),
            )
            .await?;
        let body_bytes = resp.bytes().await?;
        let user_resp = pb::user::GetUserInfoResponse::decode(body_bytes.as_ref())?;
        user_resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 更新个人资料
    /// 修改头像、简介、联系方式等
    pub async fn update_user_profile(&self, input: UpdateProfileRequest) -> Result<()> {
        let _resp = self
            .send(
                self.build_auth_request(reqwest::Method::PUT, "users/me")?
                    .body(input.encode_to_vec()),
            )
            .await?;

        Ok(())
    }

    /// 修改密码
    /// 已登录用户在知道当前密码的情况下修改密码
    /// 前端检查新密码的合法性：与旧密码不一致，密码非空，密码强度非过弱小
    pub async fn change_password(&self, old_password: String, new_password: String) -> Result<()> {
        let _resp = self
            .send(
                self.build_auth_request(reqwest::Method::POST, "auth/change-password")?
                    .body(
                        ChangePasswordRequest {
                            old_password,
                            new_password,
                        }
                        .encode_to_vec(),
                    ),
            )
            .await?;

        Ok(())
    }
}
