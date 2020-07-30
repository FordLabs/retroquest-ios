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

struct ThoughtsView: View {
    @EnvironmentObject var thoughtPubSub: PubSub<Thought>
    @EnvironmentObject var columnPubSub: PubSub<Column>
    @EnvironmentObject var thoughtsViewEnvironmentObject: ThoughtsViewEnvironmentObject
    let teamName: String

    var body: some View {
        let activeItemsViewModal = self.thoughtsViewEnvironmentObject.activeItemsViewModal

        return VStack {
            ItemsViewHeader<ThoughtsViewEnvironmentObject>(teamName: teamName)

            ThoughtsTable()
                .background(Color(RetroColors.backgroundColor))
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(RetroColors.menuHeaderColor))
        .sheet(isPresented: self.$thoughtsViewEnvironmentObject.showModal) {
            if activeItemsViewModal == .editThought {
                EditTextSwiftUIView<ThoughtsViewEnvironmentObject>(
                    titleText: "Change Thought",
                    userInput: self.thoughtsViewEnvironmentObject.thoughtToEdit?.message ?? "",
                    saveCallback: self.editThoughtCallback
                ).environmentObject(self.thoughtsViewEnvironmentObject)
            } else if activeItemsViewModal == .editColumnName {
                EditTextSwiftUIView<ThoughtsViewEnvironmentObject>(
                    titleText: "Change Column Title",
                    userInput: self.thoughtsViewEnvironmentObject.columnToEdit?.title ?? "",
                    saveCallback: self.editColumnNameCallback
                ).environmentObject(self.thoughtsViewEnvironmentObject)
            } else if activeItemsViewModal == .addItem {
                NewItemSwiftUIView<ThoughtsViewEnvironmentObject>(
                    titleText: "Add New Thought",
                    userInput: "",
                    saveCallback: self.addThoughtCallback
                ).environmentObject(self.thoughtsViewEnvironmentObject)
            }
        }
    }

    private func editThoughtCallback(userInput: String) {
        let newThought = self.thoughtsViewEnvironmentObject.thoughtToEdit?.copy(message: userInput)
        self.thoughtPubSub.publishOutgoing(newThought, outgoingType: .edit)

        MSAnalytics.trackEvent(
                "edit thought text to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func editColumnNameCallback(userInput: String) {
        let newColumn = self.thoughtsViewEnvironmentObject.columnToEdit?.copy(title: userInput)
        self.columnPubSub.publishOutgoing(newColumn, outgoingType: .edit)

        MSAnalytics.trackEvent(
                "edit column text to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func addThoughtCallback(userInput: String, selectedColumn: Column?) {
        let newThought = Thought(
                id: -1,
                message: userInput,
                hearts: 0,
                topic: selectedColumn?.topic ?? "",
                discussed: false,
                teamId: URLManager.currentTeam
        )
        self.thoughtPubSub.publishOutgoing(newThought, outgoingType: .create)
        MSAnalytics.trackEvent(
            "added \(selectedColumn?.topic ?? "") thought",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }
}

struct ThoughtsViewPreview: PreviewProvider {
    static let thoughtsViewEnvironmentObject = ThoughtsViewEnvironmentObject(
        thoughts: [
            [
                Thought(id: 1, message: "me", hearts: 0, topic: "happy", discussed: false, teamId: "1"),
                Thought(id: 2, message: "you", hearts: 1, topic: "happy", discussed: true, teamId: "1"),
                Thought(id: 3, message: "I", hearts: 1, topic: "happy", discussed: true, teamId: "1")
            ],
            [
                Thought(id: 4, message: "he", hearts: 0, topic: "confused", discussed: false, teamId: "1"),
                Thought(id: 5, message: "she", hearts: 1, topic: "confused", discussed: true, teamId: "1")
            ],
            [
                Thought(id: 6, message: "us", hearts: 7, topic: "sad", discussed: true, teamId: "1")
            ]
        ],
        columns: [
            Column(id: 88, topic: ColumnName.happy.rawValue, title: "kindaHappy", teamId: "1"),
            Column(id: 89, topic: ColumnName.confused.rawValue, title: "kindaConfused", teamId: "1"),
            Column(id: 90, topic: ColumnName.sad.rawValue, title: "kindaSad", teamId: "1")
        ]
    )

    static var previews: some View {
        ThoughtsView(teamName: "Coolest Team")
            .environmentObject(thoughtsViewEnvironmentObject)
            .environmentObject(PubSub<Thought>())
            .environmentObject(PubSub<Column>())
    }
}
