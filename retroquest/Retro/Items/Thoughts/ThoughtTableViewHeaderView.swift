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

protocol ThoughtTableViewHeaderViewDelegate: AnyObject {
    func toggleSection(_ header: ThoughtTableViewHeaderView, section: Int)
}

class ThoughtTableViewHeaderView: UITableViewHeaderFooterView {

    weak var delegate: ThoughtTableViewHeaderViewDelegate?
    var topicIndex: Int = 0

    internal let topicLabel = UILabel()
    internal let arrowLabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        let background = UIView()
        background.backgroundColor = RetroColors.tableViewHeaderBackgroundColor
        self.backgroundView = background

        contentView.addSubview(topicLabel)
        contentView.addSubview(arrowLabel)
        _ = arrowLabel.anchorWidthTo(17)
        _ = arrowLabel.anchorCenterYToSuperview()
        _ = arrowLabel.anchorTrailingToSuperview(offset: -25)
        _ = topicLabel.anchorLeadingToSuperview(offset: 25)
        _ = topicLabel.anchorCenterYToSuperview()

        addGestureRecognizer(UITapGestureRecognizer(
                target: self,
                action: #selector(ThoughtTableViewHeaderView.tapHeader(_:))
        ))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? ThoughtTableViewHeaderView else {
            return
        }

        delegate?.toggleSection(self, section: cell.topicIndex)
    }

    func setCollapsed(_ collapsed: Bool) {
        let textColor = arrowLabel.textColor ?? UIColor.black
        setupChevronIcon(collapsed, textColor: textColor)
    }

    func setupCell(columnName: String, topicIndex: Int, numThoughts: Int) {
        self.topicIndex = topicIndex

        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowColor = RetroColors.shadowColor.cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 5

        let topicFont = UIFont.retroquestBold(size: 24)
        let thoughtsCountFont = UIFont.retroquestBold(size: 14)

        var textColor: UIColor
        switch topicIndex {
        case 0:
            textColor = RetroColors.happyColor
        case 1:
            textColor = RetroColors.confusedColor
        case 2:
            textColor = RetroColors.sadColor
        default:
            textColor = UIColor.black
        }
        let labelText = NSMutableAttributedString(
            string: columnName,
            attributes: [
                NSAttributedString.Key.font: topicFont,
                NSAttributedString.Key.foregroundColor: textColor
            ]
        )
        labelText.append(NSAttributedString(
            string: "\n\(numThoughts) items",
            attributes: [
                NSAttributedString.Key.font: thoughtsCountFont,
                NSAttributedString.Key.foregroundColor: textColor
            ]
        ))

        ViewUtils.setupAttributedTextLabel(
            topicLabel,
            attributedString: labelText,
            textAlignment: .left,
            numberOfLines: 2,
            lineSpacing: 1.4
        )

        setupChevronIcon(true, textColor: textColor)
    }

    private func setupChevronIcon(_ collapsed: Bool, textColor: UIColor) {
        let arrowDirection: FontAwesome = collapsed ? .chevronRight : .chevronDown

        let chevronIconText = NSMutableAttributedString(
            string: String.fontAwesomeIcon(name: arrowDirection),
            attributes: [
                NSAttributedString.Key.font: UIFont.fontAwesome(ofSize: 20, style: .solid),
                NSAttributedString.Key.foregroundColor: textColor
            ]
        )
        ViewUtils.setupAttributedTextLabel(
            arrowLabel,
            attributedString: chevronIconText
        )
    }

}
