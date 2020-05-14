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

class NewItemView<T: Item>: UIView {
    internal let tableView = UITableView()
    internal let statusBarHeight = UIWindow.key!.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

    internal var headingLabel: UILabel!
    internal var cancelButton: UIButton!
    internal var saveButton: UIButton!
    internal var validatingTextField: ValidatingTextField!

    convenience init() {
        self.init(frame: .zero)

        self.backgroundColor = RetroColors.backgroundColor

        initializeViews()

        addSubview(headingLabel)
        addSubview(cancelButton)
        addSubview(validatingTextField)
        addSubview(saveButton)
        if isThoughtView() {
            addSubview(tableView)
        }

        setupConstraints()
    }

    internal func setupWithDelegateDataSource(
            delegate: UITableViewDelegate & UITableViewDataSource & UITextFieldDelegate
    ) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
        validatingTextField.setupWith(textFieldDelegate: delegate)
    }

    func getText() -> String? {
        return validatingTextField.itemTextField.text
    }

    private func initializeViews() {
        tableView.register(NewItemCell.self, forCellReuseIdentifier: "NewItemCell")
        tableView.reloadData()
        tableView.backgroundColor = UIColor.white
        tableView.tableFooterView = UIView()
        tableView.layer.cornerRadius = 5

        let className = String(describing: T.self).convertPascalCaseToLowerCaseWithSpaces
        headingLabel = ViewUtils.setupBasicTextLabel(
                "Add new \(className)",
            font: UIFont.retroquestBold(size: 24),
                textColor: UIColor.black
        )

        self.validatingTextField = ValidatingTextField(defaultText: nil, placeholderText: "Enter \(className)")

        cancelButton = ViewUtils.setupButtonWithText(
                "×",
                font: UIFont.retroquestBold(size: 34),
                textColor: RetroColors.buttonColor
        )
        saveButton = ViewUtils.setupButtonWithText(
                "Add",
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

        if isThoughtView() {
            _ = tableView.anchorLeadingToSuperview(offset: 20)
            _ = tableView.anchorTrailingToSuperview(offset: -20)
            _ = tableView.anchorTopTo(validatingTextField.bottomAnchor, offset: 10)
            _ = tableView.anchorHeightTo(150)

            _ = saveButton.anchorTopTo(tableView.bottomAnchor, offset: 25)
        } else {
            _ = saveButton.anchorTopTo(validatingTextField.bottomAnchor, offset: 25)
        }

        _ = saveButton.anchorCenterXToSuperview()
        _ = saveButton.anchorHeightTo(50)
        _ = saveButton.anchorWidthTo(100)
    }

    internal func isThoughtView() -> Bool {
        return T.self is Thought.Type
    }
}
