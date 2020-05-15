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

    init(_ thought: Thought) {
        UITableView.appearance().separatorColor = .clear
        self.thought = thought
    }

    var body: some View {
        VStack {
            MessageLabel(thought.message).padding(.top, 10)
            ThoughtsTableCellVerticalDivider()
            HStack {
                Group {
                    Spacer()
                    StarsLabel(thought.hearts)
                    Spacer()
                }
                ThoughtsTableCellHorizontalDivider()
                Group {
                    Spacer()
                    FAIcon("edit").padding(10)
                    Spacer()
                }
                ThoughtsTableCellHorizontalDivider()
                Group {
                    Spacer()
                    FAIcon("envelope").padding(10)
                    Spacer()
                }
            }.padding(.bottom, 10)
        }
        .background(Color(RetroColors.expandedCellBackgroundColor.withAlphaComponent(1.0)))
        .frame(minHeight: 0, maxHeight: 115)
    }
}

struct ThoughtsTableCellVerticalDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(RetroColors.separatorColor))
            .frame(height: 4)
    }
}

struct ThoughtsTableCellHorizontalDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color(RetroColors.separatorColor))
            .frame(width: 4)
    }
}

struct MessageLabel: View {
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

struct StarsLabel: View {
    let numStars: Int

    init(_ numStars: Int) {
        self.numStars = numStars
    }

    var body: some View {
        HStack {
            FAText(iconName: "star", size: 20, style: .solid)
                .foregroundColor(Color(RetroColors.starColor))
            Text(String.init(numStars))
                .font(Font.retroquestRegular(size: 20))
                .foregroundColor(Color(RetroColors.cellTextColor))
        }
    }
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

struct ThoughtsTableViewCellSwiftUIPreview: PreviewProvider {

    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
      @State(initialValue: Thought(
        id: 2,
        message: "fdsas",
        hearts: 3,
        topic: "happy",
        discussed: true,
        teamId: "testers"
      )) var thought: Thought

      var body: some View {
        ThoughtsTableViewCellSwiftUI(self.thought)
      }
    }
}
