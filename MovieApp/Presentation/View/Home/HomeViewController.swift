import UIKit
import Kingfisher

enum HomeSectionHeader: String, CaseIterable{
    case nowShowing = "Now Showing"
    case popular = "Popular"
}

class HomeViewController: BaseViewController {
    
    // MARK: - Variables
    private var viewModel =  HomeViewModel()
    private let popularMoviesCellNibName = String(describing: HorizontalMovieTableViewCell.self)
    private let movieSectionHeaderNibName = String(describing: MovieSectionHeader.self)
    private let newestMoviesCellNibName = String(describing: NewestMoviesTableViewCell.self)
    private var popularMovies: [Movie] = []
    private let sectionHeaderTitle: [String] = HomeSectionHeader.allCases.map{$0.rawValue}
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var moviesTableView: UITableView!
    
    // MARK: - UI Components
    let refreshControl = UIRefreshControl()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindingData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden  = false
        navigationController?.hidesBarsOnSwipe = false
        super.viewWillAppear(animated)
    }
    
    // MARK: - Data setup
    private func bindingData(){
        viewModel.newestMovies.observe(on: self) { [weak self] in self?.updateNewestMovies($0) }
        viewModel.popularMovies.observe(on: self) { [weak self] in self?.updatePopularMovies($0) }
        viewModel.loadingState.observe(on: self) { [weak self] in self?.updateLoadingState($0) }
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.load()
    }
    
    private func updateNewestMovies(_ movies: [Movie]){
        DispatchQueue.main.async { [weak self] in
            guard let self  = self else { return }
            let indexPath = (IndexPath(row: 0, section: 0))
            guard let cell =  self.moviesTableView.cellForRow(at: indexPath) as? NewestMoviesTableViewCell else { return }
            cell.movies = movies
            cell.collectionView.reloadData()
        }
    }
    
    private func updatePopularMovies(_ movies: [Movie]){
        popularMovies = movies
        DispatchQueue.main.async { [weak self] in
            self?.moviesTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        setupNavigationBar(.menuSideAndNotification, title: "FilmKu")
    }
    
    private func setupTableView(){
        moviesTableView.dataSource = self
        moviesTableView.delegate = self
        
        let popularMoviesCellNib = UINib(nibName: popularMoviesCellNibName, bundle: nil)
        let newestMoviesCellNib = UINib(nibName: newestMoviesCellNibName, bundle: nil)
        let movieSectionHeaderNib = UINib(nibName: movieSectionHeaderNibName, bundle: nil)
        moviesTableView.register(popularMoviesCellNib, forCellReuseIdentifier: popularMoviesCellNibName)
        moviesTableView.register(newestMoviesCellNib, forCellReuseIdentifier: newestMoviesCellNibName)
        moviesTableView.register(movieSectionHeaderNib, forHeaderFooterViewReuseIdentifier: movieSectionHeaderNibName)
        
        
        moviesTableView.separatorStyle = .none
        moviesTableView.estimatedRowHeight = Constant.horiontalMovieTableViewCellHeight
        moviesTableView.rowHeight = UITableView.automaticDimension
        
        moviesTableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        moviesTableView.showsVerticalScrollIndicator = false
    }
    
    // MARK: - Selectors
    @objc private func refreshData() {
        viewModel.load(showLoading: false) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Popular Movie Table View Data Source
extension HomeViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaderTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return popularMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let cell =  tableView.dequeueReusableCell(withIdentifier: newestMoviesCellNibName, for: indexPath) as? NewestMoviesTableViewCell
        {
            cell.delegate = self
            return cell
        }
        
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: popularMoviesCellNibName, for: indexPath) as? HorizontalMovieTableViewCell else{
            return UITableViewCell()
        }
        let movie = popularMovies[indexPath.row]
        let imageUrl = URL(string: movie.imageUrl)
        cell.movieImageView.kf.setImage(with: imageUrl)
        cell.movieNameLabel.text = movie.name
        cell.ratingLabel.text = movie.rating
        cell.durationLabel.text = movie.duration
        cell.categories = movie.categories
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let movieHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: movieSectionHeaderNibName) as? MovieSectionHeader
        movieHeader?.delegate = self
        movieHeader?.titleLabel.text = sectionHeaderTitle[section]
        movieHeader?.contentView.layoutMargins = UIEdgeInsets.zero
        movieHeader?.contentView.preservesSuperviewLayoutMargins = false
        return movieHeader
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constant.sectionHeaderHeight
    }
}

// MARK: - Popular Movie Table View Delegate
extension HomeViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.movie = popularMovies[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Newest Movie Table View Delegate
extension HomeViewController: NewestMoviesTableViewCellDelegate{
    func didSelectCollectionCell(_ tableViewCell: NewestMoviesTableViewCell, movie: Movie) {
        let vc = MovieDetailViewController()
        vc.movie = movie
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - Newest Movie Table View Delegate
extension HomeViewController: MovieSectionHeaderDelegate {
    func didSelectSeeMoreButton(title: String) {
        let homeSectionHeader = HomeSectionHeader(rawValue: title)
        let vc = ExploreMoviesViewController()
        vc.typeOfMoviesView = homeSectionHeader == .nowShowing ? .newest : .popular
        navigationController?.pushViewController(vc, animated: true)
    }
}
