//
//  Calendar+isDateInWeek.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 29.05.2021.
//

import Foundation

extension Calendar {
    func isDayInCurrentWeek(_ date: Date) -> Bool? {
        let currentComponents = Calendar.current.dateComponents([.weekOfYear], from: Date())
        let dateComponents = Calendar.current.dateComponents([.weekOfYear], from: date)
        guard let currentWeekOfYear = currentComponents.weekOfYear, let dateWeekOfYear = dateComponents.weekOfYear else { return nil }
        return currentWeekOfYear == dateWeekOfYear
    }
}
