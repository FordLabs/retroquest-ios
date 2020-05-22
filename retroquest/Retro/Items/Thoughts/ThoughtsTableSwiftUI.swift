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
    let collapsedState: [Bool]
    let thoughts: [[Thought]]

    init(columnTitles: [String], collapsedState: [Bool], thoughts: [[Thought]]) {
        self.columnTitles = columnTitles
        self.collapsedState = collapsedState
        self.thoughts = thoughts

        UITableView.appearance().backgroundColor = RetroColors.backgroundColor
        UITableViewCell.appearance().backgroundColor = .clear
    }

    var body: some View {
        List {
            ForEach(0 ..< columnTitles.count) { columnIndex in
                SwiftUI.Section(header: ThoughtsTableViewHeaderViewSwiftUI(
                    topicName: self.columnTitles[columnIndex],
                    numThoughts: self.thoughts[columnIndex].count,
                    topicIndex: columnIndex,
                    collapsed: self.collapsedState[columnIndex],
                    delegate: PreviewThoughtTableViewHeaderViewSwiftUIDelegate()
                )
                .listRowInsets(EdgeInsets())) {
                    if self.collapsedState[columnIndex] != true {
                        ForEach(0 ..< self.thoughts[columnIndex].count) { thoughtIndex in
                            ThoughtsTableViewCellSwiftUI(
                                thought: self.thoughts[columnIndex][thoughtIndex],
                                delegate: PreviewThoughtEditDelegate()
                            )
                            .listRowInsets(EdgeInsets(
                                top: 2,
                                leading: 1,
                                bottom: 2,
                                trailing: 1
                            ))
                            .listRowBackground(Color(RetroColors.backgroundColor))
                            .cornerRadius(10)
                        }
                    }
                }
            }
        }
    }
}

struct ThoughtsTableSwiftUIPreviews: PreviewProvider {
    static var previews: some View {
        ThoughtsTableSwiftUI(
            columnTitles: ["happy", "confused", "sad"],
            collapsedState: [false, true, false],
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
                    Thought(id: 6, message: "they", hearts: 7, topic: "sad", discussed: true, teamId: "1")
                ]
            ]
        )
    }
}
