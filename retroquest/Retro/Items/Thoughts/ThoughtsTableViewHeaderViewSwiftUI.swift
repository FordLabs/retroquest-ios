///**
/**
Copyright © 2019 Ford Motor Company. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import SwiftUI
import FASwiftUI

struct ThoughtsTableViewHeaderViewSwiftUI: View {
    @EnvironmentObject var items: ItemsSwiftUI
    @Binding var headerCollapsedStates: [Bool]

    let topicName: String
    let numThoughts: Int
    let topicIndex: Int

    let textColor: Color
    var chevronDirection: String = "chevron-down"

    init(
        topicName: String,
        numThoughts: Int,
        topicIndex: Int,
        headerCollapsedStates: Binding<[Bool]>
    ) {
        self.topicName = topicName
        self.numThoughts = numThoughts
        self.topicIndex = topicIndex
        self._headerCollapsedStates = headerCollapsedStates

        switch topicIndex {
        case 0:
           self.textColor = Color(RetroColors.happyColor)
        case 1:
           self.textColor = Color(RetroColors.confusedColor)
        case 2:
           self.textColor = Color(RetroColors.sadColor)
        default:
           self.textColor = Color.black
        }

        let collapsed = self.headerCollapsedStates[topicIndex]
        chevronDirection = collapsed ? "chevron-right" : "chevron-down"
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()

                Text(topicName)
                    .foregroundColor(textColor)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .padding(.bottom, 5)
                    .padding(.top, 10)
                Text(getNumThoughtsText())
                    .foregroundColor(textColor)
                    .font(.system(size: 14))
                    .fontWeight(.bold)

                Spacer()
            }
            .padding(.leading, 25)
            .padding(.vertical, 10)

            Spacer()

            FAText(iconName: chevronDirection, size: 20, style: .solid)
                .foregroundColor(textColor)
                .padding(.trailing, 25)
        }
        .background(Color(RetroColors.tableViewHeaderBackgroundColor))
        .frame(minHeight: 0, maxHeight: 100)
        .shadow(color: Color(RetroColors.shadowColor), radius: 5, x: 0, y: 2)
        .onTapGesture(perform: self.tapHeader)
        .onLongPressGesture(perform: self.longPressHeader)
    }

    internal func tapHeader() {
        print("tapped on header: \(self.headerCollapsedStates[self.topicIndex])")
        self.headerCollapsedStates[self.topicIndex].toggle()
    }

    private func longPressHeader() {
        print("long pressed on header \(self.headerCollapsedStates[self.topicIndex])")

        let topic = ColumnNameService.displayOrderForTopics[self.topicIndex].rawValue
        let columnId = -1
        let column = Column(
               id: columnId,
               topic: topic,
               title: self.topicName,
               teamId: URLManager.currentTeam
        )
        self.items.columnToEdit = column

        self.items.activeThoughtViewModal = .editColumnName
        self.items.showModal = true
    }

    private func getNumThoughtsText() -> String {
        let pluralThoughts = numThoughts != 1 ? "s" : ""
        return "\(numThoughts) item\(pluralThoughts)"
    }
}

struct ThoughtsTableViewHeaderViewSwiftUIPreviews: PreviewProvider {
    struct BindingTestHolder: View {
        @State var collapsedStates: [Bool] = [true, true, true]

        var body: some View {
            ThoughtsTableViewHeaderViewSwiftUI(
                topicName: "Happy",
                numThoughts: 3,
                topicIndex: 2,
                headerCollapsedStates: $collapsedStates
            ).environmentObject(ItemsSwiftUI())
        }
    }

    static var previews: some View {
        BindingTestHolder()
    }
}
