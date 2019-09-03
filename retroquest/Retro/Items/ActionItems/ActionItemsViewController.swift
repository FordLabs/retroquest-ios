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

import os.log
import AppCenterAnalytics

class ActionItemsViewController: UIViewController {
    var actionItemsService: ActionItemsService!
    var tableView: UITableView {
        return actionItemsView.tableView
    }

    let actionItemsView = ActionItemsView()

    convenience init(actionItemsService: ActionItemsService) {
        self.init()

        self.actionItemsService = actionItemsService
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        actionItemsView.setupWithDelegateDataSource(delegate: self)

        view.addSubview(actionItemsView)
        _ = actionItemsView.anchorEdgesToSuperView()
        actionItemsView.addActionItemButton.addTarget(self, action: #selector(addActionItem), for: .touchUpInside)

        _ = actionItemsService.registerItemCallback(actionItemCallback)
        getActionItems()
        MSAnalytics.trackEvent("view action items", withProperties: ["Team": URLManager.currentTeam])
    }

    func getActionItems() {
        _ = actionItemsService.requestItemsFromServer(team: URLManager.currentTeam)
    }

    func refreshData() {
        actionItemsService.clear()
        getActionItems()
    }

    @objc private func addActionItem() {
        print("Opening Add New Thought View")
        DispatchQueue.main.async(execute: {
            self.view.window?.rootViewController!.present(
                    NewItemViewController(pubSub: self.actionItemsService.itemPubSub),
                    animated: true
            )
        })
    }

    internal func actionItemCallback(actionItem: ActionItem?) {
        if var actionItem = actionItem {
            if actionItem.deletion ?? false {
                do {
                    actionItem = try self.actionItemsService.delete(actionItem)!
                } catch {
                    print("Attempted to delete non-existent action item with id \(actionItem.id)")
                    return
                }
            } else {
                _ = self.actionItemsService.addOrReplace(actionItem)
                self.actionItemsService.sort()
            }
            self.tableView.reloadData()
        }
    }
}

extension ActionItemsViewController: ActionItemEditDelegate {
    func changeCompleted(_ actionItem: ActionItem) {
        let newActionItem = actionItem.copy(completed: !actionItem.completed)
        actionItemsService.itemPubSub.publishOutgoing(newActionItem, outgoingType: .edit)
        MSAnalytics.trackEvent(
                "mark action item \(!actionItem.completed ? "completed" : "uncompleted")",
                withProperties: ["Team": URLManager.currentTeam]
        )
    }

    func modifyTask(_ actionItem: ActionItem) {
        DispatchQueue.main.async(execute: {
            self.view.window?.rootViewController!.present(
                EditItemViewController(titleText: "Change Task", defaultText: actionItem.task, onSave: { updatedText in
                    MSAnalytics.trackEvent("edit action item task", withProperties: ["Team": URLManager.currentTeam])
                    print("Updating action item task to \(updatedText)")
                    let newActionItem = actionItem.copy(task: updatedText)
                    self.actionItemsService.itemPubSub.publishOutgoing(newActionItem, outgoingType: .edit)
                }),
                animated: true
            )
        })
    }

    func changeAssignee(_ actionItem: ActionItem) {
        DispatchQueue.main.async(execute: {
            self.view.window?.rootViewController!.present(
                EditItemViewController(
                        titleText: "Change Assignee",
                        defaultText: actionItem.assignee,
                        onSave: { updatedText in
                            MSAnalytics.trackEvent(
                                    "edit action item assignee",
                                    withProperties: ["Team": URLManager.currentTeam]
                            )
                            print("Updating action item assignee to \(updatedText)")
                            let newActionItem = actionItem.copy(assignee: updatedText)
                            self.actionItemsService.itemPubSub.publishOutgoing(newActionItem, outgoingType: .edit)
                        }
                ),
                animated: true
            )
        })
    }
}

extension ActionItemsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.actionItemsService.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ActionItemTableViewCell",
                for: indexPath
        ) as? ActionItemTableViewCell else {
            fatalError("Unable to convert Cell to ActionItemTableViewCell")
        }
        cell.setupCell(actionItem: self.actionItemsService.items[indexPath.row], delegate: self)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { return true }

    func tableView(
            _ tableView: UITableView,
            commit editingStyle: UITableViewCell.EditingStyle,
            forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            guard let actionItemCell = tableView.cellForRow(at: indexPath) as? ActionItemTableViewCell else {
                print("Tried deleting a cell that shouldn't be deleted")
                return
            }
            let actionItem = actionItemCell.actionItem!
            actionItemsService.itemPubSub.publishOutgoing(actionItem, outgoingType: .delete)
            MSAnalytics.trackEvent("delete action item", withProperties: ["Team": URLManager.currentTeam])
            print("Deleting Action Item with id: \(actionItem.id)")
        }
    }
}
