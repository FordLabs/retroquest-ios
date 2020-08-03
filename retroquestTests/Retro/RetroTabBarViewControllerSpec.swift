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

class RetroTabBarViewControllerSpec: QuickSpec {

    override func spec() {
        var navController: UINavigationController!
        var subject: RetroTabBarViewController!
        var flowController: FakeFlowController!
        var thoughtsViewController: FakeThoughtsViewController!
        var actionItemsViewController: FakeActionItemsViewController!
        var webSocketService: FakeWebSocketService!
        var fakeNotificationWrapper: FakeNotificationCenterWrapper!

        beforeEach {
            flowController = FakeFlowController()
            thoughtsViewController = FakeThoughtsViewController()
            actionItemsViewController = FakeActionItemsViewController()
            webSocketService = FakeWebSocketService()
            fakeNotificationWrapper = FakeNotificationCenterWrapper()

            subject = RetroTabBarViewController(
                    flowController: flowController,
                    thoughtsViewController: thoughtsViewController,
                    actionItemsViewController: actionItemsViewController,
                    webSocketService: webSocketService,
                    notificationCenterWrapper: fakeNotificationWrapper
            )

            navController = UINavigationController(rootViewController: subject)
            navController.view.layoutSubviews()
            subject.view.layoutSubviews()
            UIWindow.key?.rootViewController = navController
        }

        describe("ThoughtsTabBarViewControllerSpec") {
            context("A: when the view loads") {
                it("should add the tab bar controller to the view") {
                    let topViewController: UIViewController? = navController.topViewController
                    expect(topViewController).toEventually(beAKindOf(RetroTabBarViewController.self))
                }

                it("should call the ThoughtsViewController viewDidLoad") {
                    let fakeThoughtsViewController = subject.thoughtsViewController as? FakeThoughtsViewController
                    expect(fakeThoughtsViewController!.viewDidLoadCalled).toEventually(beTrue())
                }

                it("should make ThoughtsViewController the default view controller") {
                    expect(subject.retroTabBarController.selectedViewController)
                            .toEventually(beAKindOf(ThoughtsViewController.self))
                }

                it("should have 3 tab bar items") {
                    expect(subject.retroTabBarController.tabBar.items!.count).to(equal(3))
                }

                it("should try to connect to websocket service") {
                    expect(webSocketService.wsConnectAttempt).to(beTrue())
                }

                it("should register to receive will resign notification and disconnect when notification received") {
                    let disconnectCollection = self.getNotificationObserver(
                            name: UIApplication.willResignActiveNotification,
                            wrapper: fakeNotificationWrapper
                    )
                    expect(disconnectCollection).toNot(beNil())

                    webSocketService.wsConnectAttempt = false

                    subject.perform(disconnectCollection!.2)

                    expect(webSocketService.wsDisconnectAttempt).to(beTrue())
                }

                it("should register to receive now active notification and reconnect when notification is received") {
                    let reconnectCollection = self.getNotificationObserver(
                            name: UIApplication.didBecomeActiveNotification,
                            wrapper: fakeNotificationWrapper
                    )
                    expect(reconnectCollection).toNot(beNil())

                    webSocketService.wsConnectAttempt = false

                    subject.perform(reconnectCollection!.2)

                    expect(webSocketService.wsConnectAttempt).to(beTrue())
                    expect(thoughtsViewController.refreshDataCalled).to(beTrue())
                    expect(actionItemsViewController.refreshDataCalled).to(beTrue())
                }
            }

            context("B: user taps the action items tab") {
                beforeEach {
                    subject.retroTabBarController.selectedIndex = 1
                }

                it("should show the action items view controller") {
                    expect(subject.retroTabBarController.selectedViewController)
                            .toEventually(beAKindOf(ActionItemsViewController.self))
                }

                it("should call the ActionItemsViewController viewDidLoad") {
                    let fakeViewController = subject.actionItemsViewController as? FakeActionItemsViewController
                    expect(fakeViewController!.viewDidLoadCalled).toEventually(beTrue())
                }
            }

            context("C: user then taps the thoughts tab") {
                beforeEach {
                    subject.retroTabBarController.selectedIndex = 0
                }

                it("should show the thoughts view controller") {
                    expect(subject.retroTabBarController.selectedViewController)
                            .toEventually(beAKindOf(ThoughtsViewController.self))
//                    guard let thoughtsViewController = subject.retroTabBarController.selectedViewController
//                            as? ThoughtsViewController else {
//                        assert(false)
//                    }
//                    expect(thoughtsViewController.thoughtsView.tableView).toNotEventually(beNil())
                }
            }

            context("D: user then taps the logout tab") {
                beforeEach {
                    subject.retroTabBarController.selectedIndex = 2
                }

                context("should continue showing same view controller when tapped") {
                    context("from the thoughts tab") {
                        beforeEach {
                            subject.previousViewControllerIdx = 0
                            subject.tabBarController(
                                    subject.retroTabBarController,
                                    didSelect: subject.logoutViewController
                            )
                        }

                        it("should switch back to thoughts view controller") {
                            let previousViewControllerIdx = subject.previousViewControllerIdx
                            expect(subject.retroTabBarController.selectedIndex)
                                    .toEventually(equal(previousViewControllerIdx))
                        }
                    }

                    context("from the action items tab") {
                        beforeEach {
                            subject.previousViewControllerIdx = 1
                            subject.tabBarController(
                                    subject.retroTabBarController,
                                    didSelect: subject.logoutViewController
                            )
                        }

                        it("should switch back to action items view controller") {
                            let previousViewControllerIdx = subject.previousViewControllerIdx
                            expect(subject.retroTabBarController.selectedIndex)
                                    .toEventually(equal(previousViewControllerIdx))
                        }
                    }
                }

                context("showing logout confirmation") {
                    beforeEach {
                        subject.tabBarController(subject.retroTabBarController, didSelect: subject.logoutViewController)
                    }

                    it("should show the user a logout confirmation alert") {
                        expect(subject.presentedViewController).toEventually(beAKindOf(UIAlertController.self))
                        guard let alertController = subject.presentedViewController as? UIAlertController else {
                            assert(false)
                        }

                        expect(alertController.message).toEventually(equal("Are you sure?"))
                        expect(alertController.title).toEventually(equal("Logout"))
                    }

                    context("user confirms logout") {
                        beforeEach {
                            expect(fakeNotificationWrapper.observerCollection.count).to(beGreaterThan(0))
                            guard let alertController = subject.presentedViewController as? UIAlertController else {
                                assert(false)
                            }
                            alertController.tapButton(atIndex: 0)
                        }

                        it("should transition to the LoginViewController") {
                            expect(flowController.switchToCalledWith).toEventually(equal(.login))
                        }

                        it("should disconnect the websocket") {
                            expect(webSocketService.wsDisconnectAttempt).toEventually(beTrue())
                        }

                        it("should unsubscribe to active notifications") {
                            expect(fakeNotificationWrapper.observerCollection.count).to(equal(0))
                        }
                    }

                    context("user cancels logout") {
                        it("should NOT transition to a different View Controller") {
                            guard let alertController = subject.presentedViewController as? UIAlertController else {
                                assert(false)
                            }
                            alertController.tapButton(atIndex: 1)
                            expect(subject.presentedViewController).toEventually(beNil())
                        }
                    }
                }
            }
        }
    }

    private func getNotificationObserver(
            name: Notification.Name,
            wrapper: FakeNotificationCenterWrapper
    ) -> (Any, Notification.Name, Selector)? {
        for collection in wrapper.observerCollection where collection.1 == name {
            return collection
        }
        return nil
    }
}
