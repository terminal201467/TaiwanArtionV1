//
//  PersonalFileViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit


class PersonalFileViewController: UIViewController{

    private let welcomeRegisterView = WelcomeRegisterView()
    
    private let userManager = UserManager.shared
    
    private var alreadyLoginViewController: AlreadyLoginViewController?
    
    override func loadView() {
        super.loadView()
        view = welcomeRegisterView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setActions()
    }

    private func setActions() {
        welcomeRegisterView.registerAction = {
            let viewController = RegisterViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
        welcomeRegisterView.loginAction = {
            let viewController = LoginViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
            viewController.loginSuccess = {
                self.alreadyLoginViewController = AlreadyLoginViewController()
                self.navigationController?.pushViewController(self.alreadyLoginViewController!, animated: true)
            }
        }
        
        welcomeRegisterView.socialKitRegister = { socialKitKind in
            AppLogger.debug("socialKitKind: \(socialKitKind)", category: .ui)
            switch socialKitKind {
            case "facebook":
                self.userManager.input.facebookLoginSubject.onNext(self)
            case "google":
                self.userManager.input.googleLoginSubject.onNext(self)
            case "line": AppLogger.debug("not Define", category: .ui)
            default: AppLogger.debug("default", category: .ui)
            }
        }
    }

}
