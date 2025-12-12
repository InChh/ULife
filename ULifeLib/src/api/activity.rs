use crate::{
    api::ApiClient,
    error::{Error, Result},
    pb::activity::{
        Activity, EnrollActivityRequest, EnrollActivityResponse, GetActivitiesData,
        GetActivitiesRequest, GetActivitiesResponse, GetActivityDetailResponse,
        GetMyActivitiesData, GetMyActivitiesResponse,
    },
};

#[uniffi::export(async_runtime = "tokio")]
impl ApiClient {
    /// 获取活动列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn get_activities(
        &self,
        input: GetActivitiesRequest,
        is_cached: bool,
    ) -> Result<GetActivitiesData> {
        if is_cached
            && let Some(hit) = self
                .cache
                .get(&self.cache_key(format!("activities_{:?}", input)))
                .await?
        {
            let resp: GetActivitiesResponse = self.decode_body(hit.as_slice())?;
            resp.data.ok_or(Error::ResponseDataMissing)
        } else {
            let req = self
                .build_request(reqwest::Method::GET, "/activities")
                .query(&input);
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;
            let resp: GetActivitiesResponse = self.decode_body(body_bytes.as_ref())?;

            self.cache.insert(
                self.cache_key(format!("activities_{:?}", input)),
                body_bytes.to_vec(),
            );

            resp.data.ok_or(Error::ResponseDataMissing)
        }
    }

    /// 获取活动详情
    pub async fn get_activity_details(&self, activity_id: String) -> Result<Activity> {
        let req = self.build_request(
            reqwest::Method::GET,
            &format!("/activities/{}", activity_id),
        );
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp: GetActivityDetailResponse = self.decode_body(body_bytes.as_ref())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 报名参加活动
    pub async fn enroll_activity(&self, input: EnrollActivityRequest) -> Result<()> {
        let req = self.prepare_body(
            self.build_request(
                reqwest::Method::POST,
                &format!("/activities/{}/enroll", input.activity_id),
            ),
            &input,
        )?;
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp: EnrollActivityResponse = self.decode_body(body_bytes.as_ref())?;
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
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("/activities/{}/collect", activity_id),
            )
            .await?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 取消收藏活动
    pub async fn uncollect_activity(&self, activity_id: String) -> Result<()> {
        let req = self
            .build_auth_request(
                reqwest::Method::DELETE,
                &format!("/activities/{}/collect", activity_id),
            )
            .await?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 获取我的活动列表
    pub async fn list_my_activities(&self) -> Result<GetMyActivitiesData> {
        let req = self
            .build_auth_request(reqwest::Method::GET, "/my/activities")
            .await?;
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp: GetMyActivitiesResponse = self.decode_body(body_bytes.as_ref())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }
}
