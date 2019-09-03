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

public class URLManager {
    private static var _retroBaseUrl = RetroQuestServerURL
    static var retroBaseUrl: String {
        get {
            var fixedUrl = _retroBaseUrl
            let endOfProtocol: Character = ":"
            if _retroBaseUrl.firstIndex(of: endOfProtocol) == nil {
                fixedUrl = "http://\(fixedUrl)"
            }
            let finalSlash = "/"
            let slashIndices = _retroBaseUrl.indexes(of: finalSlash)
            if slashIndices.count == 2 || fixedUrl.last != "/" {
                fixedUrl = "\(fixedUrl)/"
            }
            return fixedUrl.lowercased()
        }
        set(baselineUrl) {
            _retroBaseUrl = baselineUrl
        }
    }
    static var currentTeam = ""

    static let loginUrlPath = "api/team/login"
    static let teamUrlPath = "api/team/"
    static let feedbackPath = "api/feedback"

    static func getFullLoginPath() -> String {
        return retroBaseUrl + loginUrlPath
    }

    static func getFullTeamPath(team: String) -> String {
        return retroBaseUrl + teamUrlPath + team
    }

    static func getFeedbackPath() -> String {
        return retroBaseUrl + feedbackPath
    }

    static func getRetroWSUrl() -> String {
        let endOfProtocol: Character = ":"
        if let idx = retroBaseUrl.firstIndex(of: endOfProtocol) {
            let urlProtocol = retroBaseUrl.prefix(upTo: idx)
            var wsProtocol: String
            if urlProtocol.contains("s") {
                wsProtocol = "wss"
            } else {
                wsProtocol = "ws"
            }

            let domain = retroBaseUrl.suffix(from: idx)
            return wsProtocol + domain + "websocket/websocket"
        }
        return ""
    }

    static func getWsDestination<T: Item>(_ item: T, type: OutgoingType) -> String {
        let team = URLManager.currentTeam.replacingOccurrences(of: " ", with: "-").lowercased()

        if item.description == "column-title" && (type == .create || type == .delete) {
            return ""
        }

        if item.description == "thought" && type == .delete {
            return "/app/v2/\(team)/\(item.description)/\(type)"
        }

        if item.description == "action-item" && type == .delete {
            return "/app/\(team)/\(item.description)/\(type)"
        }

        let idPathInDestination = type != .create ? "/\(item.id)" : ""
        return "/app/\(team)/\(item.description)\(idPathInDestination)/\(type)"
    }

    static func setCurrentTeam(team: String) {
        self.currentTeam = team
    }
}
