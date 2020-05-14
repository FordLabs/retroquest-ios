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

class EditTextView: UIView {
    internal let statusBarHeight = UIWindow.key!.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

    internal var headingLabel: UILabel!
    internal var cancelButton: UIButton!
    internal var saveButton: UIButton!
    internal var validatingTextField: ValidatingTextField!
    internal var errorHeightConstraint: NSLayoutConstraint?

    internal var titleText: String!
    internal var defaultText: String!

    convenience init(titleText: String!, defaultText: String?) {
        self.init(frame: .zero)

        self.backgroundColor = RetroColors.backgroundColor

        self.titleText = titleText
        self.defaultText = defaultText != nil ? defaultText : ""

        initializeViews()

        addSubview(headingLabel)
        addSubview(cancelButton)
        addSubview(validatingTextField)
        addSubview(saveButton)

        setupConstraints()
    }

    func setupWith(textFieldDelegate: UITextFieldDelegate) {
        validatingTextField.setupWith(textFieldDelegate: textFieldDelegate)
    }

    func getText() -> String? {
        return validatingTextField.itemTextField.text
    }

    private func initializeViews() {
        headingLabel = ViewUtils.setupBasicTextLabel(
            titleText!,
            font: UIFont.retroquestBold(size: 24),
            textColor: UIColor.black
        )

        validatingTextField = ValidatingTextField(defaultText: self.defaultText, placeholderText: nil)

        cancelButton = ViewUtils.setupButtonWithText(
                "×",
                font: UIFont.retroquestBold(size: 34),
                textColor: RetroColors.buttonColor
        )
        saveButton = ViewUtils.setupButtonWithText(
                "Save",
                font: UIFont.retroquestBold(size: 24),
                backgroundColor: RetroColors.buttonColor
        )
    }

    private func setupConstraints() {
        _ = headingLabel.anchorCenterXToSuperview()
        _ = headingLabel.anchorTopToSuperview(offset: statusBarHeight)
        _ = headingLabel.anchorHeightTo(50)

        _ = cancelButton.anchorTopToSuperview(offset: statusBarHeight)
        _ = cancelButton.anchorHeightTo(50)
        _ = cancelButton.anchorRightToSuperview(offset: -20)

        _ = validatingTextField.anchorTopTo(headingLabel.bottomAnchor)
        _ = validatingTextField.anchorLeadingToSuperview()
        _ = validatingTextField.anchorTrailingToSuperview()

        _ = saveButton.anchorTopTo(validatingTextField.bottomAnchor, offset: 25)
        _ = saveButton.anchorCenterXToSuperview()
        _ = saveButton.anchorHeightTo(50)
        _ = saveButton.anchorWidthTo(100)
    }
}
