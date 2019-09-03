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

import M13Checkbox

internal class LoginView: UIView {
    internal let retroQuestLogo: UIImageView = {
        return UIImageView(image: UIImage(named: "Logo"))
    }()

    internal var inputStackView: UIStackView!

    internal var boardField: UITextField!
    internal var passwordField: UITextField!

    internal var signInButton: UIButton!
    internal var giveFeedbackButton: UIButton!

    internal var saveSettingsLabel: UILabel!
    internal var saveSettingsCheckbox: M13Checkbox!

    // swiftlint:disable:next function_body_length
    func setup() {
        let defaultLabelFont = UIFont.retroquestBold(size: 18)
        let biggerFont = UIFont.retroquestBold(size: 20)

        let boardLabel = ViewUtils.setupBasicTextLabel(
                "Board Name",
                font: defaultLabelFont,
                textColor: RetroColors.loginDarkTextColor,
                textAlignment: .left
        )
        boardField = ViewUtils.setupTextField(
                keyboardType: .default,
                isSecure: false,
                accessibilityId: "Login Board Field",
                textColor: RetroColors.loginDarkTextColor,
                backgroundColor: UIColor.white,
                borderStyle: .roundedRect
        )

        let passwordLabel = ViewUtils.setupBasicTextLabel(
                "Password",
                font: defaultLabelFont,
                textColor: RetroColors.loginDarkTextColor,
                textAlignment: .left
        )
        passwordField = ViewUtils.setupTextField(
                keyboardType: .default,
                isSecure: true,
                accessibilityId: "Login Password Field",
                textColor: RetroColors.loginDarkTextColor,
                backgroundColor: UIColor.white,
                borderStyle: .roundedRect
        )

        signInButton = ViewUtils.setupButtonWithText(
                "Sign In",
                font: biggerFont,
                backgroundColor: RetroColors.buttonColor
        )
        giveFeedbackButton = ViewUtils.setupButtonWithText(
                "Give Feedback",
                font: defaultLabelFont
        )
        giveFeedbackButton.setTitleColor(RetroColors.loginDarkTextColor, for: .normal)

        let boardStackView = ViewUtils.setupStackView(
                subviews: [boardLabel, boardField],
                axis: .vertical,
                spacing: 8,
                distribution: .equalSpacing
        )
        let passwordStackView = ViewUtils.setupStackView(
                subviews: [passwordLabel, passwordField],
                axis: .vertical,
                spacing: 8,
                distribution: .equalSpacing
        )

        inputStackView = ViewUtils.setupStackView(
                subviews: [boardStackView, passwordStackView],
                axis: .vertical,
                spacing: 13.5,
                distribution: .equalSpacing
        )

        saveSettingsLabel = UILabel()
                .withText("Save Credentials")
                .withColor(RetroColors.loginDarkTextColor)
                .withFont(defaultLabelFont)
        saveSettingsLabel.isUserInteractionEnabled = true

        saveSettingsCheckbox = setupCheckbox()

        addSubview(retroQuestLogo)
        addSubview(inputStackView)
        addSubview(signInButton)
        addSubview(giveFeedbackButton)
        addSubview(saveSettingsLabel)
        addSubview(saveSettingsCheckbox)

        setupConstraints()
    }

    private func setupCheckbox() -> M13Checkbox {
        let checkbox = M13Checkbox(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
        checkbox.boxType = .square
        checkbox.cornerRadius = 4.0
        checkbox.stateChangeAnimation = .flat(.fill)
        checkbox.secondaryTintColor = .black
        return checkbox
    }

    private func setupConstraints() {
        _ = retroQuestLogo.anchorTopToSuperview(offset: 8)
        _ = retroQuestLogo.anchorCenterXToSuperview()

        _ = inputStackView.anchorTopTo(retroQuestLogo.bottomAnchor, offset: 30)
        _ = inputStackView.anchorLeadingToSuperview(offset: 20)
        _ = inputStackView.anchorTrailingToSuperview(offset: -20)

        _ = signInButton.anchorTopTo(inputStackView.bottomAnchor, offset: 15)
        _ = signInButton.anchorLeadingTo(inputStackView.leadingAnchor)
        _ = signInButton.anchorTrailingTo(inputStackView.trailingAnchor)
        _ = signInButton.anchorHeightTo(44)

        _ = saveSettingsCheckbox.anchorTopTo(signInButton.bottomAnchor, offset: 15)
        _ = saveSettingsCheckbox.anchorLeadingTo(signInButton.leadingAnchor)
        _ = saveSettingsCheckbox.anchorHeightTo(25)
        _ = saveSettingsCheckbox.anchorWidthTo(25)

        _ = saveSettingsLabel.anchorTopTo(signInButton.bottomAnchor, offset: 15)
        _ = saveSettingsLabel.anchorLeadingTo(saveSettingsCheckbox.trailingAnchor, offset: 10)
        _ = saveSettingsLabel.anchorHeightTo(25)

        _ = giveFeedbackButton.anchorBottomToSuperview(offset: -29)
        _ = giveFeedbackButton.anchorLeadingToSuperview(offset: 20)
        _ = giveFeedbackButton.anchorTrailingToSuperview(offset: -20)
    }
}
