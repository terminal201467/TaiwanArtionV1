//
//  TaiwanArtionCalendar.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/9/5.
//

import Foundation
import UIKit

enum CalendarType {
    case withButton, withSearching, inExhibitionCalendar
}

class TaiwanArtionCalendar: UIView {
    
    var correctAction: (() -> Void)?
    
    private var isAllowSelect: Bool = false {
        didSet {
            setCorrectButton()
        }
    }
    
    enum CalendarWithButtonItems: Int, CaseIterable {
        case title = 0, week, date, button
    }

    enum CalendarItems: Int, CaseIterable {
        case title = 0, month, week, date
    }
    
    private var type: CalendarType
    
    init(frame: CGRect, type: CalendarType) {
        self.type = type
        super.init(frame: frame)
        autoLayoutContainer()
        addContentToContainer()
        addTitleToContainer(by: type)
        setNextPreMonthAction()
        setNextPreYearAction()
    }
    
    //MARK: - ContainerViews
    private let titleViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let monthViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let weekViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let dateViewContiner: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let buttonViewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    //MARK: - ContentViews
    
    private let monthView = TaiwanArtionMonthView()
    
    private let weekView = TaiwanArtionWeekView()
    
    private lazy var dateView = TaiwanArtionDateView(frame: .zero, type: type)
    
    private let correctButton: UIButton = {
        let button = UIButton()
        button.setTitle("確定", for: .normal)
        button.addTarget(self, action: #selector(correct), for: .touchDown)
        return button
    }()
    
    //MARK: - TitleViews
    
    private var titleView: UIView = {
        let view = UIView()
        return view
    }()
    
    private var monthChangedTitleView: TaiwanArtionMonthChangedView?
    
    private var yearChangedTitleView: TaiwanArtionYearChangedView?
    
    private var titleHeaderView: TitleHeaderView?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func autoLayoutContainer() {
        backgroundColor = .white
        addSubview(titleViewContainer)
        titleViewContainer.snp.makeConstraints { make in
            make.height.equalTo(40.0)
            make.top.equalToSuperview().offset(16.0)
            make.leading.equalToSuperview().offset(16.0)
            make.trailing.equalToSuperview().offset(-16.0)
        }
        
        addSubview(monthViewContainer)
        monthViewContainer.snp.makeConstraints { make in
            make.height.equalTo(49.0)
            make.top.equalTo(titleViewContainer.snp.bottom).offset(12.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        addSubview(weekViewContainer)
        weekViewContainer.snp.makeConstraints { make in
            make.top.equalTo(monthViewContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(40.0)
        }
        
        addSubview(dateViewContiner)
        dateViewContiner.snp.makeConstraints { make in
            make.height.equalTo(280.0)
            make.top.equalTo(weekViewContainer.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        addSubview(buttonViewContainer)
        buttonViewContainer.snp.makeConstraints { make in
            make.height.equalTo(50.0)
            make.top.equalTo(dateViewContiner.snp.bottom).offset(16.0)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
    }
    
    private func addContentToContainer() {
        monthViewContainer.addSubview(monthView)
        monthView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        weekViewContainer.addSubview(weekView)
        weekView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        dateViewContiner.addSubview(dateView)
        dateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonViewContainer.addSubview(correctButton)
        correctButton.snp.makeConstraints { make in
            make.height.equalTo(39.0)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func addTitleToContainer(by type: CalendarType) {
        switch type {
        case .withButton:
            let view = TaiwanArtionMonthChangedView()
            monthChangedTitleView = view
            titleView.addSubview(monthChangedTitleView!)
            monthChangedTitleView!.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            buttonViewContainer.isHidden = false
        case .withSearching:
            titleHeaderView = TitleHeaderView()
            titleView.addSubview(titleHeaderView!)
            buttonViewContainer.isHidden = true
        case .inExhibitionCalendar:
            let view = TaiwanArtionYearChangedView()
            yearChangedTitleView = view
            titleView.addSubview(yearChangedTitleView!)
            yearChangedTitleView!.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            buttonViewContainer.isHidden = true
        }
        titleViewContainer.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setCorrectButton() {
        correctButton.isEnabled = isAllowSelect ? true : false
        correctButton.backgroundColor = isAllowSelect ? .brownColor : .whiteGrayColor
        correctButton.setTitleColor(isAllowSelect ? .white : .middleGrayColor, for: .normal)
    }
    
    @objc private func correct() {
        correctAction?()
    }
    
    private func setNextPreYearAction() {
        yearChangedTitleView?.configure(by: self.dateView.dateCalculator.currentYear,
                                        by: self.dateView.dateCalculator.currentMonth)
        yearChangedTitleView?.afterAction = {
            AppLogger.debug("next", category: .ui)
            self.dateView.dateCalculator.nextMonth {
                self.yearChangedTitleView?.configure(by: self.dateView.dateCalculator.currentYear,
                                                by: self.dateView.dateCalculator.currentMonth)
                self.dateView.collectionView.reloadData()
            }
        }

        yearChangedTitleView?.beforeAction = {
            AppLogger.debug("pre", category: .ui)
            self.yearChangedTitleView?.configure(by: self.dateView.dateCalculator.currentYear,
                                            by: self.dateView.dateCalculator.currentMonth)
            self.dateView.dateCalculator.preMonth {
                self.dateView.collectionView.reloadData()
            }
        }
    }
    
    private func setNextPreMonthAction() {
        monthChangedTitleView?.afterAction = {
            AppLogger.debug("next", category: .ui)
            self.dateView.dateCalculator.nextMonth {
                self.dateView.collectionView.reloadData()
            }
        }
        
        monthChangedTitleView?.beforeAction = {
            AppLogger.debug("pre", category: .ui)
            self.dateView.dateCalculator.preMonth {
                self.dateView.collectionView.reloadData()
            }
        }
    }
}
