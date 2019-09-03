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

class FakeThoughtsService: ThoughtsService {
    internal var sortThoughtsCalled = false
    internal var dummyItemsMethodCalls: Int = 0
    internal var dummyItemsReturned: [Thought]?
    internal var getItemsCalled: Bool = false

    override init(itemPubSub: PubSub<Thought>) {
        super.init(itemPubSub: itemPubSub)

        let cannedItems = [
            Thought(
                    id: 0,
                    message: "message1",
                    hearts: 1,
                    topic: ColumnName.happy.rawValue,
                    discussed: false,
                    teamId: "1"
            ),
            Thought(
                    id: 1,
                    message: "message2",
                    hearts: 2,
                    topic: ColumnName.sad.rawValue,
                    discussed: true,
                    teamId: "1"
            ),
            Thought(
                    id: 2,
                    message: "message3",
                    hearts: 3,
                    topic: ColumnName.confused.rawValue,
                    discussed: false,
                    teamId: "1"
            ),
            Thought(
                    id: 3,
                    message: "message4",
                    hearts: 4,
                    topic: ColumnName.happy.rawValue,
                    discussed: true,
                    teamId: "1"
            ),
            Thought(
                    id: 4,
                    message: "message5",
                    hearts: 5,
                    topic: ColumnName.happy.rawValue,
                    discussed: false,
                    teamId: "1"
            )
        ]
        items = cannedItems
    }

    override func requestItemsFromServer(team: String) -> Bool {
        getItemsCalled = true
        super.publishItem(items: items)
        return true
    }

    override func sort() {
        sortThoughtsCalled = true
        super.sort()
    }
}
