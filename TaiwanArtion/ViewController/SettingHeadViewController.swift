//
//  SettingHeadViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/6.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

enum PhotoKinds: Int, CaseIterable {
    case hint = 0, photos , button
}

class SettingHeadViewController: UIViewController {
    
    private let settingHeadView = SettingHeadView()
    
    private let viewModel = SettingHeadViewModel()
    
    private let disposeBag = DisposeBag()
    
    var selectedHeadPhoto: ((Any) -> ())?
    
    override func loadView() {
        super.loadView()
        view = settingHeadView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setCollectionView()
    }
    
    private func setNavigationBar() {
        title = "設定大頭貼"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let backButton = UIBarButtonItem(image: .init(named: "back")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func back() {
        if viewModel.output.storeHead.value != nil {
            viewModel.input.resetHead.onNext(())
            selectedHeadPhoto?("defaultPeronImage")
        }
        navigationController?.popViewController(animated: true)
    }
    
    private func setCollectionView() {
        settingHeadView.collectionView.delegate = self
        settingHeadView.collectionView.dataSource = self
    }
}

extension SettingHeadViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return PhotoKinds.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch PhotoKinds(rawValue: section) {
        case .hint: return 1
        case .photos: return viewModel.output.headImagesObservable.value.count
        case .button: return 1
        case .none: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch PhotoKinds(rawValue: indexPath.section) {
        case .hint:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HintCollectionViewCell.reuseIdentifier, for: indexPath) as! HintCollectionViewCell
            cell.configure(hint: "選擇你喜歡的頭像或上傳你的照片")
            return cell
        case .photos:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HeadPhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! HeadPhotoCollectionViewCell
            let acceptIndex = viewModel.input.inputCellForRowAt.accept(indexPath)
            let headImage = viewModel.output.outputCellContentForRowAt.value
            let isSelected = viewModel.output.outputCellSelectedForRowAt.value
            if indexPath.row == 0 {
                cell.configure(imageString: headImage as! String)
            } else {
                headImage is String ? cell.configure(imageString: headImage as! String, isSelected: isSelected) : cell.configure(imageData: headImage as! Data, isSelected: isSelected)
            }
            return cell
        case .button:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCollectionViewCell.reuseIdentifier, for: indexPath) as! ButtonCollectionViewCell
            viewModel.output.isAllowSavePhoto
                .subscribe(onNext: { [weak cell] allowed in
                    cell?.configureRoundButton(isAllowToTap: allowed, buttonTitle: "儲存")
                })
                .disposed(by: disposeBag)
            cell.action = { [weak self] in
                guard let self = self else { return }
                self.viewModel.input.savePhoto.onNext(())
                self.navigationController?.popViewController(animated: true)
            }
            return cell
        case .none: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.input.selectedHeadImageIndex.onNext(indexPath)
        if PhotoKinds(rawValue: indexPath.section) == .photos {
           //如果選擇
            //點按第一個，會跳到選擇圖片的頁面
            if indexPath.row == 0 {
                //推到選擇大頭貼的照片頁面
//                selectedHeadPhoto?(<#Any#>)
            } else {
                viewModel.input.selectedHeadImageIndex.onNext(indexPath)
                selectedHeadPhoto?(viewModel.output.storeHead.value)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch PhotoKinds(rawValue: indexPath.section) {
        case .hint:
            let cellWidth = (collectionView.frame.width - 16 * 2)
            let cellHeight = 40.0
            return CGSize(width: cellWidth, height: cellHeight)
        case .photos:
            let cellSize = (collectionView.frame.width - 22 * 3) / 4
            return CGSize(width: cellSize, height: cellSize)
        case .button:
            let cellWidth = (collectionView.frame.width - 16 * 2)
            let cellHeight = 40.0
            return CGSize(width: cellWidth, height: cellHeight)
        case .none: return CGSize()
        }
    }
    
    
}
