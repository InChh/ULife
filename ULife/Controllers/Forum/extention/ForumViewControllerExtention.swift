//
//  File.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//  ForumViewController扩展
import UIKit
import UlifeLib

// 扩展实现 TableView 代理
extension ForumViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return posts.count
    }
    
    // 配置每一个 cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ForumPostCell.identifier,
                for: indexPath
            ) as? ForumPostCell
        else {
            return UITableViewCell()
        }

        cell.configure(with: posts[indexPath.row])
        return cell
    }

    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        /// TODO 根据 postLite 的帖子 id 查询详细的 post
        let postid = posts[indexPath.row].id
      
        
        Task {
            do {
                let post = try await NetworkManager.client.getPost(postId: postid)
                let forumDetailController = ForumDetailViewController(
                    post: post
                )
                // 导航到详情页
                navigationController?.pushViewController(
                    forumDetailController,
                    animated: true
                )
            } catch {
                Toast.show("获取帖子详情失败", style: .error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

        guard pageState.hasMore, !pageState.isLoading else { return }

        // 如果即将显示的是最后一个 cell → 触发下一页
        if indexPath.row == posts.count - 1 {
            applyFilterAndSort(isFresh: false)
        }
    }

}

// 扩展实现 CollectionView 代理和数据源
extension ForumViewController: UICollectionViewDelegate,
    UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return categorys.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CategoryCell.identifier,
                for: indexPath
            ) as? CategoryCell
        else {
            return UICollectionViewCell()
        }

        let isSelected = (indexPath.row == MainselectedCategoryIndex)  //是否选中
        cell.configure(with: categorys[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击调用
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if MainselectedCategoryIndex == indexPath.row{
            MainselectedCategoryIndex = -1
        }else{
            MainselectedCategoryIndex = indexPath.row // 更新选中的标签
        }
        collectionView.reloadData()  // 刷新 CollectionView 来更新选中状态

        /// 重新应用标签 + 排序 + 搜索逻辑 进行搜索
        refresh()
    }

    // 根据每一个内容的长度设置每一个 cell 的宽度和高度
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        // 创建一个临时的 Label，计算文本实际需要的宽度
        let tempLabel = UILabel()
        tempLabel.font = .systemFont(ofSize: 14, weight: .medium)
        tempLabel.text = categorys[indexPath.row].name
        tempLabel.sizeToFit()

        return CGSize(width: tempLabel.frame.width + 8, height: 32)
    }

}

