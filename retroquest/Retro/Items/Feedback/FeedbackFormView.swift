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
import FontAwesome

class FeedbackFormView: UIView {
    internal let statusBarHeight = UIApplication.shared.statusBarFrame.height

    internal var headingLabel: UILabel!
    internal var improveLabel: UILabel!

    internal var commentsLabel: UILabel!
    internal var commentsTextBox: ValidatingTextField!

    internal var starStackView: UIStackView!
    internal var stars: [UIButton]!

    internal var emailLabel: UILabel!
    internal var emailTextBox: ValidatingTextField!

    internal var submitButton: UIButton!
    internal var cancelButton: UIButton!

    convenience init() {
        self.init(frame: .zero)

        self.backgroundColor = RetroColors.backgroundColor

        initializeViews()

        addSubview(headingLabel)
        addSubview(cancelButton)
        addSubview(improveLabel)
        addSubview(starStackView)
        addSubview(commentsLabel)
        addSubview(commentsTextBox)
        addSubview(emailLabel)
        addSubview(emailTextBox)
        addSubview(submitButton)

        setupConstraints()
    }

    internal func setupWithDelegateDataSource(delegate: UITextFieldDelegate) {
        commentsTextBox.setupWith(textFieldDelegate: delegate)
        emailTextBox.setupWith(textFieldDelegate: delegate)
    }

    private func initializeViews() {
        headingLabel = ViewUtils.setupBasicTextLabel(
                "Feedback",
                font: UIFont.retroquestBold(size: 24),
                textColor: UIColor.black
        )

        cancelButton = ViewUtils.setupButtonWithText(
                "×",
                font: UIFont.retroquestBold(size: 34),
                textColor: RetroColors.buttonColor
        )

        improveLabel = ViewUtils.setupBasicTextLabel(
                "How can we improve RetroQuest?",
                font: UIFont.retroquestBold(size: 18),
                textColor: UIColor.black
        )

        createStars()

        commentsLabel = ViewUtils.setupBasicTextLabel(
                "Comments*",
                font: UIFont.retroquestBold(size: 14),
                textColor: UIColor.blue
        )
        commentsTextBox = ValidatingTextField(defaultText: nil, placeholderText: "comments...")

        emailLabel = ViewUtils.setupBasicTextLabel(
                "Feedback Email",
                font: UIFont.retroquestBold(size: 14),
                textColor: UIColor.blue
        )
        emailTextBox = ValidatingTextField()

        submitButton = ViewUtils.setupButtonWithText(
                "Submit",
                font: UIFont.retroquestBold(size: 14),
                backgroundColor: RetroColors.buttonColor
        )
    }

    private func createStars() {
        stars = []
        let starIcon = buildStarIcon(font: UIFont.fontAwesome(ofSize: 34, style: .regular))
        for _ in 0..<5 {
            stars.append(ViewUtils.setupButtonWithAttributedText(starIcon))
        }
        starStackView = ViewUtils.setupStackView(
                subviews: stars,
                axis: .horizontal,
                spacing: 25
        )
    }

    func buildStarIcon(font: UIFont) -> NSMutableAttributedString {
        return NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: .star),
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: RetroColors.buttonColor
                ]
        )
    }

    private func setupConstraints() {
        _ = headingLabel.anchorCenterXToSuperview()
        _ = headingLabel.anchorTopToSuperview(offset: statusBarHeight)
        _ = headingLabel.anchorHeightTo(50)

        _ = cancelButton.anchorTopToSuperview(offset: statusBarHeight)
        _ = cancelButton.anchorHeightTo(50)
        _ = cancelButton.anchorRightToSuperview(offset: -20)

        _ = improveLabel.anchorCenterXToSuperview()
        _ = improveLabel.anchorTopTo(headingLabel.bottomAnchor, offset: 20)
        _ = improveLabel.anchorHeightTo(40)

        _ = starStackView.anchorCenterXToSuperview()
        _ = starStackView.anchorTopTo(improveLabel.bottomAnchor, offset: 20)
        _ = starStackView.anchorHeightTo(40)

        _ = commentsLabel.anchorCenterXToSuperview()
        _ = commentsLabel.anchorTopTo(starStackView.bottomAnchor, offset: 20)
        _ = commentsLabel.anchorHeightTo(40)

        _ = commentsTextBox.anchorLeadingToSuperview()
        _ = commentsTextBox.anchorTrailingToSuperview()
        _ = commentsTextBox.anchorTopTo(commentsLabel.bottomAnchor, offset: 5)
        _ = commentsTextBox.anchorHeightTo(75)

        _ = emailLabel.anchorCenterXToSuperview()
        _ = emailLabel.anchorTopTo(commentsTextBox.bottomAnchor, offset: 0)
        _ = emailLabel.anchorHeightTo(40)

        _ = emailTextBox.anchorLeadingToSuperview()
        _ = emailTextBox.anchorTrailingToSuperview()
        _ = emailTextBox.anchorTopTo(emailLabel.bottomAnchor, offset: 5)
        _ = emailTextBox.anchorHeightTo(75)

        _ = submitButton.anchorLeadingTo(emailTextBox.itemTextField.leadingAnchor)
        _ = submitButton.anchorTrailingTo(emailTextBox.itemTextField.trailingAnchor)
        _ = submitButton.anchorCenterXToSuperview()
        _ = submitButton.anchorTopTo(emailTextBox.bottomAnchor, offset: 20)
        _ = submitButton.anchorHeightTo(50)
    }

}
