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
import AppCenterAnalytics

class NewItemViewController<T: Item>: UIViewController,
        UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    internal var newItemView: NewItemView<T>!
    internal var columnNameService: ColumnNameService?
    internal var pubSub: PubSub<T>!
    internal var tableView: UITableView {
        return newItemView.tableView
    }

    convenience init(pubSub: PubSub<T>, columnNameService: ColumnNameService? = nil) {
        self.init()

        self.pubSub = pubSub
        self.columnNameService = columnNameService

        self.newItemView = NewItemView<T>()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(newItemView)
        _ = newItemView.anchorEdgesToSuperView()
        newItemView.setupWithDelegateDataSource(delegate: self)

        newItemView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        newItemView.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)

        tableView.reloadData()
    }

    @objc internal func cancel() {
        print("dismissing new item view")
        self.dismiss(animated: true, completion: nil)
    }

    @objc internal func save() {
        print("dismissing new item view and saving")
        let enteredValue = newItemView.getText() ?? ""

        if enteredValue.count > 255 {
            newItemView.validatingTextField.showValidationError("Text must be less than 255 characters.")
            return
        }

        if enteredValue.isEmpty {
            newItemView.validatingTextField.showValidationError("Text cannot be empty.")
            return
        }

        if newItemView.isThoughtView() {
            saveThought(enteredValue)
        } else {
            saveActionItem(enteredValue)
        }
        self.dismiss(animated: true, completion: nil)
    }

    private func saveThought(_ enteredValue: String) {
        guard let selectedTopicIndex = getSelectedRowIndex() else {
            newItemView.validatingTextField.showValidationError("A topic must be selected.")
            return
        }

        guard let newThought = Thought(
                id: -1,
                message: enteredValue,
                hearts: 0,
                topic: ColumnNameService.displayOrderForTopics[selectedTopicIndex].rawValue,
                discussed: false,
                teamId: URLManager.currentTeam
        ) as? T else {
            print("Unable to add thought")
            return
        }
        self.pubSub.publishOutgoing(newThought, outgoingType: .create)
        MSAnalytics.trackEvent(
                "added \(ColumnNameService.displayOrderForTopics[selectedTopicIndex].rawValue) thought",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    private func saveActionItem(_ enteredValue: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        var task: String = enteredValue
        var assignee: String?

        if let startOfAssigneeBlock = enteredValue.firstIndex(of: "@") {
            let prefixOfAssignee = enteredValue.prefix(upTo: startOfAssigneeBlock)
            let indexOfAssigneeWithoutAt = enteredValue.index(startOfAssigneeBlock, offsetBy: 1)
            let restOfAssignee = enteredValue[indexOfAssigneeWithoutAt..<enteredValue.endIndex]
            let textBlocks = restOfAssignee.split(separator: " ", maxSplits: 1)

            assignee = String(textBlocks[0])
            task = String(prefixOfAssignee)

            if textBlocks.count > 1 {
                task += String(textBlocks[1])
            }
        }

        guard let newActionItem = ActionItem(
                id: -1,
                task: task,
                completed: false,
                teamId: URLManager.currentTeam,
                assignee: assignee,
                dateCreated: dateFormatter.string(from: Date())
        ) as? T else {
            print("Unable to add new action item")
            return
        }
        self.pubSub.publishOutgoing(newActionItem, outgoingType: .create)
        MSAnalytics.trackEvent("added action item", withProperties: ["Team": URLManager.currentTeam])
    }

    // MARK: UITableViewDelegate, UITableViewDataSource Delegate Methods

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return columnNameService?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "NewItemCell",
                for: indexPath
        ) as? NewItemCell else {
            print("Unable to convert Cell to NewItemCell")
            return UITableViewCell()
        }
        guard let column = columnNameService?.items[indexPath.row] else {
            return UITableViewCell()
        }
        cell.setupCell(topic: column.title)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
            self.newItemView.validatingTextField.hideValidationError()
        }
    }

    func getSelectedRowIndex() -> Int? {
        let numRows = tableView(tableView, numberOfRowsInSection: 0)
        for row in 0...numRows - 1 {
            let indexPath = IndexPath(row: row, section: 0)
            let currentCell = tableView.cellForRow(at: indexPath)!
            if currentCell.accessoryType == .checkmark {
                return row
            }
        }

        return nil
    }

    // MARK: UITextFieldDelegate Delegate Methods

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newItemView.validatingTextField.itemTextField {
            save()
            return true
        }
        return false
    }
}
