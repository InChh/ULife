#[derive(Debug, Clone, uniffi::Object, serde::Serialize, serde::Deserialize)]
struct User {
    id: String,
    student_id: String,     // 学号
    username: String,       // 用户名
    password: String,       // 密码（实际项目中应加密存储）
    name: String,           // 真实姓名
    avatar: Option<String>, // 头像URL
    college: String,        // 学院
    major: String,          // 专业
    grade: String,          // 年级
    class_name: String,     // 班级
    email: String,          // 邮箱
    phone: String,          // 手机号
    qq: Option<String>,     // QQ号
    wechat: Option<String>, // 微信号
    bio: Option<String>,    // 个人简介
    join_date: String,      // 注册时间
    last_login: String,     // 最后登录时间
}

#[uniffi::export]
impl User {
    #[uniffi::constructor]
    pub fn new() -> Self {
        User {
            id: String::new(),
            student_id: String::new(),
            username: String::new(),
            password: String::new(),
            name: String::new(),
            avatar: None,
            college: String::new(),
            major: String::new(),
            grade: String::new(),
            class_name: String::new(),
            email: String::new(),
            phone: String::new(),
            qq: None,
            wechat: None,
            bio: None,
            join_date: String::new(),
            last_login: String::new(),
        }
    }
    /// 显示名称
    fn display_name(&self) -> String {
        if self.name.is_empty() {
            self.username.clone()
        } else {
            self.name.clone()
        }
    }

    /// 完整学籍信息
    fn academic_info(&self) -> String {
        format!("{} · {} · {}级", self.college, self.major, self.grade)
    }
}
