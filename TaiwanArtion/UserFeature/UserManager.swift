//
//  UserManager.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import RxRelay
import RxSwift

protocol UserManagerInput {
    
    //輸入嗜好
    var updateHabbyRelay: BehaviorRelay<[String]> { get }
    
    //輸入使用者名字
    var updateNameRelay: BehaviorRelay<String> { get }
    
    //輸入出生年月日
    var updateBirthRelay: BehaviorRelay<String> { get }
    
    //輸入性別
    var updateGenderRelay: BehaviorRelay<String> { get }
    
    //輸入聯絡方式
    var updatePhoneNumberRelay: BehaviorRelay<String> { get }
    
    //輸入email
    var updateEmailRelay: BehaviorRelay<String> { get }
    
    //輸入照片
    var updateHeadImageRelay: BehaviorRelay<String> { get }
    
    //儲存資料
    var saveDataSubject: PublishSubject<Void> { get }
    
    //googleLogin
    var googleLoginSubject: PublishSubject<UIViewController> { get }
    
    //facebookLogin
    var facebookLoginSubject: PublishSubject<UIViewController> { get }
    
    //createAccount
    var normalCreateAccountPubished: PublishRelay<(account: String, password: String)> { get }
    
    //normalLogin
    var normalLoginAccountPublished: PublishRelay<(account: String, password: String)> { get }
}

protocol UserManagerOutput {
    
    //目前是會回覆登入或沒有登入的狀態
    var outputIsLoginedRelay: BehaviorRelay<Bool> { get }
    ///怎麼樣會顯示為：有登入、沒有登入？
    
    //取得使用者名字
    var outputStoreNameRelay: BehaviorRelay<String> { get }
    
    //取得出生年月日
    var outputStoreBirthRelay: BehaviorRelay<String> { get }
    
    //取得性別
    var outputStoreGenderRelay: BehaviorRelay<String> { get }
    
    //取得聯絡方式
    var outputStorePhoneNumberRelay: BehaviorRelay<String> { get }
    
    //取得email
    var outputStoreEmailRelay: BehaviorRelay<String> { get }
    
    //取得照片
    var outputStoreHeadImageRelay: BehaviorRelay<String> { get }
    
}

protocol UserInputOutputType {
    var input: UserManagerInput { get }
    var output: UserManagerOutput { get }
}

class UserManager: UserInputOutputType, UserManagerInput, UserManagerOutput {
    
    private let disposeBag = DisposeBag()
        
    static let shared = UserManager()
    
    let userDefaultInterface = UserDefaultInterface.shared
    
    private let fireBaseDataBase = FirebaseDatabase(collectionName: "users")
    
    let fireBaseAuth = FirebaseAuth.shared
    
    //MARK: -Stream
    
    var input: UserManagerInput { self }
    
    var output: UserManagerOutput { self }
    
    //MARK: -Input
    
    var updateHabbyRelay: RxRelay.BehaviorRelay<[String]> = BehaviorRelay(value: [""])
    
    var updateNameRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var updateBirthRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var updateGenderRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var updatePhoneNumberRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var updateEmailRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var updateHeadImageRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var saveDataSubject: RxSwift.PublishSubject<Void> = PublishSubject()
    
    //MARK: -ThirdPartyKitLoginRelay
    var googleLoginSubject: RxSwift.PublishSubject<UIViewController> = PublishSubject()
    
    var facebookLoginSubject: RxSwift.PublishSubject<UIViewController> = PublishSubject()
    
    ///line登入
    
    //MARK: -Normal
    var normalCreateAccountPubished: RxRelay.PublishRelay<(account: String, password: String)> = PublishRelay()
    
    var normalLoginAccountPublished: RxRelay.PublishRelay<(account: String, password: String)> = PublishRelay()
    
    //MARK: -Output
    
    var outputIsLoginedRelay: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    
    var outputStoreNameRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var outputStoreBirthRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var outputStoreGenderRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var outputStorePhoneNumberRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var outputStoreEmailRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    var outputStoreHeadImageRelay: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    
    
