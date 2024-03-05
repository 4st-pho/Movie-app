import UIKit

class MovieSearchViewController: BaseViewController {
    
    // MARK: - Variables
    var searchResult : [Movie]?
    let searchResultCellNibName = String(describing: SearchMovieTableViewCell.self)
    let loadingCellNibName = String(describing: LoadingTableViewCell.self)
    let viewModel = MovieSearchViewModel()
    private var hasMoreData: Bool = false
    
    // MARK: - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchResultTableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden  = false
        self.navigationController?.hidesBarsOnSwipe = false
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
    }
    
    // MARK: - Binding
    private func binding(){
        viewModel.error.observe(on: self) { [weak self] in self?.showError($0) }
        viewModel.searchResult.observe(on: self) { [weak self] in self?.loadSearchResult($0) }
        viewModel.hasMoreData.observe(on: self) { [weak self] in self?.handleHasMoreData($0) }
        viewModel.load()
    }
    
    private func handleHasMoreData (_ hasMoreData: Bool) {
        self.hasMoreData = hasMoreData
        DispatchQueue.main.async { [weak self] in
            self?.searchResultTableView.reloadData()
        }
    }
    private func loadSearchResult(_ result: [Movie]?){
        searchResult = result
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.searchResultTableView.reloadData()
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupTableView()
        setupSearchBar()
        setupNavigationBar(.hidden)
    }
    
    private func setupSearchBar(){
        searchBar.delegate = self
        
    }
    
    private func setupTableView(){
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
        
        let searchResultCellNib = UINib(nibName: searchResultCellNibName, bundle: nil)
        let loadingCellNib = UINib(nibName: loadingCellNibName, bundle: nil)
        searchResultTableView.register(searchResultCellNib, forCellReuseIdentifier: searchResultCellNibName)
        searchResultTableView.register(loadingCellNib, forCellReuseIdentifier: loadingCellNibName)
        
        searchResultTableView.separatorStyle = .none
        searchResultTableView.estimatedRowHeight = 175
        searchResultTableView.rowHeight = UITableView.automaticDimension
        searchResultTableView.showsVerticalScrollIndicator = false
    }
    
}


// MARK: - Search Result Table View Data Source
extension MovieSearchViewController : UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let searchResult = searchResult else { return 0 }
        if searchResult.isEmpty {
            tableView.showPlaceholderView(type: .searchNoResults)
            return 0
        }
        else{
            tableView.hidePlaceholderView()
        }
        if section == 1 { return hasMoreData ? 1 : 0 }
        return searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1, let loadingCell =  tableView.dequeueReusableCell(withIdentifier: loadingCellNibName, for: indexPath) as? LoadingTableViewCell {
            return loadingCell
        }
        
        guard let cell =  tableView.dequeueReusableCell(withIdentifier: searchResultCellNibName, for: indexPath) as? SearchMovieTableViewCell,
              let searchResult = searchResult
        else { return UITableViewCell() }
        let movie = searchResult[indexPath.row]
        let imageUrl = URL(string: movie.imageUrl)
        cell.movieImageView.kf.setImage(with: imageUrl)
        cell.movieNameLabel.text = movie.name
        cell.ratingLabel.text = movie.rating
        cell.categories = movie.categories
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

// MARK: - Search Result Table View Delegate

extension MovieSearchViewController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MovieDetailViewController()
        vc.movie = self.searchResult?[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MovieSearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.search(keyword: searchText)
    }
}
