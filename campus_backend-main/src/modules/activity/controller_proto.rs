// Protobuf 版本的 Activity Controller 示例
// 这是一个示例实现，展示如何使用 protobuf 响应

use axum::{
    extract::{Path, Query, State},
    response::{IntoResponse, Response},
    routing::get,
    Router,
    http::{StatusCode, header},
};
use prost::Message;
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::activity::service::ActivityService;
use crate::proto::{self, GetActivitiesResponse, ActivityListItem as ProtoActivityListItem, Pagination as ProtoPagination};

/// 查询参数
#[derive(serde::Deserialize)]
struct GetActivitiesQuery {
    keyword: Option<String>,
    activity_type: Option<i8>,
    #[serde(default = "default_page")]
    page: i32,
    #[serde(default = "default_page_size")]
    #[serde(rename = "pageSize")]
    page_size: i32,
}

fn default_page() -> i32 { 1 }
fn default_page_size() -> i32 { 10 }

/// Protobuf 响应包装
fn protobuf_response<M: Message>(message: M) -> Response {
    let mut buf = Vec::new();
    message.encode(&mut buf).unwrap();
    
    (
        StatusCode::OK,
        [(header::CONTENT_TYPE, "application/x-protobuf")],
        buf
    ).into_response()
}

/// 获取活动列表 (Protobuf 版本)
async fn get_activities_list_proto(
    State(pool): State<MySqlPool>,
    Query(params): Query<GetActivitiesQuery>,
) -> Result<Response, AppError> {
    // 从 service 获取数据
    let (list, pagination) = ActivityService::get_activities_list(
        &pool,
        params.keyword,
        params.activity_type,
        params.page,
        params.page_size,
    ).await?;
    
    // 转换为 proto 消息
    let proto_items: Vec<ProtoActivityListItem> = list.into_iter().map(|item| {
        ProtoActivityListItem {
            id: item.id,
            title: item.title,
            cover_url: item.cover_url.unwrap_or_default(),
            location: item.location,
            start_time: item.start_time.format("%Y-%m-%dT%H:%M:%SZ").to_string(),
            quota: item.quota,
            current_enrollments: item.current_enrollments,
        }
    }).collect();
    
    let proto_pagination = ProtoPagination {
        total: pagination.total,
        page: pagination.page,
        page_size: pagination.page_size,
        pages: pagination.pages,
    };
    
    let response = GetActivitiesResponse {
        list: proto_items,
        pagination: Some(proto_pagination),
    };
    
    Ok(protobuf_response(response))
}

/// Protobuf 路由
pub fn activity_proto_routes() -> Router<MySqlPool> {
    Router::new()
        .route("/v1/activities-proto", get(get_activities_list_proto))
}

/* 使用说明：

1. 在 main.rs 中添加路由：
   ```rust
   use crate::modules::activity::controller_proto::activity_proto_routes;
   
   let api_routes = Router::new()
       .merge(activity_proto_routes());  // 添加这行
   ```

2. 测试 API：
   ```bash
   curl -H "Accept: application/x-protobuf" \
        http://localhost:3000/api/v1/activities-proto \
        --output response.bin
   ```

3. 解码查看（需要 protoc）：
   ```bash
   protoc --decode=campus.activity.GetActivitiesResponse \
          Protocol/activity.proto < response.bin
   ```

4. iOS 客户端使用：
   ```swift
   let data = try await URLSession.shared.data(from: url)
   let response = try Campus_Activity_GetActivitiesResponse(serializedData: data.0)
   ```

*/

