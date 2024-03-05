import UIKit
enum TypeOfMoviesView: String{
    case popular = "Popular"
    case newest = "Now Showing"
}

class ExploreMoviesViewController: BaseViewController {
    // MARK: - Variables
    let movieCellNibName = String(describing: HorizontalMovieTableViewCell.self)
    let loadingCellNibName = String(describing: LoadingTableViewCell.self)
    var typeOfMoviesView: TypeOfMoviesView?
    private let viewModel = ExploreMoviesViewModel()
    private var movies: [Movie]?
    private var hasMoreData = false
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var moviesTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingViewModel()
    }
    
    // MARK: - Binding View Model
    private func bindingViewModel(){
        viewModel.loadingState.observe(on: self) { [weak self] in self?.updateLoadingState($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.movies.observe(on: self) { [weak self] in self?.updateListOfMovies($0) }
        viewModel.hasMoreData.observe(on: self) { [weak self] in self?.handleHasMoreData($0) }
        if let typeOfMoviesView = typeOfMoviesView{
            viewModel.typeOfMoviesView = typeOfMoviesView
        }
        viewModel.load()
        
    }
    
    private func handleHasMoreData (_ hasMoreData: Bool) {
        self.hasMoreData = hasMoreData
        DispatchQueue.main.async { [weak self] in
            self?.moviesTableView.reloadData()
        }
    }
    
    private func updateListOfMovies(_ movies: [Movie]){
        self.movies = movies
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            self.moviesTableView.reloadData()
        }
    }
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        setupNavigationBar(title: typeOfMoviesView?.rawValue ?? "")
        tabBarController?.tabBar.isHidden  = true
    }
    
    
    private func setupTableView(){
        self.moviesTableView.dataSource = self
        self.moviesTableView.delegate = self
        
        let movieCellNib = UINib(nibName: movieCellNibName, bundle: nil)
        let loadingCellNib = UINib(nibName: loadingCellNibName, bundle: nil)
        self.moviesTableView.register(movieCellNib, forCellReuseIdentifier: movieCellNibName)
        self.moviesTableView.register(loadingCellNib, forCellReuseIdentifier: loadingCellNibName)
        
        self.moviesTableView.separatorStyle = .none
        self.moviesTableView.estimatedRowHeight = Constant.horiontalMovieTableViewCellHeight
        self.moviesTableView.rowHeight = UITableView.automaticDimension
        moviesTableView.showsVerticalScrollIndicator = false
    }
    
}

// MARK: - Movie Table View Data Source
extension ExploreMoviesViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let movies = movies else { return 0 }
        if movies.isEmpty { return 0 }
        if section == 1 { return hasMoreData ? 1 : 0 }
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1, let loadingCell =  tableView.dequeueReusableCell(withIdentifier: loadingCellNibName, for: indexPath) as? LoadingTableViewCell 
        { return loadingCell }
        
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: movieCellNibName, for: indexPath) as? HorizontalMovieTableViewCell, let movies = movies
        else { return UITableViewCell() }
        
        let movie = movies[indexPath.row]
        let imageUrl = URL(string: movie.imageUrl)
        cell.movieImageView.kf.setImage(with: imageUrl)
        cell.movieNameLabel.text = movie.name
        cell.ratingLabel.text = movie.rating
        cell.durationLabel.text = movie.duration
        cell.categories = movie.categories
        cell.layoutIfNeeded()
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

// MARK: - Movie Table View Delegate

extension ExploreMoviesViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.movie = self.movies?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
