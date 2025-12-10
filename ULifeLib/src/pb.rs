pub mod common;
pub mod test;
pub mod user;
pub mod course;
pub mod forum;


impl user::User {
    // pub fn to_model(self) -> crate::model::user::User {
    //     crate::model::user::User {
    //         id: self.id.clone(),
    //         student_id: self.student_id,
    //         name: self.name,
    //         avatar: if self.avatar_url.is_empty() {
    //             None
    //         } else {
    //             Some(self.avatar_url)
    //         },
    //         college: self.college,
    //         major: self.major,
    //         grade: self.grade,
    //         class_name: self.class_name,
    //         email: self.email,
    //         phone: self.phone,
    //         qq: None,
    //         wechat: if self.wechat_id.is_empty() {
    //             None
    //         } else {
    //             Some(self.wechat_id)
    //         },
    //         bio: if self.bio.is_empty() {
    //             None
    //         } else {
    //             Some(self.bio)
    //         },
    //         join_date: String::new(),
    //         last_login: String::new(),
    //     }
    // }
}

impl course::PublicCourse {
    pub fn to_model(self) -> crate::model::calendar::PublicCourse {
        crate::model::calendar::PublicCourse {
            course_id: self.id,
            course_name: self.course_name,
            teacher_name: self.teacher_name,
            teacher_id: self.teacher_id,
            location: self.location,
            day_of_week: self.day_of_week,
            start_section: self.start_section,
            end_section: self.end_section,
            weeks_range: self.weeks_range,
            course_type: match self.r#type.as_str() {
                "Compulsory" => crate::model::calendar::CourseType::Compulsory,
                "elective" => crate::model::calendar::CourseType::Elective,
                _ => crate::model::calendar::CourseType::Compulsory,
            },
            credits: self.credits,
            description: self.description,
        }
    }
}