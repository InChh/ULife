// #[derive(Debug, Clone, uniffi::Object)]
// pub struct User {
//     pub id: i64,
//     pub student_id: String,     // 学号
//     pub name: String,           // 真实姓名
//     pub avatar: Option<String>, // 头像URL
//     pub college: String,        // 学院
//     pub major: String,          // 专业
//     pub grade: String,          // 年级
//     pub class_name: String,     // 班级
//     pub email: String,          // 邮箱
//     pub phone: String,          // 手机号
//     pub qq: Option<String>,     // QQ号
//     pub wechat: Option<String>, // 微信号
//     pub bio: Option<String>,    // 个人简介
//     pub join_date: String,      // 注册时间
//     pub last_login: String,     // 最后登录时间
// }

// #[uniffi::export]
// impl User {
//     #[uniffi::constructor]
//     pub fn new() -> Self {
//         User {
//             id: 0,
//             student_id: String::new(),
//             name: String::new(),
//             avatar: None,
//             college: String::new(),
//             major: String::new(),
//             grade: String::new(),
//             class_name: String::new(),
//             email: String::new(),
//             phone: String::new(),
//             qq: None,
//             wechat: None,
//             bio: None,
//             join_date: String::new(),
//             last_login: String::new(),
//         }
//     }
//     /// 显示名称
//     fn display_name(&self) -> String {
//         self.name.clone()
//     }

//     /// 完整学籍信息
//     fn academic_info(&self) -> String {
//         format!("{} · {} · {}级", self.college, self.major, self.grade)
//     }
// }
