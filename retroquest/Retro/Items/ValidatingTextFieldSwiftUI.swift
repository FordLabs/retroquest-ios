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

struct ValidatingTextFieldSwiftUI: View {
    @Binding var userInput: String

    var body: some View {
        var errorMessage = ""
        if self.userInput.count == 0 {
            errorMessage = "Text cannot be empty."
        } else if self.userInput.count > 255 {
            errorMessage = "Text must be less than 255 characters."
        }

        return VStack {
            TextField("", text: $userInput)
                .padding()
                .foregroundColor(Color.black)
                .background(Color.white)
                .cornerRadius(5)
                .font(Font(UIFont.retroquestRegular(size: 16)))
                .padding()

            if errorMessage != "" {
                Text(errorMessage)
                    .font(Font(UIFont.retroquestBold(size: 18)))
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color(RetroColors.sadColor))
                    .cornerRadius(5)
                    .padding(.horizontal)
            }
        }
    }
}

struct ValidatingTextFieldSwiftUI_Previews: PreviewProvider {
    struct BindingTestHolder: View {
        @State var userInput: String = ""

        var body: some View {
            ValidatingTextFieldSwiftUI(userInput: $userInput)
                .background(Color(RetroColors.backgroundColor))
        }
    }

    static var previews: some View {
        BindingTestHolder()
    }
}
