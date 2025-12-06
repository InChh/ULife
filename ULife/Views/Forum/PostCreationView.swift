//
//  PostCreationView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/5.
//

import UIKit

class PostCreationView: UIView {

    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "标题"
        textField.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        
        // 底部细线
        let border = UIView()
        border.backgroundColor = UIColor.lightGray.withAlphaComponent(1)
        border.translatesAutoresizingMaskIntoConstraints = false
        textField.addSubview(border)
        NSLayoutConstraint.activate([
            border.heightAnchor.constraint(equalToConstant: 1),
            border.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            border.bottomAnchor.constraint(equalTo: textField.bottomAnchor),
        ])
        return textField
    }()

    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.textContainerInset = UIEdgeInsets(
            top: 10,
            left: 0,
            bottom: 10,
            right: 0
        )
        return textView
    }()

    // 标签滚动栏
    lazy var tagsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()  //定义了排列方式
        layout.scrollDirection = .horizontal  // 关键：设置水平滚动
        layout.minimumInteritemSpacing = 8  // 标签之间的最小间距
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )  // 左右内边距

        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemBackground
        cv.showsHorizontalScrollIndicator = false  //是否显示横向滚动条
        // 注册标签删选栏的元素
        cv.register(
            TagCell.self,
            forCellWithReuseIdentifier: TagCell.identifier
        )
        return cv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(titleTextField)
        addSubview(contentTextView)
        addSubview(tagsCollectionView)
        
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        tagsCollectionView.translatesAutoresizingMaskIntoConstraints = false

        let margins = safeAreaLayoutGuide

        //  标题输入框约束
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(
                equalTo: margins.topAnchor,
                constant: 16
            ),
            titleTextField.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            titleTextField.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            titleTextField.heightAnchor.constraint(equalToConstant: 44),
        ])

        // 标签 Collection View 约束 (先定义底部元素的位置)
        NSLayoutConstraint.activate([
            // 固定高度
            tagsCollectionView.heightAnchor.constraint(equalToConstant: 36),
            // 紧贴底部安全区域
            tagsCollectionView.bottomAnchor.constraint(
                equalTo: margins.bottomAnchor
            ),
            tagsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tagsCollectionView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
        ])

        // 内容文本框约束 (填充中间区域)
        NSLayoutConstraint.activate([
            contentTextView.topAnchor.constraint(
                equalTo: titleTextField.bottomAnchor,
                constant: 8
            ),
            contentTextView.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            contentTextView.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            // 底部：明确约束到 tagsCollectionView 的顶部，有 8pt 间距
            contentTextView.bottomAnchor.constraint(
                equalTo: tagsCollectionView.topAnchor,
                constant: -8
            ),
        ])

    }

}
