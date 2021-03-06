import UIKit
import Quick
import Nimble
@testable import Movement

class SettingsControllerSpec : QuickSpec {
    override func spec() {
            describe("SettingsController") {
            var subject: SettingsController!
            var analyticsService: FakeAnalyticsService!
            var tabBarItemStylist: FakeTabBarItemStylist!
            let theme = SettingsFakeTheme()

            let regularController = FakeSettingsController(title: "Regular Controller")

            var navigationController: UINavigationController!

            beforeEach {
                analyticsService = FakeAnalyticsService()
                tabBarItemStylist = FakeTabBarItemStylist()

                subject = SettingsController(tappableControllers: [
                    regularController
                    ],
                    analyticsService: analyticsService,
                    tabBarItemStylist: tabBarItemStylist,
                    theme: theme)

                navigationController = UINavigationController()
                navigationController.pushViewController(subject, animated: false)
            }

            it("has the correct navigation item title") {
                expect(subject.navigationItem.title).to(equal("More"))
            }

            it("has the correct tab bar title") {
                expect(subject.title).to(equal("More"))
            }

            it("should set the back bar button item title correctly") {
                expect(subject.navigationItem.backBarButtonItem?.title).to(equal("Back"))
            }

            it("tracks taps on the back button with the analytics service") {
                subject.didMoveToParentViewController(nil)

                expect(analyticsService.lastBackButtonTapScreen).to(equal("Settings"))
                expect(analyticsService.lastBackButtonTapAttributes).to(beNil())
            }

            describe("when the view loads") {
                beforeEach {
                    subject.view.layoutSubviews()
                }

                it("uses the tab bar item stylist to style its tab bar item") {
                    expect(tabBarItemStylist.lastReceivedTabBarItem).to(beIdenticalTo(subject.tabBarItem))

                    expect(tabBarItemStylist.lastReceivedTabBarImage).to(equal(UIImage(named: "moreTabBarIconInactive")))
                    expect(tabBarItemStylist.lastReceivedTabBarSelectedImage).to(equal(UIImage(named: "moreTabBarIcon")))
                }

                it("styles the views according to the theme") {
                    expect(subject.tableView.backgroundColor).to(equal(UIColor.orangeColor()))
                }

                it("should have rows in the table") {
                    expect(subject.tableView.numberOfSections).to(equal(1))
                    expect(subject.tableView.numberOfRowsInSection(0)).to(equal(1))
                }

                it("should style the regular rows using the theme") {
                    let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!

                    expect(cell.textLabel!.textColor).to(equal(UIColor.purpleColor()))
                    expect(cell.textLabel!.font).to(equal(UIFont.systemFontOfSize(123)))
                    expect(cell.backgroundColor).to(equal(UIColor.yellowColor()))
                }

                describe("the table contents") {
                    it("has a regular UITableViewCell row for evey configured 'regular' controller") {
                        let cell = subject.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!
                        expect(cell.textLabel!.text).to(equal("Regular Controller"))
                        expect(cell).to(beAnInstanceOf(UITableViewCell.self))
                    }

                    describe("tapping the rows") {
                        it("should push the correct view controller onto the nav stack when the other row is tapped") {
                            let tableView = subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
                            expect(subject.navigationController!.topViewController).to(beIdenticalTo(regularController))
                        }

                        it("should log a content view with the analytics service") {
                            let tableView = subject.tableView
                            tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))

                            expect(analyticsService.lastContentViewName).to(equal("Regular Controller"))
                            expect(analyticsService.lastContentViewType).to(equal(AnalyticsServiceContentType.Settings))
                            expect(analyticsService.lastContentViewID).to(equal("Regular Controller"))
                        }
                    }
                }
            }
        }
    }
}

private class SettingsFakeTheme: FakeTheme {
    override func defaultBackgroundColor() -> UIColor {
        return UIColor.orangeColor()
    }

    override func settingsTitleFont() -> UIFont {
        return UIFont.systemFontOfSize(123)
    }

    override func settingsTitleColor() -> UIColor {
        return UIColor.purpleColor()
    }

    override func defaultTableCellBackgroundColor() -> UIColor { return UIColor.yellowColor() }
}

private class FakeSettingsController : UIViewController {
    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
