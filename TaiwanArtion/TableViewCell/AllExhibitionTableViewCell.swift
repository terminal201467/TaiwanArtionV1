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

    /// 導航到詳細頁面
    var pushToViewController: ((ExhibitionInfo) -> Void)?

    /// 載入更多的回調（用於無限滾動）
    var loadMoreAction: (() -> Void)?

    /// 距離底部多少個 cell 時觸發載入更多
    private let loadMoreThreshold = 3
    
    private let itemView = SelectCollectionItemsView()
    
    private let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
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
        // 設定 delegate（UICollectionViewDelegateFlowLayout + UICollectionViewDelegate）
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)

        // 綁定資料源
        viewModel.outputs.allExhibitionRelay
            .bind(to: collectionView.rx.items) { (collectionView, row, element) in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AllExhibitionCollectionViewCell.reuseIdentifier, for: indexPath) as! AllExhibitionCollectionViewCell
                cell.configure(with: element)
                return cell
            }
            .disposed(by: disposeBag)

        // 處理選取事件
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                self.viewModel.inputs.allExhibitionSelected.onNext(indexPath)
                self.collectionView.reloadData()
                self.pushToViewController?(self.viewModel.outputs.allExhibitionRelay.value[indexPath.row])
            })
            .disposed(by: disposeBag)

        // 設定載入更多的動作
        loadMoreAction = { [weak self] in
            self?.viewModel.loadMoreAllExhibitions()
        }
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
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}

extension AllExhibitionTableViewCell: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellHeight = 245.0
        let cellWidth = (collectionView.frame.width - (16 * 2) - 24) / 2
        return CGSize(width: cellWidth, height: cellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
}

// MARK: - UICollectionViewDelegate (Infinite Scrolling)

extension AllExhibitionTableViewCell: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let totalItems = collectionView.numberOfItems(inSection: 0)
        let lastIndex = totalItems - 1

        // 當接近底部時觸發載入更多
        if indexPath.item >= lastIndex - loadMoreThreshold {
            loadMoreAction?()
        }
    }
}
