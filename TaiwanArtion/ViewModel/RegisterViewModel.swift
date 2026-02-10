//
//  RegisterViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/6/14.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol RegisterViewModelInput {
    //MARK: -StepOne
    // 國家資訊輸入Relay（UI還沒有設計）
    var inputCountryPreCodeInfoRelay: BehaviorRelay<String> { get }
    
    // 電話號碼輸入Relay
    var inputPhoneNumberRelay: BehaviorRelay<String> { get }
    
    // 寄送認證碼Relay
    var inputSendVerifyCodeActionSubject: PublishSubject<Void> { get }
    
    // 驗證碼輸入Relay
    var inputMessengeVerifyCodeRelay: BehaviorRelay<String> { get }
    
    // 檢驗驗證碼Subject
    var inputCheckVerifyCodeSubject: PublishSubject<Void> { get }
    
    //MARK: -StepTwo
    // 帳號輸入Relay
    var inputAccountInfoRelay: BehaviorRelay<String> { get }
    
    // 密碼輸入Relay
    var inputPasswordInfoRelay: BehaviorRelay<String> { get }
    
    //MARK: -StepThree
    //Email輸入認證Relay
    var inputEmailVerifyInfoRelay: BehaviorRelay<String> { get }
    
    //重新發送驗證碼進Email
    var inputReSendVerifyCodeSubject: PublishSubject<Void> { get }
}

protocol RegisterViewModelOutput {
    
    //輸出某些資訊
    
}

protocol RegisterInputOutputType {
    var input: RegisterViewModelInput { get }
    var output: RegisterViewModelOutput { get }
}

class RegisterViewModel: RegisterInputOutputType, RegisterViewModelInput, RegisterViewModelOutput {
    
    private let disposeBag = DisposeBag()
    
    //MARK: - Input
    var inputCountryPreCodeInfoRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputPhoneNumberRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputSendVerifyCodeActionSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    var inputMessengeVerifyCodeRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputCheckVerifyCodeSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    var inputAccountInfoRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputPasswordInfoRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputEmailVerifyInfoRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var inputReSendVerifyCodeSubject: PublishSubject<Void> = PublishSubject<Void>()
    
    //MARK: - Input、output
    var input: RegisterViewModelInput { self }
    
    var output: RegisterViewModelOutput { self }
    
    //MARK: - FirebaseAuth
    private let fireBaseAuth = FirebaseAuth()
    
    private var currentStep: RegisterStep = .phoneVerify
    
    var accountPasswordStep: AccountPasswordVerifyStep = .stepOne
    
    var emailVerifyStep: EmailVerifyStep = .stepOne
    
    //MARK: - Store
    
    private var storePhoneNumber: String = "" {
        didSet {
            AppLogger.debug("電話號碼已更新 (長度: \(storePhoneNumber.count))", category: .viewModel)
        }
    }
    
    init() {
        //input訂閱
        inputPhoneNumberRelay.subscribe(onNext: { [weak self] phoneNumber in
            self?.storePhoneNumber = phoneNumber
        })
        .disposed(by: disposeBag)

        inputSendVerifyCodeActionSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.fireBaseAuth.sendMessengeVerified(byPhoneNumber: self.storePhoneNumber)
        })
        .disposed(by: disposeBag)

        inputMessengeVerifyCodeRelay.subscribe(onNext: { code in

        })
        .disposed(by: disposeBag)

        inputReSendVerifyCodeSubject.subscribe(onNext: {
            AppLogger.debug("ReSend!", category: .viewModel)
        })
        .disposed(by: disposeBag)

        inputAccountInfoRelay.subscribe(onNext: { accountText in

        })
        .disposed(by: disposeBag)

        inputPasswordInfoRelay.subscribe(onNext: { passwordText in

        })
        .disposed(by: disposeBag)

    }
    
    func getCurrentStep() -> RegisterStep {
        return currentStep
    }
    
    func setCurrentStep(step: RegisterStep) {
        currentStep = step
        AppLogger.debug("currentStep:\(currentStep)", category: .viewModel)
    }
    
    //MARK: -StepCollectionView
    func stepsNumberOfRowInSection(section: Int) -> Int{
        return RegisterStep.allCases.count
    }
    
    func stepsCellForRowAt(indexPath: IndexPath) -> (stepString: String, isSelected: Bool) {
        let isSelected = RegisterStep(rawValue: indexPath.row) == currentStep
        return (RegisterStep.allCases[indexPath.row].title, isSelected)
    }
    
    func didSelectedRowAt(indexPath: IndexPath) {
        currentStep = RegisterStep(rawValue: indexPath.row)!
    }
}
