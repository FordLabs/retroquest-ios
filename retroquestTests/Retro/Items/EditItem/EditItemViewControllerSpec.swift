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

class EditItemViewControllerSpec: QuickSpec {

    override func spec() {
        Nimble.AsyncDefaults.Timeout = 3
        Nimble.AsyncDefaults.PollInterval = 0.1
        
        var subject: EditItemViewController!

        beforeEach {
            subject = EditItemViewController(titleText: "Title", defaultText: "Default", onSave: {_ in})
            subject.view.layoutSubviews()

            let navController = UINavigationController()
            navController.viewControllers = [subject]
            navController.view.layoutSubviews()

            UIApplication.shared.keyWindow?.rootViewController = navController
        }

        describe("when the view loads") {
            it("should set the title text in the heading") {
                expect(subject.editTextView.headingLabel.text).to(equal("Title"))
            }

            it("should set default text if given") {
                expect(subject.editTextView.validatingTextField.itemTextField.text).to(equal("Default"))
            }

            describe("Submitting changed text") {
                it("should validate length of message to 255 characters by default") {
                    subject.editTextView.validatingTextField.itemTextField.text = "jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj"
                    subject.editTextView.saveButton.tap()

                    expect(subject.editTextView.validatingTextField.errorMessageView.isHidden).toEventually(beFalse())
                }

                it("should validate length by optionally provided number of characters") {
                    subject = EditItemViewController(
                            titleText: "Title",
                            defaultText: "Default",
                            onSave: {_ in},
                            maxCharacters: 15
                    )
                    subject.view.layoutSubviews()

                    subject.editTextView.validatingTextField.itemTextField.text = "jjjjjjjjjjjjjjjj"
                    subject.editTextView.saveButton.tap()
                    expect(subject.editTextView.validatingTextField.errorMessageView.isHidden).toEventually(beFalse())
                }

                it("should validate text is not empty") {
                    subject.editTextView.validatingTextField.itemTextField.text = ""
                    subject.editTextView.saveButton.tap()
                    expect(subject.editTextView.validatingTextField.errorMessageView.isHidden).toEventually(beFalse())
                }

                it("should invoke callback with updated text") {
                    var capturedText: String?
                    subject.onSave = {text in capturedText = text}

                    subject.editTextView.validatingTextField.itemTextField.text = "New text"
                    subject.editTextView.saveButton.tap()

                    expect(capturedText).toEventually(equal("New text"))
                }
            }
        }
    }
}
