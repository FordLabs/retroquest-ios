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

import Quick
import Nimble
import UIKit

@testable import retroquest

class ActionItemTableViewCellSpec: QuickSpec {

    override func spec() {
        Nimble.AsyncDefaults.timeout = .seconds(3)
        Nimble.AsyncDefaults.pollInterval = .milliseconds(100)
        
        var navController: UINavigationController!
        var subject: ActionItemTableViewCell!
        var actionItemsService: FakeActionItemsService!

        let sampleActionItem = ActionItem(
                id: 4,
                task: "thaThing",
                completed: false,
                teamId: "team",
                assignee: nil,
                dateCreated: ""
        )

        beforeEach {
            actionItemsService = FakeActionItemsService(itemPubSub: PubSub<ActionItem>())
            let actionItemsVC = ActionItemsViewController(actionItemsService: actionItemsService)

            subject = ActionItemTableViewCell()
            subject.setupCell(actionItem: sampleActionItem, delegate: actionItemsVC)

            navController = UINavigationController(rootViewController: actionItemsVC)
            navController.view.layoutSubviews()
            UIApplication.shared.keyWindow?.rootViewController = navController
        }

        describe("tapping on a cell") {

            beforeEach {
                actionItemsService.itemPubSub.clearAllSubscribers()
            }

            context("toggling completed for an action item") {
                it("should send an outgoing message when touching the markCompletedLabel") {
                    waitUntil { done in
                        actionItemsService.itemPubSub.addOutgoingSubscriber { item, _ in
                            expect(item!.completed).to(equal(!sampleActionItem.completed))
                            done()
                        }
                        subject.markCompletedTapped(sender: nil)
                    }
                }
            }

            context("updating an action item's task") {
                it("should submit send an outgoing message when touching the task label and update it") {
                    let updatedTask = "herp"
                    var published = false

                    actionItemsService.itemPubSub.addOutgoingSubscriber { item, _ in
                        published = true
                        expect(item!.task).to(equal(updatedTask))
                    }

                    subject.modifyTaskTapped(sender: nil)

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(EditItemViewController.self))
                    guard let editController = rootViewController.presentedViewController
                            as? EditItemViewController else {
                        assert(false)
                    }

                    expect(editController.editTextView.getText()).to(equal(sampleActionItem.task))
                    editController.editTextView.validatingTextField.itemTextField.text = updatedTask
                    editController.editTextView.saveButton.tap()
                    expect(published).to(beTrue())
                }
            }

            context("updating an action item's assignee") {
                it("should submit send an outgoing message when touching the assignee label and update it") {
                    let updatedAssignee = "herp"
                    var published = false

                    actionItemsService.itemPubSub.addOutgoingSubscriber { item, _ in
                        published = true
                        expect(item!.assignee).to(equal(updatedAssignee))
                    }
                    subject.assigneeTapped(sender: nil)

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(EditItemViewController.self))
                    guard let editController = rootViewController.presentedViewController
                            as? EditItemViewController else {
                        assert(false)
                    }
                    expect(editController.editTextView.getText()).to(equal(""))
                    editController.editTextView.validatingTextField.itemTextField.text = updatedAssignee
                    editController.editTextView.saveButton.tap()
                    expect(published).to(beTrue())
                }
            }
        }
    }
}
