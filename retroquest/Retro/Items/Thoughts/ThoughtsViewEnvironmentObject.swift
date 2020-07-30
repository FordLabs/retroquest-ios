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

import SwiftUI

class ThoughtsViewEnvironmentObject: ItemsViewEnvironmentObject {
    @Published var thoughts: [[Thought]] = [[], [], []]
    @Published var columns: [Column] = []

    @Published var showModal: Bool = false
    @Published var activeItemsViewModal: ActiveItemsViewModal = .none
    @Published var thoughtToEdit: Thought?
    @Published var columnToEdit: Column?

    init(
        thoughts: [[Thought]],
        columns: [Column]
    ) {
        self.thoughts = thoughts
        self.columns = columns
    }

    init() {}
}

protocol ItemsViewEnvironmentObject: ObservableObject {
    var showModal: Bool { get set }
    var activeItemsViewModal: ActiveItemsViewModal { get set }
}

enum ActiveItemsViewModal {
    case editThought,
    editColumnName,
    addItem,
    editActionItemTask,
    editActionItemAssignee,
    none
}
