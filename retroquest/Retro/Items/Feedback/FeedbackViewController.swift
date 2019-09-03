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

class FeedbackViewController: UIViewController, UITextFieldDelegate {
    internal var feedbackFormView: FeedbackFormView!
    internal var feedbackStarsSelected: Int = 0

    convenience init() {
        self.init(nibName: nil, bundle: nil)

        self.feedbackFormView = FeedbackFormView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(self.feedbackFormView)
        _ = feedbackFormView.anchorEdgesToSuperView()

        feedbackFormView.setupWithDelegateDataSource(delegate: self)

        feedbackFormView.cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        feedbackFormView.submitButton.addTarget(self, action: #selector(submit), for: .touchUpInside)
        for starIndex in 0..<5 {
            let star = feedbackFormView.stars[starIndex]
            star.tag = starIndex
            star.addTarget(
                    self,
                    action: #selector(selectFeedbackStars),
                    for: .touchUpInside
            )
        }
    }

    @objc internal func cancel() {
        print("dismissing feedback view")
        self.dismiss(animated: true, completion: nil)
    }

    @objc internal func submit() {
        var request = URLRequest(url: URL(string: URLManager.getFeedbackPath())!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let feedback = buildFeedbackHttpBody() {
            request.httpBody = feedback

            let task = URLSession.shared.dataTask(with: request, completionHandler: handleFeedbackSubmission)
            task.resume()
        } else {
            os_log("Issue submitting feedback", type: .error)
        }
    }

    private func handleFeedbackSubmission(data: Data?, response: URLResponse?, error: Error?) {
        guard let httpResponse = response as? HTTPURLResponse else {
            return
        }
        os_log("Feedback returned statusCode: %d", type: .info, httpResponse.statusCode)
        var alertTitle = ""
        if httpResponse.statusCode == 201 {
            alertTitle = "Thanks for your feedback!"
        } else {
            alertTitle = "Problem sending feedback"
        }

        DispatchQueue.main.async {
            self.presentAlertControllerWithTitle(
                    alertTitle,
                    presenter: self,
                    andMessage: "",
                    defaultHandler: { _ in
                        self.cancel()
                    }
            )
        }
    }

    @objc internal func selectFeedbackStars(sender: UIButton) {
        let buttonIndex = sender.tag

        let outlineFont = UIFont.fontAwesome(ofSize: 34, style: .regular)
        let outlineStarIcon = feedbackFormView.buildStarIcon(font: outlineFont)
        for starIndex in buttonIndex + 1..<feedbackFormView.stars.count {
            feedbackFormView.stars[starIndex].setAttributedTitle(outlineStarIcon, for: UIControl.State())
        }

        let solidFont = UIFont.fontAwesome(ofSize: 34, style: .solid)
        let solidStarIcon = feedbackFormView.buildStarIcon(font: solidFont)
        for starIndex in 0..<buttonIndex + 1 {
            feedbackFormView.stars[starIndex].setAttributedTitle(solidStarIcon, for: UIControl.State())
        }

        feedbackStarsSelected = buttonIndex + 1
    }

    internal func buildFeedbackHttpBody() -> Data? {
        let comments = feedbackFormView.commentsTextBox.itemTextField.text
        if comments == nil || comments == "" {
            feedbackFormView.commentsTextBox.itemTextField.backgroundColor = UIColor(hexString: "FAFFBD")
            return nil
        }
        let email = feedbackFormView.emailTextBox.itemTextField.text
        let teamId = "RetroQuest-iOS"
        let feedback = Feedback(
                stars: feedbackStarsSelected,
                comment: comments!,
                userEmail: email ?? "",
                teamId: teamId
        )
        guard let bodyData: Data = try? JSONEncoder().encode(feedback) else {
            os_log("Unable to encode feedback", type: .error)
            return nil
        }
        os_log("submitting feedback: %s", type: .info, String(describing: feedback))
        return bodyData
    }
}
