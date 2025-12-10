use prost::Message;
use std::sync::Arc;
use std::time::Duration;

use crate::error::{self, Error, Result};
use crate::pb::forum::{
    Board, CollectPostRequest, CollectPostResponse, Comment, CreateCommentRequest,
    CreateCommentResponse, CreatePostRequest, CreatePostResponse, CreateReportRequest,
    CreateReportResponse, DeletePostRequest, GetBoardsRequest, GetBoardsResponse, GetPostResponse,
    LikeCommentRequest, LikeCommentResponse, LikePostRequest, LikePostResponse,
    ListCommentsResponse, ListPostsResponse, MediaItem, PostDetail, PostLite, UpdatePostRequest,
    UpdatePostResponse,
};
use crate::{ApiClient, CacheOptions};

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

#[derive(Debug, Clone, uniffi::Object)]
pub struct CreatePostReq {
    pub title: String,
    pub content: String,
    pub board_id: String,
    pub media: Vec<MediaItem>,
    pub tags: Vec<String>,
}

#[uniffi::export]
impl CreatePostReq {
    #[uniffi::constructor]
    pub fn new() -> Self {
        CreatePostReq {
            title: String::new(),
            content: String::new(),
            board_id: String::new(),
            media: Vec::new(),
            tags: Vec::new(),
        }
    }

    pub fn is_valid(&self) -> bool {
        !self.title.is_empty() && !self.content.is_empty() && !self.board_id.is_empty()
    }

    pub fn to_proto(&self) -> CreatePostRequest {
        CreatePostRequest {
            title: self.title.clone(),
            content: self.content.clone(),
            board_id: self.board_id.clone(),
            media: self.media.clone(),
            tags: self.tags.clone(),
        }
    }
}

impl Default for CreatePostReq {
    fn default() -> Self {
        Self::new()
    }
}

#[uniffi::export]
impl ApiClient {
    /// 获取论坛版块列表
    pub async fn list_boards(&self) -> Result<Vec<Board>> {
        let req = self
            .build_request(reqwest::Method::GET, "forum/boards")
            .body(GetBoardsRequest {}.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = GetBoardsResponse::decode(body_bytes.clone())?;
        let list = resp.data.unwrap_or_default().list;
        Ok(list)
    }
    /// 获取指定帖子详情
    #[uniffi::method(default(is_cached = true))]
    pub async fn get_post(&self, post_id: u64, is_cached: bool) -> Result<PostDetail> {
        let key = format!("forum_post_{}", post_id);
        if is_cached && let Some(hit) = self.cache.get(&key).await? {
            let resp = GetPostResponse::decode(hit.as_slice())?;
            resp.data.ok_or(Error::ResponseDataMissing)
        } else {
            let req = self.build_request(reqwest::Method::GET, &format!("forum/posts/{}", post_id));
            let resp = self.send(req).await?;
            let bytes = resp.bytes().await?;
            let resp = GetPostResponse::decode(bytes.clone())?;
            self.cache
                .insert(
                    key.clone(),
                    bytes.clone().to_vec(),
                    CacheOptions::with_ttl(Duration::from_secs(120)),
                )
                .await?;
            resp.data.ok_or(Error::ResponseDataMissing)
        }
    }

    /// 获取帖子列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn list_posts(
        &self,
        params: ListPostsRequest,
        is_cached: bool,
    ) -> Result<Vec<PostLite>> {
        if is_cached && let Some(hit) = self.cache.get(&"forum_posts".into()).await? {
            let resp = ListPostsResponse::decode(hit.as_slice())?;
            let data = resp.data.ok_or(Error::ResponseDataMissing)?;
            Ok(data.list)
        } else {
            let req = self
                .build_auth_request(reqwest::Method::GET, "forum/posts")?
                .query(&params);
            let resp = self.send(req).await?;
            let bytes = resp.bytes().await?;
            let resp = ListPostsResponse::decode(bytes.clone())?;

            self.cache
                .insert(
                    "forum_posts".into(),
                    bytes.to_vec(),
                    CacheOptions {
                        ttl: Some(std::time::Duration::from_secs(10 * 60)),
                    },
                )
                .await?;
            let data = resp.data.ok_or(Error::ResponseDataMissing)?;
            Ok(data.list)
        }
    }

