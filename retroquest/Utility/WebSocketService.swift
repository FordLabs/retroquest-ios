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

import os.log
import Foundation
import StompClientLib

struct SocketMessage<T: Item>: Codable {
    let type: IncomingType
    let payload: T
}

enum IncomingType: String, Codable {
    case put
    case delete
}

class WebSocketService {

    internal var stompClient: StompClientLibProtocol!
    internal var thoughtPubSub: PubSub<Thought>!
    internal var actionItemPubSub: PubSub<ActionItem>!
    internal var columnPubSub: PubSub<Column>!
    internal var notificationCenterWrapper: Notifying!

    internal var thoughtTopic: String!
    internal var actionItemsTopic: String!
    internal var columnNamesTopic: String!
    internal var heartbeatTopic: String!

    internal var heartbeatTimer: Timer!

    init(
            stompClient: StompClientLibProtocol,
            thoughtPubSub: PubSub<Thought>,
            actionItemPubSub: PubSub<ActionItem>,
            columnPubSub: PubSub<Column>,
            notificationCenterWrapper: Notifying
    ) {
        self.stompClient = stompClient
        self.thoughtPubSub = thoughtPubSub
        self.actionItemPubSub = actionItemPubSub
        self.columnPubSub = columnPubSub
        self.notificationCenterWrapper = notificationCenterWrapper
    }

    func connectToWebSocketServer() {
        if let token = RetroCookies.searchForCurrentCookie(
                value: nil,
                fullUrl: URLManager.getFullTeamPath(team: URLManager.currentTeam),
                name: "token"
        ) {
            var request = URLRequest(url: URL(string: URLManager.getRetroWSUrl())!)
            request.setValue(token.value, forHTTPHeaderField: "Authorization")

            let connectionHeaders: [String: String] = ["Authorization": token.value]
            stompClient.openSocketWithURLRequest(
                    request: request as NSURLRequest,
                    delegate: self,
                    connectionHeaders: connectionHeaders
            )

            os_log(
                    "Connecting to websocket: %{public}@ for team %{public}@",
                    type: .info,
                    URLManager.getRetroWSUrl(),
                    URLManager.currentTeam
            )
        } else {
            os_log("Unable to connect to websocket server because token invalid")
        }
    }

    internal func sendMessage<T: Item>(_ item: T?, outgoingType: OutgoingType) {
        if let item = item {
            if stompClient.isConnected() {
                do {
                    let itemAsData = try JSONEncoder().encode(item)
                    let itemAsJSON = String(data: itemAsData, encoding: String.Encoding.utf8)!
                    let destination = URLManager.getWsDestination(item, type: outgoingType)
                    stompClient.sendMessage(
                            message: itemAsJSON,
                            toDestination: destination,
                            withHeaders: ["content-type": "application/json"],
                            withReceipt: nil
                    )
                } catch {
                    print("Could not encode outgoing message")
                }
            }
        }
    }

    func disconnectFromWebSocketServer() {
        if stompClient.isConnected() {
            stompClient.disconnect()
        }
    }

    func cleanup() {
        columnPubSub.clearOutgoingSubscribers()
        actionItemPubSub.clearOutgoingSubscribers()
        thoughtPubSub.clearOutgoingSubscribers()
        heartbeatTimer.invalidate()
    }

    @objc internal func sendHeartbeat() {
        if stompClient.isConnected() {
            stompClient.sendMessage(
                    message: "",
                    toDestination: "/app/heartbeat/ping",
                    withHeaders: [:],
                    withReceipt: nil
            )
        }
    }
}

extension WebSocketService: StompClientLibDelegate {
    internal func stompClientDidDisconnect(client: StompClientLibProtocol!) {
        print("STOMPCLIENT DISCONNECTED")
        cleanup()
    }

    internal func stompClient(
            client: StompClientLibProtocol!,
            didReceiveMessageWithJSONBody jsonBody: AnyObject?,
            akaStringBody stringBody: String?,
            withHeader header: [String: String]?,
            withDestination destination: String
    ) {
        if destination != heartbeatTopic {
            print("DESTINATION : \(destination)")
            if let jsonBodyObject = jsonBody {
                print("String JSON BODY : \(String(describing: stringBody))")

                let responseData = try? JSONSerialization.data(withJSONObject: jsonBodyObject)
                handleResponsePayload(responseData: responseData, destination: destination)
            }
        }
    }

    private func handleResponsePayload(responseData: Data?, destination: String) {
        switch destination {
        case thoughtTopic:
            forwardResponse(pubSub: thoughtPubSub, responseJSONData: responseData)
        case actionItemsTopic:
            forwardResponse(pubSub: actionItemPubSub, responseJSONData: responseData)
        case columnNamesTopic:
            forwardResponse(pubSub: columnPubSub, responseJSONData: responseData)
        default:
            break
        }
    }

    private func forwardResponse<ItemType: Item>(pubSub: PubSub<ItemType>, responseJSONData: Data?) {
        do {
            guard let responseJSONData = responseJSONData else {
                return
            }

            let message = try JSONDecoder().decode(SocketMessage<ItemType>.self, from: responseJSONData)

            if message.type == .delete {
                pubSub.publishIncoming(ItemType(id: message.payload.id, teamId: URLManager.currentTeam, deletion: true))
            } else {
                pubSub.publishIncoming(message.payload)
            }
        } catch {
            print("Could not create a new instance of \(SocketMessage<ItemType>.self) while forwarding response")
            print(error)
        }
    }

    fileprivate func setupSubscriptions() {
        let teamDashed = URLManager.currentTeam.replacingOccurrences(of: " ", with: "-")
        let team = teamDashed.lowercased()

        thoughtPubSub.addOutgoingSubscriber(sendMessage)
        actionItemPubSub.addOutgoingSubscriber(sendMessage)
        columnPubSub.addOutgoingSubscriber(sendMessage)

        thoughtTopic = "/topic/\(team)/thoughts"
        actionItemsTopic = "/topic/\(team)/action-items"
        columnNamesTopic = "/topic/\(team)/column-titles"
        heartbeatTopic = "/topic/heartbeat/pong"
        stompClient.subscribe(destination: thoughtTopic)
        stompClient.subscribe(destination: actionItemsTopic)
        stompClient.subscribe(destination: columnNamesTopic)
        stompClient.subscribe(destination: heartbeatTopic)
    }

    internal func stompClientDidConnect(client: StompClientLibProtocol!) {
        os_log("Connected to websocket.")
        setupSubscriptions()

        heartbeatTimer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(sendHeartbeat),
                userInfo: nil,
                repeats: true
        )
    }

    internal func serverDidSendReceipt(client: StompClientLibProtocol!, withReceiptId receiptId: String) {
        print("Receipt : \(receiptId)")
    }

    internal func serverDidSendError(
            client: StompClientLibProtocol!,
            withErrorMessage description: String,
            detailedErrorMessage message: String?
    ) {
        print("Error : \(String(describing: message))")
    }

    internal func serverDidSendPing() {
        print("Server Ping")
    }
}
