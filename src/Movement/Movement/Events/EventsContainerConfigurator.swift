import Swinject
import CoreLocation

class EventsContainerConfigurator: ContainerConfigurator {
    static func configureContainer(container: Container) {
        configureDataAccess(container)
        configureUI(container)
    }

    private static func configureDataAccess(container: Container) {
        container.register(EventDeserializer.self) { _ in
            return ConcreteEventDeserializer()
            }.inObjectScope(.Container)

        container.register(EventRepository.self) { resolver in
            return ConcreteEventRepository(
                geocoder: resolver.resolve(CLGeocoder.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                jsonClient: resolver.resolve(JSONClient.self)!,
                eventDeserializer: resolver.resolve(EventDeserializer.self)!
            )
            }.inObjectScope(.Container)

        container.register(EventService.self) { resolver in
            return BackgroundEventService(
                eventRepository: resolver.resolve(EventRepository.self)!,
                workerQueue: resolver.resolve(NSOperationQueue.self, name: "work")!,
                resultQueue: resolver.resolve(NSOperationQueue.self, name: "main")!
            )
            }.inObjectScope(.Container)
    }

    // swiftlint:disable function_body_length
    private static func configureUI(container: Container) {
        container.register(EventPresenter.self) { resolver in
            return EventPresenter(
                sameTimeZoneDateFormatter: resolver.resolve(NSDateFormatter.self, name: "time")!,
                differentTimeZoneDateFormatter: resolver.resolve(NSDateFormatter.self, name: "timeWithTimezone")!,
                sameTimeZoneFullDateFormatter: resolver.resolve(NSDateFormatter.self, name: "dateTime")!,
                differentTimeZoneFullDateFormatter: resolver.resolve(NSDateFormatter.self, name: "dateTimeWithTimezone")!
            )
            }.inObjectScope(.Container)

        container.register(EventRSVPControllerProvider.self) { resolver in
            return ConcreteEventRSVPControllerProvider(
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(EventControllerProvider.self) { resolver in
            return ConcreteEventControllerProvider(
                eventPresenter: resolver.resolve(EventPresenter.self)!,
                eventRSVPControllerProvider: resolver.resolve(EventRSVPControllerProvider.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                theme: resolver.resolve(Theme.self)!)
            }.inObjectScope(.Container)

        container.register(EventSectionHeaderPresenter.self) { resolver in
            return EventSectionHeaderPresenter(
                currentWeekDateFormatter: resolver.resolve(NSDateFormatter.self, name: "day")!,
                nonCurrentWeekDateFormatter: resolver.resolve(NSDateFormatter.self, name: "shortDate")!,
                dateProvider: resolver.resolve(DateProvider.self)!)
        }.inObjectScope(.Container)

        container.register(EventListTableViewCellStylist.self) { resolver in
            return ConcreteEventListTableViewCellStylist(
                dateProvider: resolver.resolve(DateProvider.self)!,
                theme: resolver.resolve(Theme.self)!)
        }.inObjectScope(.Container)

        container.register(ZipCodeValidator.self) { resolver in
            return StockZipCodeValidator()
        }.inObjectScope(.Container)

        container.register(EventsController.self) { resolver in
            return EventsController(
                eventService: resolver.resolve(EventService.self)!,
                eventPresenter: resolver.resolve(EventPresenter.self)!,
                eventControllerProvider: resolver.resolve(EventControllerProvider.self)!,
                eventSectionHeaderPresenter: resolver.resolve(EventSectionHeaderPresenter.self)!,
                urlProvider: resolver.resolve(URLProvider.self)!,
                urlOpener: resolver.resolve(URLOpener.self)!,
                analyticsService: resolver.resolve(AnalyticsService.self)!,
                tabBarItemStylist: resolver.resolve(TabBarItemStylist.self)!,
                eventListTableViewCellStylist: resolver.resolve(EventListTableViewCellStylist.self)!,
                zipCodeValidator: resolver.resolve(ZipCodeValidator.self)!,
                theme: resolver.resolve(Theme.self)!)
        }

        container.register(NavigationController.self, name: "events") { resolver in
            let navigationController = resolver.resolve(NavigationController.self)!
            let newsFeedController = resolver.resolve(EventsController.self)!
            navigationController.pushViewController(newsFeedController, animated: false)
            return navigationController
        }
    }
        // swiftlint:enable function_body_length
}
