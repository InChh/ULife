use chrono::{Duration, NaiveDateTime, Utc};
use serde::{Deserialize, Serialize};
use sqlx::MySqlPool;

use crate::common::error::AppError;
use crate::modules::activity::entity::ActivityListItem;
use crate::modules::bbs::entity::PostListItem;
use crate::modules::bbs::service::BbsService;

/// 工具 1：查询近期校园活动的参数
///
/// 该结构会以 JSON 的形式暴露给大模型，由大模型决定如何填写。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActivityToolArgs {
    /// 时间范围：最近 7 天 / 30 天 / 全部
    /// - "7d"  : 最近 7 天
    /// - "30d" : 最近 30 天
    /// - "all" : 不限制时间
    pub time_range: String,

    /// 活动类型（可选），目前后端暂不细分类型，预留字段方便以后扩展。
    pub category: Option<String>,

    /// 返回条数上限，避免一次性返回过多活动。
    #[serde(default = "default_activity_limit")]
    pub limit: u32,
}

fn default_activity_limit() -> u32 {
    20
}

/// 返回给大模型看到的活动精简信息
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ActivityToolItem {
    pub id: String,
    pub title: String,
    pub location: String,
    pub start_time: NaiveDateTime,
    pub quota: i32,
    pub current_enrollments: i32,
}

/// 根据工具参数，从数据库中查询近期校园活动。
///
/// 注意：这里不会执行任何来自大模型的原始 SQL，只使用受控的参数化查询，防止 SQL 注入。
pub async fn get_recent_activities(
    pool: &MySqlPool,
    _user_id: &str,
    args: ActivityToolArgs,
) -> Result<Vec<ActivityToolItem>, AppError> {
    // 计算时间范围
    let now = Utc::now().naive_utc();
    let start_time: Option<NaiveDateTime> = match args.time_range.as_str() {
        "1d" => Some(now - Duration::days(1)),
        "7d" => Some(now - Duration::days(7)),
        "30d" => Some(now - Duration::days(30)),
        "all" => None,
        // 未知取值时，兜底为 7 天，避免时间范围过大
        _ => Some(now - Duration::days(7)),
    };

    let mut query = String::from(
        "SELECT id, title, cover_url, location, start_time, quota, current_enrollments \
         FROM activities \
         WHERE status = 1",
    );

    if start_time.is_some() {
        query.push_str(" AND start_time >= ?");
    }

    query.push_str(" ORDER BY start_time ASC LIMIT ?");

    let mut q = sqlx::query_as::<_, ActivityListItem>(&query);

    if let Some(st) = start_time {
        q = q.bind(st);
    }

    // 对 limit 做一个合理的上限，防止一次性返回太多数据
    let safe_limit: i64 = args
        .limit
        .max(1)
        .min(50) as i64;
    q = q.bind(safe_limit);

    let rows: Vec<ActivityListItem> = q.fetch_all(pool).await?;

    Ok(rows
        .into_iter()
        .map(|r| ActivityToolItem {
            id: r.id,
            title: r.title,
            location: r.location,
            start_time: r.start_time,
            quota: r.quota,
            current_enrollments: r.current_enrollments,
        })
        .collect())
}

/// 工具 2：查询当天校园天气的参数
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeatherToolArgs {
    /// 位置描述，例如“上海”/“校园”。
    /// 当前实现主要用于让回答更自然，并不会影响查询逻辑。
    pub location: Option<String>,
}

/// 给大模型看到的天气结构（可后续替换为真实天气服务）。
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeatherInfo {
    pub location: String,
    pub date: String,
    pub summary: String,
    pub temperature_celsius: i32,
}

/// 工具 3：论坛摘要——返回今天/最近若干条讨论帖，供大模型做总结
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ForumSummaryItem {
    pub title: String,
    pub board_name: String,
    pub summary: String,
    pub like_count: i32,
    pub comment_count: i32,
}

/// 查询论坛最近的帖子列表（按热度/时间），供 AI 做“今天校园论坛在讨论什么”的总结。
pub async fn get_forum_recent_posts(
    pool: &MySqlPool,
    user_id: &str,
    limit: i32,
) -> Result<Vec<ForumSummaryItem>, AppError> {
    use crate::modules::bbs::entity::GetPostsQuery;

    // 直接复用已有的 BbsService::get_posts 逻辑
    let query = GetPostsQuery {
        page: 1,
        page_size: limit,
        board_id: None,
        filter: None,
        sort: Some("hot".to_string()), // 按热度排序，更适合作为“大家在讨论什么”
        keyword: None,
    };

    let (posts, _pagination) =
        BbsService::get_posts(pool, query, Some(user_id)).await?;

    let items = posts
        .into_iter()
        .map(|p: PostListItem| ForumSummaryItem {
            title: p.title,
            board_name: p.board_name,
            summary: p
                .summary
                .unwrap_or_else(|| "（无摘要内容）".to_string()),
            like_count: p.stats.like_count,
            comment_count: p.stats.comment_count,
        })
        .collect();

    Ok(items)
}

