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

import SwiftUI

class PubSub<T>: ObservableObject {

    internal var incomingSubscribers: [IncomingSubscriptionCallback<T>]!
    internal var outgoingSubscribers: [OutgoingSubscriptionCallback<T>]!

    init() {
        incomingSubscribers = []
        outgoingSubscribers = []
    }

    func addIncomingSubscriber(_ subscriber: @escaping IncomingSubscriptionCallback<T>) {
        incomingSubscribers.append(subscriber)
    }

    func addOutgoingSubscriber(_ subscriber: @escaping OutgoingSubscriptionCallback<T>) {
        outgoingSubscribers.append(subscriber)
    }

    func publishIncoming(_ callbackData: T?) {
        for callback in incomingSubscribers {
            callback(callbackData)
        }
    }

    func publishIncoming(_ callbackData: [T]) {
        if callbackData.count > 0 {
            for data in callbackData {
                publishIncoming(data)
            }
        } else {
            publishIncoming(nil)
        }
    }

    func publishOutgoing(_ callbackData: T?, outgoingType: OutgoingType) {
        for callback in outgoingSubscribers {
            callback(callbackData, outgoingType)
        }
    }

    func clearAllSubscribers() {
        incomingSubscribers = []
        clearOutgoingSubscribers()
    }

    func clearOutgoingSubscribers() {
        outgoingSubscribers = []
    }

    typealias IncomingSubscriptionCallback<T> = (T?) -> Void
    typealias OutgoingSubscriptionCallback<T> = (T?, OutgoingType) -> Void
}
