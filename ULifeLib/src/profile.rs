use crate::{ApiClient, error::Result};

#[derive(uniffi::Record, ::prost::Message)]
pub struct CurrentUser {
    #[prost(string, tag = "1")]
    pub token: String,
    #[prost(string, tag = "2")]
    pub user: String,
}

#[uniffi::export]
impl ApiClient {
    pub async fn login(&self, student_id: String, password: String) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self.send(self.build_request(method, "auth/login")).await?;

        todo!()
    }

    pub async fn logout(&self) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self.send(self.build_auth_request(method, "auth/logout")?).await?;
        todo!()
    }

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
        let resp = self.send(self.build_request(method, "auth/register")).await?;
        todo!()
    }

    pub async fn get_current_user_profile(&self) -> Result<()> {
        let method = reqwest::Method::GET;
        let resp = self
            .send(self.build_auth_request(method, "users/me")?)
            .await?;

        todo!()
    }

    pub async fn update_current_user_profile(&self) -> Result<()> {
        let method = reqwest::Method::PUT;
        let resp = self
            .send(self.build_auth_request(method, "users/me")?)
            .await?;

        todo!()
    }

    pub async fn change_password(&self, old_password: String, new_password: String) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self
            .send(self.build_auth_request(method, "auth/change-password")?)
            .await?;

        todo!()
    }
}
