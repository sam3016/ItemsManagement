//
//  SidebarView.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/16.
//

import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var dataController: DataController
    let smartFilter: [Filter] = [.recent]

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var items: FetchedResults<Item>

    @State private var itemToRename: Item?
    @State private var renamingItem = false
    @State private var itemName = ""

    @State private var itemToRemind: Item?
    @State private var addingReminder = false
    @State private var reminderDate = Date.now

    @State private var showingNotificationsError = false

    var itemFilters: [Filter] {
        items.map { item in
            Filter(
                id: item.itemID,
                name: item.itemName,
                icon: "tag",
                item: item,
                estimateDate: item.itemEstimateDate,
                average: Int(item.itemAverage),
                reminderDate: item.itemReminderDate, reminded: item.reminded
            )
        }
    }

    var body: some View {
        List(selection: $dataController.selectedFilter) {
            Section("Smart Filters") {
                ForEach(smartFilter) { filter in
                    SmartFilterRow(filter: filter)
                }
            }

            Section("Items") {
                ForEach(itemFilters) { filter in
                    ItemFilterRow(
                        filter: filter,
                        rename: rename,
                        setReminder: setReminder,
                        removeReminder: removeReminder
                    )
                    .swipeActions(edge: .leading) {
                        Button {
                            setReminder(filter)
                        } label: {
                            Label("Set Reminder", systemImage: "bell.and.waves.left.and.right")
                        }
                        .tint(.orange)

                        Button {
                            removeReminder(filter)
                        } label: {
                            Label("Remove Reminder", systemImage: "bell.slash")
                        }
                        .tint(.indigo)
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .toolbar {
            Button(action: dataController.newItem) {
                Label("Add Item", systemImage: "plus")
            }

            #if DEBUG
            Button {
                dataController.deleteAll()
                dataController.createSampleData()
            } label: {
                Label("ADD SAMPLES", systemImage: "flame")
            }
            #endif
        }
        .alert("Rename Item", isPresented: $renamingItem) {
            Button("OK", action: completeRename)
            Button("Cancel", role: .cancel) { }
            TextField("New name", text: $itemName)
        }
        .alert("Oops!", isPresented: $showingNotificationsError) {
            #if os(iOS)
            Button("Check Settings", action: showAppSetting)
            #endif
            Button("OK") { }
        } message: {
            Text("There was a problem. Please check you have notifiations enabled.")
        }
        .sheet(isPresented: $addingReminder) {
            Section(header: Text("Add reminder of current item")) {
                VStack(alignment: .leading) {
                    DatePicker(selection: $reminderDate, in: Date()..., displayedComponents: .date) {
                        Text("Select a date")
                    }

                    DatePicker(
                        selection: $reminderDate,
                        in: Date()...,
                        displayedComponents: .hourAndMinute
                    ) {
                            Text("Select a time")
                    }
                }
                .presentationDetents([.fraction(0.2)])
            }
            .onDisappear(perform: completeSetUpReminder)
        }
    }

    func delete(_ offsets: IndexSet) {
        for offset in offsets {
            let item = items[offset]
            dataController.delete(item)
        }
    }

    func rename(_ filter: Filter) {
        itemToRename = filter.item
        itemName = filter.name
        renamingItem = true
    }

    func completeRename() {
        itemToRename?.name = itemName
        dataController.save()
    }

    func setReminder(_ filter: Filter) {
        itemToRemind = filter.item
        reminderDate = filter.reminderDate
        addingReminder = true
    }

    func completeSetUpReminder() {
        itemToRemind?.reminderDate = reminderDate
        itemToRemind?.reminded = true
        dataController.addReminders(for: itemToRemind ?? Item.example) { success in
            if success == false {
                itemToRemind?.reminderDate = nil
                itemToRemind?.reminded = false
                showingNotificationsError = true
            }
        }
        dataController.save()
        addingReminder = false
    }

    func removeReminder(_ filter: Filter) {
        itemToRemind = filter.item
        dataController.removeReminders(for: filter)
        itemToRemind?.reminded = false
        dataController.save()
        addingReminder = false
    }

    #if os(iOS)
    func showAppSetting() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
                return
        }

        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
    #endif
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
