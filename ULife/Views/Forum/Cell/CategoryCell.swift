//
//  TagCell.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  板块删选栏的元素

import UIKit

class CategoryCell: UICollectionViewCell {
    
    static let identifier = "CategoryCell"
    
    //标签 label
    lazy var CategoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        label.textColor = .systemGray
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 添加 UI
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
    
    // 配置数据 选中/未选中状态
    func configure(with Category: String, isSelected: Bool) {
        CategoryLabel.text = Category
        if isSelected {
            CategoryLabel.textColor = .systemBlue
        } else {
            CategoryLabel.textColor = .label
        }
    }
    
}
