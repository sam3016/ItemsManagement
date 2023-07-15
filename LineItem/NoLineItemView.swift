//
//  NoLineItemView.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/04/23.
//

import SwiftUI

struct NoLineItemView: View {
    @EnvironmentObject var dataController: DataController

    var body: some View {
        Text("No record selected")
            .font(.title)
            .foregroundStyle(.secondary)

        Button("New LineItem", action: dataController.newLineItem)
    }
}

struct NoLineItemView_Previews: PreviewProvider {
    static var previews: some View {
        NoLineItemView()
    }
}
