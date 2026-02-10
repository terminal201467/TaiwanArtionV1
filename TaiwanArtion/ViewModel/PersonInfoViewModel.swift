//
//  PersonInfoViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/6.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import Differentiator

struct SectionModel: SectionModelType {
    typealias Item = PersonInfoCellModel

    var items: [PersonInfoCellModel] = []

    init(original: SectionModel, items: [PersonInfoCellModel]) {
        self = original
        self.items = items
    }

    init(sectionName: String, cellModels: [PersonInfoCellModel]) {
        self.sectionName = sectionName
        self.cellModels = cellModels
    }

    let sectionName: String
    let cellModels: [PersonInfoCellModel]

    struct PersonInfoCellModel {
        let infoType: PersonInfo
        let textFieldPlaceholder: String
    }
}

enum PersonInfo: Int, CaseIterable {
    case name = 0, gender, birth, email, phone, save
    var section: String {
        switch self {
        case .name: return "姓名"
        case .gender: return "性別"
        case .birth: return "生日"
        case .email: return "電子郵件"
        case .phone: return "手機號碼"
        case .save: return ""
        }
    }
    
    var placeHolder: String {
        switch self {
        case .name: return "請輸入你的姓名"
        case .gender: return "請選擇你的性別"
        case .birth: return "選擇日期"
        case .email: return "請輸入你的電子郵件"
        case .phone: return "請輸入你的手機號碼"
        case .save: return "儲存"
        }
    }
}

protocol PersonInfoInput {
    var nameInput: BehaviorRelay<String> { get }
    var genderInput: BehaviorRelay<String> { get }
    var birthMonthInput: BehaviorRelay<String> { get }
    var birthDateInput: BehaviorRelay<String> { get }
    var birthYearIntput: BehaviorRelay<String> { get }
    var emailInput: BehaviorRelay<String> { get }
    var phoneInput: BehaviorRelay<String> { get }
    var saveAction: PublishSubject<Void> { get }
}

protocol PersonInfoOutput {
    var saveCheck: BehaviorRelay<Bool> { get }
    var personInfo: Observable<[PersonInfo]> { get }
    var tableItemInfo: Observable<[SectionModel]> { get }
    var dateOutput: BehaviorRelay<String> { get }
    var monthOutput: BehaviorRelay<String> { get }
}

protocol PersonInfoViewModelType {
    var input: PersonInfoInput { get }
    var output: PersonInfoOutput { get }
}

class PersonInfoViewModel: PersonInfoInput, PersonInfoOutput, PersonInfoViewModelType {
   
    private let disposeBag = DisposeBag()
    
    //MARK: -Input
    var nameInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    var genderInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    var birthMonthInput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var birthDateInput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var birthYearIntput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var emailInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    var phoneInput: BehaviorRelay<String> = BehaviorRelay(value: "")
    var saveAction: PublishSubject<Void> = PublishSubject<Void>()
    
    //MARK: -Output
    var saveCheck: BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var personInfo: Observable<[PersonInfo]> = Observable.just(PersonInfo.allCases)
    var tableItemInfo: Observable<[SectionModel]> { Observable.just(tableItems) }
    var dateOutput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var monthOutput: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    private let tableItems: [SectionModel] = [
        .init(sectionName: PersonInfo.name.section, cellModels: [.init(infoType: .name, textFieldPlaceholder: PersonInfo.name.placeHolder)]),
        .init(sectionName: PersonInfo.gender.section, cellModels: [.init(infoType: .gender, textFieldPlaceholder: PersonInfo.gender.placeHolder)]),
        .init(sectionName: PersonInfo.birth.section, cellModels: [.init(infoType: .birth, textFieldPlaceholder: PersonInfo.birth.placeHolder)]),
        .init(sectionName: PersonInfo.email.section, cellModels: [.init(infoType: .email, textFieldPlaceholder: PersonInfo.email.section)]),
        .init(sectionName: PersonInfo.phone.section, cellModels: [.init(infoType: .phone, textFieldPlaceholder: PersonInfo.phone.placeHolder)])
    ]
    
    //MARK: -Input、Output
    var input: PersonInfoInput { self }
    var output: PersonInfoOutput { self }
    
    //MARK: -Initialization
    init() {
        nameInput.subscribe { text in
            AppLogger.debug("nameInputText:\(text)", category: .viewModel)
        }
        .disposed(by: disposeBag)

        genderInput.subscribe { text in
            AppLogger.debug("genderInput:\(text)", category: .viewModel)
        }
        .disposed(by: disposeBag)

        birthMonthInput.subscribe(onNext: { [weak self] monthText in
            AppLogger.debug("monthText:\(monthText)", category: .viewModel)
            self?.monthOutput.accept(monthText)
        }).disposed(by: disposeBag)

        birthDateInput.subscribe(onNext: { [weak self] dateText in
            AppLogger.debug("dateText:\(dateText)", category: .viewModel)
            self?.dateOutput.accept(dateText)
        }).disposed(by: disposeBag)

        birthYearIntput.subscribe(onNext: { [weak self] yearText in
            _ = self // suppress unused warning
        }).disposed(by: disposeBag)
        
        emailInput.subscribe { text in
            AppLogger.debug("emailInput:\(text)", category: .viewModel)
        }
        .disposed(by: disposeBag)

        phoneInput.subscribe { text in
            AppLogger.debug("phoneInput:\(text)", category: .viewModel)
        }
        .disposed(by: disposeBag)
        
        //checkInput is empty or not
        checkInput()
    }
    
    private func checkInput() {
        Observable.combineLatest(nameInput, genderInput, birthDateInput, birthMonthInput, birthYearIntput, emailInput, phoneInput)
            .map { name, gender, birthDate, birthMonth, birthYear, email, phone in
                return !name.isEmpty && !gender.isEmpty && !email.isEmpty && !phone.isEmpty && !birthMonth.isEmpty && !birthDate.isEmpty && !birthYear.isEmpty
            }
            .bind(to: saveCheck)
            .disposed(by: disposeBag)
    }
}
