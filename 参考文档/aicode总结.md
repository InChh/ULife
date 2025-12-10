实现总结
1. 数据模型 (Models/Activity/Activity.swift)
Activity - 活动实体（含所有字段）
ActivityListItem - 列表项简化模型
ActivityType、ActivityStatus - 枚举类型
Pagination - 分页信息
EnrollActivityRequest、EnrollmentResponse 等请求/响应模型
APIResponse<T> - 统一 API 响应格式
2. 网络层 (Managers/NetworkManager.swift)
通用网络请求方法
Bearer Token 认证支持
活动相关 API：
获取活动列表（支持关键词、类型筛选、分页）
获取活动详情
报名/取消报名
收藏/取消收藏
获取我的活动
管理员相关接口
3. 业务逻辑层 (Managers/Activity/ActivityService.swift)
ActivityService - 封装网络请求的业务逻辑
错误处理与类型转换
4. 视图组件
ActivityCell - 活动列表 Cell（封面图、标题、地点、时间、报名人数）
ActivityDetailView - 活动详情视图（封面、标题、信息、内容、操作按钮）
5. 控制器
ActivityViewController - 活动列表页
搜索功能
类型筛选（全部/讲座/社团/竞赛）
下拉刷新
上拉加载更多
ActivityDetailViewController - 活动详情页
显示完整活动信息
报名/取消报名功能
收藏/取消收藏功能
6. 工具类
Constants - API 基础 URL 和常量
APIPath - API 路径枚举
主要特性
符合接口文档规范：所有 API 调用与文档一致
统一响应格式：使用 APIResponse<T> 处理响应
错误处理：网络错误与业务错误处理
异步处理：使用 async/await
用户体验：下拉刷新、上拉加载、Toast 提示
代码已实现，可直接使用。注意：
需要在 Constants.baseURL 中配置正确的后端 API 地址
需要在登录后保存 Token 到 UserDefaults（key: "auth_token"）
图片加载使用原生 URLSession，如需缓存可后续优化
所有代码已通过语法检查，无编译错误。