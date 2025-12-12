use reqwest::RequestBuilder;
use std::time::Duration;

use crate::{HybridCache, fs::FsHandle};
use crate::{HybridCacheConfig, PERSISTENCE_MANAGER};

pub mod activity;
pub mod common;
pub mod course;
pub mod forum;
pub mod user;

use crate::error::{Error, Result};

#[derive(uniffi::Object)]
pub struct ApiClient {
    client: reqwest::Client,
    base_url: String,
    cache: HybridCache<String, Vec<u8>>,
}

#[uniffi::export]
impl ApiClient {
    #[uniffi::constructor]
    pub fn new(
        base_url: String,
        cache_folder: String,
        cache_size: u64,
        fs: FsHandle,
    ) -> Result<Self> {
        let client = reqwest::Client::builder()
            .user_agent("ULife.ios/1.0")
            .build()?;
        let cache_dir = std::path::PathBuf::from(cache_folder).join("api_cache");
        let cache = HybridCache::new(HybridCacheConfig {
            disk_dir: cache_dir,
            memory_capacity: cache_size,
            default_ttl: Some(Duration::from_hours(24)),
            memory_time_to_idle: Some(Duration::from_secs(60)),
            fs,
        })?;
        Ok(ApiClient {
            client,
            base_url,
            cache,
        })
    }
}

impl ApiClient {
    /// 构建请求
    fn build_request(&self, method: reqwest::Method, path: &str) -> RequestBuilder {
        let url = format!(
            "{}/{}",
            self.base_url.trim_end_matches('/'),
            path.trim_start_matches('/')
        );
        self.client.request(method, url)
    }

    /// 构建需要认证的请求
    fn build_auth_request(&self, method: reqwest::Method, path: &str) -> Result<RequestBuilder> {
        let token = self.require_token()?;
        Ok(self.build_request(method, path).bearer_auth(token))
    }

    /// 发送请求
    async fn send(&self, builder: RequestBuilder) -> Result<reqwest::Response> {
        let resp = builder.send().await?;
        if !resp.status().is_success() && resp.status() != reqwest::StatusCode::CONFLICT {
            return Err(Error::HttpError(resp.status()));
        }
        Ok(resp)
    }

    /// 获取当前用户的 Token
    fn require_token(&self) -> Result<String> {
        let token = PERSISTENCE_MANAGER
            .get()
            .ok_or(Error::Uninitialized)?
            .get_current_user_token()?
            .ok_or(Error::UnAuthorized)?;
        Ok(token)
    }
}
