use prost::Message;

use crate::{
    api::ApiClient,
    error::{Error, Result},
    pb::activity::{
        Activity, EnrollActivityRequest, EnrollActivityResponse, GetActivitiesData, GetActivitiesRequest, GetActivitiesResponse, GetActivityDetailResponse, GetMyActivitiesData, GetMyActivitiesResponse
    },
};

#[uniffi::export]
impl ApiClient {
    /// 获取活动列表
    pub async fn get_activities(&self, input: GetActivitiesRequest) -> Result<GetActivitiesData> {
        let req = self
            .build_request(reqwest::Method::GET, "/activities")
            .query(&input);
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = GetActivitiesResponse::decode(body_bytes.as_ref())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 获取活动详情
    pub async fn get_activity_details(&self, activity_id: String) -> Result<Activity> {
        let req = self.build_request(
            reqwest::Method::GET,
            &format!("/activities/{}", activity_id),
        );
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = GetActivityDetailResponse::decode(body_bytes.as_ref())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 报名参加活动
    pub async fn enroll_activity(&self, input: EnrollActivityRequest) -> Result<()> {
        let req = self
            .build_request(
                reqwest::Method::POST,
                &format!("/activities/{}/enroll", input.activity_id),
            )
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = EnrollActivityResponse::decode(body_bytes.as_ref())?;
        if resp.code != 0 {
            return Err(Error::LogicError(resp.code, resp.message));
        }
        Ok(())
    }

    /// 取消报名活动
    pub async fn unroll_activity(&self, activity_id: String) -> Result<()> {
        let req = self.build_request(
            reqwest::Method::DELETE,
            &format!("/activities/{}/enroll", activity_id),
        );
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 收藏活动
    pub async fn collect_activity(&self, activity_id: String) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("/activities/{}/collect", activity_id),
        )?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 取消收藏活动
    pub async fn uncollect_activity(&self, activity_id: String) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::DELETE,
            &format!("/activities/{}/collect", activity_id),
        )?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 获取我的活动列表
    pub async fn list_my_activities(&self) -> Result<GetMyActivitiesData> {
        let req = self.build_auth_request(reqwest::Method::GET, "/my/activities")?;
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = GetMyActivitiesResponse::decode(body_bytes.as_ref())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }
}
