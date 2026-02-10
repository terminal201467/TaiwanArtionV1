//
//  MainPhotosTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/18.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class MainPhotosTableViewCell: BaseTableViewCell {

    var mainPhotos: [ExhibitionInfo] = []

    private var photoObservable: Observable<[ExhibitionInfo]> { Observable.just(mainPhotos) }
    
    var pushToViewController: ((ExhibitionInfo) -> Void)?
    
    private let viewModel = HomeViewModel.shared
    
    private let collectionView: UICollectionView = {
       let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(MainPhotosCollectionViewCell.self, forCellWithReuseIdentifier: MainPhotosCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let mainDotContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let mainDotfooterView = MainDotBarFooterView()

    override func setupCell() {
        setCollectionViewBinding()
        autoLayout()
        setDotView()
    }

    override func cleanupForReuse() {
        mainPhotos = []
        pushToViewController = nil
    }
    
    private func setCollectionViewBinding() {
        collectionView.rx.setDelegate(self)
        viewModel.inputs.mainPhotoSelected
            .subscribe { index in
                AppLogger.debug("index:\(index)", category: .ui)
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.mainPhotoRelay
            .bind(to: collectionView.rx.items(cellIdentifier: MainPhotosCollectionViewCell.reuseIdentifier, cellType: MainPhotosCollectionViewCell.self)) { (row, item, cell) in
                cell.configure(item: item)
            }
            .disposed(by: disposeBag)
    }
    
    private func setDotView() {
        mainDotfooterView.currentDotIndex = { [weak self] index in
            self?.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
        }
    }
    
    private func findAndStoreCenteredCellIndexPath() {
        let centerX = collectionView.contentOffset.x + collectionView.bounds.width / 2
        if let indexPath = collectionView.indexPathForItem(at: CGPoint(x: centerX, y: collectionView.bounds.height / 2)) {
            mainDotfooterView.configureIndex(currentIndex: indexPath.row)
        }
    }

    private func autoLayout() {
        contentView.addSubview(mainDotContainerView)
        contentView.addSubview(collectionView)
        contentView.backgroundColor = .white
        mainDotContainerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(15.0)
        }
        
        mainDotContainerView.addSubview(mainDotfooterView)
        mainDotfooterView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(150.0)
            make.height.equalTo(10.0)
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(mainDotfooterView.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}

extension MainPhotosTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = collectionView.frame.height - (16 * 2)
        let cellWidth = frame.width - 45 * 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        findAndStoreCenteredCellIndexPath()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            findAndStoreCenteredCellIndexPath()
        }
    }
}
