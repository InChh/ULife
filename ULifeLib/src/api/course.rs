use crate::{
    api::ApiClient,
    error::Result,
    pb::{
        self,
        course::{
            AddScheduleItemsData, AddScheduleItemsRequest, GetPublicCoursesRequest, GetPublicCoursesResponse, GetScheduleRequest, GetScheduleResponse, GetSemestersRequest, GetSemestersResponse, PublicCourse, ScheduleItem, Semester, UpdateScheduleItemData, UpdateScheduleItemRequest, UpdateScheduleItemResponse
        },
    },
};


#[uniffi::export(async_runtime = "tokio")]
impl ApiClient {
    /// 获取全校课程列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn get_public_courses(
        &self,
        query_params: GetPublicCoursesRequest,
        is_cached: bool,
    ) -> Result<Vec<PublicCourse>> {
        let cache_key = self.cache_key(format!(
            "courses_{:?}",
            query_params
        ));
        if is_cached && let Some(hit) = self.cache.get(&cache_key).await? {
            let resp: GetPublicCoursesResponse = self.decode_body(hit.as_slice())?;
            let list = resp.data.unwrap_or_default().list;
            Ok(list)
        } else {
            let req = self
                .build_auth_request(reqwest::Method::GET, "courses")?
                .query(&query_params);
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;

            let resp: GetPublicCoursesResponse = self.decode_body(body_bytes.as_ref())?;
            let list = resp.data.unwrap_or_default().list;

            self.cache.insert(cache_key, body_bytes.to_vec());

            Ok(list)
        }
    }

    /// 获取用户课程表项
    #[uniffi::method(default(is_cached = true))]
    pub async fn list_schedule_items(
        &self,
        semester_id: i64,
        week: Option<i32>,
        is_cached: bool,
    ) -> Result<Vec<ScheduleItem>> {
        let cache_key = self.cache_key(format!(
            "schedule_items_{}_{}",
            semester_id,
            week.unwrap_or(0)
        ));
        if is_cached && let Some(hit) = self.cache.get(&cache_key).await? {
            let resp: GetScheduleResponse = self.decode_body(hit.as_slice())?;
            let items = resp.data.unwrap_or_default().items;
            Ok(items)
        } else {
            let param = GetScheduleRequest { semester_id, week };
            let resp = self
                .send(self.prepare_body(
                    self.build_auth_request(reqwest::Method::GET, "schedule")?,
                    &param,
                )?)
                .await?;

            let body_bytes = resp.bytes().await?;
            let resp: GetScheduleResponse = self.decode_body(body_bytes.as_ref())?;
            let items = resp.data.unwrap_or_default().items;
            self.cache.insert(cache_key, body_bytes.to_vec());
            Ok(items)
        }
    }

    /// 新增课程表项（全校课程或个人自定义日程）
    pub async fn add_schedule_item(
        &self,
        input: AddScheduleItemsRequest,
    ) -> Result<AddScheduleItemsData> {
        let resp = self
            .send(self.prepare_body(
                self.build_auth_request(reqwest::Method::POST, "schedule")?,
                &input,
            )?)
            .await?;

        let body_bytes = resp.bytes().await?;
        let resp: pb::course::AddScheduleItemsResponse = self.decode_body(body_bytes.as_ref())?;
        Ok(resp.data.unwrap_or_default())
    }

    /// 更新课程表项
    pub async fn update_schedule_item(
        &self,
        input: UpdateScheduleItemRequest,
    ) -> Result<UpdateScheduleItemData> {
        let resp = self
            .send(self.prepare_body(
                self.build_auth_request(reqwest::Method::PATCH, "schedule")?,
                &input,
            )?)
            .await?;
        let body_bytes = resp.bytes().await?;
        let resp: UpdateScheduleItemResponse = self.decode_body(body_bytes.as_ref())?;
        Ok(resp.data.unwrap_or_default())
    }

    /// 删除课程表项
    pub async fn delete_schedule_item(&self, item_id: i64) -> Result<()> {
        let _resp = self
            .send(
                self.build_auth_request(reqwest::Method::DELETE, "schedule")?
                    .query(&[("item_id", item_id)]),
            )
            .await?;
        Ok(())
    }

    /// 获取学期列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn list_semesters(&self, is_cached: bool) -> Result<Vec<Semester>> {
        let cache_key = self.cache_key("semesters");
        if is_cached && let Some(hit) = self.cache.get(&cache_key).await? {
            let resp: GetSemestersResponse = self.decode_body(hit.as_slice())?;
            let semesters = resp.data.unwrap_or_default().semesters;
            Ok(semesters)
        } else {
            let input = GetSemestersRequest {};
            let req = self.prepare_body(
                self.build_auth_request(reqwest::Method::GET, "semesters")?,
                &input,
            )?;
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;
            let resp: GetSemestersResponse = self.decode_body(body_bytes.as_ref())?;
            let semesters = resp.data.unwrap_or_default().semesters;

            self.cache.insert(cache_key, body_bytes.to_vec());

            Ok(semesters)
        }
    }
}
