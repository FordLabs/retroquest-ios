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

class WebSocketServiceSpec: QuickSpec {

    override func spec() {
        let stompClient = FakeStompClientLib()
        let thoughtPubSub = PubSub<Thought>()
        let actionItemPubSub = PubSub<ActionItem>()
        let columnPubSub = PubSub<Column>()
        let fakeNotificationWrapper = FakeNotificationCenterWrapper()
        let subject = WebSocketService(
                stompClient: stompClient,
                thoughtPubSub: thoughtPubSub,
                actionItemPubSub: actionItemPubSub,
                columnPubSub: columnPubSub,
                notificationCenterWrapper: fakeNotificationWrapper
        )
        let fakeSubject = FakeWebSocketService()

        let team = "test_team"

        beforeEach {
            URLManager.setCurrentTeam(team: team)
        }

        describe("ws url") {
            it("should provide wss for https") {
                URLManager.retroBaseUrl = "https://coolurl.com/"
                expect(URLManager.getRetroWSUrl()).to(equal("wss://coolurl.com/websocket/websocket"))
            }

            it("should provide ws for http") {
                URLManager.retroBaseUrl = "http://coolurl.com/"
                expect(URLManager.getRetroWSUrl()).to(equal("ws://coolurl.com/websocket/websocket"))
            }
        }

        describe("attempt to connect to websocket server") {
            beforeEach {
                RetroCookies.clearCookies()
                stompClient.resetDummies()
            }

            context("no token in cookies") {
                it("should not try to connect to ws server") {
                    subject.connectToWebSocketServer()
                    expect(stompClient.openSocketWithURLRequestCalled).to(beFalse())
                }
            }

            context("good token in cookies") {
                beforeEach {
                    let fakeToken = "fakeToken"
                    RetroCookies.setRetroCookie(
                            urlDomain: URLManager.retroBaseUrl,
                            urlPath: URLManager.teamUrlPath + team,
                            name: "token",
                            value: fakeToken)
                }

                it("should try to establish a connection") {
                    subject.connectToWebSocketServer()
                    expect(stompClient.openSocketWithURLRequestCalled).to(beTrue())
                }
            }
        }

        describe("Disconnecting") {
            it("should clean up pub sub subscribers and stop heartbeat timer after stomp session has disconnected") {
                subject.connectToWebSocketServer()

                subject.stompClientDidDisconnect(client: stompClient)

                expect(columnPubSub.outgoingSubscribers).to(beEmpty())
                expect(thoughtPubSub.outgoingSubscribers).to(beEmpty())
                expect(actionItemPubSub.outgoingSubscribers).to(beEmpty())
                expect(subject.heartbeatTimer.isValid).to(beFalse())
            }
        }

        describe("making subscriptions") {
            beforeEach {
                stompClient.resetDummies()
            }

            context("on successful connection") {
                it("should subscribe to thoughts/action items/column titles") {
                    subject.stompClientDidConnect(client: stompClient)
                    let expectedSubscriptions = [
                        "/topic/\(team)/thoughts",
                        "/topic/\(team)/action-items",
                        "/topic/\(team)/column-titles",
                        "/topic/heartbeat/pong"
                    ]
                    expect(stompClient.subscriptions).to(equal(expectedSubscriptions))
                }

                it("should convert team names with spaces to dashes") {
                    let teamWithSpaces = "with spaces"
                    let teamWithDashes = "with-spaces"
                    URLManager.setCurrentTeam(team: teamWithSpaces)

                    subject.stompClientDidConnect(client: stompClient)
                    let expectedSubscriptions = [
                        "/topic/\(teamWithDashes)/thoughts",
                        "/topic/\(teamWithDashes)/action-items",
                        "/topic/\(teamWithDashes)/column-titles",
                        "/topic/heartbeat/pong"
                    ]
                    expect(stompClient.subscriptions).to(equal(expectedSubscriptions))
                }

                it("should convert team names with upper case letters to lower case") {
                    let teamWithUpperCase = "UpperCase"
                    let teamWithLowerCase = "uppercase"
                    URLManager.setCurrentTeam(team: teamWithUpperCase)

                    subject.stompClientDidConnect(client: stompClient)
                    let expectedSubscriptions = [
                        "/topic/\(teamWithLowerCase)/thoughts",
                        "/topic/\(teamWithLowerCase)/action-items",
                        "/topic/\(teamWithLowerCase)/column-titles",
                        "/topic/heartbeat/pong"
                    ]
                    expect(stompClient.subscriptions).to(equal(expectedSubscriptions))
                }

                context("heartbeat") {
                    it("should send periodic heartbeat ws messages") {
                        subject.sendHeartbeat()

                        expect(stompClient.sendMessageCalledWithDestination).to(equal("/app/heartbeat/ping"))
                        expect(stompClient.sendMessageCalledWithMessage).to(equal(""))
                    }
                }
            }
        }

        describe("Receiving messages") {
            beforeEach {
                stompClient.resetDummies()
                subject.thoughtPubSub.clearAllSubscribers()
                subject.actionItemPubSub.clearAllSubscribers()
                subject.columnPubSub.clearAllSubscribers()
                subject.stompClientDidConnect(client: stompClient)
            }

            context("Received a Thought update") {
                it("should parse that response into a thought and publish it via the thought pubsub") {
                    let expectedThought = Thought(
                            id: 8,
                            message: "hi",
                            hearts: 12,
                            topic: ColumnName.happy.rawValue,
                            discussed: false,
                            teamId: team
                    )
                    let thoughtJSONResponseString = self.createJSONWebSocketResponseString(
                            type: .put,
                            item: expectedThought
                    )
                    let thoughtJSONObject = self.dictForJSONString(jsonStr: thoughtJSONResponseString)

                    subject.thoughtPubSub.addIncomingSubscriber(fakeSubject.thoughtsCallback)
                    subject.stompClient(
                            client: subject.stompClient,
                            didReceiveMessageWithJSONBody: thoughtJSONObject,
                            akaStringBody: thoughtJSONResponseString,
                            withHeader: [:],
                            withDestination: "/topic/\(team)/thoughts"
                    )
                    expect(fakeSubject.thoughtResponse!).to(equal(expectedThought))
                }
            }

            context("Received an Action Item update") {
                it("should parse that response into an action item and publish it via the action item pubsub") {
                    let expectedActionItem = ActionItem(
                            id: 5,
                            task: "do stuff",
                            completed: false,
                            teamId: team,
                            assignee: "swift developer",
                            dateCreated: "2018-01-01"
                    )
                    let actionItemJSONResponseString = self.createJSONWebSocketResponseString(
                            type: .put,
                            item: expectedActionItem
                    )
                    let actionItemJSONObject = self.dictForJSONString(jsonStr: actionItemJSONResponseString)

                    subject.actionItemPubSub.addIncomingSubscriber(fakeSubject.actionItemCallback)
                    subject.stompClient(
                            client: subject.stompClient,
                            didReceiveMessageWithJSONBody: actionItemJSONObject,
                            akaStringBody: actionItemJSONResponseString,
                            withHeader: [:],
                            withDestination: "/topic/\(team)/action-items"
                    )
                    expect(fakeSubject.actionItemResponse!).to(equal(expectedActionItem))
                }
            }

            context("Received a column name update") {
                it("should parse that response into a column and publish it via the column pubsub") {
                    let expectedColumn = Column(
                            id: 5,
                            topic: ColumnName.happy.rawValue,
                            title: "Slappy",
                            teamId: team
                    )
                    let columnJSONResponseString = self.createJSONWebSocketResponseString(
                            type: .put,
                            item: expectedColumn
                    )
                    let columnJSONObject = self.dictForJSONString(jsonStr: columnJSONResponseString)

                    subject.columnPubSub.addIncomingSubscriber(fakeSubject.columnCallback)
                    subject.stompClient(
                            client: subject.stompClient,
                            didReceiveMessageWithJSONBody: columnJSONObject,
                            akaStringBody: columnJSONResponseString,
                            withHeader: [:],
                            withDestination: "/topic/\(team)/column-titles"
                    )
                    expect(fakeSubject.columnResponse!).to(equal(expectedColumn))
                }
            }

            context("Received a delete update for thought") {
                it("should parse that response and publish it via the thoughts pubsub") {
                    let thoughtToDelete = Thought(
                        id: 8,
                        message: "hi",
                        hearts: 12,
                        topic: ColumnName.happy.rawValue,
                        discussed: false,
                        teamId: team
                    )
                    let deletionJSONResponseString = self.createJSONWebSocketResponseString(
                            type: .delete,
                            item: thoughtToDelete
                    )
                    let deletionJSONObject = self.dictForJSONString(jsonStr: deletionJSONResponseString)

                    subject.thoughtPubSub.addIncomingSubscriber(fakeSubject.thoughtsCallback)
                    subject.stompClient(
                            client: subject.stompClient,
                            didReceiveMessageWithJSONBody: deletionJSONObject,
                            akaStringBody: deletionJSONResponseString,
                            withHeader: [:],
                            withDestination: "/topic/\(team)/thoughts"
                    )
                    let expectedDeletionThought = Thought(
                            id: thoughtToDelete.id,
                            teamId: team,
                            deletion: true
                    )
                    expect(fakeSubject.thoughtResponse!).to(equal(expectedDeletionThought))
                }
            }
        }

        describe("sending messages") {
            context("spaces in the team name") {
                it("should convert the spaces to dashes") {
                    URLManager.setCurrentTeam(team: "with spaces")
                    subject.thoughtPubSub.addOutgoingSubscriber(subject.sendMessage)

                    let expectedId = "83"
                    let expectedJSONMessage = "{\"id\":\(expectedId),\"message\":\"fdsa\",\"hearts\":2,\"topic\":\"happy\",\"discussed\":false,\"teamId\":\"a\"}"
                    let messageAsData = expectedJSONMessage.data(using: .utf8)!
                    let sampleThought: Thought? = try? JSONDecoder().decode(Thought.self, from: messageAsData)

                    subject.thoughtPubSub.publishOutgoing(sampleThought, outgoingType: .edit)

                    let expectedDestination = "/app/with-spaces/thought/\(expectedId)/edit"
                    expect(stompClient.sendMessageCalledWithDestination).to(equal(expectedDestination))
                }
            }

            context("websocketservice receives an outgoing thought") {
                it("should call send on stomp client for edit") {
                    subject.thoughtPubSub.addOutgoingSubscriber(subject.sendMessage)

                    let expectedId = "83"
                    let expectedJSONMessage = "{\"id\":\(expectedId),\"message\":\"fdsa\",\"hearts\":2,\"topic\":\"happy\",\"discussed\":false,\"teamId\":\"a\"}"
                    let messageAsData = expectedJSONMessage.data(using: .utf8)!
                    let sampleThought: Thought? = try? JSONDecoder().decode(Thought.self, from: messageAsData)

                    subject.thoughtPubSub.publishOutgoing(sampleThought, outgoingType: .edit)

                    let actualJSONMessage: String = stompClient.sendMessageCalledWithMessage!
                    expect(actualJSONMessage).to(equal(expectedJSONMessage))

                    let expectedDestination = "/app/\(team)/thought/\(expectedId)/edit"
                    expect(stompClient.sendMessageCalledWithDestination).to(equal(expectedDestination))
                }
            }

            context("websocketservice receives an outgoing action item") {
                it("should call send on stomp client for edit") {
                    subject.actionItemPubSub.addOutgoingSubscriber(subject.sendMessage)

                    let expectedId = "83"
                    let expectedJSONMessage = "{\"id\":\(expectedId),\"teamId\":\"a\",\"task\":\"herp?\",\"completed\":false,\"dateCreated\":\"2019-01-23\",\"assignee\":\"ssss\"}"
                    let messageAsData = expectedJSONMessage.data(using: .utf8)!
                    let sampleActionItem: ActionItem? = try? JSONDecoder().decode(ActionItem.self, from: messageAsData)

                    subject.actionItemPubSub.publishOutgoing(sampleActionItem, outgoingType: .edit)

                    let actualJSONMessage: String = stompClient.sendMessageCalledWithMessage!
                    expect(actualJSONMessage).to(equal(expectedJSONMessage))

                    let expectedDestination = "/app/\(team)/action-item/\(expectedId)/edit"
                    expect(stompClient.sendMessageCalledWithDestination).to(equal(expectedDestination))
                }
            }

            context("websocketservice receives an outgoing column name") {
                it("should call send on stomp client for edit") {
                    subject.columnPubSub.addOutgoingSubscriber(subject.sendMessage)

                    let expectedId = "2"
                    let expectedJSONMessage = "{\"id\":\(expectedId),\"title\":\"gulp?\",\"topic\":\"confused\",\"teamId\":\"a\"}"
                    let messageAsData = expectedJSONMessage.data(using: .utf8)!
                    let sampleColumn: Column? = try? JSONDecoder().decode(Column.self, from: messageAsData)

                    subject.columnPubSub.publishOutgoing(sampleColumn, outgoingType: .edit)

                    let actualJSONMessage: String = stompClient.sendMessageCalledWithMessage!
                    expect(actualJSONMessage).to(equal(expectedJSONMessage))

                    let expectedDestination = "/app/\(team)/column-title/2/edit"
                    expect(stompClient.sendMessageCalledWithDestination).to(equal(expectedDestination))
                }
            }

            context("creating a new thought") {
                it("should call send on stomp client for create") {
                    subject.thoughtPubSub.addOutgoingSubscriber(subject.sendMessage)

                    let expectedId = -1
                    let expectedJSONMessage = "{\"id\":\(expectedId),\"message\":\"fdsa\",\"hearts\":2,\"topic\":\"happy\",\"discussed\":false,\"teamId\":\"a\"}"
                    let messageAsData = expectedJSONMessage.data(using: .utf8)!
                    let sampleThought: Thought? = try? JSONDecoder().decode(Thought.self, from: messageAsData)

                    subject.thoughtPubSub.publishOutgoing(sampleThought, outgoingType: .create)

                    let actualJSONMessage: String = stompClient.sendMessageCalledWithMessage!
                    expect(actualJSONMessage).to(equal(expectedJSONMessage))

                    let expectedDestination = "/app/\(team)/thought/create"
                    expect(stompClient.sendMessageCalledWithDestination).to(equal(expectedDestination))
                }
            }
        }
    }

    private func createJSONWebSocketResponseString<T: Codable>(type: IncomingType, item: T) -> String {
        let jsonItemData = try? JSONEncoder().encode(item)
        let jsonItemString = String(data: jsonItemData!, encoding: .utf8)!

        return createJSONWebSocketResponseString(type: type, jsonString: jsonItemString)
    }

    private func createJSONWebSocketResponseString(type: IncomingType, jsonString: String) -> String {
        return "{\"type\":\"\(type.rawValue)\",\"payload\":\(jsonString)}"
    }

    private func dictForJSONString(jsonStr: String?) -> AnyObject? {
        if let jsonStr = jsonStr {
            do {
                if let data = jsonStr.data(using: String.Encoding.utf8) {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    return json as AnyObject
                }
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
        return nil
    }
}
