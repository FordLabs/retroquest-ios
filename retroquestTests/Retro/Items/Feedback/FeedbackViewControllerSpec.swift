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
import Hippolyte
import UIKit

@testable import retroquest

class FeedbackViewControllerSpec: QuickSpec {
    override func spec() {
        Nimble.AsyncDefaults.Timeout = 3
        Nimble.AsyncDefaults.PollInterval = 0.1
        
        let faVersion = "FontAwesome5Free-"
        var subject: FeedbackViewController!

        beforeEach {
            subject = FeedbackViewController()
            subject.view.layoutSubviews()

            let navController = UINavigationController()
            navController.viewControllers = [subject]
            navController.view.layoutSubviews()

            UIApplication.shared.keyWindow?.rootViewController = navController
        }

        describe("when the view loads") {
            beforeEach {
                subject.viewDidLoad()
            }

            it("should set the title text in the heading") {
                expect(subject.feedbackFormView.headingLabel.text).to(equal("Feedback"))
            }

            it("should show How can we improve? text") {
                expect(subject.feedbackFormView.improveLabel.text).to(equal("How can we improve RetroQuest?"))
            }

            context("Setting feedback stars") {
                it("should highlight 4 stars when clicking on 4th star") {
                    let starButtons = subject.feedbackFormView.stars!
                    expect(subject.feedbackStarsSelected).to(equal(0))
                    for starIndex in 0..<5 {
                        let star = starButtons[starIndex]
                        let fontStyleString = self.getFontStyleString(button: star)
                        expect(fontStyleString).to(contain("\(faVersion)Regular"))
                    }

                    let fourthStar = starButtons[3]
                    fourthStar.tap()

                    for starIndex in 0..<4 {
                        let star = starButtons[starIndex]
                        let fontStyleString = self.getFontStyleString(button: star)
                        expect(fontStyleString).to(contain("\(faVersion)Solid"))
                    }
                    let fifthStar = starButtons[4]
                    let fontStyleString = self.getFontStyleString(button: fifthStar)
                    expect(fontStyleString).to(contain("\(faVersion)Regular"))
                    expect(subject.feedbackStarsSelected).to(equal(4))
                }

                it("should highlight 1 star when clicking on 1st star after 4 are already solid") {
                    let starButtons = subject.feedbackFormView.stars!

                    let fourthStar = starButtons[3]
                    fourthStar.tap()
                    let firstStar = starButtons[0]
                    firstStar.tap()

                    let fontStyleString = self.getFontStyleString(button: firstStar)
                    expect(fontStyleString).to(contain("\(faVersion)Solid"))

                    for starIndex in 1..<5 {
                        let star = starButtons[starIndex]
                        let fontStyleString = self.getFontStyleString(button: star)
                        expect(fontStyleString).to(contain("\(faVersion)Regular"))
                    }
                    expect(subject.feedbackStarsSelected).to(equal(1))
                }
            }

            context("preparing request http body") {
                it("should read values from form and prepare an http body") {
                    let commentsTextBox = subject.feedbackFormView.commentsTextBox
                    commentsTextBox?.itemTextField.text = "help"

                    let emailTextBox = subject.feedbackFormView.emailTextBox
                    emailTextBox?.itemTextField.text = "blah@google.com"

                    let teamId = "RetroQuest-iOS"
                    subject.feedbackStarsSelected = 3

                    let expectedFeedback = Feedback(
                            stars: 3,
                            comment: "help",
                            userEmail: "blah@google.com",
                            teamId: teamId
                    )

                    let httpBody: Data = subject.buildFeedbackHttpBody()!
                    guard let actualFeedback = try? JSONDecoder().decode(Feedback.self, from: httpBody) else {
                        assert(false)
                    }
                    expect(actualFeedback).to(equal(expectedFeedback))
                }
            }

            context("Submitting feedback") {
                let feedbackUrl = URL(string: URLManager.getFeedbackPath())!

                beforeEach {
                    let feedbackResponse = StubResponse.Builder()
                            .stubResponse(withStatusCode: 201)
                            .build()
                    let feedbackRequest = StubRequest.Builder()
                            .stubRequest(withMethod: .POST, url: feedbackUrl)
                            .addResponse(feedbackResponse)
                            .build()

                    Hippolyte.shared.add(stubbedRequest: feedbackRequest)
                    Hippolyte.shared.start()
                }

                it("should show a thanks alert after submitting feedback and remove it once acknowledged") {
                    let commentsTextBox = subject.feedbackFormView.commentsTextBox
                    commentsTextBox?.itemTextField.text = "help"

                    let submitButton = subject.feedbackFormView.submitButton!
                    submitButton.tap()

                    expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                    guard let alertController = subject.presentedViewController as? UIAlertController else {
                        assert(false)
                    }

                    expect(alertController.title).toEventually(equal("Thanks for your feedback!"))

                    alertController.tapButton(atIndex: 0)
                    expect(subject.presentedViewController).toEventually(beNil())
                }

                it("should highlight the comments text box when unfilled and pressing submit") {
                    let submitButton = subject.feedbackFormView.submitButton!
                    submitButton.tap()

                    let commentsTextBox = subject.feedbackFormView.commentsTextBox.itemTextField
                    expect(commentsTextBox?.backgroundColor).to(equal(UIColor(hexString: "FAFFBD")))
                }

                afterEach {
                    Hippolyte.shared.stop()
                }
            }
        }
    }

    func getFontStyleString(button: UIButton) -> String {
        let fontStyle = button.attributedTitle(for: UIControl.State())?.attribute(NSAttributedString.Key.font, at: 0, effectiveRange: nil)
        return String(describing: fontStyle)
    }
}
