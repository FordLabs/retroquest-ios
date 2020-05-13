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

class NewItemViewControllerSpec: QuickSpec {

    override func spec() {
        Nimble.AsyncDefaults.Timeout = 3
        
        let columnNameService = FakeColumnNameService(itemPubSub: PubSub<Column>())
        let thoughtSubject = NewItemViewController<Thought>(
                pubSub: PubSub<Thought>(),
                columnNameService: columnNameService
        )
        let actionItemSubject = NewItemViewController<ActionItem>(pubSub: PubSub<ActionItem>())

        specThoughts(thoughtSubject)
        specActionItems(actionItemSubject)
    }

    func specThoughts<T: Item>(_ subject: NewItemViewController<T>) {
        var rootVc: UIViewController!
        var navController: UINavigationController!

        beforeEach {
            self.setupViewController(subject: subject, rootVc: &rootVc, navController: &navController)
        }

        describe("adding a thought") {
            beforeEach {
                self.ensureTableHasLoaded(subject: subject)
                self.resetTableCheckmarks(subject: subject)
            }

            context("when viewing the add thought modal") {
                it("should have a header with thought text") {
                    let expectedTitle = "Add new thought"
                    expect(subject.newItemView.headingLabel.text).to(equal(expectedTitle))
                }

                it("should have a textfield with placeholder text") {
                    let expectedPlaceholder = "Enter thought"
                    let placeholder: String? = subject.newItemView.validatingTextField.itemTextField.placeholder
                    expect(placeholder).to(equal(expectedPlaceholder))
                }

                it("should show the three thought topics") {
                    for (row, topicName) in ColumnNameService.displayOrderForTopics.enumerated() {
                        guard let topicCell = subject.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                                as? NewItemCell else {
                            assert(false)
                        }
                        let columnName = subject.columnNameService!.getColumnName(topicName.rawValue)
                        let topicTitle = subject.columnNameService!.getColumnTitle(columnName)
                        expect(topicCell.topicLabel.text).to(equal(topicTitle))
                    }
                }

                context("clicking on a topic row") {
                    it("all rows should initially have no checkmark") {
                        let numRows = subject.tableView.numberOfRows(inSection: 0)
                        for row in 0...(numRows - 1) {
                            guard let topicCell = subject.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                                    as? NewItemCell else {
                                assert(false)
                            }
                            expect(topicCell.accessoryType).to(equal(UITableViewCell.AccessoryType.none))
                        }
                    }

                    it("should apply a checkmark to a row when it is tapped") {
                        let indexPath = IndexPath(row: 0, section: 0)
                        self.selectRow(subject: subject, indexPath: indexPath)

                        guard let happyTopicCell = subject.tableView.cellForRow(at: indexPath) as? NewItemCell else {
                            assert(false)
                        }
                        expect(happyTopicCell.accessoryType).to(equal(UITableViewCell.AccessoryType.checkmark))
                    }

                    it("should apply a checkmark to a row when it is tapped and uncheck previously tapped row") {
                        let happyRow = 0
                        let indexPath = IndexPath(row: happyRow, section: 0)
                        self.selectRow(subject: subject, indexPath: indexPath)

                        var selectedRow = subject.getSelectedRowIndex()
                        expect(selectedRow).to(equal(happyRow))

                        let confusedRow = 1
                        let indexPath2 = IndexPath(row: confusedRow, section: 0)
                        self.selectRow(subject: subject, indexPath: indexPath2)
                        self.deselectRow(subject: subject, indexPath: indexPath)

                        selectedRow = subject.getSelectedRowIndex()
                        expect(selectedRow).to(equal(confusedRow))
                    }
                }
            }

            context("when clicking the save button") {
                beforeEach {
                    // reset error view state- in normal operation this happens on text change in the text field,
                    // but the event isn't fired when we manually change the text from the unit tests.
                    subject.newItemView.validatingTextField.errorMessageView.isHidden = true
                }

                it("should show an error if the text is too large") {
                    subject.newItemView.validatingTextField.itemTextField.text = "88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999988777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777"

                    let sadPath = IndexPath(row: 2, section: 0)
                    self.selectRow(subject: subject, indexPath: sadPath)

                    subject.save()

                    expect(subject.newItemView.validatingTextField.errorMessageView.isHidden).to(beFalse())
                    let errorText = subject.newItemView.validatingTextField.errorMessageLabel.text
                    expect(errorText).to(equal("Text must be less than 255 characters."))
                }

                it("should show an error if the text is empty") {
                    subject.newItemView.validatingTextField.itemTextField.text = ""

                    let sadPath = IndexPath(row: 2, section: 0)
                    self.selectRow(subject: subject, indexPath: sadPath)

                    subject.save()

                    expect(subject.newItemView.validatingTextField.errorMessageView.isHidden).to(beFalse())
                    let errorText = subject.newItemView.validatingTextField.errorMessageLabel.text
                    expect(errorText).to(equal("Text cannot be empty."))
                }

                it("should show an error if no topic is selected") {
                    subject.newItemView.validatingTextField.itemTextField.text = "Is there another word for Synonym?"

                    subject.save()

                    expect(subject.newItemView.validatingTextField.errorMessageView.isHidden).to(beFalse())
                    let errorText = subject.newItemView.validatingTextField.errorMessageLabel.text
                    expect(errorText).to(equal("A topic must be selected."))
                }

                it("should send an outgoing message") {
                    let messageText = "If the number 666 is considered EVIL, Is 25.8069 the root of all evil?"
                    let sampleThought = Thought(
                            id: -1,
                            message: messageText,
                            hearts: 0,
                            topic: ColumnName.sad.rawValue,
                            discussed: false,
                            teamId: URLManager.currentTeam
                    )

                    waitUntil { done in
                        subject.pubSub.addOutgoingSubscriber { item, _ in
                            expect(item as? Thought).to(equal(sampleThought))
                            done()
                        }
                        subject.newItemView.validatingTextField.itemTextField.text = messageText

                        let sadPath = IndexPath(row: 2, section: 0)
                        self.selectRow(subject: subject, indexPath: sadPath)

                        subject.save()
                    }
                }
            }
        }
    }

