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

class ThoughtsView: UIView {
    internal let tableView = UITableView()
    internal let statusBarHeight = UIApplication.shared.statusBarFrame.height

    internal var headingLabel: UILabel!
    internal var addThoughtButton: UIButton!

    convenience init() {
        self.init(frame: .zero)

        initializeViews()

        addSubview(tableView)
        addSubview(headingLabel)
        addSubview(addThoughtButton)

        setupConstraints()
    }

    private func initializeViews() {
        tableView.estimatedRowHeight = 125.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none

        headingLabel = ViewUtils.setupBasicTextLabel(
            URLManager.currentTeam,
            font: UIFont.retroquestBold(size: 24),
            textColor: UIColor.black
        )

        tableView.tableFooterView = UIView()

        addThoughtButton = ViewUtils.setupButtonWithText(
                "+",
                font: UIFont.retroquestBold(size: 32),
                textColor: RetroColors.buttonColor
        )
    }

    private func setupConstraints() {
        _ = headingLabel.anchorCenterXToSuperview()
        _ = headingLabel.anchorTopToSuperview(offset: statusBarHeight)
        _ = headingLabel.anchorHeightTo(50)

        _ = addThoughtButton.anchorTopToSuperview(offset: statusBarHeight)
        _ = addThoughtButton.anchorHeightTo(50)
        _ = addThoughtButton.anchorRightToSuperview(offset: -25)

        _ = tableView.anchorEdgesToSuperView(omit: .top)
        _ = tableView.anchorTopTo(headingLabel.bottomAnchor)
    }
}
