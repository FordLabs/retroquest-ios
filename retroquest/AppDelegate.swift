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
import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import AppCenterDistribute

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let container = RetroContainer.defaultContainer()

    internal func rootViewController() -> UIViewController {
        return container.resolve(LoginViewController.self)!
    }

    func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let navigationController = container.resolve(UINavigationController.self)!
        navigationController.isNavigationBarHidden = true

        navigationController.setViewControllers([rootViewController()], animated: false)

        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()

        var appServices: [AnyClass] = []
        #if DEBUG
            // disable app center in app updates if running locally
            appServices = [ Analytics.self, Crashes.self ]
        #else
            appServices = [ Analytics.self, Crashes.self, Distribute.self ]
        #endif
        AppCenter.start(withAppSecret: AppCenterSecret, services: appServices)

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }
}
