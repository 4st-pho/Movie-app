import UIKit
import Kingfisher
import RxSwift
import RxCocoa

enum HomeSectionHeader: String, CaseIterable{
    case nowShowing = "Now Showing"
    case popular = "Popular"
}

class HomeViewController: BaseViewController {
    
    // MARK: - Variables
    private var viewModel =  HomeViewModel()
    private var popularMovies: [Movie] = []
    private let sectionHeaderTitle: [String] = HomeSectionHeader.allCases.map{$0.rawValue}
    
    let firstLoadTrigger = PublishRelay<Void>()
    let showAppLoading = BehaviorRelay<Bool>(value: true)
    
    // MARK: - Outlets
    @IBOutlet private(set) weak var moviesTableView: UITableView! {
        didSet {
            moviesTableView.letIt {
                $0.register(nibTypes: [HorizontalMovieTableViewCell.self, NewestMoviesTableViewCell.self])
                $0.register(
                    UINib(nibName: MovieSectionHeader.className, bundle: nil),
                    forHeaderFooterViewReuseIdentifier: MovieSectionHeader.className
                )
                $0.dataSource = self
                $0.delegate = self
                
                $0.separatorStyle = .none
                $0.estimatedRowHeight = Constant.horiontalMovieTableViewCellHeight
                $0.rowHeight = UITableView.automaticDimension
                
                $0.refreshControl = refreshControl
                $0.showsVerticalScrollIndicator = false
            }
        }
    }
    
    // MARK: - UI Components
    var refreshControl = UIRefreshControl() {
        didSet {
            refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)        }
    }
    
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

        
        let input = HomeViewModel.Input(
            firstLoadTrigger: firstLoadTrigger.asDriverOnErrorJustComplete(),
            showAppLoading: showAppLoading.asDriverOnErrorJustComplete()
        )
        let output = viewModel.transform(input: input)
        output.newestMovies.drive {[weak self] in self?.updateNewestMovies($0) }.disposed(by: disposeBag)
        output.popularMovies.drive{ [weak self] in self?.updatePopularMovies($0) }.disposed(by: disposeBag)
        output.loadingState.drive{ [weak self] in self?.updateLoadingState($0) }.disposed(by: disposeBag)
        output.error.drive{ [weak self] in self?.showError($0) }.disposed(by: disposeBag)
        output.firstLoadFinish.drive{[weak self] _ in self?.refreshControl.endRefreshing() }.disposed(by: disposeBag)
        firstLoadTrigger.accept(())
    }
    
    private func updateNewestMovies(_ movies: [Movie]) {
        let indexPath = (IndexPath(row: 0, section: 0))
        guard let cell =  self.moviesTableView.cellForRow(at: indexPath) as? NewestMoviesTableViewCell else { return }
        cell.movies = movies
        cell.collectionView.reloadData()
        
    }
    
    private func updatePopularMovies(_ movies: [Movie]) {
        popularMovies = movies
        moviesTableView.reloadData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupNavigationBar(.menuSideAndNotification, title: "FilmKu")
    }
    
    // MARK: - Selectors
    @objc private func refreshData() {
        showAppLoading.accept(false)
        firstLoadTrigger.accept(())
    }
}

// MARK: - Popular Movie Table View Data Source
extension HomeViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaderTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        return popularMovies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell =  tableView.dequeueReusableCell(with: NewestMoviesTableViewCell.self, for: indexPath)
            cell.delegate = self
            return cell
        }
        
        let cell =  tableView.dequeueReusableCell(with: HorizontalMovieTableViewCell.self, for: indexPath)
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
        let movieHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: MovieSectionHeader.className) as? MovieSectionHeader
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
