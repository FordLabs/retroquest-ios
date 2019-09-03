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

public class ViewUtils {

    public static func setupStackView(
            subviews: [UIView],
            axis: NSLayoutConstraint.Axis,
            spacing: CGFloat = 0,
            lineSeparate: StackViewLineSeparator = .none,
            separatorThickness: CGFloat = 2,
            distribution: UIStackView.Distribution = .fillProportionally,
            separatorColor: UIColor = RetroColors.separatorColor
    ) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.spacing = spacing

        if lineSeparate.contains(.before) {
            stackView.addArrangedSubview(
                    setupSeparator(axis: axis, size: separatorThickness, color: separatorColor)
            )
        }

        var firstLoopIteration = true
        subviews.forEach { subview in
            if lineSeparate.contains(.between) && !firstLoopIteration {
                stackView.addArrangedSubview(
                        setupSeparator(axis: axis, size: separatorThickness, color: separatorColor)
                )
            }

            stackView.addArrangedSubview(subview)
            firstLoopIteration = false
        }

        if lineSeparate.contains(.after) {
            stackView.addArrangedSubview(
                    setupSeparator(axis: axis, size: separatorThickness, color: separatorColor)
            )
        }

        return stackView
    }

    public static func setupSeparator(
            axis: NSLayoutConstraint.Axis,
            size: CGFloat,
            color: UIColor = RetroColors.separatorColor
    ) -> UIView {
        let separator = UIView()

        var separatorConstraint: NSLayoutConstraint
        if axis == .vertical {
            separatorConstraint = separator.heightAnchor.constraint(equalToConstant: size)
        } else {
            separatorConstraint = separator.widthAnchor.constraint(equalToConstant: size)
        }
        separatorConstraint.isActive = true
        separatorConstraint.priority = UILayoutPriority(999)
        separator.addConstraint(separatorConstraint)

        separator.backgroundColor = color

        return separator
    }

    public static func setupTextField(
            placeholder: String = "",
            keyboardType: UIKeyboardType,
            isSecure: Bool,
            accessibilityId: String,
            textColor: UIColor,
            backgroundColor: UIColor = UIColor.clear,
            borderStyle: UITextField.BorderStyle = .none
    ) -> UITextField {
        let textField = UITextField()
        textField.autocorrectionType = .yes
        textField.backgroundColor = backgroundColor
        textField.font = UIFont.retroquestRegular(size: 16)
        textField.textColor = textColor
        textField.placeholder = placeholder
        textField.keyboardType = keyboardType
        textField.isSecureTextEntry = isSecure
        textField.accessibilityIdentifier = accessibilityId
        textField.borderStyle = borderStyle
        textField.autocapitalizationType = .none

        return textField
    }

    public static func setupButtonWithText(
            _ text: String,
            font: UIFont,
            backgroundColor: UIColor = UIColor.clear,
            textColor: UIColor = UIColor.white
    ) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: UIControl.State())
        button.contentVerticalAlignment = .center
        button.setTitleColor(textColor, for: UIControl.State())
        button.titleLabel?.font = font
        button.layer.cornerRadius = 3.0
        button.backgroundColor = backgroundColor
        button.accessibilityIdentifier = text

        return button
    }

    public static func setupButtonWithAttributedText(_ attributedText: NSAttributedString) -> UIButton {
        let button = UIButton(type: .system)
        button.setAttributedTitle(attributedText, for: UIControl.State())
        button.contentVerticalAlignment = .center
        button.layer.cornerRadius = 3.0
        button.accessibilityIdentifier = attributedText.string

        return button
    }

    public static func setupBasicTextLabel(
            _ text: String,
            font: UIFont,
            textColor: UIColor = UIColor.white,
            textAlignment: NSTextAlignment = .center
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        return label
    }

    public static func setupAttributedTextLabel(
            _ label: UILabel,
            attributedString: NSMutableAttributedString,
            textColor: UIColor = UIColor.white,
            textAlignment: NSTextAlignment = .center,
            numberOfLines: Int = 0,
            lineBreakMode: NSLineBreakMode = .byWordWrapping,
            lineSpacing: CGFloat? = nil,
            gestureRecognizer: UIGestureRecognizer? = nil
    ) {
        label.attributedText = attributedString
        label.textAlignment = textAlignment
        label.lineBreakMode = lineBreakMode
        label.numberOfLines = numberOfLines

        if let lineSpacing = lineSpacing {
            label.setLineSpacing(lineHeightMultiple: lineSpacing)
        }
        if let gestureRecognizer = gestureRecognizer {
            label.isUserInteractionEnabled = true
            label.addGestureRecognizer(gestureRecognizer)
        }
    }

    public struct StackViewLineSeparator: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let none = StackViewLineSeparator(rawValue: 1 << 0)
        public static let before = StackViewLineSeparator(rawValue: 1 << 1)
        public static let after = StackViewLineSeparator(rawValue: 1 << 2)
        public static let between = StackViewLineSeparator(rawValue: 1 << 3)

        public static let beforeAndAfter: StackViewLineSeparator = [.before, .after]
        public static let betweenAndBeforeAndAfter: StackViewLineSeparator = [.before, .after, .between]
        public static let betweenAndAfter: StackViewLineSeparator = [.after, .between]
        public static let betweenAndBefore: StackViewLineSeparator = [.before, .between]
    }
}
