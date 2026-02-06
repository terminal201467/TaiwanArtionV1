//
//  CustomCalendarViewModel.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/7/13.
//

import RxSwift
import RxCocoa
import RxRelay

protocol CalendarOutput{
    //所有當月日期
    var isAllowToTap: BehaviorRelay<Bool> { get }
    var outputMonth: BehaviorRelay<String> { get }
    var sendOutSelecteMonthAndDate: BehaviorRelay<(month: String, date: String)> { get }
    var reloadCalendar: RxRelay.PublishRelay<Void> { get }
}

protocol CalendarInput {
    //輸入年、月
    var inputYear: BehaviorRelay<Int> { get }
    var correctTime: PublishRelay<Void> { get }
    var storeTime: BehaviorRelay<String> { get }
    var currentMonthDate: BehaviorRelay<String> { get }
    var nextMonth: PublishSubject<Void> { get }
    var preMonth: PublishSubject<Void> { get }
}

protocol CalendarViewModelType {
    var input: CalendarInput { get }
    var output: CalendarOutput { get }
}

class CustomCalendarViewModel: CalendarViewModelType, CalendarInput, CalendarOutput {

    private let disposeBag = DisposeBag()
    
    //MARK: -Input
    var correctTime: RxRelay.PublishRelay<Void> = PublishRelay()
    var storeTime: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var nextMonth: PublishSubject<Void> = PublishSubject()
    var preMonth: PublishSubject<Void> = PublishSubject()
    var inputYear: RxRelay.BehaviorRelay<Int> = BehaviorRelay(value: 0)
    
    //MARK: -Output
    var currentMonthDate: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var isAllowToTap: RxRelay.BehaviorRelay<Bool> = BehaviorRelay(value: false)
    var outputMonth: RxRelay.BehaviorRelay<String> = BehaviorRelay(value: "")
    var sendOutSelecteMonthAndDate: RxRelay.BehaviorRelay<(month: String, date: String)> = BehaviorRelay(value: ("",""))
    var reloadCalendar: RxRelay.PublishRelay<Void> = PublishRelay()
    
    //MARK: - input/output
    var input: CalendarInput { self }
    
    var output: CalendarOutput { self }
    
    //MARK: - CalendarLogic
    
    private var selectedYear: String = ""
    
    private var selectedMonth: String = ""
    
    private var selectedDate: String = ""
    
    //MARK: - CurrentTimeProperties
    
    private let calendar = Calendar.current
    
    private let currentDay = Date()
    
    private lazy var currentMonth = calendar.component(.month, from: currentDay)
    
    private lazy var currentYear = calendar.component(.year, from: currentDay)
    
    private lazy var firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDay))!
    
    private lazy var weekdayOffset = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7 // 計算偏移量
    
    init() {
        inputYear.subscribe(onNext: { year in
            self.currentYear = year
        }).disposed(by: disposeBag)
        
        correctTime.subscribe(onNext: {
            AppLogger.debug("selectedMonth:\(self.selectedMonth)", category: .viewModel)
            AppLogger.debug("selectedDate:\(self.selectedDate)", category: .viewModel)
            self.sendOutSelecteMonthAndDate.accept((self.selectedMonth, self.selectedDate))
        }).disposed(by: disposeBag)
        
        nextMonth.subscribe(onNext: {
            self.setNextMonth()
            self.reloadCalendar.accept(())
        })
        .disposed(by: disposeBag)
        
        preMonth.subscribe(onNext: {
            self.setPreMonth()
            self.reloadCalendar.accept(())
        })
        .disposed(by: disposeBag)
        setIsAllowToTap()
    }
    
    private func setNextMonth() {
        if currentMonth > 12 {
            currentYear += 1
        } else {
            currentMonth += 1
        }
    }
    
    private func setPreMonth() {
        if currentMonth == 0 {
            currentYear -= 1
        } else {
            currentMonth -= 1
        }
    }
    
    private func setIsAllowToTap() {
        isAllowToTap.accept(sendOutSelecteMonthAndDate.value.date != "" ? true : false)
    }
    
    private var currentSelectedDate: Date?
    
    func dateCellForRowAt(indexPath: IndexPath) -> (dateString: String, date: Date?, isDateSelected: Bool, isCurrentMonth: Bool) {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset, to: firstDayOfMonth)!
        let isCurrentMonth = calendar.isDate(date, equalTo: currentDay, toGranularity: .month)
        var isDateSelected: Bool = false
        if currentSelectedDate == nil {
            let isToday = calendar.isDateInToday(date)
            isDateSelected = isToday
        } else {
            isDateSelected = date == currentSelectedDate
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: date)
        return (dateString, date, isDateSelected, isCurrentMonth)
    }
    
    func didSelectedRowAt(indexPath: IndexPath) {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset, to: firstDayOfMonth)!
        let monthString = setMonth(inputDate: date)
        let dateString = setDate(inputDate: date)
        currentSelectedDate = date
        sendOutSelecteMonthAndDate.accept((monthString, dateString))
        setIsAllowToTap()
    }
    
    private func setDate(inputDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: inputDate)
        selectedDate = dateString
        return dateString
    }
    
    private func setMonth(inputDate: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM"
        let monthString = dateFormatter.string(from: inputDate)
        selectedMonth = monthString
        return monthString
    }
}
