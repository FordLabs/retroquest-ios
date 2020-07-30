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
import AppCenterAnalytics

struct ActionItemsTableCell: View {
    @EnvironmentObject var actionItemsPubSub: PubSub<ActionItem>
    @EnvironmentObject var actionItemsViewEnvironmentObject: ActionItemsViewEnvironmentObject
    let actionItem: ActionItem
    let opacity: CGFloat

    init(actionItem: ActionItem) {
        self.actionItem = actionItem
        self.opacity = CGFloat(actionItem.completed ? 0.33 : 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {

                VStack {
                    Spacer()
                    MessageLabel(messageText: self.actionItem.task, strikethroughText: self.actionItem.completed)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: self.modifyTaskTapped)
                    Spacer()
                    Text("assigned to")
                        .font(Font(UIFont.retroquestBold(size: 14)))
                        .foregroundColor(Color(RetroColors.cellDarkTextColor))
                    MessageLabel(messageText: self.actionItem.assignee ?? "", strikethroughText: false)
                        .contentShape(Rectangle())
                        .onTapGesture(perform: self.modifyAssigneeTapped)
                }.frame(height: (2 * geometry.size.height / 3) - dividerThickness)

                ItemsTableCellDivider(axis: .vertical)

                HStack {
                    VStack {
                        Text("created")
                            .font(Font(UIFont.retroquestBold(size: 13)))
                            .foregroundColor(Color(RetroColors.cellDarkTextColor))
                        Text(self.actionItem.dateCreated ?? "")
                            .font(Font(UIFont.retroquestBold(size: 15)))
                            .foregroundColor(Color(RetroColors.cellTextColor))
                    }.frame(width: (geometry.size.width / 3) - (3 * dividerThickness))

                    ItemsTableCellDivider(axis: .horizontal)

                    FAIcon(iconName: "edit")
                        .frame(width: (geometry.size.width / 3) - (3 * dividerThickness))
                        .contentShape(Rectangle())
                        .onTapGesture(perform: self.modifyTaskTapped)

                    ItemsTableCellDivider(axis: .horizontal)

                    FAIcon(iconName: self.actionItem.completed ? "envelope-open-text" : "envelope")
                        .frame(width: (geometry.size.width / 3) - (3 * dividerThickness))
                        .contentShape(Rectangle())
                        .onTapGesture(perform: self.markCompletedTapped)
                }
                .frame(height: (geometry.size.height / 3) - dividerThickness)
            }
        }
            .frame(height: 150)
            .padding(.vertical, 20)
            .background(Color(RetroColors.expandedCellBackgroundColor.withAlphaComponent(self.opacity)))
            .cornerRadius(15)
    }

    private func modifyTaskTapped() {
        print("tapped on task")
        self.actionItemsViewEnvironmentObject.actionItemToEdit = self.actionItem
        self.actionItemsViewEnvironmentObject.activeActionItemsViewModal = .editActionItemTask
        self.actionItemsViewEnvironmentObject.showModal = true
    }

    private func modifyAssigneeTapped() {
        print("tapped on assignee")
        self.actionItemsViewEnvironmentObject.actionItemToEdit = self.actionItem
        self.actionItemsViewEnvironmentObject.activeActionItemsViewModal = .editActionItemAssignee
        self.actionItemsViewEnvironmentObject.showModal = true
    }

    private func markCompletedTapped() {
        print("tapped on completed")
        let newActionItem = self.actionItem.copy(completed: !self.actionItem.completed)
        self.actionItemsPubSub.publishOutgoing(newActionItem, outgoingType: .edit)
        MSAnalytics.trackEvent(
                "mark action item \(newActionItem.completed ? "completed" : "incomplete")",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }
}

struct ActionItemsTableCellPreview: PreviewProvider {
    static var previews: some View {
        ActionItemsTableCell(
            actionItem: ActionItem(
                id: 0,
                task: "task1",
                completed: false,
                teamId: "1",
                assignee: "jim",
                dateCreated: "2018-01-05"
            )
        )
            .environmentObject(PubSub<ActionItem>())
            .environmentObject(ActionItemsViewEnvironmentObject())
    }
}
