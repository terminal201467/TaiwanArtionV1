//
//  ExhibitionInfoView.swift
//  TaiwanArtion
//
//  Created by Claude on 2026/2/11.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

/// 可復用的展覽資訊顯示組件
/// 包含圖片、標籤、標題、日期、地點、收藏按鈕
class ExhibitionInfoView: UIView {

    // MARK: - Configuration

    struct Configuration {
        var showCollectButton: Bool = true
        var showLocationInfo: Bool = true
        var showTag: Bool = true
        var imageCornerRadius: CGFloat = 8
        var titleFont: UIFont = .systemFont(ofSize: 16)
        var dateFont: UIFont = .systemFont(ofSize: 12)

        static let `default` = Configuration()
        static let compact = Configuration(showLocationInfo: false)
    }

    // MARK: - Callbacks

    var onCollectTapped: ((Bool) -> Void)?

    // MARK: - Properties

    private let disposeBag = DisposeBag()
    private var isCollected: Bool = false
    private var configuration: Configuration

    // MARK: - UI Elements

    private let exhibitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let tagContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .tagYellowColor
        view.setSpecificRoundCorners(corners: [.layerMaxXMinYCorner, .layerMinXMaxYCorner], radius: 8)
        return view
    }()

    private let tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()

    private let collectButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "collect"), for: .normal)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayTextColor
        label.textAlignment = .left
        return label
    }()

    private let locationIconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "near"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .grayTextColor
        return label
    }()

    private lazy var locationStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationIconImageView, locationLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, dateLabel, locationStack])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 4
        return stackView
    }()

    // MARK: - Init

    init(configuration: Configuration = .default) {
        self.configuration = configuration
        super.init(frame: .zero)
        setupUI()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        setupUI()
        setupBindings()
    }

    // MARK: - Setup

    private func setupUI() {
        exhibitionImageView.roundCorners(cornerRadius: configuration.imageCornerRadius)
        titleLabel.font = configuration.titleFont
        dateLabel.font = configuration.dateFont

        addSubview(exhibitionImageView)
        addSubview(infoStack)

        exhibitionImageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(exhibitionImageView.snp.width).multipliedBy(0.7)
        }

        infoStack.snp.makeConstraints { make in
            make.top.equalTo(exhibitionImageView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }

        if configuration.showTag {
            addSubview(tagContainerView)
            tagContainerView.addSubview(tagLabel)

            tagContainerView.snp.makeConstraints { make in
                make.leading.equalTo(exhibitionImageView)
                make.bottom.equalTo(exhibitionImageView)
                make.width.equalTo(40)
                make.height.equalTo(24)
            }

            tagLabel.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }

        if configuration.showCollectButton {
            addSubview(collectButton)
            collectButton.snp.makeConstraints { make in
                make.top.equalTo(exhibitionImageView).offset(8)
                make.trailing.equalTo(exhibitionImageView).offset(-8)
                make.width.height.equalTo(32)
            }
        }

        if !configuration.showLocationInfo {
            locationStack.isHidden = true
        }

        locationIconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(12)
        }
    }

    private func setupBindings() {
        collectButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.isCollected.toggle()
                self.updateCollectButton()
                self.onCollectTapped?(self.isCollected)
            })
            .disposed(by: disposeBag)
    }

    private func updateCollectButton() {
        let imageName = isCollected ? "collectSelected" : "collect"
        collectButton.setImage(UIImage(named: imageName), for: .normal)
    }

    // MARK: - Public Methods

    func configure(with exhibition: ExhibitionInfo) {
        titleLabel.text = exhibition.title
        dateLabel.text = exhibition.dateString
        locationLabel.text = exhibition.location
        tagLabel.text = exhibition.tag

        // 使用 UIImageView+Loading extension
        exhibitionImageView.loadImage(from: exhibition.image)
    }

    func configure(
        image: String,
        title: String,
        date: String,
        location: String? = nil,
        tag: String? = nil
    ) {
        titleLabel.text = title
        dateLabel.text = date
        locationLabel.text = location
        tagLabel.text = tag

        exhibitionImageView.loadImage(from: image)
    }

    func setCollected(_ collected: Bool) {
        isCollected = collected
        updateCollectButton()
    }

    func reset() {
        exhibitionImageView.image = nil
        titleLabel.text = nil
        dateLabel.text = nil
        locationLabel.text = nil
        tagLabel.text = nil
        isCollected = false
        updateCollectButton()
    }

    /// 取消圖片下載任務
    func cancelImageLoad() {
        exhibitionImageView.cancelImageLoad()
    }
}
