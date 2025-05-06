import UIKit
import RxSwift
import RxCocoa

class WatchListViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var watchListTableView: UITableView!
    
    // MARK: - Variables
    let watchListCellNibName = String(describing: HorizontalMovieTableViewCell.self)
    private lazy var viewModel = WatchListViewModel()
    private var watchList: [Movie] = []
    private let removeMovieTrigger = PublishRelay<Int>()
    private var isLoggedIn = BehaviorRelay<Bool>(value: false)
    private let firstLoadTrigger = PublishRelay<Void>()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden  = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.firstLoadTrigger.accept(())
        super.viewWillAppear(animated)
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        
        let input = WatchListViewModel.Input(
            firstLoadTrigger: firstLoadTrigger.asDriverOnErrorJustComplete(),
            removeMovieAtIndex: removeMovieTrigger.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input: input)
        output.watchList.drive{ [weak self] in self?.updateWatchList($0) }.disposed(by: disposeBag)
        output.loadingState.drive{ [weak self] in self?.updateLoadingState($0) }.disposed(by: disposeBag)
        output.error.drive{ [weak self] in self?.showError($0) }.disposed(by: disposeBag)
        output.isLoggedIn.drive(onNext: { isLoggedIn in
            self.isLoggedIn.accept(isLoggedIn)
            self.watchListTableView.reloadData()
        }).disposed(by: disposeBag)
    }
    
    private func updateWatchList(_ watchList: [Movie]){
        self.watchList = watchList
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.watchListTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar(.menuSideAndNotification, title: "Watch list")
        setupTableView()
    }
    private func setupTableView(){
        self.watchListTableView.dataSource = self
        self.watchListTableView.delegate = self
        
        let watchListCellNib = UINib(nibName: watchListCellNibName, bundle: nil)
        self.watchListTableView.register(watchListCellNib, forCellReuseIdentifier: watchListCellNibName)
        
        self.watchListTableView.separatorStyle = .none
        self.watchListTableView.estimatedRowHeight = 175
        self.watchListTableView.rowHeight = UITableView.automaticDimension
    }
    
}


// MARK: - Search Result Table View Data Source

extension WatchListViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!isLoggedIn.value) {
            tableView.showPlaceholderView(type: .loginRequired, playholderDelegate: self)
            return 0
        }
        if watchList.isEmpty {
            tableView.showPlaceholderView(type: .emptyWatchList)
        }
        else{
            tableView.hidePlaceholderView()
        }
        return watchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: watchListCellNibName, for: indexPath) as? HorizontalMovieTableViewCell else { return UITableViewCell() }
        let movie = watchList[indexPath.row]
        let imageUrl = URL(string: movie.imageUrl)
        cell.movieImageView.kf.setImage(with: imageUrl)
        cell.movieNameLabel.text = movie.name
        cell.ratingLabel.text = movie.rating
        cell.durationLabel.text = movie.duration
        cell.categories = movie.categories
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Search Result Table View Delegate

extension WatchListViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.movie = self.watchList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            watchList.remove (at: indexPath.row)
            watchListTableView.deleteRows(at: [indexPath], with: .automatic)
            removeMovieTrigger.accept(indexPath.row)
        }
    }
}

extension WatchListViewController: LoggedInMiddlewareViewDelegate{
    func didTapLoginButton() {
        navigationController?.pushViewController(LoginViewController(), animated: true)
    }
}

