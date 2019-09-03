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

import Foundation
import StompClientLib
import SocketRocket
@testable import retroquest

class FakeStompClientLib: NSObject, StompClientLibProtocol {
    func sendJSONForDict(dict: AnyObject, toDestination destination: String) { }
    func openSocketWithURLRequest(request: NSURLRequest, delegate: StompClientLibDelegate) { }
    func subscribeToDestination(destination: String, ackMode: StompAckMode) { }
    func subscribeWithHeader(destination: String, withHeader header: [String: String]) { }
    func unsubscribe(destination: String) { }
    func begin(transactionId: String) { }
    func commit(transactionId: String) { }
    func abort(transactionId: String) { }
    func ack(messageId: String) { }
    func ack(messageId: String, withSubscription subscription: String) { }
    func autoDisconnect(time: Double) { }
    func disconnect() {}
    func reconnect(
            request: NSURLRequest,
            delegate: StompClientLibDelegate,
            connectionHeaders: [String: String],
            time: Double,
            exponentialBackoff: Bool
    ) { }

    var openSocketWithURLRequestCalled = false
    var sendMessageCalledWithMessage: String?
    var sendMessageCalledWithDestination: String?
    var subscriptions: [String] = []

    func resetDummies() {
        openSocketWithURLRequestCalled = false
        subscriptions = []
    }

    func subscribe(destination: String) {
        subscriptions.append(destination)
    }

    func openSocketWithURLRequest(
            request: NSURLRequest,
            delegate: StompClientLibDelegate,
            connectionHeaders: [String: String]?
    ) {
        openSocketWithURLRequestCalled = true
        subscriptions = []
        delegate.stompClientDidConnect(client: self)
    }

    public func sendMessage(
            message: String,
            toDestination destination: String,
            withHeaders headers: [String: String]?,
            withReceipt receipt: String?
    ) {
        sendMessageCalledWithMessage = message
        sendMessageCalledWithDestination = destination
    }

    public func isConnected() -> Bool {
        return true
    }
}
