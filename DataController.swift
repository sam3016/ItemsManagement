//
//  DataController.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/17.
//

import CoreData
import SwiftUI

enum SortType: String {
    case startDate
    case endDate
}

enum Status {
    case all, today
}

class DataController: ObservableObject {
    let container: NSPersistentCloudKitContainer

    @Published var selectedFilter: Filter? = Filter.recent
    @Published var selectedLineItem: LineItem?

    @Published var filterText = ""
    @Published var filterTokens = [Item]()

    @Published var filterEnabled = false
    @Published var filterPriority = -1
    @Published var filterStatus = Status.all
    @Published var sortType = SortType.startDate
    @Published var sortNewestFirst = true

    private var saveTask: Task<Void, Error>?

    static var preview: DataController = {
        let dataController = DataController(inMemory: true)
        dataController.createSampleData()
        return dataController
    }()

    static let model: NSManagedObjectModel = {
        guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
            fatalError("Failed to locate model file.")
        }

        guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load model file.")
        }

        return managedObjectModel
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(filePath: "/dev/null")
        }

        let groupID = "group.com.samhui.itemsmanagement"

        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
            container.persistentStoreDescriptions.first?.url =
            url.appending(path: "Main.sqlite")
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        container.persistentStoreDescriptions.first?.setOption(
            true as NSNumber,
            forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey
        )

        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: container.persistentStoreCoordinator,
            queue: .main,
            using: remoteStoreChanged
        )

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Fatal error loading store: \(error.localizedDescription)")
            }
        }
    }

    func remoteStoreChanged(_ notification: Notification) {
        objectWillChange.send()
    }

    func createSampleData() {
        let viewContext = container.viewContext

        for itemCount in 1...5 {
            let item = Item(context: viewContext)
            item.id = UUID()
            item.name = "Item \(itemCount)"
            item.creationDate = .now
            item.average = 0.0
            item.reminded = false

            for _ in 1...10 {
                let lineItem = LineItem(context: viewContext)
                lineItem.startDate = .now
                lineItem.endDate = .now
                lineItem.dayDifference = Int16(0)
                item.addToLineitems(lineItem)
            }
        }
        try? viewContext.save()
    }

    func save() {
        if container.viewContext.hasChanges {
            try? container.viewContext.save()
        }
    }

    func queueSave() {
        saveTask?.cancel()

        saveTask = Task { @MainActor in
            try await Task.sleep(for: .seconds(3))
            save()
        }
    }

    func delete(_ object: NSManagedObject) {
        objectWillChange.send()
        container.viewContext.delete(object)
        save()
    }

    private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs

        if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
            let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
        }
    }

    func deleteAll() {
        let request1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
        delete(request1)

        let request2: NSFetchRequest<NSFetchRequestResult> = LineItem.fetchRequest()
        delete(request2)

        save()
    }

    func lineItemForSelectedFilter() -> [LineItem] {
        let filter = selectedFilter ?? .recent
        var predicates = [NSPredicate]()

        if let item = filter.item {
            let itemPredicate = NSPredicate(format: "item CONTAINS %@", item)
            predicates.append(itemPredicate)
        } else {
            let datePredicate = NSPredicate(format: "startDate > %@", filter.minModificationDate as NSDate)
            predicates.append(datePredicate)
        }

        let trimmedFilterText = filterText.trimmingCharacters(in: .whitespaces)

        if trimmedFilterText.isEmpty == false {
            let titlePredicate = NSPredicate(format: "item.name CONTAINS[c] %@", trimmedFilterText)
            predicates.append(titlePredicate)
        }

        let request = LineItem.fetchRequest()
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = [NSSortDescriptor(key: sortType.rawValue, ascending: sortNewestFirst)]

        let allLineItems = (try? container.viewContext.fetch(request)) ?? []
        return allLineItems
    }

    func newItem() {
        withAnimation {
            let item = Item(context: container.viewContext)
            item.id = UUID()
            item.name = "New item"
            item.creationDate = .now
            item.average = 0.0
            item.estimateDate = .now
            item.reminderDate = .now
            item.reminded = false
            save()
        }
    }

    func newLineItem() {
        withAnimation {
            let lineitem = LineItem(context: container.viewContext)
            lineitem.startDate = .now
            lineitem.endDate = .now

            if let item = selectedFilter?.item {
                lineitem.addToItem(item)
                // Remove Reminder when a new lineitem created
                selectedFilter?.item?.reminded = false
                removeReminders(for: selectedFilter ?? .recent)
            }

            save()

            selectedLineItem = lineitem
        }
    }

    func daysBetween(lineItem: LineItem) {
        let startDate = Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: lineItem.lineItemStartDate
        ) ?? .now
        let endDate = Calendar.current.date(
            bySettingHour: 0,
            minute: 0,
            second: 0,
            of: lineItem.lineItemEndDate
        ) ?? .now

        lineItem.dayDifference = Int16(Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0)

        save()
    }

    func average(item: Item) {
        let lineItems = item.itemLineItems.map { $0.dayDifference }

        let sum = Int(lineItems.reduce(0, +))
        let count = lineItems.count
        item.average = Double(sum / count)

        save()
    }

    func updateEstimateDate(item: Item) {
        let lineItems = item.itemLineItems.compactMap { $0.endDate }
        let maxDate = lineItems.max { $0 < $1 }
        let newEstimateDate = Calendar.current.date(byAdding: .day, value: Int(item.itemAverage), to: maxDate ?? .now)
        item.estimateDate = newEstimateDate

        save()
    }

    func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
        (try? container.viewContext.count(for: fetchRequest)) ?? 0
    }
}
