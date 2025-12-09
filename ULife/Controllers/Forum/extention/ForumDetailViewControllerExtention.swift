//
//  ForumDetailViewControllerExtention.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//  帖子详情页扩展

import UIKit

extension ForumDetailViewController: UITableViewDelegate, UITableViewDataSource
{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)
        -> Int
    {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        guard
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentCell.identifier,
                for: indexPath
            ) as? CommentCell
        else {
            return UITableViewCell()
        }

        let comment = comments[indexPath.row]
        let isLiked = likedCommentIDs.contains(comment.id)
        cell.configure(
            with: comment,
            isLiked: isLiked,
            likedReplyIDs: likedReplyIDs
        )

        // 实现 cell 的声明出来的方法
        /// 判断是否为自己的评论
        if true {
            cell.onCommentTap = { [weak self] in
                self?.CommentReplyOrDelete(indexPath.row)
            }
        } else {
            // 点击整条评论：回复该评论
            cell.onCommentTap = { [weak self] in
                self?.presentReplyAlert(
                    commentIndex: indexPath.row,
                    replyingToName: nil
                )
            }
        }

        // 点赞整条评论
        cell.onCommentLikeTap = { [weak self] in
            self?.toggleCommentLike(at: indexPath.row)
        }

        
        if true {
            cell.onReplyTap = { [weak self] reply in
                self?.ReplyReplyOrDelete(indexPath.row, reply)
            }
        } else {
            // 点击某一条回复：回复这条回复的作者
            cell.onReplyTap = { [weak self] reply in
                self?.presentReplyAlert(
                    commentIndex: indexPath.row,
                    replyingToName: reply.authorName
                )
            }
        }

        // 点赞某一条回复
        cell.onReplyLikeTap = { [weak self] reply in
            self?.toggleReplyLike(reply, inCommentAt: indexPath.row)
        }
        
        return cell
    }

    // 因为我的 cell 是动态高度
    // 当您不提供预估高度时，UITableView 在初始化时无法准确计算contentSize（即所有行加起来的总高度），从而导致滚动视图行为异常。
    func tableView(
        _ tableView: UITableView,
        estimatedHeightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        return 1000
    }
}

