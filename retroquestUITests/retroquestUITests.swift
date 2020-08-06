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

import XCTest
import Swifter

class retroquestUITests: XCTestCase {

    let loginUrlPath = "/api/team/login"
    let teamUrlPath = "/api/team/"
    let expectedTeamName = "board"

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func testExample() throws {
        let thoughtsEndpoint = "\(teamUrlPath)\(expectedTeamName)/thoughts"
        let columnsEndpoint = "\(teamUrlPath)\(expectedTeamName)/columns"
        let server = HttpServer()
        server[loginUrlPath] = { _ in .ok(.text("fake_token"))  }
        server[thoughtsEndpoint] = { _ in .ok(.json(self.generateJsonResponse(responseJson: self.thoughtsString))) }
        server[columnsEndpoint] = { _ in .ok(.json(self.generateJsonResponse(responseJson: self.columnsString))) }
        try server.start()
        
        let app = XCUIApplication()
        app.launch()

        let boardNameField = app.textFields["Login Board Field"]
        boardNameField.tap()
        boardNameField.typeText(expectedTeamName)
        let passwordField = app.secureTextFields["Login Password Field"]
        passwordField.tap()
        passwordField.typeText("password")
        
        let loginButton = app.buttons["Sign In"]
        loginButton.tap()

        let thoughtsViewTitle = app.staticTexts[expectedTeamName]
        XCTAssert(thoughtsViewTitle.label == expectedTeamName)
    }
    
    private func generateJsonResponse(responseJson: String) -> Any {
        let jsonData = responseJson.data(using: .utf8)!
        return try! JSONSerialization.jsonObject(with: jsonData)
    }
    
    let thoughtsString = """
        [
            {
                "id": 1,
                "message": "blah5",
                "hearts": 3,
                "topic": "happy",
                "discussed": false,
                "teamId": "a",
                "columnTitle": {
                    "id": 1,
                    "topic": "happy",
                    "title": "Happy",
                    "teamId": "a"
                },
                "boardId": null
            },
            {
                "id": 2,
                "message": "merpies",
                "hearts": 3,
                "topic": "confused",
                "discussed": false,
                "teamId": "a",
                "columnTitle": {
                    "id": 2,
                    "topic": "confused",
                    "title": "lalala?",
                    "teamId": "a"
                },
                "boardId": null
            }
        ]
    """
    
    let columnsString = """
        [
            {
                "id": 1,
                "topic": "happy",
                "title": "Happy",
                "teamId": "a"
            },
            {
                "id": 2,
                "topic": "confused",
                "title": "lalala?",
                "teamId": "a"
            },
            {
                "id": 3,
                "topic": "unhappy",
                "title": "Sad",
                "teamId": "a"
            }
        ]
    """
}
