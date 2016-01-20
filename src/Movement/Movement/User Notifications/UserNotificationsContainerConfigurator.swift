import Swinject
import Parse

class UserNotificationContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        container.register(PushNotificationRegistrar.self) { resolver in
                return ParsePushNotificationRegistrar(installation: resolver.resolve(PFInstallation.self)!)
        }

        container.register(UserNotificationHandler.self) { resolver in
            let newsHandler = OpenNewsArticleNotificationHandler(
                newsNavigationController: resolver.resolve(NavigationController.self, name: "news")!,
                interstitialController: resolver.resolve(UIViewController.self, name: "interstitial")!,
                tabBarController: resolver.resolve(TabBarController.self)!,
                newsFeedItemControllerProvider: resolver.resolve(NewsFeedItemControllerProvider.self)!,
                newsArticleService: resolver.resolve(NewsArticleService.self)!)

            let parseAnalyticsHandler = ParseAnalyticsNotificationHandler(pfAnalyticsProxy: resolver.resolve(PFAnalyticsProxy.self)!)

            let handlers: [UserNotificationHandler] = [
                newsHandler,
                parseAnalyticsHandler
            ]

            return PushNotificationHandlerDispatcher(handlers: handlers)
        }
    }
}