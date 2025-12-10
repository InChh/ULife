//
//  ForumMainView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/2.
//  帖子页面主页 UI

import UIKit

class ForumMainView: UIView {
    
    /// UI
    // 滚动栏(选择板块)
    lazy var CategoryCollectionView: UICollectionView = {
        //常用的横排竖排布局
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8  // 标签之间的最小间距
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )  // 左右内边距

        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .systemGray6 
        cv.showsHorizontalScrollIndicator = false //是否显示横向滚动条
        cv.register(
            CategoryCell.self,
            forCellWithReuseIdentifier: CategoryCell.identifier
        )
        return cv
    }()

    // 列表视图 (放帖子)
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.backgroundColor = .systemGray6
        tv.separatorStyle = .none  // 去掉系统自带的分割线
        
        tv.register(
            ForumPostCell.self,
            forCellReuseIdentifier: ForumPostCell.identifier
        )
        return tv
    }()

    // 悬浮发帖按钮
    lazy var createPostButton: UIButton = {
        let btn = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        btn.setImage(
            UIImage(systemName: "plus", withConfiguration: config),
            for: .normal
        )

        btn.backgroundColor = .systemBlue
        btn.tintColor = .white
        btn.layer.cornerRadius = 28

        // 添加阴影让它浮起来
        btn.layer.shadowColor = UIColor.systemBlue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowRadius = 6

        return btn
    }()

    
    /// 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    /// 设置 UI
    private func setupUI() {
        backgroundColor = .systemGray6

        addSubview(CategoryCollectionView)
        addSubview(tableView)
        addSubview(createPostButton)

        CategoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        createPostButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            //Collection View
            CategoryCollectionView.topAnchor.constraint(
                equalTo: safeAreaLayoutGuide.topAnchor
            ),
            CategoryCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            CategoryCollectionView.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            CategoryCollectionView.heightAnchor.constraint(equalToConstant: 44),

            
            // TableView
            tableView.topAnchor.constraint(equalTo: CategoryCollectionView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            
            // 悬浮按钮 (右下角)
            createPostButton.widthAnchor.constraint(equalToConstant: 56),
            createPostButton.heightAnchor.constraint(equalToConstant: 56),
            createPostButton.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -20
            ),
            createPostButton.bottomAnchor.constraint(
                equalTo: safeAreaLayoutGuide.bottomAnchor,
                constant: -20
            ),
        ])
    }

}
