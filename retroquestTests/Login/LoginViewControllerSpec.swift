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

class LoginViewControllerSpec: QuickSpec {

    override func spec() {

        Nimble.AsyncDefaults.Timeout = 3
        
        var subject: LoginViewController!
        var navController: UINavigationController!
        var flowController: FakeFlowController!

        let userDefaults = UserDefaults.standard

        beforeEach {
            flowController = FakeFlowController()
            RetroCookies.clearCookies()
            userDefaults.removeObject(forKey: "Saved_Team")
            userDefaults.removeObject(forKey: "Saved_Team_Password")
        }

        describe("saved credentials") {

            beforeEach {
                userDefaults.set("teamABC", forKey: "Saved_Team")
                userDefaults.set("mypassword", forKey: "Saved_Team_Password")

                self.setupController(
                        flowController: flowController,
                        subject: &subject,
                        navController: &navController
                )
            }

            context("on load") {

                it("should autofill the board name and password fields") {
                    expect(subject.loginView.boardField.text).toNot(equal(""))
                    expect(subject.loginView.passwordField.text).toNot(equal(""))
                }

                it("should autocheck the save credentials checkbox") {
                    expect(subject.loginView.saveSettingsCheckbox.checkState).to(equal(.checked))
                }
            }
        }

        describe("there are no saved credentials") {

            beforeEach {
                self.setupController(
                        flowController: flowController,
                        subject: &subject,
                        navController: &navController
                )
            }

            context("on load") {

                it("should have empty board name and password fields") {
                    expect(subject.loginView.boardField.text).to(equal(""))
                    expect(subject.loginView.passwordField.text).to(equal(""))
                }
            }

            describe("field limits") {
                var textField: UITextField!
                var shouldChange: Bool!

                beforeEach {
                    textField = subject.loginView.boardField
                }

                it("should be a delegate for the email/password textfields") {
                    expect(subject.loginView.boardField.delegate).to(be(subject))
                    expect(subject.loginView.passwordField.delegate).to(be(subject))
                }

                it("should allow board input to be up to 100 characters long") {
                    textField.text = "thisisanabsurdlylongboardaddresswith99blankspaceobliteratingcharactersthatshouldneverexist@ford.com"
                    shouldChange = subject.textField(
                            textField,
                            shouldChangeCharactersIn: NSRange(location: 99, length: 0),
                            replacementString: "x")
                    expect(shouldChange).to(beTrue())
                }

                it("should not allow input over 100 characters") {
                    textField.text = "thisisanabsurdlylongboardaddresswith100blankspaceobliteratingcharactersthatshouldneverexist@ford.com"
                    shouldChange = subject.textField(
                            textField,
                            shouldChangeCharactersIn: NSRange(location: 100, length: 0),
                            replacementString: "x")
                    expect(shouldChange).to(beFalse())
                }

                it("should allow text to be replaced as long as it's not over 100 characters") {
                    textField.text = "thisisanabsurdlylongemailaddresswith100blankspaceobliteratingcharactersthatshouldneverexist@ford.com"
                    shouldChange = subject.textField(
                            textField,
                            shouldChangeCharactersIn: NSRange(location: 99, length: 1),
                            replacementString: "x")
                    expect(shouldChange).to(beTrue())
                }
            }

            describe("when sign in button is clicked") {
                let team = "FordBoard"

                context("when password and email fields are not empty") {
                    beforeEach {
                        subject.loginView.boardField.text = team
                        subject.loginView.passwordField.text = "12345678"
                    }

                    context("when the authentication is resolved successfully") {
                        let fakeToken = "fake_token"
                        let responseData = fakeToken.data(using: .utf8)!

                        beforeEach {
                            RetroCookies.clearCookies()

                            let response = StubResponse.Builder()
                                    .stubResponse(withStatusCode: 200)
                                    .addBody(responseData)
                                    .build()
                            let request = StubRequest.Builder()
                                    .stubRequest(withMethod: .POST, url: URL(string: URLManager.getFullLoginPath())!)
                                    .addResponse(response)
                                    .build()
                            Hippolyte.shared.add(stubbedRequest: request)
                            Hippolyte.shared.start()
                        }

                        it("should transition to the thoughts view controller") {
                            subject.loginView.signInButton.tap()

                            expect(flowController.switchToCalledWith).toEventually(equal(RetroNavState.thoughts))
                        }

                        it("should set the team on the thoughts view controller") {
                            URLManager.currentTeam = ""
                            expect(URLManager.currentTeam).toNot(equal(team))

                            subject.loginView.signInButton.tap()

                            expect(URLManager.currentTeam).toEventually(equal(team))
                        }

                        it("should put the returned token in the cookie space") {
                            subject.loginView.signInButton.tap()

                            expect(RetroCookies.searchForCurrentCookie(
                                    value: fakeToken,
                                    fullUrl: URLManager.getFullTeamPath(team: team),
                                    name: "token"
                            )).toEventuallyNot(beNil())
                        }

                        it("should replace existing token in the cookie space") {
                            RetroCookies.setRetroCookie(
                                    urlDomain: URLManager.retroBaseUrl,
                                    urlPath: URLManager.teamUrlPath + team,
                                    name: "token",
                                    value: "SO_OUTTA_DATE")
                            subject.loginView.signInButton.tap()

                            expect(RetroCookies.searchForCurrentCookie(
                                    value: fakeToken,
                                    fullUrl: URLManager.getFullTeamPath(team: team),
                                    name: "token"
                            )).toEventuallyNot(beNil())
                        }

                        context("when the save credentials checkbox is checked") {
                            beforeEach {
                                userDefaults.set(nil, forKey: "Saved_Team")
                                userDefaults.set(nil, forKey: "Saved_Team_Password")
                            }

                            it("should store the credentials in user storage") {
                                subject.loginView.saveSettingsCheckbox.setCheckState(.checked, animated: false)
                                subject.loginView.signInButton.tap()

                                expect(userDefaults.object(forKey: "Saved_Team")).toEventuallyNot(beNil())
                                expect(userDefaults.object(forKey: "Saved_Team_Password")).toEventuallyNot(beNil())
                            }
                        }

                        context("when the save credentials checkbox is not checked") {
                            beforeEach {
                                userDefaults.set("teamABC", forKey: "Saved_Team")
                                userDefaults.set("mypassword", forKey: "Saved_Team_Password")
                            }

                            it("should store the credentials in user storage") {
                                subject.loginView.saveSettingsCheckbox.setCheckState(.unchecked, animated: false)
                                subject.loginView.signInButton.tap()

                                expect(userDefaults.object(forKey: "Saved_Team")).toEventually(beNil())
                                expect(userDefaults.object(forKey: "Saved_Team_Password")).toEventually(beNil())
                            }
                        }

                        afterEach {
                            Hippolyte.shared.stop()
                        }
                    }

                    context("when the authentication fails - e.g. board not found") {
                        let loginFailureMsg = "Incorrect board or password. Please try again."
                        let loginFailureException = "com.fordfacto.fordfactoweb.exception.BoardDoesNotExistException"
                        let loginErrorCode = 403
                        let retroLoginError = RetroLoginError(
                                error: "",
                                exception: loginFailureException,
                                message: loginFailureMsg,
                                path: "",
                                status: loginErrorCode)
                        let responseData = try? JSONEncoder().encode(retroLoginError)

                        beforeEach {
                            UIApplication.shared.keyWindow?.rootViewController = navController

                            let response = StubResponse.Builder()
                                    .stubResponse(withStatusCode: loginErrorCode)
                                    .addBody(responseData!)
                                    .build()
                            let request = StubRequest.Builder()
                                    .stubRequest(withMethod: .POST, url: URL(string: URLManager.getFullLoginPath())!)
                                    .addResponse(response)
                                    .build()
                            Hippolyte.shared.add(stubbedRequest: request)
                            Hippolyte.shared.start()
                            subject.loginView.signInButton.tap()
                        }

                        it("should NOT transition to the next View Controller") {
                            expect(navController.topViewController).toEventually(be(subject))
                        }

                        it("should show the user an error message") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                            guard let alertController = subject.presentedViewController as? UIAlertController else {
                                assert(false)
                            }

                            expect(alertController.message).toEventually(equal(loginFailureMsg))
                            expect(alertController.title).toEventually(equal("Login Failure"))
                        }

                        afterEach {
                            Hippolyte.shared.stop()
                        }
                    }

                    context("when the authentication fails with no error details") {
                        beforeEach {
                            UIApplication.shared.keyWindow?.rootViewController = navController

                            let response = StubResponse.Builder()
                                    .stubResponse(withStatusCode: 500)
                                    .build()
                            let request = StubRequest.Builder()
                                    .stubRequest(withMethod: .POST, url: URL(string: URLManager.getFullLoginPath())!)
                                    .addResponse(response)
                                    .build()
                            Hippolyte.shared.add(stubbedRequest: request)
                            Hippolyte.shared.start()
                            subject.loginView.signInButton.tap()
                        }

                        it("should NOT transition to the next View Controller") {
                            expect(navController.topViewController).toEventually(be(subject))
                        }

                        it("should show the user a generic error message") {
                            expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                            guard let alertController = subject.presentedViewController as? UIAlertController else {
                                assert(false)
                            }

                            expect(alertController.message).toEventually(contain("GitHub"))
                            expect(alertController.title).toEventually(equal("Login Failure"))
                        }
                    }
                }

                context("when password or board fields are empty") {
                    beforeEach {
                        UIApplication.shared.keyWindow?.rootViewController = navController

                        subject.loginView.boardField.text = nil
                        subject.loginView.passwordField.text = nil
                    }

                    it("should display a dual notification") {
                        subject.loginView.signInButton.tap()

                        expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                        guard let alertController = subject.presentedViewController as? UIAlertController else {
                            assert(false)
                        }

                        expect(alertController.message).to(equal("Please enter a valid input for all fields"))
                        expect(alertController.title).to(equal("All fields required"))
                    }

                    it("should display a notification about empty password") {
                        subject.loginView.boardField.text = "Whut"
                        subject.loginView.signInButton.tap()

                        expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                        guard let alertController = subject.presentedViewController as? UIAlertController else {
                            assert(false)
                        }

                        expect(alertController.message).to(equal("Please enter a valid input for all fields"))
                        expect(alertController.title).to(equal("Password field required"))
                    }

                    it("should display a notification about empty board") {
                        subject.loginView.passwordField.text = "NoWay"
                        subject.loginView.signInButton.tap()

                        expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                        guard let alertController = subject.presentedViewController as? UIAlertController else {
                            assert(false)
                        }

                        expect(alertController.message).to(equal("Please enter a valid input for all fields"))
                        expect(alertController.title).to(equal("Board field required"))
                    }
                }

                context("when neither field is blank") {
                    beforeEach {
                        UIApplication.shared.keyWindow?.rootViewController = navController

                        subject.loginView.boardField.text = nil
                        subject.loginView.passwordField.text = nil
                    }

                    it("alert when password has fewer than 8 characters in length") {
                        subject.loginView.boardField.text = "Whut"
                        subject.loginView.passwordField.text = "1234567"
                        subject.loginView.signInButton.tap()

                        expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                        guard let alertController = subject.presentedViewController as? UIAlertController else {
                            assert(false)
                        }

                        expect(alertController.message).to(equal("Must be at least 8 characters"))
                        expect(alertController.title).to(equal("Password field"))
                    }
                }
            }
        }

