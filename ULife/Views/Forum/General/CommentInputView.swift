//
//  CommentInputView.swift
//  ULife
//
//  Created by 骑鱼的猫 on 2025/12/10.
//  评论输入页面


import UIKit

class CommentInputView: UIView, UITextViewDelegate {
    
    var onSend: ((String) -> Void)? //点击方法给外部实现

    private let minHeight: CGFloat = 60
    private let maxHeight: CGFloat = 140

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "评论"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .label
        return label
    }()

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isScrollEnabled = false
        tv.delegate = self
        tv.layer.cornerRadius = 8
        tv.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return tv
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        label.text = "友善评论，传递温暖..."
        return label
    }()

    private lazy var sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return btn
    }()

    /// 对外暴露：让内部的文本视图获得焦点，触发键盘弹出
    func beginEditing() {
        textView.becomeFirstResponder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)

        addSubview(titleLabel)
        addSubview(textView)
        addSubview(sendButton)

        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false

        textView.addSubview(placeholderLabel)

        // 让发送按钮水平方向上抗拉伸抗压缩能力优先
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        sendButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            textView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            sendButton.leadingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            sendButton.bottomAnchor.constraint(equalTo: textView.bottomAnchor),
            
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 6),
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -4),
        ])
    }
    
    // 每当用户输入文本，textViewDidChange 就会被调用，然后 invalidateIntrinsicContentSize() 触发
    // intrinsicContentSize 返回理想宽高
    override var intrinsicContentSize: CGSize {
        // 在没有布局前，给一个大致的宽度，避免 0 宽导致计算错误
        let width = textView.bounds.width > 0 ? textView.bounds.width : UIScreen.main.bounds.width - 80
        
        let size = textView.sizeThatFits(CGSize(width: width, height: .infinity))
        // 额外加上标题区域和上下间距的高度
        let textPartHeight = size.height + 16
        let titlePartHeight: CGFloat = 28
        let totalHeight = textPartHeight + titlePartHeight
        
        let height = min(max(totalHeight, minHeight), maxHeight)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    // 发送评论
    @objc private func sendTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }

        onSend?(text)
        textView.text = ""
        textViewDidChange(textView)
    }
    
    // 文本框内容变化时调用
    func textViewDidChange(_ textView: UITextView) {
        // 内容变化时，让 Auto Layout 重新计算自身高度
        placeholderLabel.isHidden = !(textView.text?.isEmpty ?? true)
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }
}
