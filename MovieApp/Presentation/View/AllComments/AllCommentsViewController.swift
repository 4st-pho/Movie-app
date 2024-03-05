import UIKit

class AllCommentsViewController: BaseViewController {
    private lazy var viewModel  = AllCommentsViewModel()
    private var comments: [Comment] = []
    var movieId = ""
    private var hasMoreData = false
    private let movieCellNibName = String(describing: CommentsTableViewCell.self)
    private let loadingCellNibName = String(describing: LoadingTableViewCell.self)
    // MARK: - Outlets
    @IBOutlet weak var commentsTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        viewModel.fetchCommentsRequestValue.movieId = movieId
        viewModel.loadingState.observe(on: self) { [weak self] in self?.updateLoadingState($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.comments.observe(on: self) { [weak self] in self?.updateComments($0) }
        viewModel.load()
    }
    
    private func updateComments(_ comments: [Comment]) {
        self.comments = comments
        DispatchQueue.main.async { [weak self] in
            self?.commentsTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        setupNavigationBar(title: "All Comments")
    }
    
    private func setupTableView(){
        commentsTableView.dataSource = self
        let movieCellNib = UINib(nibName: movieCellNibName, bundle: nil)
        let loadingCellNib = UINib(nibName: loadingCellNibName, bundle: nil)
        commentsTableView.register(movieCellNib, forCellReuseIdentifier: movieCellNibName)
        commentsTableView.register(loadingCellNib, forCellReuseIdentifier: loadingCellNibName)
        commentsTableView.estimatedRowHeight = Constant.commentsTableViewCellHeight
        commentsTableView.rowHeight = UITableView.automaticDimension
    }
}

extension AllCommentsViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if comments.isEmpty { return 0 }
        if section == 1 { return hasMoreData ? 1 : 0 }
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1, let loadingCell =  tableView.dequeueReusableCell(withIdentifier: loadingCellNibName, for: indexPath) as? LoadingTableViewCell
        { return loadingCell }
        
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: movieCellNibName, for: indexPath) as? CommentsTableViewCell
        else { return UITableViewCell() }
        
        let comment = comments[indexPath.row]
        cell.usernameLabel.text = comment.user.username
        cell.commentLabel.text = comment.content
        cell.avatarImageView.kf.setImage(with: URL(string: comment.user.avatar))
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            viewModel.loadMore()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
