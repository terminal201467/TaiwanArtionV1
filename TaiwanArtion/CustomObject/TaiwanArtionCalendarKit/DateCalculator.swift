//
//  TaiwanArtionCalendarInfo.swift
//  TaiwanArtion
//
//  Created by Jhen Mu on 2023/9/5.
//

import Foundation

class DateCalculator {
    
    var selectedDateCompletion: ((Date) -> Void)?
    
    private var selectedDate: Date? {
        didSet {
            AppLogger.debug("selectedDate:\(selectedDate!)", category: .ui)
        }
    }
    //calendar
    private let calendar = Calendar.current
    //Date
    var currentDate = Date()
    //Month
    lazy var currentMonth = calendar.component(.month, from: currentDate)
    //Year
    lazy var currentYear = calendar.component(.year, from: currentDate)
    
    private lazy var firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))!
    
    private lazy var weekdayOffset = (calendar.component(.weekday, from: firstDayOfMonth) + 5) % 7 // 計算偏移量
    
    private var eventsString: [String] = ["2023-09-09","2023-09-10"]
    
    private var eventsDate: [Date] {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "yyyy-MM-dd"
        dateFormat.locale = .current
        dateFormat.timeZone = .current
        return self.eventsString.map { dateString in
            return dateFormat.date(from: dateString) ?? Date()
        }
    }
    
    var currentDateString: String {
        return currentDate.formatted()
    }
    
    func nextMonth(completion: @escaping (() -> Void)) {
        if currentMonth > 12 {
            currentYear += 1
            currentMonth = 1
        } else {
            currentMonth += 1
        }
        AppLogger.debug("currentYear:\(currentYear)", category: .ui)
        AppLogger.debug("currentMonth:\(currentMonth)", category: .ui)
    }
    
    func preMonth(completion: @escaping (() -> Void)) {
        if currentMonth < 1 {
            currentYear -= 1
            currentMonth = 12
        } else {
            currentMonth -= 1
        }
        AppLogger.debug("currentYear:\(currentYear)", category: .ui)
        AppLogger.debug("currentMonth:\(currentMonth)", category: .ui)
    }
    
    func setCalendarYear(year: Int) {
        currentYear = year
    }
    
    func setCalendarMonth(month: Int) {
        currentMonth = month
    }
    
    func dateCellForRowAt(indexPath: IndexPath) -> (dateString: String, date: Date, isToday: Bool, isCurrentMonth: Bool) {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset, to: firstDayOfMonth)!
        let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        let dateString = dateFormatter.string(from: date)
        return (dateString, date, isToday, isCurrentMonth)
    }
    
    func eventDateCellForRowAt(indexPath: IndexPath) -> Bool {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset + 1, to: firstDayOfMonth)!
        let isEvent = eventsDate.compactMap { eventDate in
            eventDate == date
        }
        return isEvent.contains(true)
    }
    
    func currentSelectRowAt(indexPath: IndexPath) -> Bool {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset + 1, to: firstDayOfMonth)!
        let isCurrentSelected = calendar.isDate(selectedDate ?? Date(), inSameDayAs: date)
        return isCurrentSelected
    }
    
    func singleDidSelectedRowAt(indexPath: IndexPath) {
        let date = calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset + 1, to: firstDayOfMonth)!
        selectedDate = date
        selectedDateCompletion?(date)
    }
    
    func multipleSelectedRowAt(indexPaths: [IndexPath]) -> [Date] {
        return indexPaths.map { indexPath in
            calendar.date(byAdding: .day, value: indexPath.item - weekdayOffset + 1, to: firstDayOfMonth)!
        }
    }
}
