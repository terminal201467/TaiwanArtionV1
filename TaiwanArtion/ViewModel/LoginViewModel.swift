//
//  LoginViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/13.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol NormalLoginInput {
    
    //帳號Input
    var accountInput: BehaviorRelay<String> { get }
    //密碼Input
    var passwordInput: BehaviorRelay<String> { get }
    
    //登入Subject
    var loginActionSubject: PublishSubject<Void> { get }
    
    var toPrevented: BehaviorRelay<Bool> { get }
}

protocol NormalLoginOutput {

    var accountValidation: Signal<ValidationResult> { get }
    
    var passwordValidSuccess: Signal<[PasswordRequirement]> { get }
    
    var isLocked: BehaviorRelay<Bool> { get }
    
    var isPrevented: BehaviorRelay<Bool> { get }
    
    var loginSuccessRelay: BehaviorRelay<Bool> { get }
    
}

protocol NormalLoginViewModelType {
    
    var input: NormalLoginInput { get }
    
    var output: NormalLoginOutput { get }
}

class LoginViewModel: NormalLoginInput, NormalLoginOutput, NormalLoginViewModelType {
        
    private let disposeBag = DisposeBag()
    
    //MARK: -input
    var accountInput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var passwordInput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var toPrevented: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var loginActionSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    //MARK: -output
    var accountValidation: RxCocoa.Signal<ValidationResult> = Signal.just(.empty)
    
    var passwordValidSuccess: RxCocoa.Signal<[PasswordRequirement]> = Signal.just([])
    
    var isLocked: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var isPrevented: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var loginSuccessRelay: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    //MARK: - Firebase
    
    private let firebaseAuth = FirebaseAuth.shared
    
    //MARK: - UserDefault
    
    private let userDefaultInterface = UserDefaultInterface.shared
    
    //MARK: input/output
    var input: NormalLoginInput { self }
    
    var output: NormalLoginOutput { self }
    
    init() {
        accountInput.subscribe(onNext: { [weak self] text in
            guard self != nil else { return }
            AppLogger.debug("帳號輸入中", category: .viewModel)
        }).disposed(by: disposeBag)

        passwordInput.subscribe(onNext: { [weak self] _ in
            guard self != nil else { return }
            AppLogger.debug("密碼輸入中", category: .viewModel)
        }).disposed(by: disposeBag)

        toPrevented.subscribe(onNext: { [weak self] toPrevented in
            guard self != nil else { return }
        }).disposed(by: disposeBag)

        loginActionSubject.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.firebaseAuth.normalLogin(email: self.accountInput.value, password: self.passwordInput.value) { [weak self] user in
                guard let self = self else { return }
                self.userDefaultInterface.setUsername(user.name)
                self.userDefaultInterface.setGender(user.gender)
                self.userDefaultInterface.setBirth(user.birth)
                self.userDefaultInterface.setEmail(user.email)
                self.userDefaultInterface.setPhoneNumber(number: user.phone)
                self.userDefaultInterface.setHeadImage(user.headImage)
                self.userDefaultInterface.setIsLoggedIn(true)
            }
        })
        .disposed(by: disposeBag)
        
        loginSuccessRelay.accept(self.userDefaultInterface.getIsLoggedIn())
    }
    
    //MARK: -Account
    private func checkAccount(input: String) -> ValidationResult {
        //檢查帳號
        
        return .empty
    }
    
    //MARK: -Password
    private func checkPassword(input: String) -> [PasswordRequirement] {
        //檢查密碼
        
        return []
    }
    
}
