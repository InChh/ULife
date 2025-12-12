//
//  PostCreationViewControllerExtention.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/8.
//
import UIKit
import UlifeLib

// 文本编辑的代理
extension PostCreationViewController: UITextFieldDelegate, UITextViewDelegate {
    
    //标题输入框变化时
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == postCreationView.titleTextField {
            updatePublishButtonState()
        }
    }
    
    //内容输入框变化时
    func textViewDidChange(_ textView: UITextView) {
        postCreationView.placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
        updatePublishButtonState()
    }
}



// 扩展实现 板块 CollectionView 代理和数据源
extension PostCreationViewController: UICollectionViewDelegate,
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

        let isSelected = indexPath.row == CreateselectedCategoryIndex
        cell.configure(with: categorys[indexPath.row], isSelected: isSelected)
        return cell
    }

    // 点击事件
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        CreateselectedCategoryIndex = indexPath.row
        collectionView.reloadData()
    }

    // 根据每一个标签内容的长度设置每一个 cell 的宽度和高度
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