        describe("feedback button") {

            beforeEach {
                self.setupController(
                        flowController: flowController,
                        subject: &subject,
                        navController: &navController
                )
            }

            context("when clicked") {
                it("should pull up the Feedback view controller and hide it when cancelled") {
                    expect(subject.presentedViewController).to(beNil())

                    subject.loginView.giveFeedbackButton.tap()

                    let rootViewController = UIApplication.shared.keyWindow!.rootViewController!
                    expect(rootViewController.presentedViewController)
                            .toEventually(beAKindOf(FeedbackViewController.self))
                    guard let feedbackViewController = rootViewController.presentedViewController
                            as? FeedbackViewController else {
                        assert(false)
                    }
                    let feedbackFormView = feedbackViewController.feedbackFormView!
                    feedbackFormView.cancelButton.tap()

                    expect(subject.presentedViewController).toEventually(beNil(), timeout: 5)
                }
            }
        }

        describe("user clicks the saved credential label") {

            beforeEach {
                self.setupController(
                        flowController: flowController,
                        subject: &subject,
                        navController: &navController
                )
            }

            it("should toggle the saved credential checkbox") {
                subject.loginView.saveSettingsCheckbox.setCheckState(.unchecked, animated: false)

                subject.didTapSaveCredentialsLabel()

                expect(subject.loginView.saveSettingsCheckbox.checkState).to(equal(.checked))
            }
        }
    }

    private func setupController(
            flowController: FakeFlowController!,
            subject: inout LoginViewController!,
            navController: inout UINavigationController!
    ) {
        subject = LoginViewController(
                flowController: flowController
        )
        subject.view.layoutSubviews()

        let rootVc = UIViewController()
        navController = UINavigationController()
        navController.viewControllers = [rootVc, subject]
        navController.view.layoutSubviews()

        UIApplication.shared.keyWindow?.rootViewController = navController
    }

}
