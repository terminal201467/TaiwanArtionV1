//
//  AllExhibitionTableViewCell.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/12.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay

class AllExhibitionTableViewCell: UITableViewCell {
    
    static let reuseIdentifier: String = "AllExhibitionTableViewCell"
    
    private let disposeBag = DisposeBag()
    
    private let viewModel = HomeViewModel.shared
    
    var pushToViewController: ((ExhibitionInfo) -> Void)?
    
    private let itemView = SelectCollectionItemsView()
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 5
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(AllExhibitionCollectionViewCell.self, forCellWithReuseIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .whiteGrayColor
        return collectionView
    }()

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
        collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                self.viewModel.inputs.allExhibitionSelected.onNext(indexPath)
                self.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
//        viewModel.allExhibitionObservable
//            .bind(to: collectionView.rx.items(cellIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier,cellType: AllExhibitionCollectionViewCell.self)) { row, info, cell in
//
//            }
//            .disposed(by: disposeBag)
    }
    
    private func autoLayout() {
        contentView.addSubview(itemView)
        itemView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(40.0)
        }
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(itemView.snp.bottom).offset(12.0)
            make.leading.equalToSuperview().offset(12.0)
            make.trailing.equalToSuperview().offset(-12.0)
            make.bottom.equalToSuperview()
        }
    }
}

extension AllExhibitionTableViewCell: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return viewModel.allExhibitionNumerOfRowInSection(section: section)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier, for: indexPath) as! AllExhibitionCollectionViewCell
//        cell.configure(with: viewModel.allExhibitionCellForRowAt(indexPath: indexPath))
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        viewModel.allExhibitionDidSelectedRowAt(indexPath: indexPath) { exhibition in
//            self.pushToViewController?(exhibition)
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = 230.0
        let cellWidth = (frame.width - 24 * 1) / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}
