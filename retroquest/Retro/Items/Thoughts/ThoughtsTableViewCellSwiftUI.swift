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

struct ThoughtsTableViewCellSwiftUI: View {
    let thought: Thought
    internal weak var thoughtEditDelegate: ThoughtEditDelegate!

    init(_ thought: Thought, delegate: ThoughtEditDelegate) {
        self.thought = thought
        self.thoughtEditDelegate = delegate
    }

    var body: some View {
        VStack {
            MessageLabel(thought.message).padding(.top, 10)
            ThoughtsTableCellDivider(.vertical)
            HStack {
                Button(action: starsTapped) {
                    Spacer()
                    StarsLabel(thought.hearts)
                    Spacer()
                }
                ThoughtsTableCellDivider(.horizontal)
                Button(action: modifyMessageTapped) {
                    Spacer()
                    FAIcon("edit").padding(10)
                    Spacer()
                }
                ThoughtsTableCellDivider(.horizontal)
                Button(action: markDiscussedTapped) {
                    Spacer()
                    FAIcon("envelope").padding(10)
                    Spacer()
                }
            }.padding(.bottom, 10)
        }
        .background(Color(RetroColors.expandedCellBackgroundColor.withAlphaComponent(1.0)))
        .frame(minHeight: 0, maxHeight: 115)
    }

    internal func starsTapped() {
        print("tapped on stars")
        thoughtEditDelegate.starred(thought)
    }

    internal func modifyMessageTapped() {
        print("tapped on message")
        thoughtEditDelegate.textChanged(thought)
    }

    internal func markDiscussedTapped() {
        print("tapped on discussed")
        thoughtEditDelegate.discussed(thought)
    }
}

enum DividerAxis: Int {
    case horizontal = 0

    case vertical = 1
}

struct FAIcon: View {
    let iconName: String

    init(_ iconName: String) {
        self.iconName = iconName
    }

    var body: some View {
        FAText(iconName: iconName, size: 20, style: .solid)
            .foregroundColor(Color(RetroColors.cellTextColor))
    }
}

private struct ThoughtsTableCellDivider: View {
    let axis: DividerAxis

    init(_ axis: DividerAxis) {
        self.axis = axis
    }

    var body: some View {
        Group {
            if axis == .vertical {
                Rectangle()
                    .fill(Color(RetroColors.separatorColor))
                    .frame(height: 4)
            } else {
                Rectangle()
                    .fill(Color(RetroColors.separatorColor))
                    .frame(width: 4)
            }
        }
    }
}

private struct MessageLabel: View {
    let message: String

    init(_ message: String) {
        self.message = message
    }

    var body: some View {
        Text(message)
            .font(Font.retroquestRegular(size: 20))
            .strikethrough(false)
            .foregroundColor(Color(RetroColors.cellTextColor))
    }
}

private struct StarsLabel: View {
    let numStars: Int

    init(_ numStars: Int) {
        self.numStars = numStars
    }

    var body: some View {
        HStack {
            FAText(iconName: "star", size: 20, style: .solid)
                .foregroundColor(Color(RetroColors.starColor))
            Text(String(numStars))
                .font(Font.retroquestRegular(size: 20))
                .foregroundColor(Color(RetroColors.cellTextColor))
        }
    }
}

struct ThoughtsTableViewCellSwiftUIPreview: PreviewProvider {

    static var previews: some View {
        ThoughtsTableViewCellSwiftUI(
            Thought(
              id: 2,
              message: "fdsas",
              hearts: 70,
              topic: "happy",
              discussed: true,
              teamId: "testers"
            ),
            delegate: PreviewThoughtEditDelegate()
        )
    }
}

class PreviewThoughtEditDelegate: ThoughtEditDelegate {
    func starred(_ thought: Thought) { }
    func discussed(_ thought: Thought) { }
    func textChanged(_ thought: Thought) { }
}
