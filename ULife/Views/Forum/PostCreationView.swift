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

    // 底部：帖子板块标签提示
    let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "选择帖子板块"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()

    // 底部：帖子板块选择滚动栏
    lazy var CategoryCollectionView: UICollectionView = {
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
            CategoryCell.self,
            forCellWithReuseIdentifier: CategoryCell.identifier
        )
        return cv
    }()

    // 底部：自定义标签输入框
    let tagInputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "添加标签，例如 社团活动"
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()

    let tagAddButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("添加", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 6
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()

    // 显示已添加的自定义标签
    let tagListLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = nil
        return label
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
        addSubview(categoryTitleLabel)
        addSubview(CategoryCollectionView)
        addSubview(tagListLabel)
        addSubview(tagInputTextField)
        addSubview(tagAddButton)
        
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        contentTextView.translatesAutoresizingMaskIntoConstraints = false
        categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        CategoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tagListLabel.translatesAutoresizingMaskIntoConstraints = false
        tagInputTextField.translatesAutoresizingMaskIntoConstraints = false
        tagAddButton.translatesAutoresizingMaskIntoConstraints = false

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

        // 底部标签输入行
        NSLayoutConstraint.activate([
            tagInputTextField.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            tagInputTextField.bottomAnchor.constraint(
                equalTo: margins.bottomAnchor,
                constant: -8
            ),
            tagAddButton.leadingAnchor.constraint(
                equalTo: tagInputTextField.trailingAnchor,
                constant: 8
            ),
            tagAddButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            tagAddButton.centerYAnchor.constraint(
                equalTo: tagInputTextField.centerYAnchor
            ),
            tagInputTextField.heightAnchor.constraint(equalToConstant: 34),
            tagAddButton.heightAnchor.constraint(equalToConstant: 34),
            // 文本框和按钮整体宽度
            tagInputTextField.widthAnchor.constraint(
                greaterThanOrEqualToConstant: 120
            ),
        ])

        // 底部上方：帖子板块标题 + CategoryCollectionView + 已添加标签展示
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            categoryTitleLabel.bottomAnchor.constraint(
                equalTo: CategoryCollectionView.topAnchor,
                constant: -4
            ),

            // 标签 Collection View 约束 (位于标签提示上方)
            CategoryCollectionView.heightAnchor.constraint(equalToConstant: 36),
            CategoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            CategoryCollectionView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            CategoryCollectionView.bottomAnchor.constraint(
                equalTo: tagListLabel.topAnchor,
                constant: -4
            ),

            // 已添加标签展示在 CategoryCollectionView 和 输入框之间
            tagListLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 16
            ),
            tagListLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -16
            ),
            tagListLabel.bottomAnchor.constraint(
                equalTo: tagInputTextField.topAnchor,
                constant: -4
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
            // 底部：明确约束到 CategoryCollectionView 的顶部，有 8pt 间距
            contentTextView.bottomAnchor.constraint(
                equalTo: CategoryCollectionView.topAnchor,
                constant: -8
            ),
        ])

    }

}
