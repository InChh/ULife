use axum::{
    body::Body,
    http::{Request, Response, header},
    middleware::Next,
};

/// 添加 UTF-8 字符编码到响应头
pub async fn add_charset_middleware(
    req: Request<Body>,
    next: Next,
) -> Response<Body> {
    let mut response = next.run(req).await;
    
    // 确保 JSON 响应使用 UTF-8 编码
    if let Some(content_type) = response.headers().get(header::CONTENT_TYPE) {
        if content_type.to_str().unwrap_or("").contains("application/json") {
            response.headers_mut().insert(
                header::CONTENT_TYPE,
                "application/json; charset=utf-8".parse().unwrap()
            );
        }
    }
    
    response
}

