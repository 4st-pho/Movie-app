import UIKit
import Kingfisher
import RxSwift
import RxCocoa

struct SideMenuModel {
    enum SideMenuOption: String {
        case login = "Login"
        case register = "Register"
        case logout = "Logout"
        case profile = "Profile"
    }
    
    var icon: UIImage
    var option: SideMenuOption
}

protocol SideMenuDelegate: AnyObject {
    func sideMenuOptionSelected(_ option: SideMenuModel.SideMenuOption)
}

class SideMenuViewController: UIViewController {
    private let disposeBag = DisposeBag()
    
    // MARK: - Outlets
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var sideMenuTableView: UITableView!
    
    // MARK: - Variables
    private let viewModel = SideMenuViewMode()
    weak var delegate: SideMenuDelegate?
    private let transitionManager = SideMenuTransitionManager()
    private let sideMenuCellNibName = String(describing: SideMenuCell.self)
    private let logoutTrigger = PublishRelay<Void>()
    private let reloadAppTrigger = PublishRelay<Void>()
    private let reloadDataTrigger = PublishRelay<Void>()
    private let currentUser = BehaviorRelay<User?>(value: nil)
    private var menu: [SideMenuModel] {
        return currentUser.value == nil ?
        [
            SideMenuModel(icon: UIImage(systemName: "person.fill")!, option: .login),
            SideMenuModel(icon: UIImage(systemName: "person.badge.plus.fill")!, option: .register)
        ] :
        [
            SideMenuModel(icon: UIImage(systemName: "person")! , option: .profile),
            SideMenuModel(icon: UIImage(systemName: "arrowshape.turn.up.left.fill")! , option: .logout),
        ]
    }
    
    // MARK: - Lifecycle
    init(delegate: SideMenuDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = transitionManager
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // MARK: - Binding View Model
    private func bindingViewModel(){
        let input = SideMenuViewMode.Input(
            reloadAppTrigger: reloadAppTrigger.asDriverOnErrorJustComplete(),
            reloadDataTrigger: reloadDataTrigger.asDriverOnErrorJustComplete(),
            logoutTrigger: logoutTrigger.asSignalOnErrorJustComplete()
        )
        
        let output = viewModel.transform(input: input)
        
        output.currentUser.drive(currentUser).disposed(by: disposeBag)
        
        currentUser.subscribe { _ in
            self.sideMenuTableView.reloadData()
        }.disposed(by: disposeBag)
        
        output.reloadApp.filter({$0}).drive { _ in
            Utils.resetRootView()
        }.disposed(by: disposeBag)
        
        output.reloadData.drive { [weak self] _ in
            self?.reloadData(true)
        }.disposed(by: disposeBag)
        
    }
    
    func reloadData(_ needReload: Bool) {
        if needReload {
            guard let user = currentUser.value else { return }
            headerImageView.kf.setImage(with: URL(string: user.avatar))
            titleLabel.text = user.username
            subtitleLabel.text = user.email
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        customOutlets()
    }
    
    private func setupTableView(){
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
        let nib = UINib(nibName: sideMenuCellNibName, bundle: nil)
        sideMenuTableView.register(nib, forCellReuseIdentifier: sideMenuCellNibName)
        
    }
    
    private func customOutlets(){
        currentUser.asDriverOnErrorJustComplete().drive { [weak self] user in
            guard let self  = self else { return }
            guard let user = user else { return }
            headerImageView.layer.cornerRadius = 40
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.kf.setImage(with: URL(string: user.avatar))
            titleLabel.text = user.username
            subtitleLabel.text = user.email
        }.disposed(by: disposeBag)
    }
}
// MARK: - Side Menu Table View Delegate
extension SideMenuViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

// MARK: - Side Menu Table Data Source
extension SideMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: sideMenuCellNibName, for: indexPath) as? SideMenuCell else { return UITableViewCell()}
        cell.iconImageView.image = self.menu[indexPath.row].icon
        cell.titleLabel.text = self.menu[indexPath.row].option.rawValue
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = menu[indexPath.row].option
        dismiss(animated: true){ [weak self] in
            guard let self = self else { return }
            if(option == .logout){
                logoutTrigger.accept(())
            }
            else{
                self.delegate?.sideMenuOptionSelected(option)
            }
            
        }
        
    }
}
