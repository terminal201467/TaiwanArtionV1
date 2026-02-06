//
//  ExhibitionHallViewController.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/8/2.
//

import UIKit

class ExhibitionHallViewController: UIViewController {

    private let exhibitionHallView = ExhibitionHallView()
    
    private var currentMenu: Int = 0 {
        didSet {
            self.exhibitionHallView.menu.reloadData()
        }
    }
    
    override func loadView() {
        super.loadView()
        view = exhibitionHallView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setTableView()
        setSearchBarTextField()
        setMenu()
        setBackground()
    }
    
    private func setNavigationBar() {
        let backButton = UIBarButtonItem(image: .init(named: "backArrow")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(back))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func back() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setTableView() {
        exhibitionHallView.tableView.delegate = self
        exhibitionHallView.tableView.dataSource = self
    }
    
    private func setSearchBarTextField() {
        exhibitionHallView.searchTextField.delegate = self
    }
    
    private func setMenu() {
        exhibitionHallView.menu.delegate = self
        exhibitionHallView.menu.dataSource = self
    }
    
    private func setBackground() {
        exhibitionHallView.configure(hallTitle: "台南美術館", hallImage: nil)
    }
}

extension ExhibitionHallViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ExhibitionHallContent.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch ExhibitionHallContent(rawValue: indexPath.row) {
        case .time:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
            cell.configure(title: ExhibitionHallContent.time.text, contentText: "9:00a.m - 10:00p.m")
            return cell
        case .telephone:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
            cell.configure(title: ExhibitionHallContent.telephone.text, contentText: "(02)-23530506")
            return cell
        case .website:
            let cell = tableView.dequeueReusableCell(withIdentifier: WebSiteTableViewCell.reuseIdentifier, for: indexPath) as! WebSiteTableViewCell
            cell.configure(title: ExhibitionHallContent.website.text, linkText: "Queeny女人迷你俱樂部")
            return cell
        case .address:
            let cell = tableView.dequeueReusableCell(withIdentifier: NewsDetailTableViewCell.reuseIdentifier, for: indexPath) as! NewsDetailTableViewCell
            cell.configure(title: ExhibitionHallContent.address.text + "    " + "    ", contentText: "台南市安南區安南路123號")
            return cell
        case .none:
            return UITableViewCell()
        }
    }
}

extension ExhibitionHallViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        ExhibitionHallMenu.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectedItemsCollectionViewCell.reuseIdentifier, for: indexPath) as! SelectedItemsCollectionViewCell
        let isSelected = currentMenu == indexPath.row
        cell.configure(with: ExhibitionHallMenu.allCases[indexPath.row].text, selected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentMenu = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 5, left: 5, bottom: 5, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = view.frame.width / 5
        let cellHeight = collectionView.frame.height
        return .init(width: cellWidth, height: cellHeight)
    }
}

extension ExhibitionHallViewController: UISearchTextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        AppLogger.debug("text:\(String(describing: textField.text))", category: .ui)
        textField.becomeFirstResponder()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        AppLogger.debug("text:\(String(describing: textField.text))", category: .ui)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        AppLogger.debug("text:\(String(describing: textField.text))", category: .ui)
        textField.resignFirstResponder()
    }
}
