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

struct NewItemSwiftUIView: View {
    @EnvironmentObject var items: ItemsSwiftUI
    let titleText: String
    @State var userInput: String
    let saveCallback: (String, Column?) -> Void
    @State var selectedColumn: Column?

    var body: some View {
        let numColumns: Int = self.items.columns.count
        let columnRowTextHeight: CGFloat = 50.0
        let columnRowHeight = CGFloat(numColumns) * (columnRowTextHeight + 4.0 * CGFloat(numColumns))

        return VStack {
            Spacer()

            ZStack {
                HStack {
                    Text(titleText)
                        .font(Font(UIFont.retroquestBold(size: 24)))
                        .frame(alignment: .center)
                }
                HStack {
                    Spacer()

                    Button(action: exit) {
                        Text("×")
                            .padding(.trailing, 20)
                            .font(Font(UIFont.retroquestBold(size: 34)))
                            .foregroundColor(Color(RetroColors.buttonColor))
                    }
                }
            }

            ValidatingTextFieldSwiftUI(userInput: $userInput, placeholderText: "Enter Thought")

            List {
                ForEach(self.items.columns, id: \.self) { column in
                    HStack {
                        Text(column.title)
                            .font(Font.retroquestRegular(size: 20))
                            .frame(height: 50)
                        if self.selectedColumn == column {
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color.green)
                            }
                        }
                    }
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            self.selectedColumn = column
                        }
                }
            }
                .background(Color.white)
                .frame(height: columnRowHeight)
                .cornerRadius(5.0)
                .padding(.horizontal)

            Button(action: save) {
                Text("Save")
                    .font(Font(UIFont.retroquestBold(size: 24)))
            }
                .frame(width: 100, height: 50, alignment: .center)
                .background(isValidInput() ? Color(RetroColors.buttonColor) : Color.gray)
                .foregroundColor(Color.white)
                .cornerRadius(3.0)
                .padding()
                .disabled(!isValidInput())

            Spacer()
        }
        .padding(.vertical)
        .background(Color(RetroColors.backgroundColor))
    }

    private func save() {
        print(self.userInput)
        saveCallback(self.userInput, self.selectedColumn)
        exit()
    }

    private func exit() {
        print("exiting edit text modal")
        self.items.showModal = false
    }

    private func isValidInput() -> Bool {
        return userInput.count != 0 && userInput.count <= 255 && self.selectedColumn != nil
    }
}

struct NewItemSwiftUIViewPreviews: PreviewProvider {
    static let items = ItemsSwiftUI(
        thoughts: [[], [], []],
        columns: [
            Column(id: 88, topic: ColumnName.happy.rawValue, title: "kindaHappy", teamId: "1"),
            Column(id: 89, topic: ColumnName.confused.rawValue, title: "kindaConfused", teamId: "1"),
            Column(id: 90, topic: ColumnName.sad.rawValue, title: "kindaSad", teamId: "1")
        ]
    )

    static func saveCallback(input: String, selectedColumn: Column?) {}

    static var previews: some View {
        NewItemSwiftUIView(
            titleText: "Add New Thought",
            userInput: "",
            saveCallback: saveCallback
        ).environmentObject(items)
    }
}
