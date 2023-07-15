//
//  Items-CoreDataHelpers.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/16.
//

import Foundation

extension Item {
    var itemID: UUID {
        id ?? UUID()
    }

    var itemName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var itemCreationDate: Date {
        creationDate ?? .now
    }

    var itemEstimateDate: Date {
       estimateDate ?? .now
    }

    var itemReminderDate: Date {
        reminderDate ?? .now
    }

    var itemAverage: Double {
        get { average }
        set { average = newValue }
    }

    var itemLineItems: [LineItem] {
        let array = lineitems?.allObjects as? [LineItem] ?? []
        return array.sorted()
    }

    static var example: Item {
        let controller = DataController(inMemory: true)
        let viewContext = controller.container.viewContext

        let item = Item(context: viewContext)
        item.id = UUID()
        item.name = "Example Item"
        item.creationDate = .now
        item.average = 0.0

        return item
    }
}

extension Item: Comparable {
    public static func <(lhs: Item, rhs: Item) -> Bool {
        let left = lhs.itemName.localizedLowercase
        let right = rhs.itemName.localizedLowercase

        if left == right {
            return lhs.itemID.uuidString < rhs.itemID.uuidString
        } else {
            return left < right
        }
    }
}
