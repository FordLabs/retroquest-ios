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

class RetroCookiesSpec: QuickSpec {

    override func spec() {

        describe("Handling cookies in retroquest iOS") {
            let storage = HTTPCookieStorage.shared

            context("A - adding cookies") {

                it("should add a new cookie when setRetroCookie is called") {
                    let count = storage.cookies!.count
                    RetroCookies.setRetroCookie(
                            urlDomain: "http://stuff.com",
                            urlPath: "",
                            name: "yup",
                            value: "nope"
                    )
                    expect(storage.cookies!.count).to(be(count + 1))
                }
            }

            context("B - look for a cookie in cookies") {
                beforeEach {
                    expect(storage.cookies!.count).to(beGreaterThan(0))
                }

                it("should return nothing if no matching cookie - don't care about value matching") {
                    let notFoundCookie = RetroCookies.searchForCurrentCookie(
                            fullUrl: "unknownpath/yup",
                            name: "aintGonnaFindMe"
                    )
                    expect(notFoundCookie).to(beNil())
                }

                it("should return matching cookie - don't care about value matching") {
                    let foundCookie = RetroCookies.searchForCurrentCookie(
                            fullUrl: "http://stuff.com/",
                            name: "yup"
                    )
                    expect(foundCookie).toNot(beNil())
                }

                it("should return nothing if cookie doesn't match value") {
                    let notFoundCookie = RetroCookies.searchForCurrentCookie(
                            value: "notRightValue",
                            fullUrl: "http://stuff.com/",
                            name: "yup"
                    )
                    expect(notFoundCookie).to(beNil())
                }

                it("should return matching cookie if value and full url match") {
                    let foundCookie = RetroCookies.searchForCurrentCookie(
                            value: "nope",
                            fullUrl: "http://stuff.com/",
                            name: "yup"
                    )
                    expect(foundCookie).toNot(beNil())
                }

                it("should return cookie if only name is found") {
                    let foundCookie = RetroCookies.searchForCurrentCookie(name: "yup")
                    expect(foundCookie).toNot(beNil())
                }

                it("should return nothing if name doesn't even match") {
                    let notFoundCookie = RetroCookies.searchForCurrentCookie(name: "nope")
                    expect(notFoundCookie).to(beNil())
                }
            }

            context("C - clearing cookies") {

                it("should have no cookies after clearCookies() is called") {
                    expect(storage.cookies!.count).to(beGreaterThan(0))
                    RetroCookies.clearCookies()
                    expect(storage.cookies!.count).to(be(0))
                }
            }
        }
    }

}
