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

@testable import retroquest

class ColumnNamesServiceSpec: QuickSpec {

    override func spec() {
        let columnPubSub = PubSub<Column>()
        let subject = ColumnNameService(itemPubSub: columnPubSub)
        let fakeSubject = FakeColumnNameService(itemPubSub: columnPubSub)

        describe("get a column title from a topic") {
            beforeEach {
                subject.items = fakeSubject.items
            }

            context("when providing a column name") {
                it("should return the corresponding column title") {
                    let happyColumnTitle = subject.getColumnTitle(ColumnName.happy)
                    expect(happyColumnTitle).to(equal("kindaHappy"))

                    let confusedColumnTitle = subject.getColumnTitle(ColumnName.confused)
                    expect(confusedColumnTitle).to(equal("kindaConfused"))

                    let sadColumnTitle = subject.getColumnTitle(ColumnName.sad)
                    expect(sadColumnTitle).to(equal("kindaSad"))
                }
            }

            context("when providing a topic name") {
                it("should return the corresponding column name") {
                    let happyColumnName = subject.getColumnName(ColumnName.happy.rawValue)
                    expect(happyColumnName).to(equal(ColumnName.happy))

                    let confusedColumnName = subject.getColumnName(ColumnName.confused.rawValue)
                    expect(confusedColumnName).to(equal(ColumnName.confused))

                    let sadColumnName = subject.getColumnName(ColumnName.sad.rawValue)
                    expect(sadColumnName).to(equal(ColumnName.sad))
                }
            }
        }
    }
}
