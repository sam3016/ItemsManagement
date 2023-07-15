//
//  DetailView.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/16.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        VStack {
            if let lineItem = dataController.selectedLineItem {
                LineItemView(lineItem: lineItem)
            } else {
                NoLineItemView()
            }
        }
        .navigationTitle("Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView()
    }
}
