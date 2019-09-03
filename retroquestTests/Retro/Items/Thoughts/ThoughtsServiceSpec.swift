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

class ThoughtsServiceSpec: QuickSpec {

    override func spec() {
        let thoughtPubSub = PubSub<Thought>()
        let subject = ThoughtsService(itemPubSub: thoughtPubSub)
        let fakeSubject = FakeThoughtsService(itemPubSub: thoughtPubSub)
        let cannedItems = fakeSubject.items

        beforeEach {
            subject.items = cannedItems
        }

        describe("getting thoughts of a specific topic") {
            context("when providing a topic name") {
                it("should return the corresponding topics ") {
                    var expectedHappyThoughts: [Thought] = []
                    expectedHappyThoughts.append(cannedItems[0])
                    expectedHappyThoughts.append(cannedItems[3])
                    expectedHappyThoughts.append(cannedItems[4])

                    let actualHappyThoughts = subject.getThoughtsOfTopic(ColumnName.happy)
                    expect(actualHappyThoughts).to(contain(expectedHappyThoughts))

                    var expectedConfusedThoughts: [Thought] = []
                    expectedConfusedThoughts.append(cannedItems[2])

                    let confusedThoughts = subject.getThoughtsOfTopic(ColumnName.confused)
                    expect(confusedThoughts).to(contain(expectedConfusedThoughts))

                    var expectedSadThoughts: [Thought] = []
                    expectedSadThoughts.append(cannedItems[1])

                    let sadThoughts = subject.getThoughtsOfTopic(ColumnName.sad)
                    expect(sadThoughts).to(contain(expectedSadThoughts))
                }
            }

            context("want the count") {
                it("should return number of thoughts of a specific topic") {
                    let expectedNumberOfHappyThoughts = 3
                    let actualNumberOfHappyThoughts = subject.getNumberOfThoughtsOfTopic(ColumnName.happy)
                    expect(actualNumberOfHappyThoughts).to(equal(expectedNumberOfHappyThoughts))
                }
            }
        }

        describe("getting a thought with a specific id") {
            context("when I call getThought with a specific id") {
                it("will return me that thought") {
                    let expectedThought = cannedItems[4]

                    let actualThought = subject.getThoughtById(expectedThought.id)
                    expect(actualThought).to(equal(expectedThought))
                }
            }
        }

        describe("sorting thoughts") {
            beforeEach {
                subject.sort()
            }

            it("will sort the thoughts in the expected topic order") {
                expect(self.isThoughtsArraySortedByTopic(thoughts: subject.items)).to(beTrue())
            }

            it("will sort the thoughts with discussed ones at the end") {
                expect(self.discussedThoughtsAtEndOfEachTopicGrouping(thoughts: subject.items)).to(beTrue())
            }

            it("will sort the thoughts by id within each topic") {
                expect(self.thoughtsOrderedByIdForEachTopic(thoughts: subject.items)).to(beTrue())
            }
        }
    }

    private func isThoughtsArraySortedByTopic(thoughts: [Thought]) -> Bool {
        let expectedTopicOrder: [String] = ColumnNameService.displayOrderForTopics.map { $0.rawValue }
        let numThoughts = thoughts.count

        var currentExpectedTopicIndex = 0
        var currentThoughtIndex = 0

        while currentThoughtIndex < numThoughts {
            let currentThoughtTopic = thoughts[currentThoughtIndex].topic
            let indexOfCurrentTopicInExpectedTopicOrder = expectedTopicOrder.firstIndex(of: currentThoughtTopic)!

            if indexOfCurrentTopicInExpectedTopicOrder == currentExpectedTopicIndex {
                currentThoughtIndex += 1
                continue
            } else if indexOfCurrentTopicInExpectedTopicOrder < currentExpectedTopicIndex {
                return false
            } else {
                currentExpectedTopicIndex += 1
            }
        }

        return true
    }

    private func thoughtsOrderedByIdForEachTopic(thoughts: [Thought]) -> Bool {
        let numThoughts = thoughts.count

        if numThoughts == 0 {
            return true
        }
        var currentThoughtTopic = thoughts[0].topic
        var discussedSection = thoughts[0].discussed
        var currentIdValue = thoughts[0].id
        var currentThoughtIndex = 0

        while currentThoughtIndex < numThoughts {

            if discussedSection != thoughts[currentThoughtIndex].discussed {
                discussedSection = thoughts[currentThoughtIndex].discussed
                currentIdValue = thoughts[currentThoughtIndex].id
            }
            if currentThoughtTopic != thoughts[currentThoughtIndex].topic {
                currentThoughtTopic = thoughts[currentThoughtIndex].topic
                currentIdValue = thoughts[currentThoughtIndex].id
            }
            if currentIdValue > thoughts[currentThoughtIndex].id {
                return false
            }
            currentIdValue = thoughts[currentThoughtIndex].id
            currentThoughtIndex += 1
        }

        return true
    }

    private func discussedThoughtsAtEndOfEachTopicGrouping(thoughts: [Thought]) -> Bool {
        // this check is assuming everything is grouped together already
        let numThoughts = thoughts.count
        if numThoughts == 0 {
            return true
        }
        var currentTopic = thoughts[0].topic

        var currentThoughtIndex = 0
        var inDiscussedRegion = false

        while currentThoughtIndex < numThoughts {
            let currentThought = thoughts[currentThoughtIndex]

            if currentTopic == currentThought.topic {
                if !inDiscussedRegion && currentThought.discussed {
                    inDiscussedRegion = true
                } else if inDiscussedRegion && !currentThought.discussed {
                    return false
                }
            } else {
                currentTopic = currentThought.topic
                inDiscussedRegion = currentThought.discussed
            }
            currentThoughtIndex += 1
        }

        return true
    }
}
