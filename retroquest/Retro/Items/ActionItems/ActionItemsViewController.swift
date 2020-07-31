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

class ActionItemsViewController: UIViewController {
    internal var actionItemsService: ActionItemsService!
    internal var actionItemsViewEnvironmentObject = ActionItemsViewEnvironmentObject()

    convenience init(actionItemsService: ActionItemsService) {
        self.init()

        self.actionItemsService = actionItemsService
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Action Items"

        self.actionItemsService.registerItemCallback(actionItemCallback)
        self.getActionItems()

        let actionItemsViewSwiftUI: some View = ActionItemsSwiftUIView(teamName: URLManager.currentTeam)
            .environmentObject(self.actionItemsViewEnvironmentObject)
            .environmentObject(self.actionItemsService.itemPubSub)
        let hostingController = UIHostingController(rootView: actionItemsViewSwiftUI)
        addChild(hostingController)
        let actionItemsView = hostingController.view!
        view.addSubview(actionItemsView)
        _ = actionItemsView.anchorEdgesToSuperView()
    }

    func refreshData() {
        self.actionItemsService.clear()
        self.getActionItems()
    }

    private func getActionItems() {
        _ = self.actionItemsService.requestItemsFromServer(team: URLManager.currentTeam)
    }

    private func actionItemCallback(actionItem: ActionItem?) {
        if var actionItem = actionItem {
            if actionItem.deletion ?? false {
                do {
                    actionItem = try self.actionItemsService.delete(actionItem)!
                } catch {
                    print("Attempted to delete non-existent action item with id \(actionItem.id)")
                    return
                }
            } else {
                _ = self.actionItemsService.addOrReplace(actionItem)
                self.actionItemsService.sort()
            }
            self.actionItemsViewEnvironmentObject.actionItems = self.actionItemsService.items
        }
    }
}