    /// 发布新帖子
    pub async fn create_post(&self, input: Arc<CreatePostReq>) -> Result<PostDetail> {
        let req = self
            .build_auth_request(reqwest::Method::POST, "forum/posts")?
            .body(input.to_proto().encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreatePostResponse::decode(body_bytes.clone())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 更新帖子
    pub async fn update_post(&self, post_id: u64, input: UpdatePostRequest) -> Result<PostDetail> {
        let req = self
            .build_auth_request(reqwest::Method::PATCH, &format!("forum/posts/{}", post_id))?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = UpdatePostResponse::decode(body_bytes.clone())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 删除帖子（仅限管理员或贴主）
    pub async fn delete_post(&self, post_id: u64) -> Result<()> {
        let req =
            self.build_auth_request(reqwest::Method::DELETE, &format!("forum/posts/{}", post_id))?;
        let resp = self.send(req).await?;
        Ok(())
    }

    /// 举报帖子或评论
    pub async fn report(
        &self,
        target_type: TargetType,
        reason: String,
        description: Option<String>,
    ) -> Result<String> {
        let input = CreateReportRequest {
            target_id: match target_type {
                TargetType::Post { post_id } => post_id.to_string(),
                TargetType::Comment { comment_id } => comment_id.to_string(),
            },
            target_type: match target_type {
                TargetType::Post { .. } => "post".to_string(),
                TargetType::Comment { .. } => "comment".to_string(),
            },
            reason,
            description: description.unwrap_or_default(),
        };
        let req = self
            .build_auth_request(reqwest::Method::POST, "forum/report")?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreateReportResponse::decode(body_bytes.clone())?;
        Ok(resp.data.ok_or(Error::ResponseDataMissing)?.report_id)
    }

    /// 获取指定帖子评论列表
    #[uniffi::method(default(is_cached = true))]
    pub async fn get_post_comments(
        &self,
        post_id: u64,
        page: u64,
        page_size: u64,
        is_cached: bool,
    ) -> Result<Vec<Comment>> {
        if is_cached
            && let Some(hit) = self
                .cache
                .get(&format!("forum_post_{}_comments", post_id))
                .await?
        {
            let resp = ListCommentsResponse::decode(hit.as_slice())?;
            Ok(resp.data.ok_or(Error::ResponseDataMissing)?.list)
        } else {
            let req = self
                .build_request(
                    reqwest::Method::GET,
                    &format!("forum/posts/{}/comments", post_id),
                )
                .query(&[("page", page), ("pageSize", page_size)]);
            let resp = self.send(req).await?;
            let body_bytes = resp.bytes().await?;
            let resp = ListCommentsResponse::decode(body_bytes.clone())?;

            self.cache
                .insert(
                    format!("forum_post_{}_comments", post_id),
                    body_bytes.to_vec(),
                    CacheOptions::with_ttl(Duration::from_secs(120)),
                )
                .await?;

            Ok(resp.data.ok_or(Error::ResponseDataMissing)?.list)
        }
    }

    /// 在指定帖子下发表新的评论
    pub async fn add_comment_to_post(&self, post_id: u64, content: String) -> Result<Comment> {
        let input = CreateCommentRequest {
            post_id: post_id.to_string(),
            content,
            reply_to_comment_id: None,
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/comments", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreateCommentResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        data.comment.ok_or(Error::ResponseDataMissing)
    }

    /// 回复指定评论
    pub async fn reply_comment(
        &self,
        post_id: u64,
        comment_id: u64,
        content: String,
    ) -> Result<Comment> {
        let input = CreateCommentRequest {
            post_id: post_id.to_string(),
            content,
            reply_to_comment_id: Some(comment_id.to_string()),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/comments", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreateCommentResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        data.comment.ok_or(Error::ResponseDataMissing)
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
    pub async fn like_comment(&self, comment_id: u64) -> Result<i32> {
        let input = LikeCommentRequest {
            id: comment_id.to_string(),
            action: "like".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/comments/{}/like", comment_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = LikeCommentResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.current_like_count)
    }

    /// 取消点赞评论
    pub async fn unlike_comment(&self, comment_id: u64) -> Result<i32> {
        let input = LikeCommentRequest {
            id: comment_id.to_string(),
            action: "unlike".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/comments/{}/like", comment_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = LikeCommentResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.current_like_count)
    }

    /// 点赞帖子
    pub async fn like_post(&self, post_id: u64) -> Result<i32> {
        let input = LikePostRequest {
            id: post_id.to_string(),
            action: "like".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/like", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = LikePostResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.current_like_count)
    }

    /// 取消点赞帖子
    pub async fn unlike_post(&self, post_id: u64) -> Result<i32> {
        let input = LikePostRequest {
            id: post_id.to_string(),
            action: "unlike".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/like", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = LikePostResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.current_like_count)
    }

    /// 收藏帖子
    pub async fn favorite_post(&self, post_id: u64) -> Result<bool> {
        let input = CollectPostRequest {
            id: post_id.to_string(),
            action: "collect".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/collect", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CollectPostResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.is_collected)
    }

    /// 取消收藏帖子
    pub async fn unfavorite_post(&self, post_id: u64) -> Result<bool> {
        let input = CollectPostRequest {
            id: post_id.to_string(),
            action: "uncollect".to_string(),
        };
        let req = self
            .build_auth_request(
                reqwest::Method::DELETE,
                &format!("forum/posts/{}/collect", post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CollectPostResponse::decode(body_bytes.clone())?;
        let data = resp.data.ok_or(Error::ResponseDataMissing)?;
        Ok(data.is_collected)
    }
}
