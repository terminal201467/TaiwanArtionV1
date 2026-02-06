//
//  TaiwanArtionDateView.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/9/5.
//

import UIKit

class TaiwanArtionDateView: UIView {

    var calendarType: CalendarType

    var selectedDate: ((Date) -> Void)?

    init(frame: CGRect, type: CalendarType) {
        calendarType = type
        super.init(frame: frame)
        autoLayout()
        setDelegate()
    }

    let dateCalculator = DateCalculator()

    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(DateCollectionViewCell.self, forCellWithReuseIdentifier: DateCollectionViewCell.reuseIdentifier)
        collectionView.allowsSelection = true
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setDelegate() {
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func autoLayout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func setYearMonth(year: Int, month: Int) {
        dateCalculator.setCalendarYear(year: year)
        dateCalculator.setCalendarMonth(month: month)
    }
}

extension TaiwanArtionDateView: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7 * 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DateCollectionViewCell.reuseIdentifier, for: indexPath) as! DateCollectionViewCell
        let isEvent = dateCalculator.eventDateCellForRowAt(indexPath: indexPath)
        let dateInfo = dateCalculator.dateCellForRowAt(indexPath: indexPath)
        cell.configure(dateString: dateInfo.dateString,
                       isToday: dateInfo.isToday,
                       isCurrentMonth: dateInfo.isCurrentMonth)
        cell.configureEventDot(isEvent: isEvent)
        let isSelected = dateCalculator.currentSelectRowAt(indexPath: indexPath)
        cell.changeCurrentSelectedItem(isCurrentSelected: isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dateCalculator.singleDidSelectedRowAt(indexPath: indexPath)
        dateCalculator.selectedDateCompletion = { date in
            self.selectedDate?(date)
            AppLogger.debug("date:\(date)", category: .ui)
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - (16 * 2) - (8 * 8)) / 7
        let cellHeight = 40.0
        return .init(width: cellWidth, height: cellHeight)
    }
}
