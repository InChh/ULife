use prost::Message;
use std::time::Duration;

use crate::error::Result;
use crate::{ApiClient, CacheOptions};

#[derive(uniffi::Record)]
pub struct Media {
    pub media_type: String,
    pub url: String,
    pub thumbnail_url: String,
    pub meta: MediaMeta,
}

#[derive(uniffi::Record)]
pub struct MediaMeta {
    pub size: u64,
    pub width: Option<u64>,
    pub height: Option<u64>,
    pub filename: String,
}

#[derive(uniffi::Enum)]
pub enum TargetType {
    Post { post_id: u64 },
    Comment { comment_id: u64 },
}

#[derive(uniffi::Record, serde::Serialize)]
#[serde(rename_all = "camelCase")]
pub struct ListPostsRequest {
    pub page: u64,
    pub page_size: u64,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub board_id: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub filter: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub sort: Option<Vec<String>>,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub keyword: Option<Vec<String>>,
}

#[derive(uniffi::Object, serde::Serialize)]
pub struct CreatePostRequest {
    pub title: String,
    pub content: String,
    pub category: String,
    pub tags: Vec<String>,
}

#[uniffi::export]
impl CreatePostRequest {

    #[uniffi::constructor]
    pub fn new() -> Self {
        CreatePostRequest {
            title: String::new(),
            content: String::new(),
            category: String::new(),
            tags: Vec::new(),
        }
    }

    pub fn is_valid(&self) -> bool {
        !self.title.trim().is_empty() && !self.content.trim().is_empty()
    }
}

impl Default for CreatePostRequest {
    fn default() -> Self {
        Self::new()
    }
}

#[uniffi::export]
impl ApiClient {
    /// 获取论坛版块列表
    pub async fn list_boards(&self) -> Result<()> {
        let req = self.build_request(reqwest::Method::GET, "forum/boards");
        todo!()
    }
    /// 获取指定帖子详情
    pub async fn get_post(&self, post_id: u64) -> Result<()> {
        let key = post_id.to_string();
        let bytes = if let Some(hit) = self.cache.get(&key).await? {
            hit
        } else {
            let req = self.build_request(reqwest::Method::GET, &format!("forum/posts/{}", post_id));
            let resp = self.send(req).await?;
            let bytes = resp.bytes().await?.to_vec();
            self.cache
                .insert(
                    key.clone(),
                    bytes.clone(),
                    CacheOptions::with_ttl(Duration::from_secs(120)),
                )
                .await?;
            bytes
        };

        todo!()
    }

    /// 获取帖子列表
    pub async fn list_posts(&self, params: ListPostsRequest) -> Result<()> {
        let req = self
            .build_auth_request(reqwest::Method::GET, "forum/posts")?
            .query(&params);
        let resp = self.send(req).await?;
        todo!()
    }

    /// 发布新帖子
    pub async fn create_post(
        &self,
        board_id: String,
        title: String,
        content: String,
        tags: Vec<String>,
        medias: Option<Vec<Media>>,
    ) -> Result<()> {
        let req = self.build_auth_request(reqwest::Method::POST, "forum/posts")?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 更新帖子
    pub async fn update_post(
        &self,
        post_id: u64,
        title: Option<String>,
        content: Option<String>,
        tags: Option<Vec<String>>,
        medias: Option<Vec<String>>,
    ) -> Result<()> {
        let req =
            self.build_auth_request(reqwest::Method::PATCH, &format!("forum/posts/{}", post_id))?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 删除帖子（仅限管理员或贴主）
    pub async fn delete_post(&self, post_id: u64) -> Result<()> {
        let req =
            self.build_auth_request(reqwest::Method::DELETE, &format!("forum/posts/{}", post_id))?;
        let resp = self.send(req).await?;
        Ok(())
    }
    pub async fn report(
        &self,
        target_type: TargetType,
        reason: String,
        description: Option<String>,
    ) -> Result<()> {
        let req = self.build_auth_request(reqwest::Method::POST, "forum/report")?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 获取指定帖子评论列表
    pub async fn get_post_comments(&self, post_id: u64, page: u64, page_size: u64) -> Result<()> {
        let req = self
            .build_request(
                reqwest::Method::GET,
                &format!("forum/posts/{}/comments", post_id),
            )
            .query(&[("page", page), ("pageSize", page_size)]);
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 在指定帖子下发表新的评论
    pub async fn add_comment_to_post(&self, post_id: u64, content: String) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/posts/{}/comments", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 回复指定评论
    pub async fn reply_comment(
        &self,
        post_id: u64,
        comment_id: u64,
        content: String,
    ) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/posts/{}/comments", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 删除指定评论（仅限管理员或评论作者本人）
    pub async fn delete_comment(&self, comment_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::DELETE,
            &format!("forum/comments/{}", comment_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 点赞评论
    pub async fn like_comment(&self, comment_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/comments/{}/like", comment_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 取消点赞评论
    pub async fn unlike_comment(&self, comment_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/comments/{}/like", comment_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 点赞帖子
    pub async fn like_post(&self, post_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/posts/{}/like", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 取消点赞帖子
    pub async fn unlike_post(&self, post_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/posts/{}/like", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 收藏帖子
    pub async fn favourite_post(&self, post_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::POST,
            &format!("forum/posts/{}/collect", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 取消收藏帖子
    pub async fn unfavourite_post(&self, post_id: u64) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::DELETE,
            &format!("forum/posts/{}/collect", post_id),
        )?;
        let resp = self.send(req).await?;
        Ok(())
    }
}
