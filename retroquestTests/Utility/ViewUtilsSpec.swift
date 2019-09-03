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

import Quick
import Nimble
import UIKit

@testable import retroquest

class ViewUtilsSpec: QuickSpec {
    override func spec() {

        describe("stack views") {
            let separatorThickness: CGFloat = 3.0
            var expectedView1: UIView!
            var expectedView2: UIView!

            beforeEach {
                expectedView1 = UIView()
                expectedView2 = UIView()
            }

            it("should be able to construct a stack view with separators between provided views") {
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .between,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(3))
                expect(stackView.subviews[0]).to(equal(expectedView1))
                expect(stackView.subviews[2]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(1, stackView: stackView, separatorThickness: separatorThickness)
            }

            it("should be able to construct a stack view with no separators") {
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .none
                )
                expect(stackView.subviews.count).to(equal(2))
                expect(stackView.subviews[0]).to(equal(expectedView1))
                expect(stackView.subviews[1]).to(equal(expectedView2))
            }

            it("should be able to construct a stack view with separators around the views") {
                let separatorThickness: CGFloat = 3.0
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .beforeAndAfter,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(4))
                expect(stackView.subviews[1]).to(equal(expectedView1))
                expect(stackView.subviews[2]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(0, stackView: stackView, separatorThickness: separatorThickness)
                self.expectViewAtIndexIsSeparator(3, stackView: stackView, separatorThickness: separatorThickness)
            }

            it("should be able to construct a stack view with separators between the views and after") {
                let separatorThickness: CGFloat = 3.0
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .betweenAndAfter,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(4))
                expect(stackView.subviews[0]).to(equal(expectedView1))
                expect(stackView.subviews[2]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(1, stackView: stackView, separatorThickness: separatorThickness)
                self.expectViewAtIndexIsSeparator(3, stackView: stackView, separatorThickness: separatorThickness)
            }

            it("should be able to construct a stack view with separators between and around the views") {
                let separatorThickness: CGFloat = 3.0
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .betweenAndBeforeAndAfter,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(5))
                expect(stackView.subviews[1]).to(equal(expectedView1))
                expect(stackView.subviews[3]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(0, stackView: stackView, separatorThickness: separatorThickness)
                self.expectViewAtIndexIsSeparator(2, stackView: stackView, separatorThickness: separatorThickness)
                self.expectViewAtIndexIsSeparator(4, stackView: stackView, separatorThickness: separatorThickness)
            }

            it("should be able to construct a stack view with a separator after provided views") {
                let separatorThickness: CGFloat = 3.0
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .after,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(3))
                expect(stackView.subviews[0]).to(equal(expectedView1))
                expect(stackView.subviews[1]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(2, stackView: stackView, separatorThickness: separatorThickness)
            }

            it("should be able to construct a stack view with a separator before provided views") {
                let separatorThickness: CGFloat = 3.0
                let stackView = ViewUtils.setupStackView(
                        subviews: [expectedView1, expectedView2],
                        axis: .horizontal,
                        lineSeparate: .before,
                        separatorThickness: separatorThickness
                )
                expect(stackView.subviews.count).to(equal(3))
                expect(stackView.subviews[1]).to(equal(expectedView1))
                expect(stackView.subviews[2]).to(equal(expectedView2))

                self.expectViewAtIndexIsSeparator(0, stackView: stackView, separatorThickness: separatorThickness)
            }
        }

        describe("separators") {
            it("should be able to construct a standalone separator") {
                let thickness: CGFloat = 3.0
                let separator = ViewUtils.setupSeparator(axis: .vertical, size: thickness)

                let heightConstraint: NSLayoutConstraint = separator.constraints[0]
                let expectedSeparatorConstraintValue = heightConstraint.constant
                expect(expectedSeparatorConstraintValue).to(equal(thickness))
            }
        }
    }

    private func expectViewAtIndexIsSeparator(
            _ viewIndex: Int,
            stackView: UIStackView,
            separatorThickness: CGFloat
    ) {
        let widthConstraint = stackView.subviews[viewIndex].constraints[0]
        let expectedSeparatorConstraintValue = widthConstraint.constant
        expect(expectedSeparatorConstraintValue).to(equal(separatorThickness))
    }
}
