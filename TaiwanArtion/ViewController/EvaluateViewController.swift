//
//  EvaluateViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/5/30.
//

import UIKit

class EvaluateViewController: UIViewController {
    
    private let evaluateView = EvaluateView()
    
    private let viewModel = ExhibitionCardViewModel.shared
    
    override func loadView() {
        super.loadView()
        view = evaluateView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setCollectionView()
        setInfo()
        evaluateView.popViewController = {
            self.navigationController?.popViewController(animated: true)
        }
        evaluateView.pushViewController = {
            let viewController = EvaluateSucceedViewController()
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func setInfo() {
        evaluateView.configure(personImageText: "Allise", name: "Allise")
    }
    
    private func setTableView() {
        evaluateView.slidersTableView.delegate = self
        evaluateView.slidersTableView.dataSource = self
    }
    
    private func setCollectionView() {
        evaluateView.starCollectionView.delegate = self
        evaluateView.starCollectionView.dataSource = self
    }
    
    private func setNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }

}

extension EvaluateViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch CommentType(rawValue: indexPath.row) {
        case .contentRichness:
            let contentRichnessCell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.reuseIdentifier, for: indexPath) as! SliderTableViewCell
            contentRichnessCell.selectionStyle = .none
            contentRichnessCell.configure(title: CommentType.contentRichness.text)
            contentRichnessCell.sliderValue = { value in
                AppLogger.debug("contentRichnessCell.sliderValue:\(value)", category: .ui)
            }
            return contentRichnessCell
        case .geoLocation:
            let geoLocationCell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.reuseIdentifier, for: indexPath) as! SliderTableViewCell
            geoLocationCell.selectionStyle = .none
            geoLocationCell.configure(title: CommentType.geoLocation.text)
            geoLocationCell.sliderValue = { value in
                AppLogger.debug("geoLocationCell.sliderValue:\(value)", category: .ui)
            }
            return geoLocationCell
        case .equipment:
            let equipmentCell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.reuseIdentifier, for: indexPath) as! SliderTableViewCell
            equipmentCell.selectionStyle = .none
            equipmentCell.configure(title: CommentType.equipment.text)
            equipmentCell.sliderValue = { value in
                AppLogger.debug("equipmentCell.sliderValue:\(value)", category: .ui)
            }
            return equipmentCell
        case .price:
            let priceCell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.reuseIdentifier, for: indexPath) as! SliderTableViewCell
            priceCell.selectionStyle = .none
            priceCell.configure(title: CommentType.price.text)
            priceCell.sliderValue = { value in
                AppLogger.debug("priceCell.sliderValue:\(value)", category: .ui)
            }
            return priceCell
        case .serice:
            let sericeCell = tableView.dequeueReusableCell(withIdentifier: SliderTableViewCell.reuseIdentifier, for: indexPath) as! SliderTableViewCell
            sericeCell.selectionStyle = .none
            sericeCell.configure(title: CommentType.serice.text)
            sericeCell.sliderValue = { value in
                AppLogger.debug("sericeCell.sliderValue:\(value)", category: .ui)
            }
            return sericeCell
        case .none:
            return UITableViewCell()
        }
    }
}

extension EvaluateViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StarCollectionViewCell.reuseIdentifier, for: indexPath) as! StarCollectionViewCell
        cell.configure(isValueStar: viewModel.evaluateCellForRowAt(indexPath: indexPath))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.evaluateStarDidSelectedRowAt(indexPath: indexPath)
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 32.0, height: 32.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16.0
    }
}
