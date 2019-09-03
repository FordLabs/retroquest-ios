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
import Swinject

protocol FlowController {
    func switchTo(_ state: RetroNavState)
}

class RetroFlowController: NSObject, FlowController {
    var navController: UINavigationController!
    var container: Container!

    init(_ withNavigationController: UINavigationController, _ container: Container) {
        super.init()

        self.navController = withNavigationController
        self.container = container
    }

    func switchTo(_ state: RetroNavState) {
        if isShowingAlertController() {
            return
        }

        let viewControllerToSwitchTo = self.getViewControllerForState(state)

        if isControllerToNavigateToSameAsCurrent(viewControllerToSwitchTo) {
            return
        }

        self.navController.pushViewController(viewControllerToSwitchTo, animated: true)
    }

    internal func isShowingAlertController() -> Bool {
        if let currentlyShowing = navController.presentedViewController,
           currentlyShowing.isKind(of: UIAlertController.self) {
            return true
        }
        return false
    }

    internal func isControllerToNavigateToSameAsCurrent(_ viewController: UIViewController) -> Bool {
        if let topController = navController.topViewController {
            return topController.isKind(of: type(of: viewController)) ? true : false
        }
        return false
    }

    func getViewControllerForState(_ state: RetroNavState) -> UIViewController {
        switch state {
        case .login:
            return self.container.resolve(LoginViewController.self)!
        case .thoughts:
            return self.container.resolve(RetroTabBarViewController.self)!
        }
    }
}
