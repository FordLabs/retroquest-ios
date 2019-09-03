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

class FakeItemsService<T: Item> {

    var dummyItemsMethodCalls: Int = 0
    var dummyItemsReturned: [T]?
    var getItemsCalled: Bool = false

    func fakeRequestItemsFromServer(items: [T], callback: @escaping ([T]?) -> Void) -> Bool {
        getItemsCalled = true

        callback(items)

        return false
    }

    func dummyItemsMethod(items: [T]?) {
        dummyItemsMethodCalls += 1
        dummyItemsReturned = items
    }

    func dummyItemMethod(item: T?) {
        dummyItemsMethodCalls += 1
        if item != nil {
            if dummyItemsReturned == nil {
                dummyItemsReturned = [item!]
            } else {
                dummyItemsReturned!.append(item!)
            }
        }
    }

    func resetDummies() {
        dummyItemsMethodCalls = 0
        dummyItemsReturned = nil
    }

    func getDummyResponse(team: String) -> Data? {
        let exampleDummy = T.init(id: 1000, teamId: team, deletion: false)
        var itemArray: [T] = []

        itemArray.append(exampleDummy)
        let encodedData = try? JSONEncoder().encode(itemArray)

        return encodedData
    }

    func getBlankDummyResponse() -> Data? {
        let emptyItemArray: [T] = []
        let encodedData = try? JSONEncoder().encode(emptyItemArray)

        return encodedData
    }
}
