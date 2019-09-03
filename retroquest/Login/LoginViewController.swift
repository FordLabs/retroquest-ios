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
import os.log
import M13Checkbox
import AppCenterAnalytics

class LoginViewController: UIViewController {

    internal let loginView: LoginView = LoginView()
    fileprivate var backgroundImageView = UIImageView()

    internal var flowController: RetroFlowController!

    internal var team: String?

    convenience init(flowController: RetroFlowController) {
        self.init()

        self.flowController = flowController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loginView.setup()

        view.backgroundColor = RetroColors.backgroundColor
        view.addSubview(backgroundImageView)
        _ = backgroundImageView.anchorEdgesToSuperView()

        view.addSubview(loginView)
        _ = loginView.anchorTopTo(view.safeAreaLayoutGuide.topAnchor, offset: 0)
        _ = loginView.anchorEdgesToSuperView(omit: .top)

        loginView.boardField.delegate = self
        loginView.passwordField.delegate = self

        loginView.signInButton.addTarget(self, action: #selector(signInTapped), for: .touchUpInside)
        loginView.giveFeedbackButton.addTarget(self, action: #selector(didTapHelp), for: .touchUpInside)

        loginView.saveSettingsLabel.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(didTapSaveCredentialsLabel))
        )

        checkForSavedCredentials()
    }

    @objc func didTapHelp() {
        print("Opening Feedback View")
        DispatchQueue.main.async(execute: {
            self.view.window?.rootViewController!.present(
                    FeedbackViewController(),
                    animated: true
            )
        })
    }

    @objc func didTapSaveCredentialsLabel() {
        let originalCheckState = loginView.saveSettingsCheckbox.checkState
        let newCheckedState: M13Checkbox.CheckState = originalCheckState == .unchecked ? .checked : .unchecked
        loginView.saveSettingsCheckbox.setCheckState(newCheckedState, animated: true)
    }

    @objc func signInTapped() {
        if !validateFields() {
            return
        }
        showSpinner()

        attemptToLogin()
    }

    private func checkForSavedCredentials() {
        let userDefaults = UserDefaults.standard
        guard let savedTeam = userDefaults.object(forKey: "Saved_Team") as? String,
              let savedPassword = userDefaults.object(forKey: "Saved_Team_Password") as? String else {
            return
        }
        self.loginView.boardField.text = savedTeam
        self.loginView.passwordField.text = savedPassword
        self.loginView.saveSettingsCheckbox.setCheckState(.checked, animated: false)
    }

    private func attemptToLogin() {
        team = loginView.boardField.text! as String
        let url = URL(string: URLManager.getFullLoginPath())!
        let loginParameters: [String: String] = [
            "name": team!,
            "password": loginView.passwordField.text!
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginParameters)
        } catch {
            os_log("Could not encode post body for login")
            return
        }
        let task = URLSession.shared.dataTask(with: request, completionHandler: handleLoginResponse)
        task.resume()
    }

    private func handleLoginResponse(data: Data?, response: URLResponse?, error: Error?) {
        DispatchQueue.main.async {
            self.hideSpinner()
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            self.handleBadResponse(data)
            return
        }
        guard let data = data else {
            os_log("No data in the login response", type: .error)
            return
        }
        os_log("Login returned statusCode: %d", type: .info, httpResponse.statusCode)

        if (200..<300) ~= httpResponse.statusCode {
            self.handleGoodResponse(data)
        } else {
            self.handleBadResponse(data)
        }
    }

    private func handleGoodResponse(_ data: Data) {
        let token = String(data: data, encoding: .utf8)

        self.storeTokenInCookie(
                loginUrlEndpoint: URLManager.retroBaseUrl,
                loginUrlPath: URLManager.teamUrlPath + team!,
                name: "token", value: token
        )
        os_log("Successfully logged in.", type: .info)

        DispatchQueue.main.async {
            if self.loginView.saveSettingsCheckbox.checkState == .checked {
                self.storeCredentialsInUserDefaults(userName: self.team, password: self.loginView.passwordField.text)
            } else {
                self.storeCredentialsInUserDefaults(userName: nil, password: nil)
            }

            URLManager.setCurrentTeam(team: self.team!)
            MSAnalytics.trackEvent("login", withProperties: ["Team": URLManager.currentTeam])
            self.flowController.switchTo(.thoughts)
        }
    }

    private func handleBadResponse(_ data: Data?) {
        guard let data = data,
              let errors = try? JSONDecoder().decode(RetroLoginError.self, from: data) else {
            let message = """
                          An unexpected error occurred.
                          Please try again and if the issue persists,
                          file an issue on our GitHub (see the Help link below).
                          """
            logAndDisplayLoginError(message, message: message)
            return
        }
        let debugMessage = errors.toString()
        let displayMessage = errors.message
        logAndDisplayLoginError(debugMessage, message: displayMessage)
    }

    private func logAndDisplayLoginError(_ debugString: String, message: String) {
        os_log("Login response: %{public}@", type: .error, debugString)
        DispatchQueue.main.async {
            self.presentAlertControllerWithTitle(
                    "Login Failure",
                    presenter: self,
                    andMessage: message
            )
        }
    }

    private func storeTokenInCookie(loginUrlEndpoint: String, loginUrlPath: String, name: String, value: String?) {
        if RetroCookies.searchForCurrentCookie(value: nil, fullUrl: loginUrlEndpoint, name: "token") != nil {
            os_log("Existing cookie detected. Overwriting.", type: .info)
        }

        RetroCookies.setRetroCookie(
                urlDomain: URLManager.retroBaseUrl,
                urlPath: loginUrlPath,
                name: name,
                value: value!)
    }

    private func storeCredentialsInUserDefaults(userName: String?, password: String?) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(userName, forKey: "Saved_Team")
        userDefaults.set(password, forKey: "Saved_Team_Password")
    }

    private func validateFields() -> Bool {
        guard let board = loginView.boardField.text, let password = loginView.passwordField.text else {
            return false
        }

        var validationAlertTitle = ""
        var validationAlertMessage = ""
        if board.isEmpty && password.isEmpty {
            validationAlertTitle = "All fields required"
            validationAlertMessage = "Please enter a valid input for all fields"
        } else if board.isEmpty {
            validationAlertTitle = "Board field required"
            validationAlertMessage = "Please enter a valid input for all fields"
        } else if password.isEmpty {
            validationAlertTitle = "Password field required"
            validationAlertMessage = "Please enter a valid input for all fields"
        } else if password.count < 8 {
            validationAlertTitle = "Password field"
            validationAlertMessage = "Must be at least 8 characters"
        }

        if !validationAlertTitle.isEmpty {
            self.presentAlertControllerWithTitle(
                    validationAlertTitle,
                    presenter: self,
                    andMessage: validationAlertMessage
            )
            return false
        }

        return true
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        let currentCharacterCount = (textField.text?.count ?? 0)
        if range.length + range.location > currentCharacterCount {
            return false
        }
        let newLength = currentCharacterCount + (string.count - range.length)
        return newLength <= 100
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.boardField || textField == loginView.passwordField {
            signInTapped()
            return true
        }
        return false
    }
}
