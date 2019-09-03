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

class FakeActionItemsService: ActionItemsService {
    internal var sortActionItemsCalled = false
    internal var dummyItemsMethodCalls: Int = 0
    internal var dummyItemsReturned: [ActionItem]?
    internal var getItemsCalled: Bool = false

    override init(itemPubSub: PubSub<ActionItem>) {
        super.init(itemPubSub: itemPubSub)

        let cannedItems = [
            ActionItem(id: 0, task: "task1", completed: false, teamId: "1", assignee: "jim", dateCreated: "2018-01-05"),
            ActionItem(id: 1, task: "task2", completed: true, teamId: "1", assignee: "bob", dateCreated: "2018-01-06"),
            ActionItem(id: 2, task: "task3", completed: false, teamId: "1", assignee: nil, dateCreated: nil)
        ]
        items = cannedItems
    }

    override func requestItemsFromServer(team: String) -> Bool {
        getItemsCalled = true
        super.publishItem(items: items)
        return true
    }

    override func sort() {
        sortActionItemsCalled = true
        super.sort()
    }
}
