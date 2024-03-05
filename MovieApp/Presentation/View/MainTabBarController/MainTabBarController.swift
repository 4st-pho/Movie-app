import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Variables
    let viewModel = MainTapBarViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        viewModel.load()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        initTabBar()
        addBorder()
    }
    
    private func initTabBar() {
        let homeVC = HomeViewController()
        let homeNA = UINavigationController(rootViewController: homeVC)
        let searchVC = MovieSearchViewController()
        let searchNA = UINavigationController(rootViewController: searchVC)
        let watchListVC = WatchListViewController()
        let watchListNA = UINavigationController(rootViewController: watchListVC)
        homeVC.tabBarItem = UITabBarItem(
            title: "Home",
            image: .home,
            selectedImage: .homeActive
        )
        searchVC.tabBarItem = UITabBarItem(
            title: "Search",
            image: .search,
            selectedImage: .searchActive
        )
        watchListVC.tabBarItem = UITabBarItem(
            title: "Watch list",
            image: .bookmark,
            selectedImage: .bookmarkActive
        )
        viewControllers = [homeNA, searchNA, watchListNA]
    }
    
    private func addBorder(){
        let borderView = UIView(frame: CGRect(x: 0, y: -1, width: self.tabBar.frame.size.width, height: 1))
        borderView.backgroundColor = UIColor.tintColor.withAlphaComponent(0.7)
        self.tabBar.addSubview(borderView)
    }
}
