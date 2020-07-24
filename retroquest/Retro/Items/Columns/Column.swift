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

struct Column: Item {
    let description: String = "column-title"
    let id: Int
    let topic: String
    let title: String
    let teamId: String
    let deletion: Bool? = nil

    init(id: Int, teamId: String, deletion: Bool) {
        self.id = id
        self.topic = ""
        self.title = ""
        self.teamId = teamId
    }

    init(id: Int, topic: String, title: String, teamId: String) {
        self.id = id
        self.topic = topic
        self.title = title
        self.teamId = teamId
    }

    func copy(id: Int? = nil,
              topic: String? = nil,
              title: String? = nil,
              teamId: String? = nil
    ) -> Column {
        return Column(
                id: id ?? self.id,
                topic: topic ?? self.topic,
                title: title ?? self.title,
                teamId: teamId ?? self.teamId
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case topic
        case title
        case teamId
    }
}
