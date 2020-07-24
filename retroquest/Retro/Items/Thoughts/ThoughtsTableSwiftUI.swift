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

struct HeaderCollapsedStates {
    var collapsedStates: [Bool] = [true, true, true]
}

struct ThoughtsTableSwiftUI: View {
    @EnvironmentObject var items: ItemsSwiftUI
    @EnvironmentObject var thoughtPubSub: PubSub<Thought>
    @State private var headerCollapsedStates: HeaderCollapsedStates = HeaderCollapsedStates()

    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some View {
        let iterableColumns = Array(self.items.columns.enumerated())

        return List {
            ForEach(iterableColumns, id: \.element) { columnIndex, column in
                SwiftUI.Section(header: ThoughtsTableViewHeaderViewSwiftUI(
                    column: column,
                    numThoughts: self.items.thoughts[columnIndex].count,
                    topicIndex: columnIndex,
                    headerCollapsedStates: self.$headerCollapsedStates.collapsedStates
                )
                .listRowInsets(EdgeInsets())) {
                    if self.headerCollapsedStates.collapsedStates[columnIndex] != true {
                        ForEach(self.items.thoughts[columnIndex], id: \.self) { thought in
                            ThoughtsTableViewCellSwiftUI(thought: thought)
                                .listRowInsets(EdgeInsets(
                                    top: 2,
                                    leading: 1,
                                    bottom: 2,
                                    trailing: 1
                                ))
                                .listRowBackground(Color(RetroColors.backgroundColor))
                        }.onDelete { thoughtIndex in
                            self.delete(thoughtIndex: thoughtIndex, columnIndex: columnIndex)
                        }
                    }
                }
            }
        }
    }

    func delete(thoughtIndex: IndexSet, columnIndex: Int) {
        let thought = self.items.thoughts[columnIndex][thoughtIndex.first!]
        self.thoughtPubSub.publishOutgoing(thought, outgoingType: .delete)
        MSAnalytics.trackEvent("delete \(thought.topic) thought", withProperties: ["Team": URLManager.currentTeam])
        print("Deleting Thought with id: \(thought.id)")
    }
}

struct ThoughtsTableSwiftUIPreviews: PreviewProvider {
    static let longMessage = """
    really long message, really long message, really long message, really long message,\
    really long message, really long message, really long message, really long message.
    """

    static let thoughtPubSub = PubSub<Thought>()
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
                Thought(id: 6, message: longMessage, hearts: 7, topic: "sad", discussed: true, teamId: "1")
            ]
        ],
        columnTitles: [
            Column(id: 88, topic: ColumnName.happy.rawValue, title: "kindaHappy", teamId: "1"),
            Column(id: 89, topic: ColumnName.confused.rawValue, title: "kindaConfused", teamId: "1"),
            Column(id: 90, topic: ColumnName.sad.rawValue, title: longMessage, teamId: "1")
        ]
    )

    static var previews: some View {
        ThoughtsTableSwiftUI()
            .environmentObject(items)
            .environmentObject(thoughtPubSub)
    }
}
