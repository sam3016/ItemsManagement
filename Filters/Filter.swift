//
//  Filter.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/16.
//

import Foundation

struct Filter: Identifiable, Hashable {
    var id: UUID
    var name: String
    var icon: String
    var minModificationDate = Date.distantPast
    var item: Item?
    var estimateDate = Date.distantPast
    var average: Int
    var reminderDate = Date.distantPast
    var reminded: Bool

    static var recent = Filter(
        id: UUID(),
        name: NSLocalizedString("Recent Items", comment: "Recent Items"),
        icon: "clock",
        minModificationDate: .now.addingTimeInterval(86400 * -7),
        estimateDate: .now,
        average: 0,
        reminderDate: .now,
        reminded: false
    )

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        lhs.id == rhs.id
    }
}

extension Filter {
    var formattedEstimateDate: String {
        return estimateDate.formatted(date: .numeric, time: .omitted)
    }

    var formattedReminderDate: String {
        return reminderDate.formatted(date: .numeric, time: .shortened)
    }
}
