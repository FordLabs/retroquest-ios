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

struct ActionItemsSwiftUIView: View {
    @EnvironmentObject var actionItemsPubSub: PubSub<ActionItem>
    @EnvironmentObject var actionItemsViewEnvironmentObject: ActionItemsViewEnvironmentObject
    let teamName: String

    var body: some View {
        let activeActionItemsViewModal = self.actionItemsViewEnvironmentObject.activeItemsViewModal

        return VStack {
            ItemsViewHeader<ActionItemsViewEnvironmentObject>(teamName: teamName)

            ActionItemsTable()
                .background(Color(RetroColors.backgroundColor))
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(RetroColors.menuHeaderColor))
        .sheet(isPresented: self.$actionItemsViewEnvironmentObject.showModal) {
            if activeActionItemsViewModal == .editActionItemTask {
                EditTextSwiftUIView<ActionItemsViewEnvironmentObject>(
                    titleText: "Change Task",
                    userInput: self.actionItemsViewEnvironmentObject.actionItemToEdit?.task ?? "",
                    saveCallback: self.editActionItemTaskCallback
                ).environmentObject(self.actionItemsViewEnvironmentObject)
            } else if activeActionItemsViewModal == .editActionItemAssignee {
                EditTextSwiftUIView<ActionItemsViewEnvironmentObject>(
                    titleText: "Change Assignee",
                    userInput: self.actionItemsViewEnvironmentObject.actionItemToEdit?.assignee ?? "",
                    saveCallback: self.editActionItemAssigneeCallback
                ).environmentObject(self.actionItemsViewEnvironmentObject)
            } else if activeActionItemsViewModal == .addItem {
                NewItemSwiftUIView<ActionItemsViewEnvironmentObject>(
                    titleText: "Add New Action Item",
                    userInput: "",
                    saveCallback: self.addActionItemCallback
                ).environmentObject(self.actionItemsViewEnvironmentObject)
            }
        }
    }

    private func editActionItemTaskCallback(userInput: String) {
        let newActionItem = self.actionItemsViewEnvironmentObject.actionItemToEdit?.copy(task: userInput)
        self.actionItemsPubSub.publishOutgoing(newActionItem, outgoingType: .edit)

        Analytics.trackEvent(
                "edit action item task to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func editActionItemAssigneeCallback(userInput: String) {
        let newActionItem = self.actionItemsViewEnvironmentObject.actionItemToEdit?.copy(assignee: userInput)
        self.actionItemsPubSub.publishOutgoing(newActionItem, outgoingType: .edit)

        Analytics.trackEvent(
                "edit action item assignee to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func addActionItemCallback(userInput: String, selectedColumn: Column?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        var task: String = userInput
        var assignee: String?

        if let startOfAssigneeBlock = userInput.firstIndex(of: "@") {
            let prefixOfAssignee = userInput.prefix(upTo: startOfAssigneeBlock)
            let indexOfAssigneeWithoutAt = userInput.index(startOfAssigneeBlock, offsetBy: 1)
            let restOfAssignee = userInput[indexOfAssigneeWithoutAt..<userInput.endIndex]
            let textBlocks = restOfAssignee.split(maxSplits: 1, whereSeparator: \.isWhitespace)

            assignee = String(textBlocks[0])
            task = String(prefixOfAssignee)

            if textBlocks.count > 1 {
                task += String(textBlocks[1])
            }
        }

        let newActionItem = ActionItem(
                id: -1,
                task: task,
                completed: false,
                teamId: URLManager.currentTeam,
                assignee: assignee,
                dateCreated: dateFormatter.string(from: Date())
        )
        self.actionItemsPubSub.publishOutgoing(newActionItem, outgoingType: .create)
        Analytics.trackEvent(
            "added action item",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }
}

struct ActionItemsSwiftUIViewPreview: PreviewProvider {
    static let actionItemsViewEnvironmentObject = ActionItemsViewEnvironmentObject(actionItems: [
        ActionItem(id: 0, task: "task1", completed: false, teamId: "1", assignee: "jim", dateCreated: "2018-01-05"),
        ActionItem(id: 1, task: "task2", completed: true, teamId: "1", assignee: "bob", dateCreated: "2018-01-06"),
        ActionItem(id: 2, task: "task3", completed: false, teamId: "1", assignee: nil, dateCreated: nil)
    ])
    static var previews: some View {
        ActionItemsSwiftUIView(teamName: "Coolest Team")
            .environmentObject(actionItemsViewEnvironmentObject)
            .environmentObject(PubSub<ActionItem>())
    }
}
