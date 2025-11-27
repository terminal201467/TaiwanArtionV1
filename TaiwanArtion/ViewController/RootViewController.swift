//
//  RootViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/11.
//

import UIKit
import RxSwift
import FirebaseCore

class RootViewController: UITabBarController {
    
    private let disposeBag = DisposeBag()
    
    //MARK: - ViewControllers
    private let homeViewController = UINavigationController(rootViewController: HomeViewController())
    
    private let nearViewController = UINavigationController(rootViewController: NearViewController())
    
    private let collectionViewController = UINavigationController(rootViewController: CollectViewController())
    
    private let calendarViewController = ExhibitionCalendarViewController()
    
    private var personFileViewController: UIViewController?
    
    private let userManager = UserManager.shared
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setPersonFileViewController()
        setTabBar()
    }
    
    //MARK: - Methods
    private func setNavigationBar() {
        navigationItem.hidesBackButton = true
    }
    
    private func setTabBar() {
        homeViewController.tabBarItem = UITabBarItem(title: "首頁",
                                                     image: UIImage(named: "home")?.withRenderingMode(.alwaysOriginal),
                                                     selectedImage: UIImage(named: "homeSelected")?.withRenderingMode(.alwaysOriginal))
        homeViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.brownTitleColor], for: .selected)
        nearViewController.tabBarItem = UITabBarItem(title: "附近展覽",
                                                     image: UIImage(named: "near")?.withRenderingMode(.alwaysOriginal),
                                                     selectedImage: UIImage(named: "nearSelected")?.withRenderingMode(.alwaysOriginal))
        nearViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.brownTitleColor], for: .selected)
        collectionViewController.tabBarItem = UITabBarItem(title: "收藏展覽",
                                                           image: UIImage(named: "collect")?.withRenderingMode(.alwaysOriginal),
                                                           selectedImage: UIImage(named: "collectSelect")?.withRenderingMode(.alwaysOriginal))
        collectionViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.brownTitleColor], for: .selected)
        calendarViewController.tabBarItem = UITabBarItem(title: "展覽月曆",
                                                         image: UIImage(named: "calendar")?.withRenderingMode(.alwaysOriginal),
                                                         selectedImage: UIImage(named: "calendarSelected")?.withRenderingMode(.alwaysOriginal))
        calendarViewController.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.brownTitleColor], for: .selected)
        personFileViewController?.tabBarItem = UITabBarItem(title: "個人檔案",
                                                           image: UIImage(named: "personal")?.withRenderingMode(.alwaysOriginal),
                                                           selectedImage: UIImage(named: "personalSelected")?.withRenderingMode(.alwaysOriginal))
        personFileViewController?.tabBarItem.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.brownTitleColor], for: .selected)
        viewControllers = [homeViewController, nearViewController, collectionViewController, calendarViewController, personFileViewController!]
        view.backgroundColor = .white
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .white
        tabBar.setSpecificRoundCorners(corners: [.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 12)
    }
    
    private func setPersonFileViewController() {
        userManager.output.outputIsLoginedRelay
            .subscribe(onNext: { isLogined in
                print("isLogined:\(isLogined)")
                if isLogined {
                    //已經登入的狀態
                    self.personFileViewController = UINavigationController(rootViewController: AlreadyLoginViewController())
                } else {
                    //未登入的狀態
                    self.personFileViewController = UINavigationController(rootViewController: PersonalFileViewController())
                }
            })
            .disposed(by: disposeBag)
        
    }
}

