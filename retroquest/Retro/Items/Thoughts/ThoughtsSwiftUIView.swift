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

struct ThoughtsSwiftUIView: View {
    @EnvironmentObject var thoughtPubSub: PubSub<Thought>
    @EnvironmentObject var columnPubSub: PubSub<Column>
    @EnvironmentObject var items: ItemsSwiftUI
    let teamName: String

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text(self.teamName)
                        .font(.system(size: 24))
                        .frame(alignment: .center)
                }
                HStack {
                    Spacer()
                    Button(action: addItem) {
                        Text("+")
                            .font(.system(size: 32))
                            .foregroundColor(Color(RetroColors.buttonColor))
                            .frame(alignment: .trailing)
                            .padding(.trailing, 25)
                    }
                }
            }
            .padding(.top, 50)
            .background(Color(RetroColors.backgroundColor))

            ThoughtsTableSwiftUI()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.top)
        .background(Color(RetroColors.backgroundColor))
        .sheet(isPresented: self.$items.showModal) {
            if self.items.activeThoughtViewModal == .editThought {
                EditTextSwiftUIView(
                    titleText: "Change Thought",
                    userInput: self.items.thoughtToEdit?.message ?? "",
                    saveCallback: self.editThoughtCallback
                ).environmentObject(self.items)
            } else if self.items.activeThoughtViewModal == .editColumnName {
                EditTextSwiftUIView(
                    titleText: "Change Column Title",
                    userInput: self.items.columnToEdit?.title ?? "",
                    saveCallback: self.editColumnNameCallback
                ).environmentObject(self.items)
            }
        }
    }

    private func addItem() {

    }

    private func editThoughtCallback(userInput: String) {
        let newThought = self.items.thoughtToEdit?.copy(message: userInput)
        self.thoughtPubSub.publishOutgoing(newThought, outgoingType: .edit)

        MSAnalytics.trackEvent(
                "edit thought text to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func editColumnNameCallback(userInput: String) {
        let newColumn = self.items.columnToEdit?.copy(title: userInput)
        self.columnPubSub.publishOutgoing(newColumn, outgoingType: .edit)

        MSAnalytics.trackEvent(
                "edit column text to \(userInput)",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }
}

struct ThoughtsSwiftUIViewPreviews: PreviewProvider {
    static let items = ItemsSwiftUI(
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
        columnTitles: [
            Column(id: 88, topic: ColumnName.happy.rawValue, title: "kindaHappy", teamId: "1"),
            Column(id: 89, topic: ColumnName.confused.rawValue, title: "kindaConfused", teamId: "1"),
            Column(id: 90, topic: ColumnName.sad.rawValue, title: "kindaSad", teamId: "1")
        ]
    )

    static var previews: some View {
        ThoughtsSwiftUIView(teamName: "Coolest Team")
            .environmentObject(items)
            .environmentObject(PubSub<Thought>())
            .environmentObject(PubSub<Column>())
    }
}

class ItemsSwiftUI: ObservableObject {
    @Published var thoughts: [[Thought]] = [[]]
    @Published var columns: [Column] = []

    @Published var showModal: Bool = false
    @Published var activeThoughtViewModal: ActiveThoughtViewModal = .none
    @Published var thoughtToEdit: Thought?
    @Published var columnToEdit: Column?

    init(
        thoughts: [[Thought]],
        columnTitles: [Column]
    ) {
        self.thoughts = thoughts
        self.columns = columnTitles
    }

    init() {}
}

enum ActiveThoughtViewModal {
    case editThought, editColumnName, addThought, none
}
