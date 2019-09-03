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

protocol ActionItemEditDelegate: AnyObject {
    func changeCompleted(_ actionItem: ActionItem)
    func modifyTask(_ actionItem: ActionItem)
    func changeAssignee(_ actionItem: ActionItem)
}

class ActionItemTableViewCell: UITableViewCell {
    internal let taskLabel = UILabel()
    internal let assignedToLabel = UILabel()
    internal let assigneeLabel = UILabel()
    internal let markCompletedLabel = UILabel()
    internal let creationDateLabel = UILabel()
    internal let modifyTaskLabel = UILabel()
    internal var actionsStackView: UIStackView!

    internal let topSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)
    internal let actionSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)
    internal let trailingSeparator = ViewUtils.setupSeparator(axis: .vertical, size: 4)

    internal var actionItem: ActionItem!
    internal weak var actionItemEditDelegate: ActionItemEditDelegate!

    func setupCell(actionItem: ActionItem, delegate: ActionItemEditDelegate) {
        let opacity = CGFloat(actionItem.completed ? 0.33 : 1.0)
        backgroundColor = RetroColors.expandedCellBackgroundColor.withAlphaComponent(opacity)
        selectionStyle = .none
        self.actionItemEditDelegate = delegate
        self.actionItem = actionItem

        setupTaskLabel(actionItem: actionItem)
        setupAssignedToLabel()
        setupAssigneeLabel(actionItem: actionItem)
        setupCompletedLabel(actionItem: actionItem)
        setupCreatedOnLabel(actionItem: actionItem)
        setupModifyTaskLabel(actionItem: actionItem)

        if actionsStackView == nil {
            actionsStackView = ViewUtils.setupStackView(
                    subviews: [creationDateLabel, modifyTaskLabel, markCompletedLabel],
                    axis: .horizontal,
                    lineSeparate: .between,
                    distribution: .fill
            )
        }
        markCompletedLabel.widthAnchor.constraint(equalTo: creationDateLabel.widthAnchor).isActive = true
        modifyTaskLabel.widthAnchor.constraint(equalTo: creationDateLabel.widthAnchor).isActive = true

        contentView.addSubview(topSeparator)
        contentView.addSubview(taskLabel)
        contentView.addSubview(assignedToLabel)
        contentView.addSubview(assigneeLabel)
        contentView.addSubview(actionSeparator)
        contentView.addSubview(actionsStackView)
        contentView.addSubview(trailingSeparator)

        anchorViews()
    }

    private func anchorViews() {
        _ = topSeparator.anchorTopToSuperview()
        _ = topSeparator.anchorLeadingToSuperview()
        _ = topSeparator.anchorTrailingToSuperview()
        _ = taskLabel.anchorTopTo(topSeparator.bottomAnchor, offset: 10)
        _ = taskLabel.anchorTrailingToSuperview(offset: -10)
        _ = taskLabel.anchorLeadingToSuperview(offset: 10)
        _ = assignedToLabel.anchorTopTo(taskLabel.bottomAnchor, offset: 10)
        _ = assignedToLabel.anchorLeadingToSuperview(offset: 10)
        _ = assignedToLabel.anchorTrailingToSuperview(offset: -10)
        _ = assigneeLabel.anchorTopTo(assignedToLabel.bottomAnchor)
        _ = assigneeLabel.anchorTrailingToSuperview(offset: -10)
        _ = assigneeLabel.anchorLeadingToSuperview(offset: 10)
        _ = actionSeparator.anchorTopTo(assigneeLabel.bottomAnchor, offset: 10)
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
    internal func markCompletedTapped(sender: UITapGestureRecognizer?) {
        print("tapped on completed")
        actionItemEditDelegate.changeCompleted(actionItem)
    }

    @objc
    internal func modifyTaskTapped(sender: UITapGestureRecognizer?) {
        print("tapped on task")
        actionItemEditDelegate.modifyTask(actionItem)
    }

    @objc
    internal func assigneeTapped(sender: UITapGestureRecognizer?) {
        print("tapped on assignee")
        actionItemEditDelegate.changeAssignee(actionItem)
    }

    private func setupTaskLabel(actionItem: ActionItem) {
        let taskText = NSMutableAttributedString(
                string: actionItem.task,
                attributes: [
                    NSAttributedString.Key.font: UIFont.retroquestBold(size: 20),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellTextColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                taskLabel,
                attributedString: taskText,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(modifyTaskTapped))
        )
    }

    private func setupAssignedToLabel() {
        let assignedToText = NSMutableAttributedString(
            string: "assigned to",
            attributes: [
                NSAttributedString.Key.font: UIFont.retroquestBold(size: 14),
                NSAttributedString.Key.foregroundColor: RetroColors.cellDarkTextColor
            ]
        )

        ViewUtils.setupAttributedTextLabel(
            assignedToLabel,
            attributedString: assignedToText
        )
    }

    private func setupAssigneeLabel(actionItem: ActionItem) {
        let assigneeText = NSMutableAttributedString(
                string: actionItem.assignee ?? "Unassigned",
                attributes: [
                    NSAttributedString.Key.font: UIFont.retroquestBold(size: 20),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellTextColor,
                    NSAttributedString.Key.underlineColor: RetroColors.actionItemColor,
                    NSAttributedString.Key.underlineStyle: 1
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                assigneeLabel,
                attributedString: assigneeText,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(assigneeTapped))
        )
    }

    private func setupCompletedLabel(actionItem: ActionItem) {
        let completedFontAwesomeIcon: FontAwesome = actionItem.completed ? .envelopeOpenText : .envelope
        let completedIconText = NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: completedFontAwesomeIcon),
                attributes: [
                    NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellTextColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                markCompletedLabel,
                attributedString: completedIconText,
                numberOfLines: 2,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(markCompletedTapped))
        )
    }

    private func setupModifyTaskLabel(actionItem: ActionItem) {
        let modifyTaskIcon = NSMutableAttributedString(
                string: String.fontAwesomeIcon(name: .edit),
                attributes: [
                    NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellTextColor
                ]
        )
        ViewUtils.setupAttributedTextLabel(
                modifyTaskLabel,
                attributedString: modifyTaskIcon,
                numberOfLines: 2,
                gestureRecognizer: UITapGestureRecognizer(target: self, action: #selector(modifyTaskTapped))
        )
    }

    private func setupCreatedOnLabel(actionItem: ActionItem) {
        let createdOnText = NSMutableAttributedString(
                string: "created\n",
                attributes: [
                    NSAttributedString.Key.font: UIFont.retroquestBold(size: 13),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellDarkTextColor
                ]
        )
        createdOnText.append(NSMutableAttributedString(
                string: actionItem.dateCreated ?? "",
                attributes: [
                    NSAttributedString.Key.font: UIFont.retroquestBold(size: 15),
                    NSAttributedString.Key.foregroundColor: RetroColors.cellTextColor
                ]
        ))
        ViewUtils.setupAttributedTextLabel(
                creationDateLabel,
                attributedString: createdOnText,
                numberOfLines: 2
        )
    }
}
