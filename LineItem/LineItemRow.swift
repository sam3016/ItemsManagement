//
//  LineItemRow.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/23.
//

import SwiftUI

struct LineItemRow: View {
    @EnvironmentObject var dataController: DataController
    @ObservedObject var lineItem: LineItem

    var body: some View {
        NavigationLink(value: lineItem) {
            VStack(alignment: .leading) {
                if dataController.selectedFilter == .recent {
                    Text(lineItem.lineItemItem.first?.itemName ?? "Unknown")
                }

                Text(lineItem.lineItemDateRange)
                    .foregroundColor(dataController.selectedFilter == .recent ? .secondary : .primary)

                Text("\(lineItem.lineItemDayDifference) days")
                .foregroundStyle(.secondary)
            }
            .navigationTitle(dataController.selectedFilter == .recent
                             ? NSLocalizedString("List", comment: "List")
                             :  lineItem.lineItemItemList)
        }
        .accessibilityElement()
        .accessibilityLabel(lineItem.lineItemItem.first?.itemName ?? "Unknown")
        .accessibilityHint(lineItem.lineItemDateRangeLabel)
        .accessibilityInputLabels([lineItem.lineItemItem.first?.itemName ?? "Unknown", lineItem.lineItemDateRange])
    }
}

struct LineItemRow_Previews: PreviewProvider {
    static var previews: some View {
        LineItemRow(lineItem: .example)
    }
}
