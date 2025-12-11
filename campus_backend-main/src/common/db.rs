use sqlx::{MySqlPool, Pool, MySql, mysql::MySqlConnectOptions};
use dotenv::dotenv;
use std::env;
use std::str::FromStr;

/// 获取数据库连接池
pub async fn get_db_pool() -> Result<Pool<MySql>, sqlx::Error> {
    dotenv().ok();
    
    let database_url = env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set in .env file");
    
    // 解析连接选项并设置字符集
    let mut options = MySqlConnectOptions::from_str(&database_url)?;
    options = options.charset("utf8mb4");
    options = options.collation("utf8mb4_unicode_ci");
    
    MySqlPool::connect_with(options).await
}

