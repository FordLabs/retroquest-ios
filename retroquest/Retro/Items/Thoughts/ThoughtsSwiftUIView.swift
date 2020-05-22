//
//  ThoughtsSwiftUIView.swift
//  retroquest
//
//  Created by Candela, Paul (P.V.) on 5/19/20.
//  Copyright © 2020 Ford. All rights reserved.
//

import SwiftUI

struct ThoughtsSwiftUIView: View {
    let teamName: String

    init(teamName: String) {
        self.teamName = teamName
    }

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

            ThoughtsTableSwiftUI(
                columnTitles: ["happy", "confused", "sad"],
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

            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.top)
        .background(Color(RetroColors.backgroundColor))
    }

    internal func addItem() {
        
    }
}

struct ThoughtsSwiftUIViewPreviews: PreviewProvider {
    static var previews: some View {
        ThoughtsSwiftUIView(teamName: "Coolest Team")
    }
}
