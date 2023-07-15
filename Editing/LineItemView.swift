//
//  LineItemView.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/23.
//

import SwiftUI

struct LineItemView: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var lineItem: LineItem

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name)]) var items: FetchedResults<Item>

    var body: some View {
        Form {
            Section(header: Text("Name")) {
                ForEach(lineItem.lineItemItem) { lineItem in
                    Text(lineItem.itemName)
                }
            }

            Section(header: Text("Start Date")) {
                DatePicker(selection: $lineItem.lineItemStartDate, in: ...Date(), displayedComponents: .date) {
                    Text("Select a start Date")
                }
            }

            Section(header: Text("End Date")) {
                DatePicker(
                    selection: $lineItem.lineItemEndDate,
                    in: lineItem.lineItemStartDate...,
                    displayedComponents: .date
                ) {
                    Text("Select an end date")
                }
            }

            Section(header: Text("Day Difference")) {
                Text("\(lineItem.lineItemDayDifference) days")
            }
        }
        .disabled(lineItem.isDeleted)
        .onReceive(lineItem.objectWillChange) { _ in
            dataController.queueSave()
        }
        .onDisappear {
            dataController.daysBetween(lineItem: lineItem)
            dataController.average(item: lineItem.lineItemItem[0])
            dataController.updateEstimateDate(item: lineItem.lineItemItem[0])
        }
    }
}

struct LineItemView_Previews: PreviewProvider {
    static var previews: some View {
        LineItemView(lineItem: .example)
    }
}
