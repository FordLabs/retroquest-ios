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

@testable import retroquest

class ThoughtsViewControllerSpec: QuickSpec {

    override func spec() {
        let currentTeam = "whoopie"

        var rootVc: UIViewController!
        var navController: UINavigationController!

        var subject: ThoughtsViewController!
        var thoughtsService: FakeThoughtsService!
        var columnNameService: FakeColumnNameService!

        var initialThoughts: [Thought]!

        beforeEach {
            rootVc = UIViewController()
            URLManager.setCurrentTeam(team: currentTeam)

            thoughtsService = FakeThoughtsService(itemPubSub: PubSub<Thought>())
            columnNameService = FakeColumnNameService(itemPubSub: PubSub<Column>())

            subject = ThoughtsViewController(
                    thoughtsService: thoughtsService,
                    columnNameService: columnNameService
            )
            initialThoughts = subject.thoughtsService.items
            subject.view.layoutSubviews()

            navController = UINavigationController()
            navController.viewControllers = [rootVc, subject]
            navController.view.layoutSubviews()

            UIApplication.shared.keyWindow?.rootViewController = navController
        }

        describe("when the view loads") {
            it("should show the name of the table in the header") {
                let headingText = subject.thoughtsView.headingLabel.text
                expect(headingText).to(equal(currentTeam))
            }

            it("should get thoughts from thoughtService") {
                expect(thoughtsService.getItemsCalled).to(beTrue())
            }

            it("should register a ws callback for thoughts") {
                expect(thoughtsService.itemPubSub.incomingSubscribers.count > 0).toEventually(beTrue())
            }

            it("should register a ws callback for column names") {
                expect(columnNameService.itemPubSub.incomingSubscribers.count > 0).toEventually(beTrue())
            }

            it("should have sorted thoughts") {
                expect(thoughtsService.sortThoughtsCalled).to(beTrue())
            }

            it("should have happy expandable cell in green") {
                let happyExpandingCell = getHeaderView(forSection: 0)
                expect(happyExpandingCell.topicLabel.textColor).to(equal(RetroColors.happyColor))
            }

            it("should show number of happy thoughts on expandable cell") {
                let happyExpandingCell = getHeaderView(forSection: 0)
                expect(happyExpandingCell.topicLabel.text).to(contain("3 items"))
            }
        }

        describe("displaying thoughts") {
            context("when the thoughts request succeeds") {
                it("displays the headers in collapsed form with the correct name from columnNameService") {
                    expect(subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: 0)).to(equal(0))
                    expect(subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: 1)).to(equal(0))
                    expect(subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: 2)).to(equal(0))

                    let happyExpandingCell = getHeaderView(forSection: 0)
                    expect(happyExpandingCell.topicLabel.text).toEventually(contain("kindaHappy"))

                    let confusedExpandingCell = getHeaderView(forSection: 1)
                    expect(confusedExpandingCell.topicLabel.text).toEventually(contain("kindaConfused"))

                    let sadExpandingCell = getHeaderView(forSection: 2)
                    expect(sadExpandingCell.topicLabel.text).toEventually(contain("kindaSad"))
                }

                it("displays happy thoughts under the happy expandable cell") {
                    let happyCells = getThoughtCellsForExpandedRow(section: 0)

                    let numHappyThoughts = subject.thoughtsService.getThoughtsOfTopic(ColumnName.happy).count
                    expect(happyCells.count).to(equal(numHappyThoughts))

                    for cell in happyCells {
                        let thought = subject.thoughtsService.getThoughtById(cell.thought.id)
                        expect(thought!.topic).to(equal(ColumnName.happy.rawValue))
                    }
                }

                it("displays confused thoughts under the confused expandable cell") {
                    let confusedCells = getThoughtCellsForExpandedRow(section: 1)

                    let numConfusedThoughts = subject.thoughtsService.getThoughtsOfTopic(ColumnName.confused).count
                    expect(confusedCells.count).to(equal(numConfusedThoughts))

                    for cell in confusedCells {
                        let thought = subject.thoughtsService.getThoughtById(cell.thought.id)
                        expect(thought!.topic).to(equal(ColumnName.confused.rawValue))
                    }
                }

                it("displays sad thoughts under the sad expandable cell") {
                    let sadCells = getThoughtCellsForExpandedRow(section: 2)

                    let numSadThoughts = subject.thoughtsService.getThoughtsOfTopic(ColumnName.sad).count
                    expect(sadCells.count).to(equal(numSadThoughts))

                    for cell in sadCells {
                        let thought = subject.thoughtsService.getThoughtById(cell.thought.id)
                        expect(thought!.topic).to(equal(ColumnName.sad.rawValue))
                    }
                }

