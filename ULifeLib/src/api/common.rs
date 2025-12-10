use prost::Message;

use crate::ApiClient;
use crate::error::Result;
use crate::pb::storage::{UploadFileResponse, UploadResult};

#[uniffi::export]
impl ApiClient {
    /// 下载文件
    #[uniffi::method(default(is_cached = true))]
    pub async fn download_file(&self, url: String, is_cached: bool) -> Result<Vec<u8>> {
        if is_cached && let Some(cached_data) = self.cache.get(&url).await? {
            return Ok(cached_data);
        }

        let response = self.client.get(&url).send().await?;
        if !response.status().is_success() {
            return Err(crate::error::Error::HttpError(response.status()));
        }

        let data = response.bytes().await?.to_vec();

        self.cache
            .insert(url.clone(), data.clone(), crate::CacheOptions::default())
            .await?;

        Ok(data)
    }

    pub async fn upload_file(&self, data: Vec<u8>, filename: String) -> Result<UploadResult> {
        let filename_cloned = filename.clone();
        let file_type = filename_cloned.rsplit('.').next().unwrap_or("unknown");
        let req = self
            .build_auth_request(reqwest::Method::POST, "storage/upload")?
            .multipart(
                reqwest::multipart::Form::new()
                    .part(
                        "file",
                        reqwest::multipart::Part::bytes(data).file_name(filename),
                    )
                    .part(
                        "file_type",
                        reqwest::multipart::Part::text(file_type.to_string()),
                    ),
            );

        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let upload_resp = UploadFileResponse::decode(body_bytes.as_ref())?;
        upload_resp
            .data
            .ok_or(crate::error::Error::ResponseDataMissing)
    }
}
