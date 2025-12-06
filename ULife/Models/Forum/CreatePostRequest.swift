import Foundation

// MARK: - 发帖请求体 Model
// 专用于封装向后端提交新帖子时所需的数据
struct CreatePostRequest {
    let title: String
    let content: String
    // 标签在你的需求中是可选的，但通常也会作为数组提交
    var tags: [String] = [] 
    
    // 检查发帖数据是否有效（业务校验）
    var isValid: Bool {
        return !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // 如果使用 Alamofire 或 URLSession，可能需要一个方法将自身转换为 JSON 字典
    func toDictionary() -> [String: Any] {
        return [
            "title": title,
            "content": content,
            "tags": tags 
        ]
    }
}