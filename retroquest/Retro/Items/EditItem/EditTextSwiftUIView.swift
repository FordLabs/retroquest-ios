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

struct EditTextSwiftUIView: View {
    @EnvironmentObject var itemPubSub: PubSub<Thought>
    @EnvironmentObject var items: ItemsSwiftUI
    let titleText: String
    @State var userInput: String

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
//                ValidatingTextFieldSwiftUI(defaultText: $defaultText, placeholderText: .constant(nil))
            TextField("", text: $userInput)
                .padding()
                .foregroundColor(Color.black)
                .background(Color.white)
                .cornerRadius(5)
                .font(Font(UIFont.retroquestRegular(size: 16)))
                .padding()

            if userInput.count == 0 {
                EditTextValidationErrorSwiftUIView(errorMessage: "Text cannot be empty.")
            } else if userInput.count > 255 {
                EditTextValidationErrorSwiftUIView(errorMessage: "Text must be less than 255 characters.")
            }

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

    internal func save() {
        print(self.userInput)
        
        MSAnalytics.trackEvent(
                "edit \(self.userInput) thought text",
                withProperties: ["Team": URLManager.currentTeam]
        )
        let newThought = self.items.thoughtToEdit?.copy(message: userInput)
        self.itemPubSub.publishOutgoing(newThought, outgoingType: .edit)

        exit()
    }

    internal func exit() {
        print("exiting edit text modal")
        self.items.showThoughtEditModal = false
        self.items.thoughtToEdit = nil
    }

    internal func isValidInput() -> Bool {
        return userInput.count != 0 && userInput.count <= 255
    }
}

struct EditTextValidationErrorSwiftUIView: View {
    let errorMessage: String

    var body: some View {
        Text(errorMessage)
            .font(Font(UIFont.retroquestBold(size: 18)))
            .foregroundColor(Color.white)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
            .background(Color(RetroColors.sadColor))
            .cornerRadius(5)
            .padding(.horizontal)
    }
}

struct EditTextSwiftUIViewPreviews: PreviewProvider {

    static var previews: some View {
        EditTextSwiftUIView(titleText: "Change Column Name", userInput: "Happy")
            .environmentObject(PubSub<Thought>())
            .environmentObject(ItemsSwiftUI())
    }
}
