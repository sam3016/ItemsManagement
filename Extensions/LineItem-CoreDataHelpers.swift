//
//  LineItem-CoreDataHelpers.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/16.
//

import Foundation

extension LineItem {
    enum SortOrder {
        case startDate, endDate, dayDifference
    }

    var lineItemStartDate: Date {
        get { startDate ?? .now }
        set { startDate = newValue }
    }

    var lineItemEndDate: Date {
        get { endDate ?? .now }
        set { endDate = newValue }
    }

    var lineItemDayDifference: Int16 {
        get { dayDifference }
        set { dayDifference = newValue }
    }

    var lineItemItem: [Item] {
        let result = item?.allObjects as? [Item] ?? []
        return result.sorted()
    }

    var lineItemItemList: String {
        guard let item else { return "No Items"}

        if item.count == 0 {
            return "No Items"
        } else {
            return lineItemItem.map(\.itemName).formatted()
        }
    }

    var lineItemDateRange: String {
        return "\(lineItemStartDate.formatted(date: .numeric, time: .omitted)) ~ "
        +  "\(lineItemEndDate.formatted(date: .numeric, time: .omitted))"
    }

    var lineItemDateRangeLabel: String {
        return "From \(lineItemStartDate.formatted(date: .abbreviated, time: .omitted)) to"
        +  "\(lineItemEndDate.formatted(date: .abbreviated, time: .omitted))"
    }

    static var example: LineItem {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let lineItem = LineItem(context: viewContext)
        lineItem.startDate = Date()
        lineItem.endDate = Date()

        return lineItem
    }
}

extension LineItem: Comparable {
    public static func <(lhs: LineItem, rhs: LineItem) -> Bool {
        let left = lhs.lineItemStartDate
        let right = rhs.lineItemStartDate

        if left == right {
            return lhs.lineItemEndDate < rhs.lineItemEndDate
        } else {
            return left < right
        }
    }
}
