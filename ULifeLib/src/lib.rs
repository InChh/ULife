#![allow(unused)]
use once_cell::sync::OnceCell;
use reqwest::RequestBuilder;
use std::time::Duration;

use crate::{
    error::{Error, Result},
    fs::{FsHandle, default_fs},
    persistence::PersistenceManager,
};

pub mod error;
pub mod fs;
pub mod hybrid_cache;
pub mod pb;
pub mod persistence;

pub mod api;
pub mod model;
pub mod util;
pub use hybrid_cache::{CacheOptions, HybridCache, HybridCacheConfig};

uniffi::setup_scaffolding!();

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

static PERSISTENCE_MANAGER: OnceCell<PersistenceManager> = OnceCell::new();

pub fn init_persistence_manager(base_folder: String, fs: FsHandle) -> Result<()> {
    let manager = PersistenceManager::new_with_fs(base_folder, fs)?;
    let _ = PERSISTENCE_MANAGER.set(manager);
    Ok(())
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
        if !resp.status().is_success() {
            return Err(Error::HttpError(resp.status()));
        }
        Ok(resp)
    }

    /// 发送请求并解析 Protobuf 响应
    async fn send_proto<T>(&self, builder: RequestBuilder) -> Result<T>
    where
        T: prost::Message + Default,
    {
        let resp = self.send(builder).await?;
        if !resp.status().is_success() {
            return Err(Error::HttpError(resp.status()));
        }
        let bytes = resp.bytes().await?;
        let message = T::decode(bytes)?;
        Ok(message)
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
