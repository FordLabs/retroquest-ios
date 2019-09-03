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

struct ActionItem: Item {
    let description: String = "action-item"
    let id: Int
    let task: String
    let completed: Bool
    let teamId: String
    let assignee: String?
    let dateCreated: String?
    var deletion: Bool?

    init(id: Int, teamId: String, deletion: Bool) {
        self.id = id
        self.task = ""
        self.completed = false
        self.teamId = teamId
        self.assignee = ""
        self.dateCreated = ""
        self.deletion = deletion
    }

    init(id: Int, task: String, completed: Bool, teamId: String, assignee: String?, dateCreated: String?) {
        self.id = id
        self.task = task
        self.completed = completed
        self.teamId = teamId
        self.assignee = assignee
        self.dateCreated = dateCreated
    }

    func copy(id: Int? = nil,
              task: String? = nil,
              completed: Bool? = nil,
              teamId: String? = nil,
              assignee: String? = nil,
              dateCreated: String? = nil
    ) -> ActionItem {
        return ActionItem(
                id: id ?? self.id,
                task: task ?? self.task,
                completed: completed ?? self.completed,
                teamId: teamId ?? self.teamId,
                assignee: assignee ?? self.assignee,
                dateCreated: dateCreated ?? self.dateCreated
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case task
        case completed
        case teamId
        case assignee
        case dateCreated
    }
}
