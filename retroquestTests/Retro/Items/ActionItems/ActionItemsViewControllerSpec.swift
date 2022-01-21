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

class ActionItemsViewControllerSpec: QuickSpec {

    override func spec() {
        var rootVc: UIViewController!
        var navController: UINavigationController!

        var subject: ActionItemsViewController!
        var actionItemsService: FakeActionItemsService!
        var actionItemPubSub: PubSub<ActionItem>!
        var initialActionItems: [ActionItem]!

        beforeEach {
            rootVc = UIViewController()

            actionItemPubSub = PubSub<ActionItem>()
            actionItemsService = FakeActionItemsService(itemPubSub: actionItemPubSub)

            subject = ActionItemsViewController(actionItemsService: actionItemsService)
            initialActionItems = subject.actionItemsService.items
            subject.view.layoutSubviews()

            navController = UINavigationController()
            navController.viewControllers = [rootVc, subject]
            navController.view.layoutSubviews()

            UIWindow.key?.rootViewController = navController
        }

        describe("when the view loads") {
            it("should get action items from actionItemsService") {
                expect(actionItemsService.getItemsCalled).to(beTrue())
            }

            it("should register a ws callback for actionItems") {
                expect(actionItemsService.itemPubSub.incomingSubscribers.count > 0).toEventually(beTrue())
            }

            it("should have all cells editable") {
                let numActionItems = initialActionItems.count
                for row in 0...numActionItems {
                    let indexPath = IndexPath(row: row, section: 0)
                    expect(subject.tableView(subject.tableView, canEditRowAt: indexPath)).to(beTrue())
                }
            }

            it("should have sorted action items") {
                expect(actionItemsService.sortActionItemsCalled).to(beTrue())
            }

            describe("Updates") {
                context("when an update to an existing action item comes in") {
                    it("should show the updated information") {
                        let firstIndex = IndexPath(row: 0, section: 0)
                        expect(subject.tableView.cellForRow(at: firstIndex))
                                .toEventually(beAKindOf(ActionItemTableViewCell.self))

                        guard let firstActionItem = subject.tableView.cellForRow(at: firstIndex)
                                as? ActionItemTableViewCell else {
                            assert(false)
                        }
                        expect(firstActionItem.taskLabel.text).to(contain(initialActionItems[0].task))

                        let updatedActionItem = ActionItem(
                                id: 0,
                                task: "task5000",
                                completed: false,
                                teamId: "1",
                                assignee: "jim",
                                dateCreated: "2018-01-05"
                        )
                        subject.actionItemsService.publishItem(items: [updatedActionItem])

                        guard let firstActionItemUpdated = subject.tableView.cellForRow(at: firstIndex)
                                as? ActionItemTableViewCell else {
                            assert(false)
                        }
                        expect(firstActionItemUpdated.taskLabel.text).to(contain(updatedActionItem.task))
                    }
                }

                context("deleting action items") {
                    it("should remove the action item from the screen") {
                        let firstIndex = IndexPath(row: 0, section: 0)
                        expect(subject.tableView.cellForRow(at: firstIndex))
                                .toEventually(beAKindOf(ActionItemTableViewCell.self))
                        let originalNumberOfShownRows = subject.tableView.numberOfRows(inSection: 0)

                        let deletionActionItem = ActionItem(id: 0, teamId: "1", deletion: true)
                        subject.actionItemsService.publishItem(items: [deletionActionItem])

                        expect(subject.tableView.numberOfRows(inSection: 0))
                                .toEventually(equal(originalNumberOfShownRows - 1))
                    }
                }
            }

            describe("mutations") {
                context("deleting action items") {
                    it("should send a message to delete the action item") {
                        waitUntil { done in
                            subject.actionItemsService.itemPubSub.addOutgoingSubscriber { _, outgoingType in
                                expect(outgoingType).to(equal(OutgoingType.delete))
                                done()
                            }
                            subject.tableView(
                                    subject.tableView,
                                    commit: .delete,
                                    forRowAt: IndexPath(row: 0, section: 0)
                            )
                        }
                    }
                }
            }

            describe("adding new action items") {
                context("Trying to add and then canceling") {
                    it("should pull up and hide the NewItemViewController") {
                        expect(subject.presentedViewController).to(beNil())

                        let actionItemsView = subject.actionItemsView
                        actionItemsView.addActionItemButton.sendActions(for: .touchUpInside)

                        let rootViewController = UIWindow.key!.rootViewController!
                        expect(rootViewController.presentedViewController)
                                .toEventually(beAKindOf(NewItemViewController<ActionItem>.self))
                        guard let newItemViewController = rootViewController.presentedViewController
                                as? NewItemViewController<ActionItem> else {
                            assert(false)
                        }
                        let newItemView = newItemViewController.newItemView!
                        newItemView.cancelButton.sendActions(for: .touchUpInside)

                        expect(subject.presentedViewController).toEventually(beNil(), timeout: .seconds(5))
                    }
                }
            }

            context("when the action items request succeeds") {
                it("displays the list of action items") {
                    expect(subject.tableView.numberOfRows(inSection: 0)).to(equal(initialActionItems.count))

                    let firstIndex = IndexPath(row: 0, section: 0)
                    expect(subject.tableView.cellForRow(at: firstIndex))
                            .toEventually(beAKindOf(ActionItemTableViewCell.self))
                    let firstCell = subject.tableView.cellForRow(at: firstIndex) as? ActionItemTableViewCell
                    expect(firstCell!.taskLabel.text).to(equal("task1"))
                    expect(firstCell!.assigneeLabel.text).to(contain("jim"))
                    expect(firstCell!.creationDateLabel.text).to(contain("2018-01-05"))

                    let secondIndex = IndexPath(row: 1, section: 0)
                    expect(subject.tableView.cellForRow(at: secondIndex))
                            .toEventually(beAKindOf(ActionItemTableViewCell.self))
                    let secondCell = subject.tableView.cellForRow(at: secondIndex) as? ActionItemTableViewCell
                    expect(secondCell!.taskLabel.text).to(equal("task3"))
                    expect(secondCell!.assigneeLabel.text).to(contain("Unassigned"))
                    expect(secondCell!.creationDateLabel.text).to(equal("created\n"))

                    let thirdIndex = IndexPath(row: 2, section: 0)
                    expect(subject.tableView.cellForRow(at: thirdIndex))
                            .toEventually(beAKindOf(ActionItemTableViewCell.self))
                    let thirdCell = subject.tableView.cellForRow(at: thirdIndex) as? ActionItemTableViewCell
                    expect(thirdCell!.taskLabel.text).to(equal("task2"))
                    expect(thirdCell!.assigneeLabel.text).to(contain("bob"))
                    expect(thirdCell!.creationDateLabel.text).to(contain("2018-01-06"))
                }

                it("displays discussed items more transparent than not discussed items") {
                    var actionItemIndex = 0
                    while actionItemIndex < subject.actionItemsService.items.count {
                        let currentIndex = IndexPath(row: actionItemIndex, section: 0)
                        expect(subject.tableView.cellForRow(at: currentIndex))
                                .toEventually(beAKindOf(ActionItemTableViewCell.self))

                        guard let currentCell = subject.tableView.cellForRow(at: currentIndex)
                                as? ActionItemTableViewCell else {
                            assert(false)
                        }
                        let backgroundColorAlpha = currentCell.backgroundColor!.cgColor.alpha

                        if subject.actionItemsService.items[actionItemIndex].completed {
                            expect(backgroundColorAlpha).toEventually(beLessThan(1))
                        } else {
                            expect(backgroundColorAlpha).toEventually(equal(1))
                        }

                        actionItemIndex += 1
                    }
                }
            }
        }
    }
}
