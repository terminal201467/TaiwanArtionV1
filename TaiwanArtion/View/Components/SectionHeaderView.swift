//
//  SectionHeaderView.swift
//  TaiwanArtion
//
//  Created by Claude on 2026/2/11.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

/// 可復用的區段標頭組件
/// 支援標題、副標題、按鈕
final class SectionHeaderView: UIView {

    // MARK: - Configuration

    struct Configuration {
        var titleFont: UIFont = .systemFont(ofSize: 18, weight: .semibold)
        var titleColor: UIColor = .brownTitleColor
        var buttonTitle: String? = nil
        var showSeeAllButton: Bool = false
        var height: CGFloat = 50

        static let `default` = Configuration()
        static let withSeeAll = Configuration(buttonTitle: "查看全部", showSeeAllButton: true)
    }

    // MARK: - Callbacks

    var onButtonTapped: (() -> Void)?

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private var configuration: Configuration

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        label.textAlignment = .left
        label.isHidden = true
        return label
    }()

    private lazy var titleStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitleColor(.brownColor, for: .normal)
        button.isHidden = true
        return button
    }()

    // MARK: - Init

    init(configuration: Configuration = .default) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupUI()
        setupBindings()
        applyConfiguration()
    }

    required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        setupUI()
        setupBindings()
        applyConfiguration()
    }

    // MARK: - Setup

    private func setupUI() {
        addSubview(titleStack)
        addSubview(actionButton)

        titleStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualTo(actionButton.snp.leading).offset(-8)
        }

        actionButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }

    private func setupBindings() {
        actionButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.onButtonTapped?()
            })
            .disposed(by: disposeBag)
    }

    private func applyConfiguration() {
        titleLabel.font = configuration.titleFont
        titleLabel.textColor = configuration.titleColor

        if let buttonTitle = configuration.buttonTitle {
            actionButton.setTitle(buttonTitle, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = !configuration.showSeeAllButton
        }
    }

    // MARK: - Public Methods

    func configure(title: String, subtitle: String? = nil) {
        titleLabel.text = title
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.isHidden = true
        }
    }

    func setButtonTitle(_ title: String?) {
        if let title = title {
            actionButton.setTitle(title, for: .normal)
            actionButton.isHidden = false
        } else {
            actionButton.isHidden = true
        }
    }

    func hideButton() {
        actionButton.isHidden = true
    }

    func showButton() {
        actionButton.isHidden = false
    }
}
