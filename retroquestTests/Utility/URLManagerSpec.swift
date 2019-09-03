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

@testable import retroquest

class URLManagerSpec: QuickSpec {

    override func spec() {

        describe("Handle various url formats provided for baseurl") {
            let expectedUrl = "http://herp.com/"

            it("should do nothing if baseurl has http:// and ends in a forward slash") {
                URLManager.retroBaseUrl = expectedUrl
                let actualUrl = URLManager.retroBaseUrl
                expect(actualUrl).to(equal(expectedUrl))
            }

            it("should append http:// if baseurl doesn't have it") {
                let providedUrl = "herp.com/"
                URLManager.retroBaseUrl = providedUrl
                let actualUrl = URLManager.retroBaseUrl
                expect(actualUrl).to(equal(expectedUrl))
            }

            it("should append end / to baseurl if not there") {
                var providedUrl = "http://herp.com"
                URLManager.retroBaseUrl = providedUrl
                var actualUrl = URLManager.retroBaseUrl
                expect(actualUrl).to(equal(expectedUrl))

                providedUrl = "http://herp.com/derpage"
                URLManager.retroBaseUrl = providedUrl
                actualUrl = URLManager.retroBaseUrl
                expect(actualUrl).to(equal("\(providedUrl)/"))
            }

            it("should lowercase any capitals") {
                let providedUrl = "herP.com/"
                URLManager.retroBaseUrl = providedUrl
                let actualUrl = URLManager.retroBaseUrl
                expect(actualUrl).to(equal(expectedUrl))
            }
        }

        describe("Getting WS Destinations") {

            let team = "The Avengers"
            beforeEach {
                URLManager.setCurrentTeam(team: team)
            }

            context("Thought messages") {
                it("should return a v2 url for thought deletions") {
                    let thought = Thought(id: 1, teamId: team, deletion: true)
                    let destination = URLManager.getWsDestination(thought, type: .delete)

                    expect(destination).to(equal("/app/v2/the-avengers/thought/delete"))
                }

                it("should return a non-v2 url with no id for thought creation") {
                    let thought = Thought(id: 1, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(thought, type: .create)

                    expect(destination).to(equal("/app/the-avengers/thought/create"))
                }

                it("should return a non-v2 url with an id for thought update") {
                    let thought = Thought(id: 1, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(thought, type: .edit)

                    expect(destination).to(equal("/app/the-avengers/thought/1/edit"))
                }
            }

            context("Action item messages") {
                it("should return a url with no action item id for action item deletions") {
                    let actionItem = ActionItem(id: 1, teamId: team, deletion: true)
                    let destination = URLManager.getWsDestination(actionItem, type: .delete)

                    expect(destination).to(equal("/app/the-avengers/action-item/delete"))
                }

                it("should return a url with no action item id for action item creates") {
                    let actionItem = ActionItem(id: 2, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(actionItem, type: .create)

                    expect(destination).to(equal("/app/the-avengers/action-item/create"))
                }

                it("should return a url with an action item id for action item edits") {
                    let actionItem = ActionItem(id: 2, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(actionItem, type: .edit)

                    expect(destination).to(equal("/app/the-avengers/action-item/2/edit"))
                }
            }

            context("Column messages") {
                it("should return an empty string if trying to create a column title") {
                    let column = Column(id: 3, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(column, type: .create)

                    expect(destination).to(beEmpty())
                }

                it("should return an empty string if trying to delete a column title") {
                    let column = Column(id: 3, teamId: team, deletion: true)
                    let destination = URLManager.getWsDestination(column, type: .delete)

                    expect(destination).to(beEmpty())
                }

                it("should return a url with an column id for column edits") {
                    let column = Column(id: 3, teamId: team, deletion: false)
                    let destination = URLManager.getWsDestination(column, type: .edit)

                    expect(destination).to(equal("/app/the-avengers/column-title/3/edit"))
                }
            }
        }
    }
}