                it("displays discussed items more transparent than not discussed items") {
                    let happyCells = getThoughtCellsForExpandedRow(section: 0)

                    for cell in happyCells {
                        let backgroundColorAlpha = cell.backgroundColor!.cgColor.alpha
                        let expectedThought = subject.thoughtsService.getThoughtById(cell.thought.id)

                        if expectedThought!.discussed {
                            expect(backgroundColorAlpha).to(beLessThan(1))
                        } else {
                            expect(backgroundColorAlpha).to(equal(1))
                        }
                    }
                }
            }
        }

        describe("expanding expandable cells") {
            context("tapping expandable cell") {
                it("should change direction of chevron") {
                    let sadIndex = 2
                    let sadHeader: ThoughtTableViewHeaderView = getHeaderView(forSection: sadIndex)
                    let arrowLabel: UIKit.UILabel = sadHeader.arrowLabel
                    expect(arrowLabel.attributedText?.string).to(equal(String.fontAwesomeIcon(name: .chevronRight)))

                    guard let gestureRecognizer = sadHeader.gestureRecognizers![0] as? UITapGestureRecognizer else {
                        assert(false)
                    }
                    gestureRecognizer.state = UIGestureRecognizer.State.began
                    sadHeader.tapHeader(gestureRecognizer)

                    expect(arrowLabel.attributedText?.string).to(equal(String.fontAwesomeIcon(name: .chevronDown)))

                    sadHeader.tapHeader(gestureRecognizer)

                    expect(arrowLabel.attributedText?.string).to(equal(String.fontAwesomeIcon(name: .chevronRight)))
                }
            }
        }

        describe("making changes to thoughts") {
            context("when an update to an existing thought comes in") {
                it("should show the updated information") {
                    let firstHappyThoughtRow = getTableCell(forIndex: IndexPath(row: 0, section: 0))
                    expect(firstHappyThoughtRow.messageLabel.text).to(contain(initialThoughts[0].message))

                    let updatedThought = Thought(
                            id: 0,
                            message: "newmessage1",
                            hearts: 2,
                            topic: ColumnName.happy.rawValue,
                            discussed: false,
                            teamId: "1"
                    )
                    subject.thoughtsService.publishItem(items: [updatedThought])

                    let firstHappyThoughtRowUpdated = getTableCell(forIndex: IndexPath(row: 0, section: 0))
                    expect(firstHappyThoughtRowUpdated.messageLabel.text).to(contain(updatedThought.message))
                }
            }

            context("adding thoughts") {
                it("should pull up the NewItemViewController on tapping add button and hide it when cancelled") {
                    expect(subject.presentedViewController).to(beNil())

                    subject.thoughtsView.addThoughtButton.tap()

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(NewItemViewController<Thought>.self))
                    guard let newItemViewController = rootViewController.presentedViewController
                            as? NewItemViewController<Thought> else {
                        assert(false)
                    }
                    let newItemView = newItemViewController.newItemView!
                    newItemView.cancelButton.tap()

                    expect(subject.presentedViewController).toEventually(beNil(), timeout: 5)
                }

                it("should show a new happy thought") {
                    let happySection = 0
                    expectNewThoughtAppears(topicSection: happySection)
                }

                it("should update the number of thoughts shown on the expandable header view") {
                    let originalNumHappyThoughts = subject.thoughtsService.getThoughtsOfTopic(ColumnName.happy).count

                    let happyExpandingCell = getHeaderView(forSection: 0)
                    expect(happyExpandingCell.topicLabel.text).to(contain("\(originalNumHappyThoughts) items"))

                    let newThought = Thought(
                            id: 1001,
                            message: "message1001",
                            hearts: 0,
                            topic: ColumnName.happy.rawValue,
                            discussed: false,
                            teamId: "1"
                    )
                    subject.thoughtsService.publishItem(items: [newThought])
                    let happyExpandingCellUpdatedText = getHeaderView(forSection: 0).topicLabel.text
                    let expectedItemCount = "\(originalNumHappyThoughts + 1) items"
                    expect(happyExpandingCellUpdatedText).toEventually(contain(expectedItemCount), timeout: 10)
                }

                it("should show a new confused thought") {
                    let confusedSection = 1
                    expectNewThoughtAppears(topicSection: confusedSection)
                }

                it("should show a new sad thought") {
                    let sadSection = 2
                    expectNewThoughtAppears(topicSection: sadSection)
                }
            }

            context("deleting thoughts") {
                it("should send a message to delete the thought") {
                    let happySection = 0
                    waitUntilRowIsExpanded(section: happySection)

                    waitUntil { done in
                        subject.thoughtsService.itemPubSub.addOutgoingSubscriber { _, outgoingType in
                            expect(outgoingType).to(equal(OutgoingType.delete))
                            done()
                        }
                        subject.tableView(
                                subject.thoughtsView.tableView,
                                commit: .delete,
                                forRowAt: IndexPath(row: 1, section: happySection)
                        )
                    }
                }

                it("should remove the thought from the screen") {
                    let happySection = 0
                    waitUntilRowIsExpanded(section: happySection)

                    let originalNumberOfShownRows = subject.tableView(
                            subject.thoughtsView.tableView,
                            numberOfRowsInSection: happySection
                    )

                    let deletionThought = [Thought(id: 0, teamId: "1", deletion: true)]
                    subject.thoughtsService.publishItem(items: deletionThought)

                    expect(subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: happySection))
                            .toEventually(equal(originalNumberOfShownRows - 1))
                }
            }

            context("changing column title names") {
                it("should send a message to change the sad column name") {
                    let newSadTopicName = "More Sad"
                    let sadIndex = 2
                    let topicExpandingIndex = IndexPath(row: 0, section: sadIndex)
                    let sadHeader = getHeaderView(forSection: sadIndex)
                    var outgoingPublished = false

                    subject.columnNameService.itemPubSub.addOutgoingSubscriber { item, outgoingType in
                        outgoingPublished = true
                        expect(outgoingType).to(equal(OutgoingType.edit))
                        guard let item = item else {
                            assert(false)
                        }
                        expect(item.topic).to(equal(ColumnNameService.displayOrderForTopics[sadIndex].rawValue))
                        let expectedIdOfSadColumnTopic = columnNameService.items[sadIndex].id
                        expect(item.id).to(equal(expectedIdOfSadColumnTopic))
                        expect(item.title).to(equal(newSadTopicName))
                    }
                    guard let gestureRecognizer = sadHeader.gestureRecognizers![1]
                            as? UILongPressGestureRecognizer else {
                        assert(false)
                    }
                    gestureRecognizer.state = UIGestureRecognizer.State.began

                    subject.longPressHandler(longPressGestureRecognizer: gestureRecognizer)

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(EditItemViewController.self))
                    guard let editItemVC = rootViewController.presentedViewController as? EditItemViewController else {
                        assert(false)
                    }
                    let editTextView = editItemVC.editTextView!
                    editTextView.validatingTextField.itemTextField.text = newSadTopicName
                    editTextView.saveButton.tap()
                    expect(outgoingPublished).to(beTrue())
                }
            }
        }

        func getHeaderView(forSection: Int) -> ThoughtTableViewHeaderView {
            guard let view = subject.tableView(subject.thoughtsView.tableView, viewForHeaderInSection: forSection)
                    as? ThoughtTableViewHeaderView else {
                assert(false)
            }
            return view
        }

        func getTableCell(forIndex: IndexPath) -> ThoughtTableViewCell {
            guard let cell = subject.tableView(subject.thoughtsView.tableView, cellForRowAt: forIndex)
                    as? ThoughtTableViewCell else {
                assert(false)
            }
            return cell
        }

        func waitUntilRowIsExpanded(section: Int) {
            expect(subject.tableView(subject.thoughtsView.tableView, viewForHeaderInSection: section))
                    .toEventually(beAKindOf(ThoughtTableViewHeaderView.self))

            guard let headerView = subject.tableView(subject.thoughtsView.tableView, viewForHeaderInSection: section)
                    as? ThoughtTableViewHeaderView else {
                assert(false)
            }
            guard let gesture = headerView.gestureRecognizers![0] as? UITapGestureRecognizer else {
                assert(false)
            }
            headerView.tapHeader(gesture)

            let topicCell = IndexPath(row: 0, section: section)
            expect(subject.tableView(subject.thoughtsView.tableView, cellForRowAt: topicCell)).toNotEventually(beNil())
        }

        func expectNewThoughtAppears(topicSection: Int) {
            waitUntilRowIsExpanded(section: topicSection)
            let originalNumberOfShownRows = subject.tableView(
                    subject.thoughtsView.tableView,
                    numberOfRowsInSection: topicSection
            )

            let newThought = Thought(
                    id: 1000,
                    message: "message1000",
                    hearts: 0,
                    topic: ColumnNameService.displayOrderForTopics[topicSection].rawValue,
                    discussed: false,
                    teamId: "1"
            )
            subject.thoughtsService.publishItem(items: [newThought])

            expect(subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: topicSection))
                    .toEventually(equal(originalNumberOfShownRows + 1))
        }

        func getThoughtCellsForExpandedRow(section: Int) -> [ThoughtTableViewCell] {
            waitUntilRowIsExpanded(section: section)

            let numberRowsInSection = subject.tableView(subject.thoughtsView.tableView, numberOfRowsInSection: section)
            let range = 0..<numberRowsInSection

            let thoughtCells = range.map {
                subject.tableView(
                        subject.thoughtsView.tableView,
                        cellForRowAt: IndexPath(row: $0, section: section)
                ) as? ThoughtTableViewCell
            }

            return thoughtCells.compactMap {
                $0
            }
        }
    }
}
