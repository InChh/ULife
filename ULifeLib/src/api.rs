use std::sync::Arc;

use foyer::HybridCache;
use prost::Message;
use reqwest::{
    RequestBuilder,
    header::{ACCEPT, CONTENT_TYPE},
};
use serde::{Serialize, de::DeserializeOwned};

use crate::{API_CACHE, PERSISTENCE_MANAGER};

pub mod activity;
pub mod common;
pub mod course;
pub mod forum;
pub mod user;

use crate::error::{Error, Result};

#[derive(Clone, Copy, Debug, PartialEq, Eq, uniffi::Enum)]
pub enum ApiProtocol {
    Json,
    Protobuf,
}

impl ApiProtocol {
    fn accept_header(&self) -> &'static str {
        match self {
            ApiProtocol::Json => "application/json",
            ApiProtocol::Protobuf => "application/x-protobuf",
        }
    }

    fn content_type(&self) -> &'static str {
        match self {
            ApiProtocol::Json => "application/json",
            ApiProtocol::Protobuf => "application/x-protobuf",
        }
    }

    fn cache_prefix(&self) -> &'static str {
        match self {
            ApiProtocol::Json => "json",
            ApiProtocol::Protobuf => "pb",
        }
    }
}

#[derive(uniffi::Object)]
pub struct ApiClient {
    client: reqwest::Client,
    base_url: String,
    cache: Arc<HybridCache<String, Vec<u8>>>,
    protocol: ApiProtocol,
}

#[uniffi::export]
impl ApiClient {
    #[uniffi::constructor]
    pub fn new(base_url: String) -> Result<Self> {
        Self::new_with_protocol(base_url, ApiProtocol::Protobuf)
    }

    #[uniffi::constructor(name = "with_protocol")]
    pub fn new_with_protocol(base_url: String, protocol: ApiProtocol) -> Result<Self> {
        let client = reqwest::Client::builder()
            .user_agent("ULife.ios/1.0")
            .build()?;

        let cache = API_CACHE.get().cloned().ok_or(Error::Uninitialized)?;

        Ok(ApiClient {
            client,
            base_url,
            cache,
            protocol,
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
        self.add_accept(self.client.request(method, url))
    }

    /// 构建需要认证的请求
    async fn build_auth_request(
        &self,
        method: reqwest::Method,
        path: &str,
    ) -> Result<RequestBuilder> {
        let token = self.require_token().await?;
        Ok(self.build_request(method, path).bearer_auth(token))
    }

    fn add_accept(&self, builder: RequestBuilder) -> RequestBuilder {
        builder.header(ACCEPT, self.protocol.accept_header())
    }

    fn prepare_body<T>(&self, builder: RequestBuilder, body: &T) -> Result<RequestBuilder>
    where
        T: Message + Serialize,
    {
        let (content_type, payload) = match self.protocol {
            ApiProtocol::Json => (self.protocol.content_type(), serde_json::to_vec(body)?),
            ApiProtocol::Protobuf => (self.protocol.content_type(), body.encode_to_vec()),
        };
        Ok(builder.header(CONTENT_TYPE, content_type).body(payload))
    }

    fn decode_body<T>(&self, bytes: &[u8]) -> Result<T>
    where
        T: Message + Default + DeserializeOwned,
    {
        match self.protocol {
            ApiProtocol::Json => Ok(serde_json::from_slice(bytes)?),
            ApiProtocol::Protobuf => Ok(T::decode(bytes)?),
        }
    }

    fn cache_key(&self, key: impl AsRef<str>) -> String {
        format!("{}::{}", self.protocol.cache_prefix(), key.as_ref())
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
    async fn require_token(&self) -> Result<String> {
        let token = PERSISTENCE_MANAGER
            .get()
            .ok_or(Error::Uninitialized)?
            .get_current_user_token()
            .await?
            .ok_or(Error::UnAuthorized)?;
        Ok(token)
    }
}
