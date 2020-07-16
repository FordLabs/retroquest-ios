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

struct ThoughtsTableSwiftUI: View {
    let columnTitles: [String]
    let thoughts: [[Thought]]

    @State var collapsedStates: [Bool] = [true, true, true]

    init(columnTitles: [String], thoughts: [[Thought]]) {
        self.columnTitles = columnTitles
        self.thoughts = thoughts

        UITableView.appearance().backgroundColor = .clear
        UITableView.appearance().separatorColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some View {
        List {
            ForEach(0 ..< columnTitles.count) { columnIndex in
                SwiftUI.Section(header: ThoughtsTableViewHeaderViewSwiftUI(
                    topicName: self.columnTitles[columnIndex],
                    numThoughts: self.thoughts[columnIndex].count,
                    topicIndex: columnIndex,
                    headerCollapsedStates: self.$collapsedStates
                )
                .listRowInsets(EdgeInsets())) {
                    if self.collapsedStates[columnIndex] != true {
                        ForEach(0 ..< self.thoughts[columnIndex].count) { thoughtIndex in
                            ThoughtsTableViewCellSwiftUI(
                                thought: self.getThoughtsOfTopic(self.thoughts[columnIndex])[thoughtIndex],
                                delegate: PreviewThoughtEditDelegate()
                            )
                            .listRowInsets(EdgeInsets(
                                top: 2,
                                leading: 1,
                                bottom: 2,
                                trailing: 1
                            ))
                            .listRowBackground(Color(RetroColors.backgroundColor))
                        }
                    }
                }
            }
        }
    }

    func getThoughtsOfTopic(_ thoughts: [Thought]) -> [Thought] {
        let unDiscussedThoughtsOfThisTopic: [Thought] = thoughts.filter { !$0.discussed }
        let discussedThoughtsOfThisTopic: [Thought] = thoughts.filter { $0.discussed }

        let sortedUnDiscussedThoughts = unDiscussedThoughtsOfThisTopic.sorted(by: { $0.id < $1.id })
        let sortedDiscussedThoughts = discussedThoughtsOfThisTopic.sorted(by: { $0.id < $1.id })
        return sortedUnDiscussedThoughts + sortedDiscussedThoughts
    }
}

struct ThoughtsTableSwiftUIPreviews: PreviewProvider {
    static let longMessage = """
    really long message, really long message, really long message, really long message,\
    really long message, really long message, really long message, really long message.
    """

    static var previews: some View {
        ThoughtsTableSwiftUI(
            columnTitles: ["happy", "confused", "so sad, so sad, so sad, so sad, so sad, so sad"],
            thoughts: [
                [
                    Thought(id: 1, message: "me", hearts: 0, topic: "happy", discussed: true, teamId: "1"),
                    Thought(id: 2, message: "you", hearts: 1, topic: "happy", discussed: false, teamId: "1"),
                    Thought(id: 3, message: "I", hearts: 1, topic: "happy", discussed: false, teamId: "1")
                ],
                [
                    Thought(id: 4, message: "he", hearts: 0, topic: "confused", discussed: true, teamId: "1"),
                    Thought(id: 5, message: "she", hearts: 1, topic: "confused", discussed: false, teamId: "1")
                ],
                [
                    Thought(id: 6, message: longMessage, hearts: 7, topic: "sad", discussed: true, teamId: "1")
                ]
            ]
        )
    }
}
