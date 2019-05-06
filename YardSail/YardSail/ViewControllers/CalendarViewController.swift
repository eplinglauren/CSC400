//
//  CalendarViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/20/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date \(self.dateFormatter.string(from: date))")
        let selectedDates = calendar.selectedDates.map({self.dateFormatter.string(from: $0)})
        print("selected dates is \(selectedDates)")
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
}
