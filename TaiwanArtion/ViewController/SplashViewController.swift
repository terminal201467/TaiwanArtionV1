//
//  SplashViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/11.
//

import UIKit
import RxSwift
import RxCocoa

public enum HabbyItem: Int, CaseIterable {
    case painting = 0, sculpture, calligraphy, design, camara, literature, media, installationArt, compositeMedia, history
    var imageText: String {
        switch self {
        case .painting: return "painting"
        case .sculpture: return "sculpture"
        case .calligraphy: return "calligraphy"
        case .design: return "design"
        case .camara: return "camara"
        case .literature: return "literature"
        case .media: return "media"
        case .installationArt: return "installationArt"
        case .compositeMedia: return "compositeMedia"
        case .history: return "history"
        }
    }
    var titleText: String {
        switch self {
        case .painting: return "繪畫"
        case .sculpture: return "雕塑"
        case .calligraphy: return "書法"
        case .design: return "設計"
        case .camara: return "攝影"
        case .literature: return "文學"
        case .media: return "影音"
        case .installationArt: return "裝置藝術"
        case .compositeMedia: return "複合媒材"
        case .history: return "歷史文物"
        }
    }
    
    var habbyTitleText: String {
        switch self {
        case .painting: return "繪畫"
        case .sculpture: return "雕塑"
        case .calligraphy: return "書法"
        case .design: return "設計"
        case .camara: return "攝影"
        case .literature: return "文學"
        case .media: return "影音"
        case .installationArt: return "藝術"
        case .compositeMedia: return "媒材"
        case .history: return "歷史"
        }
    }
    
    var homeHabbyImageText: String {
        switch self {
        case .painting: return "homePainting"
        case .sculpture: return "homeSculpture"
        case .calligraphy: return "homeCalligraphy"
        case .design: return "homeDesign"
        case .camara: return "homeCamara"
        case .literature: return "homeLiterature"
        case .media: return "homeMedia"
        case .installationArt: return "homeInstallationArt"
        case .compositeMedia: return "homeCompositeMedia"
        case .history: return "homeHistory"
        }
    }
}
class SplashViewController: UIViewController {
    
    private let splashView = SplashView()
    
    private let viewModel = SplashViewModel()
    
    private let disposeBag = DisposeBag()
    
    //MARK: - LifeCycle
    override func loadView() {
        super.loadView()
        view = splashView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setHabbyCollectionView()
        setNextButtonAllowTap()
        setHomeViewControllerPush()
    }
    
    private func setHabbyCollectionView() {
        splashView.habbyCollectionView.delegate = self
        splashView.habbyCollectionView.dataSource = self
    }
    
    private func setHomeViewControllerPush() {
        splashView.pushToHome = {
            let rootViewController = RootViewController()
            self.navigationController?.pushViewController(rootViewController, animated: true)
        }
    }
    
    private func setNextButtonAllowTap() {
        viewModel.allowTap = { allow in
            self.splashView.setNextButtonTappedOrNot(by: allow)
        }
    }
}

extension SplashViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return HabbyItem.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HabbyCollectionViewCell.reuseIdentifier, for: indexPath) as! HabbyCollectionViewCell
        cell.configureImageAndLabel(by: HabbyItem.allCases[indexPath.row])
        cell.handleSelectedItemView(by: viewModel.provideSelectedCell(indexPath: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedHabbyText = HabbyItem(rawValue: indexPath.item)?.titleText ?? ""
        viewModel.handleSelectedItem.accept(selectedHabbyText)
        viewModel.handleSelectedIndex.accept(indexPath.item)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 24, left: 25, bottom: 24, right: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - (25 * 2) - (16 * 3)) / 4
        let cellHeight = (collectionView.frame.height - (24 * 2)) / 4
        return CGSize(width: cellWidth, height: cellHeight)
    }
}
