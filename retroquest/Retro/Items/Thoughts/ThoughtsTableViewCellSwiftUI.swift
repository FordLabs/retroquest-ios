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

let dividerThickness: CGFloat = 4.0

struct ThoughtsTableViewCellSwiftUI: View {
    @EnvironmentObject var thoughtPubSub: PubSub<Thought>
    @EnvironmentObject var items: ItemsSwiftUI
    let thought: Thought
    let opacity: CGFloat

    init(thought: Thought) {
        self.thought = thought
        self.opacity = CGFloat(thought.discussed ? 0.7 : 1.0)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {

                MessageLabel(thought: self.thought)
                    .frame(height: (geometry.size.height / 2) - dividerThickness)
                    .contentShape(Rectangle())
                    .onTapGesture { self.modifyMessageTapped() }

                ThoughtsTableCellDivider(axis: .vertical)

                HStack {
                    StarsLabel(numStars: self.thought.hearts)
                        .padding(.vertical)
                        .frame(width: (geometry.size.width / 3) - (3 * dividerThickness))
                        .contentShape(Rectangle())
                        .onTapGesture { self.starsTapped() }

                    ThoughtsTableCellDivider(axis: .horizontal)

                    FAIcon(iconName: "edit")
                        .padding(.vertical)
                        .frame(width: (geometry.size.width / 3) - (3 * dividerThickness))
                        .contentShape(Rectangle())
                        .onTapGesture { self.modifyMessageTapped() }

                    ThoughtsTableCellDivider(axis: .horizontal)

                    FAIcon(iconName: self.thought.discussed ? "envelope-open-text" : "envelope")
                        .padding(.vertical)
                        .frame(width: (geometry.size.width / 3) - (3 * dividerThickness))
                        .contentShape(Rectangle())
                        .onTapGesture { self.markDiscussedTapped() }
                }
                .frame(height: (geometry.size.height / 2) - dividerThickness)
            }
        }
        .frame(height: 100)
        .padding(.vertical, 20)
        .background(Color(RetroColors.expandedCellBackgroundColor.withAlphaComponent(self.opacity)))
        .cornerRadius(15)
    }

    internal func starsTapped() {
        print("tapped on stars")
        let newThought = thought.copy(hearts: thought.hearts + 1)
        self.thoughtPubSub.publishOutgoing(newThought, outgoingType: .edit)
        MSAnalytics.trackEvent("star \(newThought.topic) thought", withProperties: ["Team": URLManager.currentTeam])
    }

    internal func modifyMessageTapped() {
        print("tapped on message")
        self.items.thoughtToEdit = self.thought
        self.items.activeThoughtViewModal = .editThought
        self.items.showModal = true
    }

    internal func markDiscussedTapped() {
        print("tapped on discussed")
        let newThought = thought.copy(discussed: !thought.discussed)
        self.thoughtPubSub.publishOutgoing(newThought, outgoingType: .edit)
        MSAnalytics.trackEvent(
                "mark \(newThought.topic) thought \(newThought.discussed ? "discussed" : "undiscussed")",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }
}

enum DividerAxis: Int {
    case horizontal = 0

    case vertical = 1
}

struct FAIcon: View {
    let iconName: String

    var body: some View {
        FAText(iconName: iconName, size: 20, style: .solid)
            .foregroundColor(Color(RetroColors.cellTextColor))
    }
}

private struct ThoughtsTableCellDivider: View {
    let axis: DividerAxis

    var body: some View {
        Group {
            if axis == .vertical {
                Rectangle()
                    .fill(Color(RetroColors.separatorColor))
                    .frame(height: dividerThickness)
            } else {
                Rectangle()
                    .fill(Color(RetroColors.separatorColor))
                    .frame(width: dividerThickness)
            }
        }
    }
}

private struct MessageLabel: View {
    let thought: Thought

    var body: some View {
        Text(self.thought.message)
            .font(Font.retroquestRegular(size: 20))
            .strikethrough(self.thought.discussed)
            .foregroundColor(Color(RetroColors.cellTextColor))
            .padding(.horizontal, 25)
    }
}

private struct StarsLabel: View {
    let numStars: Int

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
            thought: Thought(
              id: 2,
              message: "fdsas",
              hearts: 70,
              topic: "happy",
              discussed: true,
              teamId: "testers"
            )
        )
            .environmentObject(PubSub<Thought>())
            .environmentObject(ItemsSwiftUI())
    }
}
