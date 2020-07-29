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
import AppCenterAnalytics

class ThoughtsViewController: UIViewController {

    internal var columnNameService: ColumnNameService!
    internal var thoughtsService: ThoughtsService!
    internal var itemsSwiftUI: ItemsSwiftUI = ItemsSwiftUI(thoughts: [[], [], []], columns: [])

    convenience init(thoughtsService: ThoughtsService, columnNameService: ColumnNameService) {
        self.init()

        self.thoughtsService = thoughtsService
        self.columnNameService = columnNameService
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Thoughts"

        thoughtsService.registerItemCallback(thoughtCallback)
        columnNameService.registerItemCallback(columnNamesCallback)
        getThoughtsAndColumns()

        let thoughtsViewSwiftUI: some View = ThoughtsSwiftUIView(teamName: URLManager.currentTeam)
            .environmentObject(itemsSwiftUI)
            .environmentObject(thoughtsService.itemPubSub)
            .environmentObject(columnNameService.itemPubSub)
        let hostingController = UIHostingController(rootView: thoughtsViewSwiftUI)
        addChild(hostingController)
        let thoughtsView = hostingController.view!
        view.addSubview(thoughtsView)
        _ = thoughtsView.anchorEdgesToSuperView()
    }

    func getThoughtsAndColumns() {
        _ = thoughtsService.requestItemsFromServer(team: URLManager.currentTeam)
        _ = columnNameService.requestItemsFromServer(team: URLManager.currentTeam)
    }

    private func columnNamesCallback(column: Column?) {
        if let column = column {
            _ = columnNameService.addOrReplace(column)
            itemsSwiftUI.columns = columnNameService.items
        }
    }

    func refreshData() {
        thoughtsService.clear()
        getThoughtsAndColumns()
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
            let thoughts: [[Thought]] = [
                thoughtsService.getThoughtsOfTopic(.happy),
                thoughtsService.getThoughtsOfTopic(.confused),
                thoughtsService.getThoughtsOfTopic(.sad)
            ]
            itemsSwiftUI.thoughts = thoughts
        }
    }
}

protocol ThoughtEditDelegate: AnyObject {
    func starred(_ thought: Thought)
    func discussed(_ thought: Thought)
    func textChanged(_ thought: Thought)
}
