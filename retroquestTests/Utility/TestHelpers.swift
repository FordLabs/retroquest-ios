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

import UIKit
import Swinject
import Quick
import Nimble

extension UIControl {
    @objc func tap() {
        expect(self.isHidden).to(beFalse())
        expect(self.isEnabled).to(beTrue())
    }
}

extension UIButton {
    override func tap() {
        super.tap()
        sendActions(for: .touchUpInside)
    }
}

extension UITextField {
    override func tap() {
        super.tap()
        self.becomeFirstResponder()
        expect(self.isFirstResponder).to(beTrue())
        sendActions(for: .editingDidBegin)
    }

    func editText(_ text: String) {
        self.text = text
        sendActions(for: .editingChanged)
    }

    func tapReturn() {
        sendActions(for: .editingDidEndOnExit)
    }
}
