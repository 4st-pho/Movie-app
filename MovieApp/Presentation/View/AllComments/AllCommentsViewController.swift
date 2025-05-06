import UIKit
import RxSwift
import RxCocoa

class AllCommentsViewController: BaseViewController {
    private lazy var viewModel  = AllCommentsViewModel()
    private var comments: [Comment] = []
    var movieId = ""
    private var hasMoreData = false
    private let movieCellNibName = String(describing: CommentsTableViewCell.self)
    private let loadingCellNibName = String(describing: LoadingTableViewCell.self)
    // MARK: - Outlets
    private let loadMoreTrigger = PublishSubject<Void>()
    @IBOutlet weak var commentsTableView: UITableView! {
        didSet {
            commentsTableView.letIt {
                $0.dataSource = self
                $0.register(nibTypes: [CommentsTableViewCell.self, LoadingTableViewCell.self])
                $0.estimatedRowHeight = Constant.commentsTableViewCellHeight
                $0.rowHeight = UITableView.automaticDimension
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel() {
        let input = AllCommentsViewModel.Input(
            firstTimeLoad: Driver.just(()),
            loadMoreTrigger: loadMoreTrigger.asDriverOnErrorJustComplete(),
            movieId: Driver.just(self.movieId)
        )
        
        let output = viewModel.transform(input: input)
        
        output.loadingState.drive { [weak self] state in
            self?.updateLoadingState(state)
        }.disposed(by: disposeBag)
        
        output.error.drive { [weak self] error in
            self?.showError(error)
        }.disposed(by: disposeBag)
        
        output.comments.drive {[weak self] comments in
            self?.updateComments(comments)
        }.disposed(by: disposeBag)
    }
    
    private func updateComments(_ comments: [Comment]) {
        self.comments = comments
        DispatchQueue.main.async { [weak self] in
            self?.commentsTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar(title: "All Comments")
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
        if indexPath.section == 1 {
            return tableView.dequeueReusableCell(with: LoadingTableViewCell.self,for: indexPath)
        }
        
        let cell =  tableView.dequeueReusableCell(with: CommentsTableViewCell.self, for: indexPath)
        let comment = comments[indexPath.row]
        cell.commentLabel.text = comment.content
        cell.avatarImageView.kf.setImage(with: URL(string: comment.user.avatar))
        cell.usernameLabel.text = comment.user.username
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            loadMoreTrigger.onNext(())
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
