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

public class FakeNotificationCenterWrapper: Notifying {

    internal var observerCollection: [(Any, Notification.Name, Selector)] = []
    internal var postedToName: Notification.Name?

    public func addObserver(
            _ observer: Any,
            selector aSelector: Selector,
            name aName: NSNotification.Name?,
            object anObject: Any?
    ) {
        observerCollection.append((observer, aName!, aSelector))
    }

    public func post(name aName: NSNotification.Name, object anObject: Any?) {
        postedToName = aName
    }

    public func removeObserver(_ observer: Any) {
        observerCollection = observerCollection.filter { existingObserver in
            existingObserver.0 as? RetroTabBarViewController !== observer as? RetroTabBarViewController
        }
    }
}
