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

class FlowControllerSpec: QuickSpec {
    override func spec() {
        var flowController: RetroFlowController!
        let testContainer = TestRetroContainer.newContainer()
        var fakeNavController: FakeNavigationController!

        beforeEach {
            fakeNavController = FakeNavigationController()
            flowController = RetroFlowController(fakeNavController, testContainer)
        }

        describe("switch views") {

            context("pushing to a view that is already showing") {
                it("does not push the view again") {
                    flowController.switchTo(.login)

                    flowController.switchTo(.login)

                    expect(fakeNavController.timesPushCalled).to(equal(1))
                }
            }

            context("pushing while an alert view is showing") {
                it("does not push the view") {
                    fakeNavController.presentedViewController = UIAlertController()

                    flowController.switchTo(.login)

                    expect(fakeNavController.timesPushCalled).to(equal(0))
                }
            }

            context("switching registration views") {

                it("can switch to login") {
                    flowController.switchTo(.login)

                    expect(fakeNavController.pushViewControllerCalledWith).to(beAKindOf(LoginViewController.self))
                }

                it("can switch to thoughts") {
                    flowController.switchTo(.thoughts)

                    expect(fakeNavController.pushViewControllerCalledWith).to(beAKindOf(RetroTabBarViewController.self))
                }
            }
        }
    }
}
