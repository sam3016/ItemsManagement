//
//  LineChartDataPoint.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/07/24.
//

import SwiftUI
import Charts

struct LineChartDataPoint: Identifiable {
    let id = UUID()
    let weekday: Date
    let dayDifference: Int

    init(day: String, dayDifference: Int) {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        self.weekday = formatter.date(from: day) ?? Date.distantPast
        self.dayDifference = dayDifference
    }
}
