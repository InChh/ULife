//
//  TagCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  标签删选栏的元素

import UIKit

class CategoryCell: UICollectionViewCell {
    
    //标识符
    static let identifier = "TagCell"
    
    //标签 label
    lazy var CategoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGray // 默认未选中颜色
        label.layer.cornerRadius = 16 // 圆角
        label.clipsToBounds = true
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(CategoryLabel)
        CategoryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            CategoryLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            CategoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            CategoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            CategoryLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 选中/未选中状态
    func configure(with tag: String, isSelected: Bool) {
        CategoryLabel.text = tag
        if isSelected {
            //tagLabel.backgroundColor = .systemBlue
            CategoryLabel.textColor = .systemBlue
        } else {
            //tagLabel.backgroundColor = .systemGray5
            CategoryLabel.textColor = .label
        }
    }
    
    // 返回标签的合适尺寸，让 Cell 自适应文本宽度
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 32) // 44是 Tag Collection View 的高度
        let size = CategoryLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: targetSize.height))
        
        // 文本宽度 + 左右各 16pt 填充
        layoutAttributes.frame.size.width = size.width + 16
        return layoutAttributes
    }
}