/// 简单的天气工具实现
///
/// 通过 Open-Meteo 提供的免费天气与地理编码接口，根据城市名称获取当日天气。
/// 注意：这里不会记录任何用户隐私信息，只使用城市级别的地理位置。
pub async fn get_today_weather(args: WeatherToolArgs) -> Result<WeatherInfo, AppError> {
    let raw_location = args.location.unwrap_or_else(|| "校园".to_string());

    // 使用 Open-Meteo 的地理编码服务将城市名称转换为经纬度
    // 文档：https://open-meteo.com/en/docs/geocoding-api
    let encoded_name = urlencoding::encode(&raw_location);
    let geo_url = format!(
        "https://geocoding-api.open-meteo.com/v1/search?name={}&count=1&language=zh&format=json",
        encoded_name
    );

    #[derive(Debug, Deserialize)]
    struct GeoResult {
        name: String,
        country: Option<String>,
        latitude: f64,
        longitude: f64,
    }

    #[derive(Debug, Deserialize)]
    struct GeoResponse {
        results: Option<Vec<GeoResult>>,
    }

    let client = reqwest::Client::new();

    let geo_resp = client
        .get(&geo_url)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("weather geocoding failed: {}", e)))?;

    let geo: GeoResponse = geo_resp
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("weather geocoding decode failed: {}", e)))?;

    let first = match geo.results.and_then(|mut v| v.pop()) {
        Some(r) => r,
        None => {
            // 如果地理编码没有结果，回退为一个通用的“校园”天气，而不是直接报错中断工具。
            let today = Utc::now().date_naive().to_string();
            return Ok(WeatherInfo {
                location: raw_location,
                date: today,
                summary: "暂时无法从天气服务获取该地点的实时天气，默认认为今日天气总体适宜日常出行与学习。".to_string(),
                temperature_celsius: 25,
            });
        }
    };

    let display_location = if let Some(country) = first.country {
        format!("{}（{}）", first.name, country)
    } else {
        first.name
    };

    // 使用 Open-Meteo 天气接口获取当前天气
    // 文档：https://open-meteo.com/en/docs
    let weather_url = format!(
        "https://api.open-meteo.com/v1/forecast?latitude={}&longitude={}&current_weather=true&timezone=Asia%2FShanghai",
        first.latitude, first.longitude
    );

    #[derive(Debug, Deserialize)]
    struct CurrentWeather {
        temperature: f64,
        weathercode: i32,
    }

    #[derive(Debug, Deserialize)]
    struct WeatherResponse {
        current_weather: CurrentWeather,
    }

    let weather_resp = client
        .get(&weather_url)
        .send()
        .await
        .map_err(|e| AppError::Internal(format!("weather api request failed: {}", e)))?;

    let w: WeatherResponse = weather_resp
        .json()
        .await
        .map_err(|e| AppError::Internal(format!("weather api decode failed: {}", e)))?;

    let temp_c = w.current_weather.temperature.round() as i32;
    let summary = match w.current_weather.weathercode {
        0 => "晴朗，无云".to_string(),
        1 | 2 => "多云到晴，整体天气较好".to_string(),
        3 => "多云，可能有短暂阴天".to_string(),
        45 | 48 => "有雾或霾，能见度较低".to_string(),
        51 | 53 | 55 => "有小到中雨，外出记得带伞".to_string(),
        61 | 63 | 65 => "有明显降雨，建议减少长时间户外逗留".to_string(),
        71 | 73 | 75 => "有降雪，注意保暖和路面湿滑".to_string(),
        95 | 96 | 99 => "可能有雷阵雨或强对流天气，尽量避免户外活动".to_string(),
        _ => "天气情况一般，可按实际体感安排出行。".to_string(),
    };

    let today = Utc::now().date_naive().to_string();

    Ok(WeatherInfo {
        location: display_location,
        date: today,
        summary,
        temperature_celsius: temp_c,
    })
}

