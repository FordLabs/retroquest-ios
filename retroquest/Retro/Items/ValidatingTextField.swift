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

class ValidatingTextField: UIView {

    internal var itemTextField: UITextField!
    internal var errorMessageView: UIView!
    internal var errorMessageLabel: UILabel!
    internal var errorHeightConstraint: NSLayoutConstraint?

    internal var defaultText: String!
    internal var placeholderText: String!

    convenience init(defaultText: String?, placeholderText: String?) {
        self.init(frame: .zero)

        self.backgroundColor = RetroColors.backgroundColor

        self.defaultText = defaultText != nil ? defaultText : ""
        self.placeholderText = placeholderText != nil ? placeholderText : ""

        initializeViews()

        addSubview(itemTextField)
        addSubview(errorMessageView)

        setupConstraints()
    }

    convenience init() {
        self.init(defaultText: nil, placeholderText: nil)
    }

    func setupWith(textFieldDelegate: UITextFieldDelegate) {
        itemTextField.delegate = textFieldDelegate
    }

    public func showValidationError(_ message: String) {
        errorMessageLabel.text = message
        changeErrorViewHeightTo(50)
        UIView.transition(with: errorMessageView,
                          duration: 0.5,
                          options: [.transitionFlipFromLeft],
                          animations: { self.errorMessageView.isHidden = false },
                          completion: nil)
    }

    @objc public func hideValidationError() {
        if !errorMessageView.isHidden {
            errorMessageView.isHidden = true
            changeErrorViewHeightTo(0)
        }
    }

    private func changeErrorViewHeightTo(_ newHeight: CGFloat) {
        if let errorHeightConstraint = self.errorHeightConstraint {
            errorHeightConstraint.constant = newHeight
        } else {
            errorHeightConstraint = errorMessageView.anchorHeightTo(newHeight)
        }
    }

    private func initializeViews() {

        itemTextField = ViewUtils.setupTextField(
            placeholder: self.placeholderText,
            keyboardType: .default,
            isSecure: false,
            accessibilityId: defaultText!,
            textColor: UIColor.black,
            backgroundColor: UIColor.white,
            borderStyle: .roundedRect
        )
        itemTextField.text = defaultText
        itemTextField.becomeFirstResponder()

        errorMessageView = UIView()
        errorMessageLabel = ViewUtils.setupBasicTextLabel(
            "",
            font: UIFont.retroquestBold(size: 18),
            textColor: UIColor.white,
            textAlignment: .center
        )
        errorMessageView.addSubview(errorMessageLabel)
        errorMessageLabel.anchorCenterToSuperview()
        errorMessageView.backgroundColor = RetroColors.sadColor
        errorMessageView.isHidden = true
        errorMessageView.layer.cornerRadius = 5

        itemTextField.addTarget(self, action: #selector(hideValidationError), for: .editingChanged)
    }

    private func setupConstraints() {
        _ = itemTextField.anchorTopToSuperview()
        _ = itemTextField.anchorLeadingToSuperview(offset: 20)
        _ = itemTextField.anchorTrailingToSuperview(offset: -20)
        _ = itemTextField.anchorHeightTo(50)

        _ = errorMessageView.anchorTopTo(itemTextField.bottomAnchor, offset: 10)
        _ = errorMessageView.anchorLeadingToSuperview(offset: 20)
        _ = errorMessageView.anchorTrailingToSuperview(offset: -20)
        _ = errorMessageLabel.anchorCenterYToSuperview()

        _ = self.anchorBottomTo(errorMessageView.bottomAnchor)
    }
}
