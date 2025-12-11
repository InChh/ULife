// 声明一级模块
mod common;
mod modules;
mod proto;

use axum::{Router, middleware};
use crate::common::db::get_db_pool;
use crate::common::middleware::add_charset_middleware;
use crate::modules::user::controller::user_routes;
use crate::modules::user::controller_proto::user_proto_routes;
use crate::modules::course::controller::course_routes;
use crate::modules::course::controller_proto::course_proto_routes;
use crate::modules::bbs::controller::bbs_routes;
use crate::modules::bbs::controller_proto::bbs_proto_routes;
use crate::modules::activity::controller::activity_routes;

#[tokio::main]
async fn main() {
    // 初始化日志
    tracing_subscriber::fmt::init();
    
    println!("🚀 Campus Backend is starting...");
    println!("📝 Loading configuration from .env file...");
    
    // 初始化数据库连接池
    println!("🔗 Connecting to database...");
    let pool = match get_db_pool().await {
        Ok(pool) => {
            println!("✅ Database connected successfully!");
            pool
        }
        Err(e) => {
            eprintln!("❌ Failed to connect to database:");
            eprintln!("   Error: {}", e);
            eprintln!("\n💡 Please check:");
            eprintln!("   1. MySQL server is running");
            eprintln!("   2. Database 'campus_db' exists");
            eprintln!("   3. .env file has correct DATABASE_URL");
            eprintln!("   4. Username and password are correct");
            std::process::exit(1);
        }
    };
    
    // 构建路由
    let api_routes = Router::new()
        // JSON API 路由
        .merge(user_routes())
        .merge(course_routes())
        .merge(bbs_routes())
        .merge(activity_routes())
        // Protobuf API 路由
        .merge(user_proto_routes())
        .merge(course_proto_routes())
        .merge(bbs_proto_routes());
    
    let app = Router::new()
        .nest("/api", api_routes)
        .layer(middleware::from_fn(add_charset_middleware))
        .with_state(pool);
    
    // 启动服务器
    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .expect("Failed to bind to address");
    
    println!("Server running on http://0.0.0.0:3000");
    
    axum::serve(listener, app)
        .await
        .expect("Server failed to start");
}