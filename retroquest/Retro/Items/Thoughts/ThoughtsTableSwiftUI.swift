//
//  ThoughtsTableSwiftUI.swift
//  retroquest
//
//  Created by Candela, Paul (P.V.) on 5/18/20.
//  Copyright © 2020 Ford. All rights reserved.
//

import SwiftUI

struct ThoughtsTableSwiftUI: View {
    let columnTitles: [String]
    let thoughts: [[Thought]]

    init(columnTitles: [String], thoughts: [[Thought]]) {
        self.columnTitles = columnTitles
        self.thoughts = thoughts

        UITableView.appearance().separatorColor = .clear
    }

    var body: some View {
        List {
            ForEach(0 ..< columnTitles.count) { columnIndex in
                SwiftUI.Section(header: ThoughtsTableViewHeaderViewSwiftUI(
                    topicName: self.columnTitles[columnIndex],
                    numThoughts: self.thoughts[columnIndex].count,
                    topicIndex: columnIndex
                ).listRowInsets(EdgeInsets())) {
                    ForEach(0 ..< self.thoughts[columnIndex].count) { thoughtIndex in
                        ThoughtsTableViewCellSwiftUI(
                            self.thoughts[columnIndex][thoughtIndex],
                            delegate: PreviewThoughtEditDelegate()
                        ).listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
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
            thoughts: [
                [
                    Thought(id: 1, message: "me", hearts: 0, topic: "happy", discussed: true, teamId: "1"),
                    Thought(id: 2, message: "you", hearts: 1, topic: "happy", discussed: false, teamId: "1")
                ],
                [
                    Thought(id: 3, message: "he", hearts: 0, topic: "confused", discussed: true, teamId: "1"),
                    Thought(id: 4, message: "she", hearts: 1, topic: "confused", discussed: false, teamId: "1")
                ],
                [
                    Thought(id: 4, message: "they", hearts: 0, topic: "sad", discussed: true, teamId: "1")
                ]
            ]
        )
    }
}
