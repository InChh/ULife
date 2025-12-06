//
//  ProfileSettingCell.swift
//  ULife
//
//  Created by 赵文哲 on 6/12/2025.
//  设置项单元格

import UIKit

class ProfileSettingCell: UITableViewCell {
    
    // MARK: - UI Components
    
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        return imageView
    }()
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private lazy var toggleSwitch: UISwitch = {
        let toggle = UISwitch()
        toggle.onTintColor = .systemBlue
        return toggle
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        contentView.backgroundColor = .secondarySystemBackground
        
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(accessoryImageView)
        contentView.addSubview(toggleSwitch)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryImageView.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 图标
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // 标题
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            
            // 副标题
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            
            // 右侧箭头
            accessoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 16),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 16),
            
            // 开关
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, subtitle: String? = nil, iconName: String, showSwitch: Bool = false, isOn: Bool = false, showAccessory: Bool = true) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.isHidden = subtitle == nil
        
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        iconImageView.image = UIImage(systemName: iconName, withConfiguration: config)
        
        accessoryImageView.isHidden = showSwitch || !showAccessory
        toggleSwitch.isHidden = !showSwitch
        toggleSwitch.isOn = isOn
    }
    
    func getSwitchValue() -> Bool {
        return toggleSwitch.isOn
    }
    
    func setSwitchValue(_ value: Bool) {
        toggleSwitch.isOn = value
    }
}
