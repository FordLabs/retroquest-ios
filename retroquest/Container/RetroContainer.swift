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

import Swinject

import StompClientLib

open class RetroContainer {
    static internal var navigationController = UINavigationController()

    // swiftlint:disable:next function_body_length
    static func defaultContainer() -> Container {
        let container = Container()

        container.register(ThoughtsService.self) { r in
            ThoughtsService(itemPubSub: r.resolve(PubSub<Thought>.self)!)
        }

        container.register(ActionItemsService.self) { r in
            ActionItemsService(itemPubSub: r.resolve(PubSub<ActionItem>.self)!)
        }

        container.register(ColumnNameService.self) { r in
            ColumnNameService(itemPubSub: r.resolve(PubSub<Column>.self)!)
        }

        container.register(UINavigationController.self) { _ in
            navigationController
        }

        container.register(Notifying.self) { _ in
            NotificationCenterWrapper()
        }

        container.register(StompClientLib.self) { _ in
            StompClientLib()
        }

        container.register(PubSub<Thought>.self) { _ in
            PubSub<Thought>()
        }

        container.register(PubSub<ActionItem>.self) { _ in
            PubSub<ActionItem>()
        }

        container.register(PubSub<Column>.self) { _ in
            PubSub<Column>()
        }

        container.register(ThoughtsViewController.self) { r in
            let controller = ThoughtsViewController(
                thoughtsService: r.resolve(ThoughtsService.self)!,
                columnNameService: r.resolve(ColumnNameService.self)!
            )
            return controller
        }

        container.register(RetroFlowController.self) { _ in
            let controller = RetroFlowController(
                    navigationController,
                    container
            )
            return controller
        }

        container.register(WebSocketService.self) { r in
            let service = WebSocketService(
                    stompClient: r.resolve(StompClientLib.self)!,
                    thoughtPubSub: r.resolve(PubSub<Thought>.self)!,
                    actionItemPubSub: r.resolve(PubSub<ActionItem>.self)!,
                    columnPubSub: r.resolve(PubSub<Column>.self)!,
                    notificationCenterWrapper: r.resolve(Notifying.self)!
            )
            return service
        }

        container.register(ActionItemsViewController.self) { r in
            let controller = ActionItemsViewController(
                    actionItemsService: r.resolve(ActionItemsService.self)!
            )
            return controller
        }

        container.register(LoginViewController.self) { r in
            let controller = LoginViewController(
                    flowController: r.resolve(RetroFlowController.self)!
            )
            return controller
        }

        container.register(RetroTabBarViewController.self) { r in
            let controller = RetroTabBarViewController(
                    flowController: r.resolve(RetroFlowController.self)!,
                    thoughtsViewController: r.resolve(ThoughtsViewController.self)!,
                    actionItemsViewController: r.resolve(ActionItemsViewController.self)!,
                    webSocketService: r.resolve(WebSocketService.self)!,
                    notificationCenterWrapper: r.resolve(Notifying.self)!
            )
            return controller
        }

        return container
    }
}
