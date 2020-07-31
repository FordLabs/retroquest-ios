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

import UIKit
import SwiftUI

class ThoughtsViewController: UIViewController {

    internal var columnNameService: ColumnNameService!
    internal var thoughtsService: ThoughtsService!
    internal var thoughtsViewEnvironmentObject = ThoughtsViewEnvironmentObject()

    convenience init(thoughtsService: ThoughtsService, columnNameService: ColumnNameService) {
        self.init()

        self.thoughtsService = thoughtsService
        self.columnNameService = columnNameService
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Thoughts"

        self.thoughtsService.registerItemCallback(thoughtCallback)
        self.columnNameService.registerItemCallback(columnNamesCallback)
        self.getThoughtsAndColumns()

        let thoughtsViewSwiftUI: some View = ThoughtsView(teamName: URLManager.currentTeam)
            .environmentObject(self.thoughtsViewEnvironmentObject)
            .environmentObject(self.thoughtsService.itemPubSub)
            .environmentObject(self.columnNameService.itemPubSub)
        let hostingController = UIHostingController(rootView: thoughtsViewSwiftUI)
        addChild(hostingController)
        let thoughtsView = hostingController.view!
        view.addSubview(thoughtsView)
        _ = thoughtsView.anchorEdgesToSuperView()
    }

    func refreshData() {
        self.thoughtsService.clear()
        self.getThoughtsAndColumns()
    }

    private func getThoughtsAndColumns() {
        _ = self.thoughtsService.requestItemsFromServer(team: URLManager.currentTeam)
        _ = self.columnNameService.requestItemsFromServer(team: URLManager.currentTeam)
    }

    private func thoughtCallback(thought: Thought?) {
        if var thought = thought {
            if thought.deletion ?? false {
                do {
                    thought = try self.thoughtsService.delete(thought)!
                } catch {
                    print("Attempted to delete non-existent thought with id \(thought.id)")
                    return
                }
            } else {
                _ = self.thoughtsService.addOrReplace(thought)
                self.thoughtsService.sort()
            }

            let columnName: ColumnName = self.columnNameService.getColumnName(thought.topic)
            if let columnIndex = ColumnNameService.displayOrderForTopics.firstIndex(of: columnName) {
                let thoughtsOfTopic = self.thoughtsService.getThoughtsOfTopic(columnName)
                self.thoughtsViewEnvironmentObject.thoughts[columnIndex] = thoughtsOfTopic
            }
        }
    }

    private func columnNamesCallback(column: Column?) {
        if let column = column {
            _ = self.columnNameService.addOrReplace(column)
            self.thoughtsViewEnvironmentObject.columns = self.columnNameService.items
        }
    }
}
