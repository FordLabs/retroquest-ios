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

class EditItemViewController: UIViewController, UITextFieldDelegate {
    internal var editTextView: EditTextView!

    internal var titleText: String!
    internal var defaultText: String!
    internal var onSave: ((String) -> Void)!
    internal var maxCharacters = 255

    convenience init(titleText: String!, defaultText: String!, onSave: ((String) -> Void)!, maxCharacters: Int = 255) {
        self.init()

        self.editTextView = EditTextView(titleText: titleText, defaultText: defaultText)
        self.onSave = onSave
        self.maxCharacters = maxCharacters
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        editTextView.setupWith(textFieldDelegate: self)
        view.addSubview(editTextView)
        _ = editTextView.anchorEdgesToSuperView()

        editTextView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        editTextView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    }

    @objc internal func cancel() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc internal func save() {
        let enteredValue = editTextView.getText() ?? ""

        if enteredValue.count > self.maxCharacters {
            editTextView.validatingTextField.showValidationError(
                    "Text must be less than \(self.maxCharacters) characters."
            )
            return
        }

        if enteredValue.isEmpty {
            editTextView.validatingTextField.showValidationError("Text cannot be empty.")
            return
        }

        onSave(enteredValue)
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: UITextFieldDelegate Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == editTextView.validatingTextField.itemTextField {
            save()
            return true
        }
        return false
    }
}
