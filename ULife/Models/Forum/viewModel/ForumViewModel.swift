//
//  constant.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//

var MainselectedCategoryIndex: Int = -1

var pageState = PageState()

var posts: [PostLite] = []  //帖子列表数据


var sortMode: Sort = .latest


var categorys: [Board] = []


struct PageState {
    var page: Int = 1           // 当前页
    var pageSize: Int = 10      // 每页数量
    var isLoading: Bool = false // 是否正在加载
    var hasMore: Bool = true    // 是否还有更多数据
}
