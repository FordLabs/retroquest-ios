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

class NewItemCell: UITableViewCell {
    internal let topicLabel = UILabel()

    internal var newItemStackView: UIStackView!

    func setupCell(topic: String) {
        topicLabel.text = topic

        contentView.addSubview(topicLabel)
        self.accessoryType = .none
        self.selectionStyle = .none

        topicLabel.font = UIFont.retroquestBold(size: 18)

        _ = topicLabel.anchorTopToSuperview()
        _ = topicLabel.anchorLeadingToSuperview(offset: 20)
        _ = topicLabel.anchorTrailingToSuperview(offset: 20)
        _ = topicLabel.anchorBottomToSuperview()
    }
}
