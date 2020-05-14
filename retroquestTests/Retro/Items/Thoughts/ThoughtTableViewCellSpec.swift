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

class ThoughtTableViewCellSpec: QuickSpec {

    override func spec() {
        Nimble.AsyncDefaults.Timeout = 3
        Nimble.AsyncDefaults.PollInterval = 0.1
        
        var navController: UINavigationController!
        var subject: ThoughtTableViewCell!
        var thoughtsService: FakeThoughtsService!

        var thoughtsViewController: ThoughtsViewController!

        let sampleThought = Thought(
                id: 3,
                message: "gur",
                hearts: 2,
                topic: ColumnName.happy.rawValue,
                discussed: false,
                teamId: "team"
        )

        beforeEach {
            thoughtsService = FakeThoughtsService(itemPubSub: PubSub<Thought>())
            thoughtsViewController = ThoughtsViewController(
                    thoughtsService: thoughtsService,
                    columnNameService: FakeColumnNameService(itemPubSub: PubSub<Column>())
            )

            subject = ThoughtTableViewCell()

            subject.setupCell(thought: sampleThought, delegate: thoughtsViewController)

            navController = UINavigationController(rootViewController: thoughtsViewController)
            navController.view.layoutSubviews()
            UIApplication.shared.keyWindow?.rootViewController = navController
        }

        describe("tapping on a cell") {
            beforeEach {
                thoughtsService.itemPubSub.clearAllSubscribers()
            }

            context("starring a thought") {
                it("should send an outgoing message when touching the starsLabel") {
                    waitUntil { done in
                        thoughtsService.itemPubSub.addOutgoingSubscriber { item, _ in
                            expect(item!.hearts).to(equal(sampleThought.hearts + 1))
                            done()
                        }
                        subject.starsTapped(sender: nil)
                    }
                }
            }

            context("toggling discussed for a thought") {
                it("should submit send an outgoing message when touching the markDiscussedLabel") {
                    waitUntil { done in
                        thoughtsService.itemPubSub.addOutgoingSubscriber { item, _ in
                            expect(item!.discussed).to(equal(!sampleThought.discussed))
                            done()
                        }
                        subject.markDiscussedTapped(sender: nil)
                    }
                }
            }

            context("updating a thought's text") {
                it("should submit send an outgoing message when touching the thought message and updating it") {
                    let updatedMessage = "herp"
                    var published = false

                    thoughtsService.itemPubSub.addOutgoingSubscriber { item, _ in
                        published = true
                        expect(item!.message).to(equal(updatedMessage))
                    }

                    subject.modifyMessageTapped(sender: nil)

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(EditItemViewController.self))
                    guard let editController = rootViewController.presentedViewController
                            as? EditItemViewController else {
                        assert(false)
                    }
                    let editTextView: EditTextView! = editController.editTextView
                    expect(editTextView.validatingTextField.itemTextField.text).to(equal(sampleThought.message))
                    editTextView.validatingTextField.itemTextField.text = updatedMessage
                    editTextView.saveButton.tap()

                    expect(published).to(beTrue())
                }
            }
        }
    }
}
