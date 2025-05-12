import UIKit
import SwiftUI
import RxSwift

enum NavigationBarType{
    case defaultNavigationBar
    case hidden
    case transparentWithBackAndMenuButton
    case menuSideAndNotification
    
}

class BaseViewController: UIViewController, Alertable {
    // MARK: - Variables
    private var navigationBarType = NavigationBarType.defaultNavigationBar
    private lazy var isSideMenuOpen = false
    private lazy var sideMenuWidth = self.view.frame.width * 0.6
    let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private lazy var menuButton =  UIBarButtonItem(
        image: UIImage.menu,
        style: .plain, target: self, action: #selector(openSidebar)
    )
    
    private lazy var menuView : UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        return view
    }()
    
    private lazy var notificationButton = UIBarButtonItem(
        image: UIImage(systemName: "bell"),
        style: .plain, target: self, action: #selector(moreActionButtonTapped)
    )
    
    private lazy var whiteBackButton =  UIBarButtonItem(
        image: UIImage.back,
        style: .plain, target: self, action: #selector(backButtonTapped)
    )
    private lazy var moreOptionButton =  UIBarButtonItem(
        image: UIImage.more,
        style: .plain, target: self, action: #selector(moreOptionButtonTapped)
    )
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    
    
    
    // MARK: - UI Setup
    
    private func setupUI() {
        self.setupTapGesture()
        self.setupNavigationBar(.defaultNavigationBar)
    }
    
    func setupNavigationBar(_ type : NavigationBarType = .defaultNavigationBar, title: String = "", prefersLargeTitles: Bool = false) {
        self.navigationItem.title = title
        self.navigationController?.navigationBar.prefersLargeTitles = prefersLargeTitles
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        switch type {
        case .defaultNavigationBar:
            self.navigationController?.navigationBar.backgroundColor = .systemBackground
            self.navigationController?.navigationBar.tintColor = .tintColor
            
        case .transparentWithBackAndMenuButton :
            self.navigationController?.navigationBar.backgroundColor = .clear
//            self.navigationController?.navigationBar.tintColor = .white
            self.navigationItem.leftBarButtonItem = whiteBackButton
            self.navigationItem.rightBarButtonItem = moreOptionButton
            
        case .menuSideAndNotification :
            self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.appDarkPuple]
            self.navigationItem.leftBarButtonItem = menuButton
            self.navigationItem.rightBarButtonItem = notificationButton
            
        case .hidden:
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Handle View Model Events
    func updateLoadingState(_ isLoading: Bool){
        DispatchQueue.main.async {
            if isLoading {
                LoadingView.show()
            }
            else {
                LoadingView.hide()
            }
            
        }
    }
    
    func showError(_ error: String) {
        guard !error.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            LoadingView.hide()
            showAlert(title: "Error", message: error)
        }
    }
    
    func showMessage(_ message: String, title: String = "") {
        guard !message.isEmpty else { return }
        DispatchQueue.main.async { [weak self] in
            self?.showAlert(title: title, message: message)
        }
    }
    
    // MARK: - Selectors
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func openSidebar() {
        let sideMenu = SideMenuViewController(delegate: self)
        present(sideMenu, animated: true)
    }
    
    @objc func moreActionButtonTapped() {
        
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func moreOptionButtonTapped() {
    }
    
    
}

extension BaseViewController: SideMenuDelegate {
    func sideMenuOptionSelected(_ option: SideMenuModel.SideMenuOption) {
        switch option {
        case .login:
            navigationController?.pushView(LoginView(), animated: true)
        case .register:
            navigationController?.pushView(RegisterView(), animated: true)
        case .profile:
            navigationController?.pushViewController(UserProfileViewController(), animated: true)
        case .logout:
            print(option.rawValue)
        }
    }
    
    
}
