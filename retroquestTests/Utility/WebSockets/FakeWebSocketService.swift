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
@testable import retroquest

class FakeWebSocketService: WebSocketService {
    internal var wsConnectAttempt: Bool = false
    internal var wsDisconnectAttempt: Bool = false
    internal var thoughtResponse: Thought?
    internal var actionItemResponse: ActionItem?
    internal var columnResponse: Column?

    init() {
        super.init(stompClient: FakeStompClientLib(),
                thoughtPubSub: PubSub<Thought>(),
                actionItemPubSub: PubSub<ActionItem>(),
                columnPubSub: PubSub<Column>(),
                notificationCenterWrapper: FakeNotificationCenterWrapper()
        )
    }

    override func connectToWebSocketServer() {
        wsConnectAttempt = true
    }

    override func disconnectFromWebSocketServer() {
        wsDisconnectAttempt = true
    }

    internal func resetDummies() {
        wsConnectAttempt = false
        thoughtResponse = nil
        actionItemResponse = nil
        columnResponse = nil
    }

    internal func thoughtsCallback(thought: Thought?) {
        thoughtResponse = thought
    }

    internal func actionItemCallback(actionItem: ActionItem?) {
        actionItemResponse = actionItem
    }

    internal func columnCallback(column: Column?) {
        columnResponse = column
    }
}
