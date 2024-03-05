import UIKit

class OnboardingViewController: UIViewController {
    // MARK: - Outlets
    @IBOutlet private(set) weak var onboardingView: UIView!
    @IBOutlet private(set) weak var pageControl: UIPageControl!
    @IBOutlet weak var navigateNextPageButtonView: UIView!
    
    // MARK: - UI Components
    var pageViewController = UIPageViewController(
        transitionStyle: .scroll,
        navigationOrientation: .horizontal,
        options: nil
    )
    
    lazy var circularProgessButton: CircularProgessButton = {
        let circularProgessButton = CircularProgessButton(frame: self.navigateNextPageButtonView.bounds)
        let tap = UITapGestureRecognizer(target: self, action: #selector(jumpToNextPage))
        circularProgessButton.addGestureRecognizer(tap)
        return circularProgessButton
    }()
    
    
    private let pages: [UIViewController] = [OnboardingItem1ViewController(), OnboardingItem2ViewController(), OnboardingItem3ViewController()]
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupPageView()
        navigateNextPageButtonView.addSubview(circularProgessButton)
    }
    
    private func setupPageView(){
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = self.onboardingView.bounds
        self.onboardingView.addSubview(pageViewController.view)
        if let firstPage = pages.first {
            pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        pageViewController.didMove(toParent: self)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
    }
    
    private func updatePageControlState(currentIndex: Int){
        pageControl.currentPage = currentIndex
        let percent = Double(currentIndex) / (Double(pageControl.numberOfPages) - 1) * 100
        circularProgessButton.progressAnimation(to: percent)
    }
    
    // MARK: - Selectors
    @objc func jumpToNextPage(){
        if pageControl.currentPage < pageControl.numberOfPages - 1 {
            let vc = pages[pageControl.currentPage + 1]
            pageViewController.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            updatePageControlState(currentIndex: pageControl.currentPage + 1)
        }
        else {
            Utils.skipOnboarding()
            Utils.resetRootView()
        }
    }
}

// MARK: - Onboarding Page View Controller DataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex > 0 else { return nil }
        return pages[currentIndex - 1]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pages.firstIndex(of: viewController), currentIndex < pages.count - 1 else { return nil }
        return pages[currentIndex + 1]
    }
    
    
}

// MARK: - Onboarding Page View Controller Delegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            updatePageControlState(currentIndex: currentIndex)
        }
    }
}
