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
import Hippolyte
import UIKit

@testable import retroquest

class ItemsServiceSpec: QuickSpec {
    let team = "test_team"

    override func spec() {
        let thoughtPubSub = PubSub<Thought>()
        spec(ThoughtsService(itemPubSub: thoughtPubSub), endpoint: "/thoughts")

        let actionItemPubSub = PubSub<ActionItem>()
        spec(ActionItemsService(itemPubSub: actionItemPubSub), endpoint: "/action-items")

        let columnPubSub = PubSub<Column>()
        spec(ColumnNameService(itemPubSub: columnPubSub), endpoint: "/columns")
    }

    func spec<T: Item>(_ subject: ItemsService<T>, endpoint: String) {
        let fakeSubject = FakeItemsService<T>()
        let sampleData = fakeSubject.getDummyResponse(team: team)
        let endpointUrl = URL(string: URLManager.getFullTeamPath(team: self.team) + endpoint)!

        describe("querying for \(endpoint) with cookie issues") {
            beforeEach {
                RetroCookies.clearCookies()
                fakeSubject.resetDummies()
            }

            context("no cookies for this team") {
                it("should return false and not call our callback") {
                    let itemsReturned = subject.requestItemsFromServer(team: self.team)

                    expect(itemsReturned).to(beFalse())
                    expect(fakeSubject.dummyItemsMethodCalls).to(equal(0))
                }
            }
        }

        describe("querying for \(endpoint) with good cookie") {
            let fakeToken = "fakeToken"
            subject.itemPubSub.clearAllSubscribers()
            subject.itemPubSub.addIncomingSubscriber(fakeSubject.dummyItemMethod)

            beforeEach {
                RetroCookies.clearCookies()
                RetroCookies.setRetroCookie(
                        urlDomain: URLManager.retroBaseUrl,
                        urlPath: URLManager.teamUrlPath + self.team,
                        name: "token",
                        value: fakeToken)

                fakeSubject.resetDummies()
            }

            describe("weird team names") {
                context("spaces in team name") {
                    let spacedTeam = "get it"

                    beforeEach {
                        let dashedURL = URL(string: URLManager.getFullTeamPath(team: "get-it") + endpoint)!
                        RetroCookies.setRetroCookie(
                                urlDomain: URLManager.retroBaseUrl,
                                urlPath: URLManager.teamUrlPath + spacedTeam,
                                name: "token",
                                value: fakeToken
                        )

                        let thoughtsResponse = StubResponse.Builder()
                                .stubResponse(withStatusCode: 200)
                                .build()
                        let thoughtsRequest = StubRequest.Builder()
                                .stubRequest(withMethod: .GET, url: dashedURL)
                                .addResponse(thoughtsResponse)
                                .build()
                        Hippolyte.shared.add(stubbedRequest: thoughtsRequest)
                        Hippolyte.shared.start()
                    }

                    it("should make convert those spaces to dashes when submitting http request") {
                        let thoughtsReturned = subject.requestItemsFromServer(team: spacedTeam)

                        expect(thoughtsReturned).to(beTrue())
                        expect(fakeSubject.dummyItemsMethodCalls).toEventually(equal(1))
                    }

                    afterEach {
                        Hippolyte.shared.stop()
                    }
                }

                context("upper cased letters in team name") {
                    let upperCasedTeam = "GetIt"

                    beforeEach {
                        let lowercasedURL = URL(string: URLManager.getFullTeamPath(team: "getit") + endpoint)!
                        RetroCookies.setRetroCookie(
                                urlDomain: URLManager.retroBaseUrl,
                                urlPath: URLManager.teamUrlPath + upperCasedTeam,
                                name: "token",
                                value: fakeToken
                        )

                        let thoughtsResponse = StubResponse.Builder()
                                .stubResponse(withStatusCode: 200)
                                .build()
                        let thoughtsRequest = StubRequest.Builder()
                                .stubRequest(withMethod: .GET, url: lowercasedURL)
                                .addResponse(thoughtsResponse)
                                .build()

                        Hippolyte.shared.add(stubbedRequest: thoughtsRequest)
                        Hippolyte.shared.start()
                    }

                    it("should make convert those spaces to dashes when submitting http request") {
                        let thoughtsReturned = subject.requestItemsFromServer(team: upperCasedTeam)

                        expect(thoughtsReturned).to(beTrue())
                        expect(fakeSubject.dummyItemsMethodCalls).toEventually(equal(1))
                    }

                    afterEach {
                        Hippolyte.shared.stop()
                    }
                }
            }

            context("no items") {
                beforeEach {
                    guard let blankThoughts = fakeSubject.getBlankDummyResponse() else {
                        assert(false)
                    }

                    let thoughtsResponse = StubResponse.Builder()
                            .stubResponse(withStatusCode: 200)
                            .addBody(blankThoughts)
                            .build()
                    let thoughtsRequest = StubRequest.Builder()
                            .stubRequest(withMethod: .GET, url: endpointUrl)
                            .addResponse(thoughtsResponse)
                            .build()

                    Hippolyte.shared.add(stubbedRequest: thoughtsRequest)
                    Hippolyte.shared.start()
                }

                it("should return true and call our dummy method with no items") {
                    let thoughtsReturned = subject.requestItemsFromServer(team: self.team)

                    expect(thoughtsReturned).to(beTrue())
                    expect(fakeSubject.dummyItemsMethodCalls).toEventually(equal(1))
                    expect(fakeSubject.dummyItemsReturned).toEventually(beNil())
                }

                afterEach {
                    Hippolyte.shared.stop()
                }
            }

            context("some items") {
                beforeEach {
                    guard let responseData = sampleData else {
                        assert(false)
                    }

                    let response = StubResponse.Builder()
                            .stubResponse(withStatusCode: 200)
                            .addBody(responseData)
                            .build()
                    let request = StubRequest.Builder()
                            .stubRequest(withMethod: .GET, url: endpointUrl)
                            .addResponse(response)
                            .build()
                    Hippolyte.shared.add(stubbedRequest: request)
                    Hippolyte.shared.start()
                }

                it("should return true and call our dummy method with some items") {
                    let thoughtsReturned = subject.requestItemsFromServer(team: self.team)

                    expect(thoughtsReturned).to(beTrue())
                    expect(fakeSubject.dummyItemsMethodCalls).toEventually(beGreaterThan(0))
                    expect(fakeSubject.dummyItemsReturned).toEventuallyNot(beNil())
                }

                afterEach {
                    Hippolyte.shared.stop()
                }
            }

            context("bad response from server") {
                beforeEach {
                    let response = StubResponse.Builder()
                            .stubResponse(withStatusCode: 400)
                            .build()
                    let request = StubRequest.Builder()
                            .stubRequest(withMethod: .GET, url: endpointUrl)
                            .addResponse(response)
                            .build()
                    Hippolyte.shared.add(stubbedRequest: request)
                    Hippolyte.shared.start()
                }

                it("should return true and call our dummy method with some items") {
                    let thoughtsReturned = subject.requestItemsFromServer(team: self.team)

                    expect(thoughtsReturned).to(beTrue())
                    expect(fakeSubject.dummyItemsMethodCalls).toEventually(equal(1))
                    expect(fakeSubject.dummyItemsReturned).toEventually(beNil())
                }

                afterEach {
                    Hippolyte.shared.stop()
                }
            }
        }

        describe("adding/replacing \(endpoint)") {
            it("addOrReplace should add a new item and return true") {
                let oldItem = T(id: 0, teamId: "1", deletion: false)
                let newItem = T(id: 1, teamId: "1", deletion: false)
                subject.items = [oldItem]

                let added = subject.addOrReplace(newItem)

                expect(added).to(beTrue())
                expect(subject.items.count).to(equal(2))
            }

            it("addOrReplace should update an existing item and return false") {
                let oldItem = T(id: 0, teamId: "1", deletion: false)
                let updatedItem = T(id: 0, teamId: "1", deletion: false)
                subject.items = [oldItem]

                let added = subject.addOrReplace(updatedItem)

                expect(added).to(beFalse())
                expect(subject.items.count).to(equal(1))
            }
        }

        describe("deleting \(endpoint)") {
            it("delete should remove an item and return it") {
                let oldItem = T(id: 0, teamId: "1", deletion: false)
                subject.items = [oldItem]

                do {
                    let expectedItem = try subject.delete(oldItem)
                    expect(expectedItem).to(equal(oldItem))
                } catch {
                    assert(false)
                }

                expect(subject.items.count).to(equal(0))
            }

            it("delete should throw an exception if item to delete is not found") {
                let oldItem = T(id: 0, teamId: "1", deletion: false)
                let nonExistentItem = T(id: 1, teamId: "1", deletion: true)
                subject.items = [oldItem]

                do {
                    _ =  try subject.delete(nonExistentItem)
                    assert(false)
                } catch {
                    assert(true)
                }
            }
        }
    }
}
