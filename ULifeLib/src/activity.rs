use crate::{ApiClient, error::Result};

#[derive(uniffi::Record, serde::Serialize)]
pub struct ListActivitiesRequest {
    pub page: u64,
    pub page_size: u64,
    pub keyword: Option<String>,
    pub activity_type: Option<u8>,
}

#[uniffi::export]
impl ApiClient {
    /// 获取活动列表
    pub async fn list_activities(&self, query_params: ListActivitiesRequest) -> Result<()> {
        let req = self
            .build_request(reqwest::Method::GET, "/activities")
            .query(&query_params);
        let resp = self.send(req).await?;

        todo!()
    }

    /// 获取活动详情
    pub async fn get_activity_details(&self, activity_id: u64) -> Result<()> {
        let req = self.build_request(
            reqwest::Method::GET,
            &format!("/activities/{}", activity_id),
        );
        let resp = self.send(req).await?;
        todo!()
    }

    /// 报名参加活动
    pub async fn enroll_activity(
        &self,
        activity_id: u64,
        username: String,
        student_id: String,
        major: String,
    ) -> Result<()> {
        let req = self.build_request(
            reqwest::Method::POST,
            &format!("/activities/{}/enroll", activity_id),
        );
        let resp = self.send(req).await?;
        todo!()
    }

    /// 取消报名活动
    pub async fn unroll_activity(&self, activity_id: u64) -> Result<()> {
        let req = self.build_request(
            reqwest::Method::DELETE,
            &format!("/activities/{}/enroll", activity_id),
        );
        let resp = self.send(req).await?;
        todo!()
    }

    /// 收藏活动
    pub async fn favorite_activity(&self, activity_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("/activities/{}/collect", activity_id),
        )?;
        let resp = self.send(req).await?;
        todo!()
    }

    pub async fn unfavorite_activity(&self, activity_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::DELETE,
            &format!("/activities/{}/collect", activity_id),
        )?;
        let resp = self.send(req).await?;
        todo!()
    }

    pub async fn list_my_activities(&self) -> Result<()> {
        let req = self.build_auth_request(reqwest::Method::GET, "/my/activities")?;
        let resp = self.send(req).await?;
        todo!()
    }
}
