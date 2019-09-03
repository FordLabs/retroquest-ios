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

class ThoughtsService: ItemsService<Thought> {
    override func requestItemsFromServer(team: String) -> Bool {
        return requestItemsFromServer(team: team, itemType: "/thoughts", callback: super.publishItem)
    }

    func getThoughtById(_ id: Int) -> Thought? {
        let item = items.filter { $0.id == id }
        return item.count > 0 ? item.first : nil
    }

    override func sort() {
        let happyThoughts = getThoughtsOfTopic(ColumnName.happy)
        let confusedThoughts = getThoughtsOfTopic(ColumnName.confused)
        let sadThoughts = getThoughtsOfTopic(ColumnName.sad)

        items = happyThoughts + confusedThoughts + sadThoughts
    }

    func getThoughtsOfTopic(_ topic: ColumnName) -> [Thought] {
        let topicName = topic.rawValue
        let unDiscussedThoughtsOfThisTopic: [Thought] = items.filter { currentThought in
            currentThought.topic == topicName && !currentThought.discussed
        }

        let discussedThoughtsOfThisTopic: [Thought] = items.filter { currentThought in
            currentThought.topic == topicName && currentThought.discussed
        }

        let sortedUnDiscussedThoughts = unDiscussedThoughtsOfThisTopic.sorted(by: { $0.id < $1.id })
        let sortedDiscussedThoughts = discussedThoughtsOfThisTopic.sorted(by: { $0.id < $1.id })
        return sortedUnDiscussedThoughts + sortedDiscussedThoughts
    }

    func getNumberOfThoughtsOfTopic(_ topic: ColumnName) -> Int {
        let topicName = topic.rawValue
        return items.filter { $0.topic == topicName }.count
    }
}
