import UIKit
import Kingfisher

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
    private lazy var menu: [SideMenuModel] =
    viewModel.currentUser == nil ?
    [
        SideMenuModel(icon: UIImage(systemName: "person.fill")!, option: .login),
        SideMenuModel(icon: UIImage(systemName: "person.badge.plus.fill")!, option: .register)
    ] :
    [
        SideMenuModel(icon: UIImage(systemName: "person")! , option: .profile),
        SideMenuModel(icon: UIImage(systemName: "arrowshape.turn.up.left.fill")! , option: .logout),
    ]
    
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
        viewModel.reloadUserData()
    }
    // MARK: - Binding View Model
    private func bindingViewModel(){
        viewModel.reloadData.observe(on: self) { [weak self] in self?.reloadData($0) }
        viewModel.reloadApp.observe(on: self) { hasReload in
            if hasReload{
                Utils.resetRootView()
            }
        }
        viewModel.load()
    }
    func reloadData(_ needReload: Bool) {
        if needReload {
            guard let user = viewModel.currentUser else { return }
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
        guard let user = viewModel.currentUser else { return }
        headerImageView.layer.cornerRadius = 40
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.kf.setImage(with: URL(string: user.avatar))
        titleLabel.text = user.username
        subtitleLabel.text = user.email
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
                viewModel.logOut()
            }
            else{
                self.delegate?.sideMenuOptionSelected(option)
            }
            
        }
        
    }
}
