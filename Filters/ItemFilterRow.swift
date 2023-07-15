//
//  ItemFilterRow.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/06/17.
//

import SwiftUI

struct ItemFilterRow: View {
    let filter: Filter
    var rename: (Filter) -> Void
    var setReminder: (Filter) -> Void
    var removeReminder: (Filter) -> Void

    var body: some View {
        NavigationLink(value: filter) {
            HStack {
                Image(systemName: "shippingbox")
                    .imageScale(.large)
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(filter.name)
                        .contextMenu {
                            Button {
                                rename(filter)
                            } label: {
                                Label("Rename", systemImage: "pencil")
                            }
                        }

                    Text("Average: \(filter.average) days")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Text("Next: \(filter.formattedEstimateDate)")
                        .font(.caption2)
                        .foregroundColor(.blue)

                    Text("Reminder: \(filter.formattedReminderDate)")
                        .font(.caption2)
                        .foregroundColor(.blue)
                }

                Spacer()

                if filter.reminded {
                    Image(systemName: "bell.fill")
                        .imageScale(.large)
                        .foregroundColor(.red)
                }
            }
        }
        .accessibilityElement()
        .accessibilityLabel(filter.name)
        .accessibilityHint("Next is" + filter.estimateDate.formatted(date: .abbreviated, time: .omitted)
        )
        .accessibilityInputLabels([filter.name, filter.estimateDate.formatted(date: .abbreviated, time: .omitted)])
    }
}

struct ItemFilterRow_Previews: PreviewProvider {
    static var previews: some View {
        ItemFilterRow(filter: .recent, rename: {_ in }, setReminder: {_ in}, removeReminder: {_ in })
    }
}
