use prost::Message;
use std::time::Duration;

use crate::error::{Error, Result};
use crate::pb::forum::{
    Board, CollectPostData, CollectPostRequest, CollectPostResponse, Comment, CreateCommentData,
    CreateCommentRequest, CreateCommentResponse, CreatePostRequest, CreatePostResponse,
    CreateReportRequest, CreateReportResponse, GetBoardsRequest, GetBoardsResponse,
    GetPostResponse, LikeCommentData, LikeCommentRequest, LikeCommentResponse, LikePostData,
    LikePostRequest, LikePostResponse, ListCommentsResponse, ListPostsResponse, MediaItem,
    PostDetail, PostLite, UpdatePostRequest, UpdatePostResponse,
};
use crate::{CacheOptions, api::ApiClient};

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
    pub async fn get_post(&self, post_id: String, is_cached: bool) -> Result<PostDetail> {
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
    pub async fn create_post(&self, input: CreatePostRequest) -> Result<PostDetail> {
        let req = self
            .build_auth_request(reqwest::Method::POST, "forum/posts")?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreatePostResponse::decode(body_bytes.clone())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 更新帖子
    pub async fn update_post(
        &self,
        post_id: String,
        input: UpdatePostRequest,
    ) -> Result<PostDetail> {
        let req = self
            .build_auth_request(reqwest::Method::PATCH, &format!("forum/posts/{}", post_id))?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = UpdatePostResponse::decode(body_bytes.clone())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 删除帖子（仅限管理员或贴主）
    pub async fn delete_post(&self, post_id: String) -> Result<()> {
        let req =
            self.build_auth_request(reqwest::Method::DELETE, &format!("forum/posts/{}", post_id))?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 举报帖子或评论
    pub async fn create_report(&self, input: CreateReportRequest) -> Result<String> {
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
        post_id: String,
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

    /// 创建评论
    pub async fn create_comment(&self, input: CreateCommentRequest) -> Result<CreateCommentData> {
        let req = self
            .build_auth_request(
                reqwest::Method::POST,
                &format!("forum/posts/{}/comments", input.post_id),
            )?
            .body(input.encode_to_vec());
        let resp = self.send(req).await?;
        let body_bytes = resp.bytes().await?;
        let resp = CreateCommentResponse::decode(body_bytes.clone())?;
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 删除指定评论（仅限管理员或评论作者本人）
    pub async fn delete_comment(&self, comment_id: String) -> Result<()> {
        let req = self.build_auth_request(
            reqwest::Method::DELETE,
            &format!("forum/comments/{}", comment_id),
        )?;
        let _resp = self.send(req).await?;
        Ok(())
    }

    /// 点赞评论
    pub async fn like_comment(&self, comment_id: String) -> Result<LikeCommentData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 取消点赞评论
    pub async fn unlike_comment(&self, comment_id: String) -> Result<LikeCommentData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 点赞帖子
    pub async fn like_post(&self, post_id: String) -> Result<LikePostData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 取消点赞帖子
    pub async fn unlike_post(&self, post_id: String) -> Result<LikePostData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 收藏帖子
    pub async fn collect_post(&self, post_id: String) -> Result<CollectPostData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }

    /// 取消收藏帖子
    pub async fn uncollect_post(&self, post_id: String) -> Result<CollectPostData> {
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
        resp.data.ok_or(Error::ResponseDataMissing)
    }
}
