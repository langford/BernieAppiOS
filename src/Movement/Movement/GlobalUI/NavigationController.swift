import UIKit

class NavigationController: UINavigationController {
    private let theme: Theme

    init(theme: Theme) {
        self.theme = theme
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = theme.defaultBackgroundColor()
        setNeedsStatusBarAppearanceUpdate()
        navigationBar.translucent = false
        navigationBar.barTintColor = theme.navigationBarBackgroundColor()
        navigationBar.tintColor = theme.navigationBarTextColor()
        navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: theme.navigationBarTextColor(),
            NSFontAttributeName: theme.navigationBarFont()
        ]

        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSForegroundColorAttributeName: theme.navigationBarTextColor(),
            NSFontAttributeName: theme.navigationBarButtonFont()], forState: .Normal
        )
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}
