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

struct Thought: Item {
    let description: String = "thought"
    let id: Int
    let message: String
    let hearts: Int
    let topic: String
    let discussed: Bool
    let teamId: String
    var deletion: Bool?

    init(id: Int, teamId: String, deletion: Bool) {
        self.id = id
        self.message = ""
        self.hearts = 0
        self.topic = ""
        self.discussed = false
        self.teamId = teamId
        self.deletion = deletion
    }

    init(id: Int, message: String, hearts: Int, topic: String, discussed: Bool, teamId: String) {
        self.id = id
        self.message = message
        self.hearts = hearts
        self.topic = topic
        self.discussed = discussed
        self.teamId = teamId
    }

    func copy(id: Int? = nil,
              message: String? = nil,
              hearts: Int? = nil,
              topic: String? = nil,
              discussed: Bool? = nil,
              teamId: String? = nil
    ) -> Thought {
        return Thought(
                id: id ?? self.id,
                message: message ?? self.message,
                hearts: hearts ?? self.hearts,
                topic: topic ?? self.topic,
                discussed: discussed ?? self.discussed,
                teamId: teamId ?? self.teamId
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case message
        case hearts
        case topic
        case discussed
        case teamId
    }
}
