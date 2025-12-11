use prost::Message;

use crate::{
    CacheOptions,
    api::ApiClient,
    error::Result,
    pb::{
        self,
        course::{
            AddScheduleItemsData, AddScheduleItemsRequest, GetPublicCoursesResponse,
            GetScheduleRequest, GetScheduleResponse, GetSemestersRequest,
            GetSemestersResponse, PublicCourse, ScheduleItem, Semester,
            UpdateScheduleItemData, UpdateScheduleItemRequest, UpdateScheduleItemResponse,
        },
    },
};

#[derive(uniffi::Record, serde::Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ListCoursesRequest {
    #[serde(skip_serializing_if = "Option::is_none")]
    #[serde(rename = "semester_id")]
    pub semester_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub teacher: Option<String>,
    pub page: u64,
    pub page_size: u64,
}

#[uniffi::export]
impl ApiClient {
    /// 获取全校课程列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn list_courses(
        &self,
        query_params: ListCoursesRequest,
        is_cached: bool,
    ) -> Result<Vec<PublicCourse>> {
        if is_cached && let Some(hit) = self.cache.get(&"courses".into()).await? {
            let resp = GetPublicCoursesResponse::decode(hit.as_slice())?;
            let list = resp.data.unwrap_or_default().list;
            Ok(list)
        } else {
            let req = self
                .build_auth_request(reqwest::Method::GET, "courses")?
                .query(&query_params);
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;

            let resp = GetPublicCoursesResponse::decode(body_bytes.clone())?;
            let list = resp.data.unwrap_or_default().list;

            self.cache
                .insert(
                    "courses".into(),
                    body_bytes.to_vec(),
                    CacheOptions {
                        ttl: Some(std::time::Duration::from_hours(24 * 7)),
                    },
                )
                .await?;

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
        if is_cached && let Some(hit) = self.cache.get(&"schedule_items".into()).await? {
            let resp = GetScheduleResponse::decode(hit.as_slice())?;
            let items = resp.data.unwrap_or_default().items;
            Ok(items)
        } else {
            let param = GetScheduleRequest { semester_id, week };
            let resp = self
                .send(
                    self.build_auth_request(reqwest::Method::GET, "schedule")?
                        .body(param.encode_to_vec()),
                )
                .await?;

            let body_bytes = resp.bytes().await?;
            let resp = GetScheduleResponse::decode(body_bytes.clone())?;
            let items = resp.data.unwrap_or_default().items;
            self.cache
                .insert(
                    "schedule_items".into(),
                    body_bytes.to_vec(),
                    CacheOptions {
                        ttl: Some(std::time::Duration::from_hours(24 * 7)),
                    },
                )
                .await?;
            Ok(items)
        }
    }

    /// 新增课程表项（全校课程或个人自定义日程）
    pub async fn add_schedule_item(
        &self,
        input: AddScheduleItemsRequest,
    ) -> Result<AddScheduleItemsData> {
        let resp = self
            .send(
                self.build_auth_request(reqwest::Method::POST, "schedule")?
                    .body(input.encode_to_vec()),
            )
            .await?;

        let body_bytes = resp.bytes().await?;
        let resp = pb::course::AddScheduleItemsResponse::decode(body_bytes)?;
        Ok(resp.data.unwrap_or_default())
    }

    /// 更新课程表项
    pub async fn update_schedule_item(
        &self,
        input: UpdateScheduleItemRequest,
    ) -> Result<UpdateScheduleItemData> {
        let resp = self
            .send(
                self.build_auth_request(reqwest::Method::PATCH, "schedule")?
                    .body(input.encode_to_vec()),
            )
            .await?;
        let body_bytes = resp.bytes().await?;
        let resp = UpdateScheduleItemResponse::decode(body_bytes)?;
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
        if is_cached && let Some(hit) = self.cache.get(&"semesters".into()).await? {
            let resp = GetSemestersResponse::decode(hit.as_slice())?;
            let semesters = resp.data.unwrap_or_default().semesters;
            Ok(semesters)
        } else {
            let input = GetSemestersRequest {};
            let req = self
                .build_auth_request(reqwest::Method::GET, "semesters")?
                .body(input.encode_to_vec());
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;
            let resp = GetSemestersResponse::decode(body_bytes.clone())?;
            let semesters = resp.data.unwrap_or_default().semesters;

            self.cache
                .insert(
                    "semesters".into(),
                    body_bytes.to_vec(),
                    CacheOptions {
                        ttl: Some(std::time::Duration::from_hours(24 * 7)),
                    },
                )
                .await?;

            Ok(semesters)
        }
    }
}
