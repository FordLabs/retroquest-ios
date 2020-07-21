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

struct EditTextSwiftUIView: View {
    let titleText: String
    @State var userInput: String

    init(titleText: String, defaultText: String) {
        self.titleText = titleText
        self._userInput = State(initialValue: defaultText)
    }

    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text(titleText)
                        .font(Font(UIFont.retroquestBold(size: 24)))
                        .frame(alignment: .center)
                }
                HStack {
                    Spacer()
                    
                    Text("×")
                        .padding(.trailing, 20)
                        .font(Font(UIFont.retroquestBold(size: 34)))
                        .foregroundColor(Color(RetroColors.buttonColor))
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

            Button(action: save) {
                Text("Save")
                    .font(Font(UIFont.retroquestBold(size: 24)))
            }
                .frame(width: 100, height: 50, alignment: .center)
                .background(Color(RetroColors.buttonColor))
                .foregroundColor(Color.white)
                .cornerRadius(3.0)
                .padding()
        }
        .padding(.vertical)
        .background(Color(RetroColors.backgroundColor))
    }

    internal func save() {
        print(self.userInput)
    }
}

struct EditTextSwiftUIViewPreviews: PreviewProvider {
    static var previews: some View {
        EditTextSwiftUIView(titleText: "Change Column Name", defaultText: "Happy")
    }
}
