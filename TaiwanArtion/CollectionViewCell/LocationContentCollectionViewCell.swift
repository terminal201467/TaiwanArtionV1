//
//  LocationContentCollectionViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/18.
//

import UIKit
import RxCocoa

class LocationContentCollectionViewCell: BaseCollectionViewCell {

    //MARK: -Signals
    var lookUpLocationSignal: Signal<Void> = Signal.just(())

    var lookUpExhibitionHallSignal: Signal<Void> = Signal.just(())

    //MARK: -Titles
    private let exhibitionImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.roundCorners(cornerRadius: 8)
        return imageView
    }()

    private let exhibitionTitlelabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .black
        return label
    }()

    //MARK: - Locations
    private let locationImage: UIImageView = {
        let imageView = UIImageView(image: .init(named: "locationIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()

    private lazy var locationInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationImage, locationLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()

    //MARK: -Times
    private let timeImage: UIImageView = {
        let imageView = UIImageView(image: .init(named: "timeIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()

    private lazy var timeInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [timeImage, timeLabel])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        return stackView
    }()

    private lazy var locationAndTimeStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [locationInfoStack, timeInfoStack])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    //MARK: -LookUpButtons
    private let lookUpLocationButton: UIButton = {
        let button = UIButton()
        button.setTitle("查看位置", for: .normal)
        button.setTitleColor(.brownTitleColor, for: .normal)
        button.backgroundColor = .white
        button.roundCorners(cornerRadius: 12)
        button.addBorder(borderWidth: 1, borderColor: .brownColor)
        return button
    }()

    private let lookUpExhibitionHallButton: UIButton = {
        let button = UIButton()
        button.setTitle("查看展覽館", for: .normal)
        button.setTitleColor(.grayTextColor, for: .normal)
        button.backgroundColor = .whiteGrayColor
        button.roundCorners(cornerRadius: 12)
        return button
    }()

    private lazy var infoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exhibitionTitlelabel, locationInfoStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    private lazy var imageAndInfoStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [exhibitionImage, infoStack])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 8
        return stackView
    }()

    private lazy var lookUpStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [lookUpLocationButton, lookUpExhibitionHallButton])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()

    private lazy var contentStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageAndInfoStack, lookUpStack])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 15.5
        return stackView
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.roundCorners(cornerRadius: 12)
        view.backgroundColor = .white
        return view
    }()

    override func setupCell() {
        autoLayout()
        setButtonSubscription()
    }

    override func cleanupForReuse() {
        exhibitionImage.image = nil
        exhibitionTitlelabel.text = nil
        locationLabel.text = nil
        timeLabel.text = nil
        lookUpLocationSignal = Signal.just(())
        lookUpExhibitionHallSignal = Signal.just(())
    }

    private func autoLayout() {
        addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        exhibitionImage.snp.makeConstraints { make in
            make.height.equalTo(42.0)
            make.width.equalTo(42.0)
        }

        locationImage.snp.makeConstraints { make in
            make.height.equalTo(16.0)
            make.width.equalTo(16.0)
        }

        timeImage.snp.makeConstraints { make in
            make.height.equalTo(16.0)
            make.width.equalTo(16.0)
        }

        lookUpLocationButton.snp.makeConstraints { make in
            make.height.equalTo(34.0)
        }

        lookUpExhibitionHallButton.snp.makeConstraints { make in
            make.height.equalTo(34.0)
        }

        containerView.addSubview(contentStack)
        contentStack.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-12)
        }
    }

    private func setButtonSubscription() {
        lookUpLocationSignal = lookUpLocationButton.rx.tap.asSignal()
        lookUpExhibitionHallSignal = lookUpExhibitionHallButton.rx.tap.asSignal()
    }

    func configure(hallInfo: ExhibitionHallInfo) {
        exhibitionImage.image = .init(named: "defaultLocationImage")
        exhibitionTitlelabel.text = hallInfo.title
        locationLabel.text = hallInfo.location
        timeLabel.text = "營業中\(hallInfo.time)"
    }
}
