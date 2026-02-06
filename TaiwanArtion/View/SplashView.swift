//
//  SplashView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/11.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit

enum StepType: Int, CaseIterable{
    case stepOne = 0, stepTwo, stepThree, stepFour, stepFive
    var buttonText: String {
        switch self {
        case .stepOne: return "Next"
        case .stepTwo: return "Next"
        case .stepThree: return "Next"
        case .stepFour: return "Get Started"
        case .stepFive: return "Next"
        }
    }
    
    var titleText: String {
        switch self {
        case .stepOne: return "早找展覽"
        case .stepTwo: return "附近展覽"
        case .stepThree: return "展覽月曆"
        case .stepFour: return "收藏展覽"
        case .stepFive: return ""
        }
    }
    
    var hintText: String {
        switch self {
        case .stepOne: return "讓你迅速找到你所喜愛的近期展覽"
        case .stepTwo: return "透過附近展覽，找到離你最近的有趣展覽！"
        case .stepThree: return "將喜歡的展覽加入您的專屬月曆中！"
        case .stepFour: return "將喜歡的展覽加入您的專屬月曆中！"
        case .stepFive: return ""
        }
    }
    
    var stepImage: String {
        switch self {
        case .stepOne: return "step1"
        case .stepTwo: return "step2"
        case .stepThree: return "step3"
        case .stepFour: return "step4"
        case .stepFive: return ""
        }
    }
}

class SplashView: UIView {
    
    //MARK: - Rx Settings
    private let disposeBag = DisposeBag()
    
    private let countDownTimer = CountdownTimer(timeInterval: 3)
    
    var pushToHome: (() -> (Void))?
    
    private var step: Int = 0 {
        didSet {
            if step < 5 {
                setForegroundStepSetting(by: .init(rawValue: step)!)
                setBackgroundStepSetting(by: .init(rawValue: step)!)
                skipView.currentSteps = step
            } else {
                self.pushToHome?()
            }
        }
    }
    
    //MARK: - Forground Object
    private let startView = StartView()
    
    private let skipView = SkipView()
    
