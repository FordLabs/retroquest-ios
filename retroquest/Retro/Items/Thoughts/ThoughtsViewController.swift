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

struct Section {
    var collapsed: Bool
}

class ThoughtsViewController: UIViewController {

    internal var columnNameService: ColumnNameService!
    internal var thoughtsService: ThoughtsService!
    internal var itemsSwiftUI: ItemsSwiftUI = ItemsSwiftUI(thoughts: [[]], columnTitles: [])

    convenience init(thoughtsService: ThoughtsService, columnNameService: ColumnNameService) {
        self.init()

        self.thoughtsService = thoughtsService
        self.columnNameService = columnNameService
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Thoughts"

//        thoughtsView.addThoughtButton.addTarget(self, action: #selector(addThought), for: .touchUpInside)
        thoughtsService.registerItemCallback(thoughtCallback)
        columnNameService.registerItemCallback(columnNamesCallback)
        getThoughtsAndColumns()

        let thoughtsViewSwiftUI: some View = ThoughtsSwiftUIView(teamName: URLManager.currentTeam).environmentObject(itemsSwiftUI)
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
            let columnNames: [String] = [
                columnNameService.getColumnTitle(.happy),
                columnNameService.getColumnTitle(.confused),
                columnNameService.getColumnTitle(.sad)
            ]
            itemsSwiftUI.columnTitles = columnNames
        }
    }

    func refreshData() {
        thoughtsService.clear()
        getThoughtsAndColumns()
    }

//    @objc private func addThought() {
//        print("Opening Add New Thought View")
//        DispatchQueue.main.async(execute: {
//            self.view.window?.rootViewController!.present(
//                    NewItemViewController(
//                            pubSub: self.thoughtsService.itemPubSub,
//                            columnNameService: self.columnNameService
//                    ),
//                    animated: true
//            )
//        })
//    }

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

//    @objc func longPressHandler(longPressGestureRecognizer: UILongPressGestureRecognizer) {
//        if longPressGestureRecognizer.state == UIGestureRecognizer.State.began {
//            if let view = longPressGestureRecognizer.view as? ThoughtTableViewHeaderView {
//
//                let columnName = ColumnNameService.displayOrderForTopics[view.topicIndex]
//                let columnTitle = columnNameService.getColumnTitle(columnName)
//                DispatchQueue.main.async(execute: {
//                    self.view.window?.rootViewController!.present(
//                            EditItemViewController(
//                                    titleText: "Change Column Name",
//                                    defaultText: columnTitle,
//                                    onSave: { updatedText in
//                                        let topic = ColumnNameService.displayOrderForTopics[view.topicIndex].rawValue
//                                        let columnId = self.columnNameService.items[view.topicIndex].id
//                                        let column = Column(
//                                                id: columnId,
//                                                topic: topic,
//                                                title: updatedText,
//                                                teamId: URLManager.currentTeam
//                                        )
//
//                                        self.columnNameService.itemPubSub.publishOutgoing(column, outgoingType: .edit)
//                                        MSAnalytics.trackEvent(
//                                                "change column name",
//                                                withProperties: ["Team": URLManager.currentTeam]
//                                        )
//                                    },
//                                    maxCharacters: 16
//                            ),
//                            animated: true
//                    )
//                })
//            }
//        }
//        return
//    }
}

//extension ThoughtsViewController: UITableViewDelegate, UITableViewDataSource {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return collapsedState.count
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let columnName = ColumnNameService.displayOrderForTopics[section]
//        return collapsedState[section].collapsed ? 0 : thoughtsService.getNumberOfThoughtsOfTopic(columnName)
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? ThoughtTableViewCell ??
//                ThoughtTableViewCell()
//
//        let columnName = ColumnNameService.displayOrderForTopics[indexPath.section]
//
//        let thought = self.thoughtsService.getThoughtsOfTopic(columnName)[indexPath.row]
//
//        cell.setupCell(thought: thought, delegate: self)
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header")
//                as? ThoughtTableViewHeaderView ?? ThoughtTableViewHeaderView(reuseIdentifier: "header")
//
//        let columnName = ColumnNameService.displayOrderForTopics[section]
//        let title = columnNameService.getColumnTitle(columnName)
//        let numThoughts = thoughtsService.getNumberOfThoughtsOfTopic(columnName)
//        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))
//
//        header.setupCell(columnName: title, topicIndex: section, numThoughts: numThoughts)
//        header.setCollapsed(collapsedState[section].collapsed)
//        header.delegate = self
//
//        header.addGestureRecognizer(longPressRecognizer)
//
//        return header
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 100.0
//    }
//
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 1.0
//    }
//
//    func tableView(
//            _ tableView: UITableView,
//            commit editingStyle: UITableViewCell.EditingStyle,
//            forRowAt indexPath: IndexPath
//    ) {
//        if editingStyle == .delete {
//            guard let thoughtCell = tableView.cellForRow(at: indexPath) as? ThoughtTableViewCell else {
//                print("Tried deleting a cell that shouldn't be deleted")
//                return
//            }
//            let thought = thoughtCell.thought!
//            thoughtsService.itemPubSub.publishOutgoing(thought, outgoingType: .delete)
//            MSAnalytics.trackEvent("delete \(thought.topic) thought", withProperties: ["Team": URLManager.currentTeam])
//            print("Deleting Thought with id: \(thought.id)")
//        }
//    }
//}
//
//extension ThoughtsViewController: ThoughtEditDelegate {
//    func starred(_ thought: Thought) {
//        let newThought = thought.copy(hearts: thought.hearts + 1)
//        thoughtsService.itemPubSub.publishOutgoing(newThought, outgoingType: .edit)
//        MSAnalytics.trackEvent("star \(newThought.topic) thought", withProperties: ["Team": URLManager.currentTeam])
//    }
//
//    func discussed(_ thought: Thought) {
//        let newThought = thought.copy(discussed: !thought.discussed)
//        thoughtsService.itemPubSub.publishOutgoing(newThought, outgoingType: .edit)
//        MSAnalytics.trackEvent(
//                "mark \(newThought.topic) thought \(newThought.discussed ? "discussed" : "undiscussed")",
//                withProperties: ["Team": URLManager.currentTeam]
//        )
//    }
//
//    func textChanged(_ thought: Thought) {
//        print("Opening Edit New Thought View")
//        DispatchQueue.main.async(execute: {
//            self.view.window?.rootViewController!.present(
//                    EditItemViewController(
//                            titleText: "Change Thought",
//                            defaultText: thought.message,
//                            onSave: { updatedText in
//                                MSAnalytics.trackEvent(
//                                        "edit \(thought.topic) thought text",
//                                        withProperties: ["Team": URLManager.currentTeam]
//                                )
//                                let newThought = thought.copy(message: updatedText)
//                                self.thoughtsService.itemPubSub.publishOutgoing(newThought, outgoingType: .edit)
//                            }
//                    ),
//                    animated: true
//            )
//        })
//    }
//}
//
//extension ThoughtsViewController: ThoughtTableViewHeaderViewDelegate {
//
//    func toggleSection(_ header: ThoughtTableViewHeaderView, section: Int) {
//        let collapsed = !collapsedState[section].collapsed
//
//        // Toggle collapse
//        collapsedState[section].collapsed = collapsed
//        header.setCollapsed(collapsed)
//
//        thoughtsView.tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
//    }
//
//}
