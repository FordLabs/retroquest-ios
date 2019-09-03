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

class ActionItemsService: ItemsService<ActionItem> {
    override func requestItemsFromServer(team: String) -> Bool {
        return requestItemsFromServer(team: team, itemType: "/action-items", callback: super.publishItem)
    }

    override func sort() {
        let uncompletedActionItems: [ActionItem] = items.filter { !$0.completed }
        let completedActionItems: [ActionItem] = items.filter { $0.completed }

        let sortedUncompletedActionItems = uncompletedActionItems.sorted(by: { $0.id < $1.id })
        let sortedCompletedActionItems = completedActionItems.sorted(by: { $0.id < $1.id })
        items = sortedUncompletedActionItems + sortedCompletedActionItems
    }
}
