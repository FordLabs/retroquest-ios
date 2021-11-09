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

import UIKit
import os.log
import AppCenterAnalytics

class RetroTabBarViewController: UIViewController, UITabBarControllerDelegate {
    let retroTabBarController = UITabBarController()

    internal var thoughtsViewController: ThoughtsViewController!
    internal var actionItemsViewController: ActionItemsViewController!
    internal var webSocketService: WebSocketService!
    internal var notificationCenterWrapper: Notifying!
    internal var logoutViewController = UIViewController()

    internal var flowController: RetroFlowController!

    internal var previousViewControllerIdx: Int!

    convenience init(
            flowController: RetroFlowController,
            thoughtsViewController: ThoughtsViewController,
            actionItemsViewController: ActionItemsViewController,
            webSocketService: WebSocketService,
            notificationCenterWrapper: Notifying
    ) {
        self.init()

        self.flowController = flowController
        self.thoughtsViewController = thoughtsViewController
        self.actionItemsViewController = actionItemsViewController
        self.webSocketService = webSocketService
        self.notificationCenterWrapper = notificationCenterWrapper

        self.previousViewControllerIdx = 0
    }

    deinit {
        notificationCenterWrapper.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        retroTabBarController.delegate = self
        view.addSubview(retroTabBarController.view)
        view.backgroundColor = RetroColors.backgroundColor

        webSocketService.connectToWebSocketServer()

        let fontAttributes = [NSAttributedString.Key.font: UIFont.retroquestRegular(size: 12)]
        UITabBarItem.appearance().setTitleTextAttributes(fontAttributes, for: .normal)

        thoughtsViewController.tabBarItem = UITabBarItem(
            title: "Thoughts",
            image: UIImage(named: "ThoughtsTab"),
            tag: 0
        )
        actionItemsViewController.tabBarItem = UITabBarItem(
            title: "Action Items",
            image: UIImage(named: "ActionItemsTab"),
            tag: 1
        )
        logoutViewController.tabBarItem = UITabBarItem(title: "Logout", image: UIImage(named: "LogoutTab"), tag: 2)

        retroTabBarController.setViewControllers(
            [thoughtsViewController, actionItemsViewController, logoutViewController],
            animated: true
        )

        notificationCenterWrapper.addObserver(
                self,
                selector: #selector(closeWebsocketConnection),
                name: UIApplication.willResignActiveNotification,
                object: nil
        )

        notificationCenterWrapper.addObserver(
                self,
                selector: #selector(resetWebsocketConnection),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
        )
    }

    @objc func closeWebsocketConnection() {
        webSocketService.disconnectFromWebSocketServer()
    }

    @objc func resetWebsocketConnection() {
        self.thoughtsViewController.refreshData()
        self.actionItemsViewController.refreshData()
        self.webSocketService.connectToWebSocketServer()
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 2 {
            tabBarController.selectedIndex = self.previousViewControllerIdx

            let alert = UIAlertController(title: "Logout", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Confirm", style: .default) { _ in
                Analytics.trackEvent("logout", withProperties: ["Team": URLManager.currentTeam])
                self.webSocketService.disconnectFromWebSocketServer()
                self.notificationCenterWrapper.removeObserver(self)
                self.logout()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alert.dismiss(animated: true)
            })

            self.present(alert, animated: true, completion: {})
        } else {
            self.previousViewControllerIdx = tabBarController.selectedIndex
        }
    }

    private func logout() {
        self.flowController.switchTo(.login)
    }
}