    //MARK: -Initailization
    private init() {
        //input訂閱
        updateNameRelay.subscribe(onNext: { name in
            self.userDefaultInterface.setUsername(name)
        })
        .disposed(by: disposeBag)
        
        updateGenderRelay.subscribe(onNext: { gender in
            self.userDefaultInterface.setGender(gender)
        })
        .disposed(by: disposeBag)
        
        updateBirthRelay.subscribe(onNext: { birth in
            self.userDefaultInterface.setBirth(birth)
        })
        .disposed(by: disposeBag)
        
        updateEmailRelay.subscribe(onNext: { email in
            self.userDefaultInterface.setEmail(email)
        })
        .disposed(by: disposeBag)
        
        updateHabbyRelay.subscribe(onNext: { habbys in
            self.userDefaultInterface.setStoreHabby(habbys: habbys)
        })
        .disposed(by: disposeBag)
        
        updateHeadImageRelay.subscribe(onNext: { headImage in
            self.userDefaultInterface.setHeadImage(headImage)
        })
        .disposed(by: disposeBag)
        
        updatePhoneNumberRelay.subscribe(onNext: { phoneNumber in
            self.userDefaultInterface.setPhoneNumber(number: phoneNumber)
        })
        .disposed(by: disposeBag)
        
        saveDataSubject.subscribe(onNext: {
            print("Save!")
            self.uploadUserInfoToFireBase()
        })
        .disposed(by: disposeBag)
        
        googleLoginSubject.subscribe(onNext: { controller in
            self.googleLogin(controller: controller) { isLogin in
                print("isGoogleLogin Result:\(isLogin)")
            }
        })
        .disposed(by: disposeBag)
        
        facebookLoginSubject.subscribe(onNext: { controller in
            self.facebookLogin(controller: controller)
        })
        .disposed(by: disposeBag)
        
        normalCreateAccountPubished.subscribe(onNext: { account, password in
            self.normalCreateUser(email: account, password: password) { user in
                
            }
        })
        .disposed(by: disposeBag)
        
        normalLoginAccountPublished.subscribe(onNext: { account, password in
            self.normalUserLogin(email: account, password: password) { user in

            }
        })
        .disposed(by: disposeBag)
        
        //output訂閱
        outputIsLoginedRelay.accept(self.userDefaultInterface.getIsLoggedIn())
        
        outputStoreNameRelay.accept(self.userDefaultInterface.getUsername() ?? "未輸入名字")
        
        outputStoreGenderRelay.accept(self.userDefaultInterface.getGender() ?? "未輸入性別")
        
        outputStoreEmailRelay.accept(self.userDefaultInterface.getEmail() ?? "未輸入Email")
        
        outputStoreBirthRelay.accept(self.userDefaultInterface.getBirth() ?? "未輸入生日")
        
        outputStoreHeadImageRelay.accept(self.userDefaultInterface.getHeadImage() ?? "未輸入大頭照")
        
        outputStorePhoneNumberRelay.accept(self.userDefaultInterface.getPhoneNumber() ?? "未輸入電話號碼")
        
    }
    
    //MARK: - FirebaseAuth
    //Google驗證
    func googleLogin(controller: UIViewController, completionIsVerified: @escaping (Bool) -> Void) {
        fireBaseAuth.googleSignInAction(with: controller) { user in
            self.userDefaultInterface.setUsername(user.name)
            self.userDefaultInterface.setGender(user.gender)
            self.userDefaultInterface.setBirth(user.birth)
            self.userDefaultInterface.setEmail(user.email)
            self.userDefaultInterface.setPhoneNumber(number: user.phone)
            self.userDefaultInterface.setHeadImage(user.headImage)
            self.userDefaultInterface.setIsLoggedIn(true)
        }
         fireBaseAuth.googleSignIn(.sharedInstance, didSignInFor: .init(), withError: .none) { isEmailVerified in
            completionIsVerified(isEmailVerified)
        }
    }
    
    //Facebook驗證
    func facebookLogin(controller: UIViewController) {
        fireBaseAuth.facebookSignIn(with: controller) { user in
            self.userDefaultInterface.setUsername(user.name)
            self.userDefaultInterface.setGender(user.gender)
            self.userDefaultInterface.setBirth(user.birth)
            self.userDefaultInterface.setEmail(user.email)
            self.userDefaultInterface.setPhoneNumber(number: user.phone)
            self.userDefaultInterface.setHeadImage(user.headImage)
            self.userDefaultInterface.setIsLoggedIn(true)
        }
    }
    
    //一般用戶驗證
    func normalCreateUser(email: String, password: String, completion: @escaping (User) -> Void) {
        fireBaseAuth.normalCreateAccount(email: email, password: password) { user in
            completion(user)
        }
    }
    
    //一般用戶登入
    func normalUserLogin(email: String, password: String, completion: @escaping (User) -> Void) {
        fireBaseAuth.normalLogin(email: email, password: password) { user in
            completion(user)
        }
    }
    
    //MARK: - FireBaseDataBase
    //後台資料上傳
    private func uploadUserInfoToFireBase() {
        let storeUserInfo = ["birth" : self.userDefaultInterface.getBirth(),
                             "email" : self.userDefaultInterface.getEmail(),
                             "gender" : self.userDefaultInterface.getGender(),
                             "headImage" : self.userDefaultInterface.getHeadImage(),
                             "phone" : self.userDefaultInterface.getPhoneNumber(),
                             "username" : self.userDefaultInterface.getUsername()]
        fireBaseDataBase.createDocument(data: storeUserInfo) { documentID, error in
            if let error = error {
                print("上傳使用者資訊Error:\(error.localizedDescription)")
            }
            print("documentID:\(documentID)")
            self.userDefaultInterface.setDocumentID(identifier: documentID ?? "未知的ID")
        }
    }
    
    private func readUserInfoFromFireBase(documentID: String, completion: @escaping (User) -> Void) {
        fireBaseDataBase.readDocument(documentID: documentID) { data, error in
            if let error = error {
                print("error:\(error)")
            } else if let data = data {
                guard let name = data["username"] as? String,
                      let birth = data["birth"] as? String,
                      let email = data["email"] as? String,
                      let gender = data["gender"] as? String,
                      let phone = data["phone"] as? String,
                      let headImage = data["headImage"] as? String else { return }
                let userInfo = User(birth: birth,
                                    email: email,
                                    gender: gender,
                                    headImage: headImage,
                                    phone: phone,
                                    name: name)
                completion(userInfo)
            }
        }
    }
}