    private let stepImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .heavy)
        label.textColor = .brownTitleColor
        return label
    }()
    
    private let hintLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        return label
    }()
    
    private lazy var labelStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, hintLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 10
        return stackView
    }()
    
    private let nextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private let nextImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "next")
        return imageView
    }()
    
    private lazy var nextStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [nextLabel, nextImage])
        stackView.spacing = 5
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()
    
    private let nextButton: UIView = {
       let view = UIView()
        view.roundCorners(cornerRadius: 20)
        view.backgroundColor = .brownColor
        return view
    }()
    
    //MARK: - 興趣、喜歡相關物件
    private let chooseHabbylabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .brownTitleColor
        label.text = "選擇你喜歡的興趣"
        return label
    }()
    
    private let chooseHintlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .grayTextColor
        label.text = "請選擇1~3項你喜歡的展覽類別"
        return label
    }()
    
    private lazy var chooseHabbyStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [chooseHabbylabel, chooseHintlabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        return stackView
    }()
    
    let habbyCollectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(HabbyCollectionViewCell.self, forCellWithReuseIdentifier: HabbyCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = nil
        return collectionView
    }()

    //MARK: - Background Object
    private let middleWaveImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let topWaveImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let bottomWaveImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundAutoLayout()
        foregroundAutoLayout()
        setNextButtonBinding()
        setForegroundStepSetting(by: .init(rawValue: step)!)
        setBackgroundStepSetting(by: .init(rawValue: step)!)
        setStartView()
        setStartViewRoutine()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setNextButtonTappedOrNot(by allowTap: Bool) {
        if allowTap {
            nextButton.backgroundColor = .brownColor
            nextLabel.textColor = .white
            nextButton.isUserInteractionEnabled = true
            nextImage.image = UIImage(named: "next")?.withTintColor(.white)
        } else {
            nextButton.backgroundColor = .whiteGrayColor
            nextLabel.textColor = .middleGrayColor
            nextButton.isUserInteractionEnabled = false
            nextImage.image = UIImage(named: "next")?.withTintColor(.middleGrayColor)
        }
    }
    
    private func setNextButtonBinding() {
        nextButton.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                if self.step < 5 {
                    self.nextButton.backgroundColor = .darkBrownColor
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.nextButton.backgroundColor = .brownColor
                        self.step += 1
                    }
                }
            })
            .disposed(by: disposeBag)
        
        skipView.skipValue
            .subscribe(onNext: { value in
                self.step = 5
            })
            .disposed(by: disposeBag)
    }
    
    private func foregroundAutoLayout() {
        nextLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }

        nextImage.snp.makeConstraints { make in
            make.height.equalTo(16)
            make.width.equalTo(16)
        }
        
        nextButton.addSubview(nextStack)
        nextStack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        addSubview(skipView)
        skipView.snp.makeConstraints { make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
        }
        
        addSubview(stepImageView)
        stepImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalTo(330)
            make.height.equalTo(316)
        }
        
        addSubview(labelStack)
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(stepImageView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        
        addSubview(nextButton)
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(labelStack.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
    }
    
    private func backgroundAutoLayout() {
        addSubview(middleWaveImage)
        middleWaveImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        addSubview(topWaveImage)
        topWaveImage.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        addSubview(bottomWaveImage)
        bottomWaveImage.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
    }
    
    private func setHabbyAutoLayout() {
        addSubview(chooseHabbyStack)
        chooseHabbyStack.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(30)
        }
        
        addSubview(habbyCollectionView)
        habbyCollectionView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(360.0 / 844.0)
            make.top.equalTo(chooseHabbyStack.snp.bottom)
        }
    }
    
    private func setBackgroundStepSetting(by step: StepType) {
        switch step {
        case .stepOne:
            middleWaveImage.image = UIImage(named: "stepOneWave")
            middleWaveImage.isHidden = false
            topWaveImage.isHidden = true
            bottomWaveImage.isHidden = true
            backgroundColor = .toffeeColor
        case .stepTwo:
            topWaveImage.image = UIImage(named: "stepTwoWave1")
            middleWaveImage.image = UIImage(named: "stepTwoWave2")
            topWaveImage.isHidden = false
            middleWaveImage.isHidden = false
            bottomWaveImage.isHidden = true
            backgroundColor = .caramelColor
        case .stepThree:
            topWaveImage.image = UIImage(named: "stepThreeWave1")
            bottomWaveImage.image = UIImage(named: "stepThreeWave2")
            middleWaveImage.isHidden = true
            topWaveImage.isHidden = false
            bottomWaveImage.isHidden = false
            backgroundColor = .caramelColor
        case .stepFour:
            topWaveImage.image = UIImage(named: "stepFourWave1")
            bottomWaveImage.image = UIImage(named: "stepFourWave2")
            middleWaveImage.isHidden = true
            topWaveImage.isHidden = false
            bottomWaveImage.isHidden = false
            backgroundColor = .caramelColor
        case .stepFive:
            middleWaveImage.image = UIImage(named: "line")
            bottomWaveImage.image = UIImage(named: "stepFiveWave1")
            topWaveImage.image = UIImage(named: "stepFiveWave2")
            topWaveImage.contentMode = .scaleAspectFill
            middleWaveImage.isHidden = false
            bottomWaveImage.isHidden = false
            backgroundColor = .caramelColor
        }
    }
    
    private func setForegroundStepSetting(by step: StepType) {
        stepImageView.image = UIImage(named: step.stepImage)
        titleLabel.text = step.titleText
        hintLabel.text = step.hintText
        nextLabel.text = step.buttonText
        if step == .stepFour {
            nextImage.isHidden = true
        } else {
            nextImage.isHidden = false
        }
        
        if step == .stepFive {
            stepImageView.isHidden = true
            skipView.isHidden = true
            nextButton.backgroundColor = .whiteGrayColor
            nextLabel.textColor = .middleGrayColor
            nextImage.image = UIImage(named: "next")?.withTintColor(.middleGrayColor)
            nextButton.isUserInteractionEnabled = false
            setHabbyAutoLayout()
        }
        
    }
    
    private func setStartViewRoutine() {
        countDownTimer.onTick = { timeRemaining in
            AppLogger.debug("Time remaining: \(timeRemaining)", category: .ui)
        }
        countDownTimer.onCompleted = {
            self.removeStartView()
        }
        countDownTimer.start()
    }
    
    private func setStartView() {
        addSubview(startView)
        startView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func removeStartView() {
        self.startView.removeFromSuperview()
    }
}
