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

class FakeColumnNameService: ColumnNameService {
    internal var dummyItemsMethodCalls: Int = 0
    internal var dummyItemsReturned: [Column]?
    internal var getItemsCalled: Bool = false

    override init(itemPubSub: PubSub<Column>) {
        super.init(itemPubSub: itemPubSub)

        let cannedItems = [
            Column(id: 88, topic: ColumnName.happy.rawValue, title: "kindaHappy", teamId: "1"),
            Column(id: 89, topic: ColumnName.confused.rawValue, title: "kindaConfused", teamId: "1"),
            Column(id: 90, topic: ColumnName.sad.rawValue, title: "kindaSad", teamId: "1")
        ]
        items = cannedItems
    }

    override func requestItemsFromServer(team: String) -> Bool {
        super.publishItem(items: items)
        return true
    }
}
