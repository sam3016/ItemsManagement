//
//  ContentViewToolbar.swift
//  ItemsManagement
//
//  Created by Sam Hui on 2023/06/17.
//

import SwiftUI
import Charts

struct ContentViewToolbar: View {
    @EnvironmentObject var dataController: DataController
    @State private var showingChart = false

    var body: some View {
        Menu {
            Button(dataController.filterEnabled ? "Turn Filter Off" : "Turn Filter On") {
                dataController.filterEnabled.toggle()
            }

            Divider()

            Menu("Sort By") {
                Picker("Sort By", selection: $dataController.sortType) {
                    Text("Start Date").tag(SortType.startDate)
                    Text("End Date").tag(SortType.endDate)
                }

                Divider()

                Picker("Sort Order", selection: $dataController.sortNewestFirst) {
                    Text("Newest to Oldest").tag(true)
                    Text("Oldest to Newest").tag(false)
                }
            }
        } label: {
            Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(dataController.filterEnabled ? .fill : .none)
        }

        if dataController.selectedFilter != .recent {
            Button(action: dataController.newLineItem) {
                Label("New LineItem", systemImage: "square.and.pencil")
            }

            Button {
                showingChart.toggle()
            } label: {
                Label("Chart", systemImage: "chart.xyaxis.line")
            }
            .disabled(getLineItemData().count == 0)
            .sheet(isPresented: $showingChart) {
                GroupBox("Usage Amount") {
                    Chart {
                        ForEach(getLineItemData()) {
                            LineMark(
                                x: .value("Week Day", $0.weekday, unit: .month),
                                y: .value("Day Difference", $0.dayDifference)
                            )
                            .foregroundStyle(by: .value("Value", "Day Difference"))
                        }
                        .lineStyle(StrokeStyle(lineWidth: 2.0))
                        .interpolationMethod(.cardinal)
                    }
                    .chartForegroundStyleScale([
                        "Day Difference": .blue
                    ])
                }
            }
        }
    }

    func getLineItemData() -> [LineChartDataPoint] {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return dataController.lineItemForSelectedFilter().map {
            let data = LineChartDataPoint(
                day: formatter.string(from: $0.lineItemStartDate),
                dayDifference: Int($0.dayDifference)
            )
            return data
        }
    }
}

struct ContentViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewToolbar()
    }
}
