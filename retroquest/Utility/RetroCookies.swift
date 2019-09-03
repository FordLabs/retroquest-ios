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

public class RetroCookies {

    static func setRetroCookie(
            urlDomain: String,
            urlPath: String,
            name: String,
            value: String) {

        let storage = HTTPCookieStorage.shared
        let tokenCookieProps: [HTTPCookiePropertyKey: Any] = [
            HTTPCookiePropertyKey.domain: urlDomain,
            HTTPCookiePropertyKey.path: urlPath,
            HTTPCookiePropertyKey.name: name,
            HTTPCookiePropertyKey.value: value,
            HTTPCookiePropertyKey.secure: "TRUE"
        ]
        let tokenCookie = HTTPCookie(properties: tokenCookieProps)
        storage.setCookie(tokenCookie!)
    }

    static func searchForCurrentCookie(
            value: String? = nil,
            fullUrl: String? = nil,
            name: String) -> HTTPCookie? {

        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! where cookie.name == name {
            if fullUrl == nil && value == nil {
                return cookie
            }
            if let tokenValue = value {
                if cookie.value == tokenValue && (cookie.domain + cookie.path == fullUrl) {
                    return cookie
                }
            } else if cookie.domain + cookie.path == fullUrl {
                return cookie
            }
        }

        return nil
    }

    static func clearCookies() {
        let storage = HTTPCookieStorage.shared
        for cookie in storage.cookies! {
            storage.deleteCookie(cookie)
        }
    }
}
