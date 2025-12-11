use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PublicCourse {
    pub course_id: i64,
    pub course_name: String,
    pub teacher_name: String,
    pub teacher_id: Option<i64>,
    pub location: String,
    pub day_of_week: i32,      // 1 = 周一
    pub start_section: i32,    // 例如 1 表示第 1 节
    pub end_section: i32,      // 例如 2 表示第 2 节
    pub weeks_range: Vec<i32>, // 例如 [1,2,...,16]
    pub course_type: CourseType,
    pub credits: Option<i32>,
    pub description: Option<String>,
}

#[derive(Debug, Clone, uniffi::Enum, Serialize, Deserialize)]
pub enum CourseType {
    Compulsory,
    Elective,
}

/// 节次对应的时间段，用于生成展示用的 timeRange
#[derive(Debug, Clone, uniffi::Record, Serialize, Deserialize)]
pub struct SectionSlot {
    pub start: String,
    pub end: String,
}
