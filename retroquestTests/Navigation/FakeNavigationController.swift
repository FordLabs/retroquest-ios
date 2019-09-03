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
@testable import retroquest

class FakeNavigationController: UINavigationController {
    override var topViewController: UIViewController? {
        set {
            mockTopViewController = newValue
        }
        get {
            return mockTopViewController
        }
    }
    override var presentedViewController: UIViewController? {
        set {
            mockPresentedViewController = newValue
        }
        get {
            return mockPresentedViewController
        }
    }
    private var mockTopViewController: UIViewController?
    private var mockPresentedViewController: UIViewController?

    var pushViewControllerCalledWith: UIViewController?
    var presentCalledWith: UIViewController?
    var popViewControllerCalled = false
    var timesPushCalled = 0

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        topViewController = viewController
        timesPushCalled += 1
        pushViewControllerCalledWith = viewController
    }

    override func present(
            _ viewControllerToPresent: UIViewController,
            animated flag: Bool,
            completion: (() -> Swift.Void)?
    ) {
        presentCalledWith = viewControllerToPresent
        topViewController = viewControllerToPresent
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        popViewControllerCalled = true
        return nil
    }
}
