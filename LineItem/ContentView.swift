//
//  ContentView.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/08.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        List(selection: $dataController.selectedLineItem) {
            ForEach(dataController.lineItemForSelectedFilter()) { lineItem in
                LineItemRow(lineItem: lineItem)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(
            (dataController.selectedFilter == .recent
             ? NSLocalizedString("List", comment: "List")
             :  dataController.selectedLineItem?.lineItemItemList)
            ?? NSLocalizedString("List", comment: "List")
        )
        .searchable(text: $dataController.filterText, prompt: "Filter items")
        .toolbar(content: ContentViewToolbar.init)
    }

    func delete(_ offsets: IndexSet) {
        let issues = dataController.lineItemForSelectedFilter()

        for offset in offsets {
            let item = issues[offset]
            dataController.delete(item)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
