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

import Foundation
import os.log

class ItemsService<T: Item> {
    internal var itemPubSub: PubSub<T>!
    internal var items: [T] = []

    init(itemPubSub: PubSub<T>) {
        self.itemPubSub = itemPubSub
    }

    internal func requestItemsFromServer(team: String) -> Bool { return false }

    internal func sort() {}

    internal func requestItemsFromServer(team: String, itemType: String, callback: @escaping ([T]?) -> Void) -> Bool {
        if let token = RetroCookies.searchForCurrentCookie(
                value: nil,
                fullUrl: URLManager.getFullTeamPath(team: team),
                name: "token"
        ) {
            let teamDashed = team.replacingOccurrences(of: " ", with: "-")
            let team = teamDashed.lowercased()
            let url = URL(string: URLManager.getFullTeamPath(team: team) + itemType)!

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer " + token.value, forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                do {
                    if let httpResponse = response as? HTTPURLResponse {
                        os_log("Team thoughts query returned status code %d", type: .info, httpResponse.statusCode)

                        guard let data = data else {
                            os_log("Bad server response", type: .error)
                            callback(nil)
                            return
                        }
                        guard let itemResult = try? JSONDecoder().decode([T].self, from: data) else {
                            os_log("Unable to decode %{public}@ response from server", type: .error, itemType)
                            callback(nil)
                            return
                        }

                        DispatchQueue.main.async {
                            callback(itemResult)
                        }
                    }
                }
            }
            task.resume()
            return true
        }

        return false
    }

    func clear() {
        self.items.removeAll()
    }

    func addOrReplace(_ newItem: T) -> Bool {
        if items.first(where: { $0.id == newItem.id }) != nil {
            items = items.map { item -> T in
                if item.id == newItem.id {
                    return newItem
                }
                return item
            }
            return false
        } else {
            items.append(newItem)
            return true
        }
    }

    func delete(_ itemToDelete: T) throws -> T? {
        let idComparison: (T) -> Bool = { $0.id == itemToDelete.id }

        if let currentItemToDelete = items.first(where: idComparison) {
            items.removeAll(where: idComparison)
            return currentItemToDelete
        } else {
            throw DeletionError()
        }
    }

    func registerItemCallback(_ callback: @escaping (T?) -> Void) {
        itemPubSub.addIncomingSubscriber(callback)
    }

    internal func publishItem(items: [T]?) {
        if let itemsList = items {
            itemPubSub.publishIncoming(itemsList)
        } else {
            itemPubSub.publishIncoming([])
        }
    }
}

struct DeletionError: Error {
    public var localizedDescription: String {
        return "Item to delete not found"
    }
}
