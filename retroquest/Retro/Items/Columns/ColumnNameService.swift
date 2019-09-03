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

class ColumnNameService: ItemsService<Column> {
    static let displayOrderForTopics = [ColumnName.happy, ColumnName.confused, ColumnName.sad]

    override func requestItemsFromServer(team: String) -> Bool {
        return requestItemsFromServer(team: team, itemType: "/columns", callback: super.publishItem)
    }

    func getColumnTitle(_ columnName: ColumnName) -> String {
        let topicString = columnName.rawValue
        let topic = items.filter { $0.topic == topicString }.first
        return topic?.title ?? ""
    }

    func getColumnName(_ topic: String) -> ColumnName {
        return ColumnName(rawValue: topic)!
    }
}
