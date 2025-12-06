//
//  TagCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  标签删选栏的元素

import UIKit

class TagCell: UICollectionViewCell {
    
    //标识符
    static let identifier = "TagCell"
    
    //标签 label
    lazy var tagLabel: UILabel = {
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
        contentView.addSubview(tagLabel)
        tagLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tagLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            tagLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            tagLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 选中/未选中状态
    func configure(with tag: String, isSelected: Bool) {
        tagLabel.text = tag
        if isSelected {
            tagLabel.backgroundColor = .systemBlue
            tagLabel.textColor = .white
        } else {
            tagLabel.backgroundColor = .systemGray5
            tagLabel.textColor = .label
        }
    }
    
    // 返回标签的合适尺寸，让 Cell 自适应文本宽度
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let targetSize = CGSize(width: layoutAttributes.frame.width, height: 44) // 44是 Tag Collection View 的高度
        let size = tagLabel.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: targetSize.height))
        
        // 文本宽度 + 左右各 16pt 填充
        layoutAttributes.frame.size.width = size.width + 32
        return layoutAttributes
    }
}
