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

class MainPhotosTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "MainPhotosTableViewCell"
    
    var mainPhotos: [ExhibitionInfo] = []
    
    private var photoObservable: Observable<[ExhibitionInfo]> { Observable.just(mainPhotos) }
    
    private let disposeBag = DisposeBag()
    
    var pushToViewController: ((ExhibitionInfo) -> Void)?
    
    private let viewModel = HomeViewModel.shared
    
    private let collectionView: UICollectionView = {
       let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 16
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(MainPhotosCollectionViewCell.self, forCellWithReuseIdentifier: MainPhotosCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private let footerView = MainDotBarFooterView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setCollectionViewBinding()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setCollectionViewBinding() {
        collectionView.rx.setDelegate(self)
        viewModel.inputs.mainPhotoSelected
            .subscribe { index in
                print("index:\(index)")
            }
            .disposed(by: disposeBag)
        
        viewModel.outputs.mainPhotos
            .bind(to: collectionView.rx.items(cellIdentifier: MainPhotosCollectionViewCell.reuseIdentifier, cellType: MainPhotosCollectionViewCell.self)) { (row, item, cell) in
                cell.configure(title: item.title, date: item.dateString, tagText: item.tag, image: item.image)
            }
            .disposed(by: disposeBag)
    }

    private func autoLayout() {
        contentView.addSubview(footerView)
        contentView.addSubview(collectionView)
        contentView.backgroundColor = .white
        footerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.height.equalTo(30.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        collectionView.snp.makeConstraints { make in
            make.bottom.equalTo(footerView.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }
    }
}

extension MainPhotosTableViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = frame.height - 60
        let cellWidth = frame.width - 45 * 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}
