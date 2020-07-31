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
import AppCenterAnalytics

struct ActionItemsTable: View {
    @EnvironmentObject var actionItemsPubSub: PubSub<ActionItem>
    @EnvironmentObject var actionItemsViewEnvironmentObject: ActionItemsViewEnvironmentObject

    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some View {
        List {
            ForEach(self.actionItemsViewEnvironmentObject.actionItems, id: \.self) { actionItem in
                ActionItemsTableCell(actionItem: actionItem)
                    .listRowInsets(EdgeInsets(
                        top: 4,
                        leading: 4,
                        bottom: 4,
                        trailing: 4
                    ))
                    .listRowBackground(Color(RetroColors.backgroundColor))
            }.onDelete(perform: self.delete)
        }
    }

    private func delete(actionItemIndex: IndexSet) {
        let actionItem = self.actionItemsViewEnvironmentObject.actionItems[actionItemIndex.first!]
        self.actionItemsPubSub.publishOutgoing(actionItem, outgoingType: .delete)
        MSAnalytics.trackEvent("delete action item", withProperties: ["Team": URLManager.currentTeam])
        print("Deleting Thought with id: \(actionItem.id)")
    }
}

struct ActionItemsTablePreview: PreviewProvider {
    static let actionItemsViewEnvironmentObject = ActionItemsViewEnvironmentObject(actionItems: [
        ActionItem(id: 0, task: "task1", completed: false, teamId: "1", assignee: "jim", dateCreated: "2018-01-05"),
        ActionItem(id: 1, task: "task2", completed: true, teamId: "1", assignee: "bob", dateCreated: "2018-01-06"),
        ActionItem(id: 2, task: "task3", completed: false, teamId: "1", assignee: nil, dateCreated: nil)
    ])

    static var previews: some View {
        ActionItemsTable()
            .environmentObject(actionItemsViewEnvironmentObject)
            .environmentObject(PubSub<ActionItem>())
    }
}
