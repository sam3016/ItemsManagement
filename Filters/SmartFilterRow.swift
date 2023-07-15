//
//  SmartFilterRow.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/06/17.
//

import SwiftUI

struct SmartFilterRow: View {
    let filter: Filter

    var body: some View {
        NavigationLink(value: filter) {
            Label(filter.name, systemImage: filter.icon)
        }
    }
}

struct SmartFilterRow_Previews: PreviewProvider {
    static var previews: some View {
        SmartFilterRow(filter: .recent)
    }
}