    func specActionItems<T: Item>(_ subject: NewItemViewController<T>) {
        describe("adding a new action item") {

            beforeEach {
                subject.pubSub.clearOutgoingSubscribers()
            }
            context("when viewing the add action item modal") {
                it("should have a header with action item text") {
                    let expectedTitle = "Add new action item"
                    expect(subject.newItemView.headingLabel.text).to(equal(expectedTitle))
                }

                it("should have a textfield with placeholder text") {
                    let expectedPlaceholder = "Enter action item"
                    let actualPlaceholder = subject.newItemView.validatingTextField.itemTextField.placeholder
                    expect(actualPlaceholder).to(equal(expectedPlaceholder))
                }

                it("should not show a table view of topics") {
                    let views = subject.newItemView.subviews
                    let viewsThatAreTables: [UIView] = views.filter { view in
                        view is UITableView
                    }
                    expect(viewsThatAreTables.count).to(equal(0))
                }
            }

            context("when clicking the save button") {
                it("should show an error if the text is too large") {
                    subject.newItemView.validatingTextField.itemTextField.text = "88888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888888999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999988777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777777"

                    subject.save()

                    expect(subject.newItemView.validatingTextField.errorMessageView.isHidden).to(beFalse())
                    let expectedText = "Text must be less than 255 characters."
                    expect(subject.newItemView.validatingTextField.errorMessageLabel.text).to(equal(expectedText))
                }

                it("should show an error if the text is empty") {
                    subject.newItemView.validatingTextField.itemTextField.text = ""

                    subject.save()

                    expect(subject.newItemView.validatingTextField.errorMessageView.isHidden).to(beFalse())
                    let expectedText = "Text cannot be empty."
                    expect(subject.newItemView.validatingTextField.errorMessageLabel.text).to(equal(expectedText))
                }

                it("should send an outgoing message with no assignee") {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                    let messageText = "Is a paper cut a tree’s last revenge?"

                    waitUntil { done in
                        subject.pubSub.addOutgoingSubscriber { item, _ in
                            guard let actualActionItem = item as? ActionItem else {
                                assert(false)
                            }
                            expect(actualActionItem.assignee).to(beNil())
                            done()
                        }
                        subject.newItemView.validatingTextField.itemTextField.text = messageText

                        subject.save()
                    }
                }

                describe("providing assignee") {
                    it("should send an outgoing message with an assignee specified at end") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let messageText = "Is a paper cut a tree’s last revenge?"
                        let sampleActionItem = ActionItem(
                            id: -1,
                            task: messageText,
                            completed: false,
                            teamId: URLManager.currentTeam,
                            assignee: "bob",
                            dateCreated: dateFormatter.string(from: Date())
                        )

                        waitUntil { done in
                            subject.pubSub.addOutgoingSubscriber { item, _ in
                                guard let actualActionItem = item as? ActionItem else {
                                    assert(false)
                                }
                                expect(actualActionItem.assignee).to(equal(sampleActionItem.assignee))
                                done()
                            }
                            subject.newItemView.validatingTextField.itemTextField.text = "\(messageText)@bob"

                            subject.save()
                        }
                    }

                    it("should send an outgoing message with an assignee specified in the middle") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let sampleActionItem = ActionItem(
                            id: -1,
                            task: "Is a paper cut a tree’s last revenge?",
                            completed: false,
                            teamId: URLManager.currentTeam,
                            assignee: "bob",
                            dateCreated: dateFormatter.string(from: Date())
                        )

                        waitUntil { done in
                            subject.pubSub.addOutgoingSubscriber { item, _ in
                                guard let actualActionItem = item as? ActionItem else {
                                    assert(false)
                                }
                                expect(actualActionItem.assignee).to(equal(sampleActionItem.assignee))
                                done()
                            }
                            let assignedText = "Is a paper cut a @bob tree’s last revenge?"
                            subject.newItemView.validatingTextField.itemTextField.text = assignedText

                            subject.save()
                        }
                    }

                    it("should send an outgoing message with an assignee specified at the beginning") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        let messageText = "Is a paper cut a tree’s last revenge?@bob"
                        let sampleActionItem = ActionItem(
                            id: -1,
                            task: messageText,
                            completed: false,
                            teamId: URLManager.currentTeam,
                            assignee: "bob",
                            dateCreated: dateFormatter.string(from: Date())
                        )

                        waitUntil { done in
                            subject.pubSub.addOutgoingSubscriber { item, _ in
                                guard let actualActionItem = item as? ActionItem else {
                                    assert(false)
                                }
                                expect(actualActionItem.assignee).to(equal(sampleActionItem.assignee))
                                done()
                            }
                            subject.newItemView.validatingTextField.itemTextField.text = "@bob \(messageText)"

                            subject.save()
                        }
                    }

                }
            }
        }
    }

    private func setupViewController<T: Item>(
            subject: NewItemViewController<T>,
            rootVc: inout UIViewController!,
            navController: inout UINavigationController!
    ) {
        rootVc = UIViewController()

        subject.view.layoutSubviews()

        navController = UINavigationController()
        navController!.viewControllers = [rootVc!, subject]
        navController!.view.layoutSubviews()

        UIApplication.shared.keyWindow?.rootViewController = navController

        URLManager.currentTeam = "Team"
    }

    private func selectRow<T: Item>(subject: NewItemViewController<T>!, indexPath: IndexPath) {
        subject.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        subject.tableView.delegate?.tableView?(subject.tableView, didSelectRowAt: indexPath)
    }

    private func deselectRow<T: Item>(subject: NewItemViewController<T>!, indexPath: IndexPath) {
        subject.tableView.deselectRow(at: indexPath, animated: false)
        subject.tableView.delegate?.tableView?(subject.tableView, didDeselectRowAt: indexPath)
    }

    private func ensureTableHasLoaded<T: Item>(subject: NewItemViewController<T>!) {
        expect(subject.tableView.numberOfRows(inSection: 0)).toEventually(equal(3))
    }

    private func resetTableCheckmarks<T: Item>(subject: NewItemViewController<T>!) {
        let numRows = subject.tableView.numberOfRows(inSection: 0)
        for row in 0...(numRows - 1) {
            guard let topicCell = subject.tableView.cellForRow(at: IndexPath(row: row, section: 0))
                    as? NewItemCell else {
                assert(false)
            }
            topicCell.accessoryType = UITableViewCell.AccessoryType.none
        }
    }
}
