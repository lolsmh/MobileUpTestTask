//
//  Calendar+Get.swift
//  MobileUpTestTask
//
//  Created by Даниил Апальков on 30.05.2021.
//

import Foundation

extension Calendar {
    func get(_ component: Calendar.Component, from date: Date) -> Int {
        return Calendar.current.component(component, from: date)
    }
}
