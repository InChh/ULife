use crate::{ApiClient, CacheOptions, error::Result};

#[uniffi::export]
impl ApiClient {
    /// 获取全校课程列表
    pub async fn list_courses(&self) -> Result<()> {
        if let Some(_hit) = self.cache.get(&"courses".into()).await? {
            // return cached courses
            todo!()
        } else {
            let method = reqwest::Method::GET;
            let resp = self.send(self.build_request(method, "courses")).await?;

            self.cache.insert("courses".into(), resp.bytes().await?.to_vec(), CacheOptions {
                ttl: Some(std::time::Duration::from_secs(120)),
            }).await?;

            todo!()
        }
    }

    /// 获取用户课程表项
    pub async fn list_schedule_items(&self, semester_id: String, week: Option<u64>) -> Result<()> {
        let method = reqwest::Method::GET;
        let mut query = vec![("semester_id", semester_id)];
        if let Some(week) = week {
            query.push(("week", week.to_string()));
        }
        let resp = self
            .send(self.build_auth_request(method, "schedule")?.query(&query))
            .await?;
        todo!()
    }

    /// 新增课程表项（全校课程或个人自定义日程）
    pub async fn add_schedule_item(&self) -> Result<()> {
        let method = reqwest::Method::POST;
        let resp = self
            .send(self.build_auth_request(method, "schedule")?)
            .await?;

        todo!()
    }

    /// 更新课程表项
    pub async fn update_schedule_item(&self) -> Result<()> {
        let method = reqwest::Method::PATCH;
        let resp = self
            .send(self.build_auth_request(method, "schedule")?)
            .await?;
        todo!()
    }

    /// 删除课程表项
    pub async fn delete_schedule_item(&self) -> Result<()> {
        let method = reqwest::Method::DELETE;
        let resp = self
            .send(self.build_auth_request(method, "schedule")?)
            .await?;
        todo!()
    }

    /// 获取学期列表
    pub async fn list_semesters(&self) -> Result<()> {
        let method = reqwest::Method::GET;
        let resp = self.send(self.build_request(method, "semesters")).await?;
        todo!()
    }
}
