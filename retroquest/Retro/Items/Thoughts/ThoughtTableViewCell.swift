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

class ThoughtTableViewCell: UITableViewCell {
    internal let messageLabel = UILabel()
    internal let starsLabel = UILabel()
    internal let markDiscussedLabel = UILabel()
    internal let modifyMessageLabel = UILabel()
    internal let topSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)
    internal let actionSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)
    internal let trailingSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)

    internal var actionsStackView: UIStackView!

    internal var thought: Thought!
    internal weak var thoughtEditDelegate: ThoughtEditDelegate!

    func setupCell(thought: Thought, delegate: ThoughtEditDelegate) {
        let opacity = CGFloat(thought.discussed ? 0.7 : 1.0)
        backgroundColor = RetroColors.expandedCellBackgroundColor.withAlphaComponent(opacity)
        selectionStyle = .none
        self.thoughtEditDelegate = delegate
        self.thought = thought

        let defaultTextColor = RetroColors.cellTextColor
        let defaultFont = UIFont.retroquestRegular(size: 20)
        let faFont = UIFont.fontAwesome(ofSize: 20, style: .solid)
        setupMessageLabel(thought: thought, font: defaultFont, defaultColor: defaultTextColor)
        setupStarLabel(thought: thought, font: faFont, defaultColor: defaultTextColor)
        setupDiscussedLabel(thought: thought, font: faFont, defaultColor: defaultTextColor)
        setupModifyMessageLabel(thought: thought, font: faFont, defaultColor: defaultTextColor)

        if actionsStackView == nil {
            self.actionsStackView = ViewUtils.setupStackView(
                    subviews: [starsLabel, modifyMessageLabel, markDiscussedLabel],
                    axis: .horizontal,
                    spacing: 8,
                    lineSeparate: .between,
                    separatorThickness: 4
            )
        }

        markDiscussedLabel.widthAnchor.constraint(equalTo: starsLabel.widthAnchor).isActive = true
        modifyMessageLabel.widthAnchor.constraint(equalTo: starsLabel.widthAnchor).isActive = true

        contentView.addSubview(topSeparator)
        contentView.addSubview(messageLabel)
        contentView.addSubview(actionSeparator)
        contentView.addSubview(actionsStackView)
        contentView.addSubview(trailingSeparator)

        anchorViews()
    }

    private func anchorViews() {
        _ = topSeparator.anchorTopToSuperview()
        _ = topSeparator.anchorLeadingToSuperview()
        _ = topSeparator.anchorTrailingToSuperview()
        _ = messageLabel.anchorTopTo(topSeparator.bottomAnchor, offset: 10)
        _ = messageLabel.anchorTrailingToSuperview(offset: -10)
        _ = messageLabel.anchorLeadingToSuperview(offset: 10)
        _ = actionSeparator.anchorTopTo(messageLabel.bottomAnchor, offset: 10)
        _ = actionSeparator.anchorLeadingToSuperview()
        _ = actionSeparator.anchorTrailingToSuperview()
        _ = actionsStackView.anchorTopTo(actionSeparator.bottomAnchor, offset: 10)
        _ = actionsStackView.anchorLeadingToSuperview()
        _ = actionsStackView.anchorTrailingToSuperview()
        _ = trailingSeparator.anchorTopTo(actionsStackView.bottomAnchor, offset: 10)
        _ = trailingSeparator.anchorLeadingToSuperview()
        _ = trailingSeparator.anchorTrailingToSuperview()
        _ = trailingSeparator.anchorBottomToSuperview()
    }

    @objc
    internal func starsTapped(sender: UITapGestureRecognizer?) {
        print("tapped on stars")
        thoughtEditDelegate.starred(thought)
    }

    @objc
    internal func markDiscussedTapped(sender: UITapGestureRecognizer?) {
        print("tapped on discussed")
        thoughtEditDelegate.discussed(thought)
    }

    @objc
    internal func modifyMessageTapped(sender: UITapGestureRecognizer?) {
        print("tapped on message")
        thoughtEditDelegate.textChanged(thought)
    }

    private func setupDiscussedLabel(thought: Thought, font: UIFont, defaultColor: UIColor) {
        let discussedFontAwesomeIcon: FontAwesome = thought.discussed ? .envelopeOpenText : .envelope
        let discussedIconText = NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: discussedFontAwesomeIcon),
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: defaultColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                markDiscussedLabel,
                attributedString: discussedIconText,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(markDiscussedTapped))
        )
    }

    private func setupModifyMessageLabel(thought: Thought, font: UIFont, defaultColor: UIColor) {
        let modifyMessageIcon = NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: .edit),
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: defaultColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                modifyMessageLabel,
                attributedString: modifyMessageIcon,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(modifyMessageTapped))
        )
    }

    private func setupStarLabel(thought: Thought, font: UIFont, defaultColor: UIColor) {
        let starsLabelText = NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: .star) + " " + String(thought.hearts),
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.foregroundColor: defaultColor
                ]
        )
        starsLabelText.addAttribute(
                NSAttributedString.Key.foregroundColor,
                value: RetroColors.starColor,
                range: NSRange(location: 0, length: 1)
        )
        ViewUtils.setupAttributedTextLabel(
                starsLabel,
                attributedString: starsLabelText,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(starsTapped))
        )
    }

    private func setupMessageLabel(thought: Thought, font: UIFont, defaultColor: UIColor) {
        let strikeThrough = thought.discussed ? 1 : 0
        let messageText = NSMutableAttributedString(
                string: thought.message,
                attributes: [
                    NSAttributedString.Key.font: font,
                    NSAttributedString.Key.strikethroughStyle: strikeThrough,
                    NSAttributedString.Key.foregroundColor: defaultColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                messageLabel,
                attributedString: messageText,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(modifyMessageTapped))
        )
    }
}
