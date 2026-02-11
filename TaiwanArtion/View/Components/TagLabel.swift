//
//  TagLabel.swift
//  TaiwanArtion
//
//  Created by Claude on 2026/2/11.
//

import UIKit
import SnapKit

/// 可復用的標籤 Label 組件
/// 支援多種樣式配置
final class TagLabel: UIView {

    // MARK: - Style

    enum Style {
        case primary    // 黃色背景，白色文字
        case secondary  // 灰色背景，深色文字
        case outlined   // 透明背景，邊框

        var backgroundColor: UIColor {
            switch self {
            case .primary: return .tagYellowColor
            case .secondary: return .systemGray5
            case .outlined: return .clear
            }
        }

        var textColor: UIColor {
            switch self {
            case .primary: return .white
            case .secondary: return .darkGray
            case .outlined: return .brownColor
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .outlined: return 1
            default: return 0
            }
        }

        var borderColor: UIColor {
            return .brownColor
        }
    }

    // MARK: - Properties

    private let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    private var style: Style = .primary

    // MARK: - Init

    init(style: Style = .primary) {
        self.style = style
        super.init(frame: .zero)
        setupUI()
        applyStyle()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        applyStyle()
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8))
        }

        setSpecificRoundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
    }

    private func applyStyle() {
        backgroundColor = style.backgroundColor
        label.textColor = style.textColor
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
    }

    // MARK: - Public Methods

    func configure(text: String) {
        label.text = text
    }

    func setStyle(_ style: Style) {
        self.style = style
        applyStyle()
    }

    var text: String? {
        get { label.text }
        set { label.text = newValue }
    }
}
