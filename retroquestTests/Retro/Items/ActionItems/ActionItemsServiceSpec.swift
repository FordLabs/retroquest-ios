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

class ActionItemsServiceSpec: QuickSpec {

    override func spec() {
        let actionItemPubSub = PubSub<ActionItem>()
        let subject = ActionItemsService(itemPubSub: actionItemPubSub)
        let fakeSubject = FakeActionItemsService(itemPubSub: actionItemPubSub)
        let cannedItems = fakeSubject.items

        beforeEach {
            subject.items = cannedItems
        }

        describe("sorting") {
            beforeEach {
                subject.sort()
            }

            it("should have completed action items at the end") {
                expect(self.completedActionItemsAtEnd(actionItems: subject.items)).to(beTrue())
            }

            it("should have action items in order by id") {
                expect(self.completedActionItemsAtEnd(actionItems: subject.items)).to(beTrue())
            }
        }
    }

    private func actionItemsOrderedById(actionItems: [ActionItem]) -> Bool {
        let numActionItems = actionItems.count

        if numActionItems == 0 {
            return true
        }
        var completedSection = actionItems[0].completed
        var currentIdValue = actionItems[0].id
        var currentActionItemIndex = 0

        while currentActionItemIndex < numActionItems {

            if completedSection != actionItems[currentActionItemIndex].completed {
                completedSection = actionItems[currentActionItemIndex].completed
                currentIdValue = actionItems[currentActionItemIndex].id
            }
            if currentIdValue > actionItems[currentActionItemIndex].id {
                return false
            }
            currentIdValue = actionItems[currentActionItemIndex].id
            currentActionItemIndex += 1
        }

        return true
    }

    private func completedActionItemsAtEnd(actionItems: [ActionItem]) -> Bool {
        if actionItems.count == 0 {
            return true
        }

        var inCompletedRegion = false

        for actionItem in actionItems {
            if !inCompletedRegion && actionItem.completed {
                inCompletedRegion = true
            } else if inCompletedRegion && !actionItem.completed {
                return false
            }
        }

        return true
    }
}
