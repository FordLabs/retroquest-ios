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

struct EditTextSwiftUIView<T: ItemsViewEnvironmentObject>: View {
    @EnvironmentObject var itemsViewEnvironmentObject: T
    let titleText: String
    @State var userInput: String
    let saveCallback: (String) -> Void

    var body: some View {
        VStack {
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

            ValidatingTextFieldSwiftUI(userInput: $userInput)

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
        saveCallback(self.userInput)
        exit()
    }

    private func exit() {
        print("exiting edit text modal")
        self.itemsViewEnvironmentObject.showModal = false
        if type(of: T.self) == ThoughtsViewEnvironmentObject.Type.self {
            if let thoughtsViewEnvironmentObject = self.itemsViewEnvironmentObject as? ThoughtsViewEnvironmentObject {
                thoughtsViewEnvironmentObject.thoughtToEdit = nil
                thoughtsViewEnvironmentObject.columnToEdit = nil
            }
        } else {
            if let actionItemsViewEnvironmentObject = self.itemsViewEnvironmentObject as? ActionItemsViewEnvironmentObject {
                actionItemsViewEnvironmentObject.actionItemToEdit = nil
            }
        }
    }

    private func isValidInput() -> Bool {
        return userInput.count != 0 && userInput.count <= 255
    }
}

struct EditTextSwiftUIViewPreviews: PreviewProvider {
    static func saveCallback(input: String) {}

    static var previews: some View {
        EditTextSwiftUIView<ThoughtsViewEnvironmentObject>(
            titleText: "Change Column Name",
            userInput: "Happy",
            saveCallback: saveCallback
        ).environmentObject(ThoughtsViewEnvironmentObject())
    }
}
