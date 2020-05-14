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

class ActionItemsView: UIView {
    let tableView = UITableView()
    let statusBarHeight = UIWindow.key!.windowScene?.statusBarManager?.statusBarFrame.height ?? 0

    var headingLabel: UILabel!
    var addActionItemButton: UIButton!

    convenience init() {
        self.init(frame: .zero)

        initializeViews()

        addSubview(tableView)
        addSubview(headingLabel)
        addSubview(addActionItemButton)

        setupConstraints()
    }

    internal func setupWithDelegateDataSource(delegate: UITableViewDelegate & UITableViewDataSource) {
        tableView.dataSource = delegate
        tableView.delegate = delegate
    }

    private func initializeViews() {
        tableView.register(ActionItemTableViewCell.self, forCellReuseIdentifier: "ActionItemTableViewCell")

        tableView.reloadData()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 150

        headingLabel = ViewUtils.setupBasicTextLabel(
                URLManager.currentTeam,
                font: UIFont.retroquestBold(size: 24),
                textColor: UIColor.black
        )

        addActionItemButton = ViewUtils.setupButtonWithText(
                "+",
                font: UIFont.retroquestBold(size: 32),
                textColor: RetroColors.buttonColor
        )
    }

    private func setupConstraints() {
        _ = headingLabel.anchorLeftToSuperview()
        _ = headingLabel.anchorRightToSuperview()
        _ = headingLabel.anchorTopToSuperview(offset: statusBarHeight)
        _ = headingLabel.anchorHeightTo(50)

        _ = addActionItemButton.anchorTopToSuperview(offset: statusBarHeight)
        _ = addActionItemButton.anchorHeightTo(50)
        _ = addActionItemButton.anchorRightToSuperview(offset: -25)

        _ = tableView.anchorEdgesToSuperView(omit: .top)
        _ = tableView.anchorTopTo(headingLabel.bottomAnchor)
    }

}
