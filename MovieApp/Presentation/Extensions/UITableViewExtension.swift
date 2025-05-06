import UIKit



extension UITableView {
    enum EmptyViewAlign{
        case center
        case top(padding: Double = 20)
    }
    
    enum PlaceholderViewType{
        case searchNoResults
        case loginRequired
        case emptyWatchList
    }
    enum PlaceholderSize{
        case full
        case half
    }
    
    func showPlaceholderView(type: PlaceholderViewType, align: EmptyViewAlign = .center, size: PlaceholderSize = .full, playholder: UIView? = nil, playholderDelegate: AnyObject? = nil) {
        var playholder = playholder ?? UIView()
        let contaner = UIView(frame: self.bounds)
        self.backgroundView = contaner
        
        switch type {
        case .searchNoResults:
            let view: EmptyListView = .fromNib()
            playholder = view
            
        case .loginRequired:
            let view: LoggedInMiddlewareView = .fromNib()
            if let playholderDelegate = playholderDelegate as? LoggedInMiddlewareViewDelegate{
                view.delegate = playholderDelegate
            }
            playholder = view
        case .emptyWatchList:
            let view: EmptyListView = .fromNib()
            view.imageView.image = .emptyBox
            view.titlelabel.text = "There is no movie yet!"
            view.subtitleLabel.text = "Find your movie by Type title, categories, years, etc"
            playholder = view
        }
        contaner.addSubview(playholder)
        playholder.translatesAutoresizingMaskIntoConstraints = false
        
        switch size {
        case .full:
            NSLayoutConstraint.activate([
                playholder.widthAnchor.constraint(equalTo: contaner.widthAnchor),
                playholder.heightAnchor.constraint(equalTo: contaner.heightAnchor)
                
            ])
        case .half:
            NSLayoutConstraint.activate([
                playholder.widthAnchor.constraint(equalTo: contaner.widthAnchor, multiplier: 0.5),
                playholder.heightAnchor.constraint(equalTo: contaner.heightAnchor, multiplier: 0.5)
            ])
        }
        
        switch align {
        case .center:
            NSLayoutConstraint.activate([
                playholder.centerXAnchor.constraint(equalTo: contaner.centerXAnchor),
                playholder.centerYAnchor.constraint(equalTo: contaner.centerYAnchor),
            ])
        case .top(let padding):
            NSLayoutConstraint.activate([
                playholder.leadingAnchor.constraint(equalTo: contaner.leadingAnchor),
                playholder.trailingAnchor.constraint(equalTo: contaner.trailingAnchor),
                playholder.topAnchor.constraint(equalTo: contaner.topAnchor, constant: padding),
            ])
        }
    }
    
    func hidePlaceholderView() {
        self.backgroundView = nil
    }
}

extension UITableView {
    func register(cellType: UITableViewCell.Type) {
        let className = cellType.className
        register(cellType, forCellReuseIdentifier: className)
    }

    func register(cellTypes: [UITableViewCell.Type]) {
        cellTypes.forEach { register(cellType: $0) }
    }
    
    func register(nibType: UITableViewCell.Type) {
        let className = nibType.className
        let nib = UINib(nibName: className, bundle: nil)
        register(nib, forCellReuseIdentifier: className)
    }
    
    func register(nibTypes: [UITableViewCell.Type]) {
        nibTypes.forEach { register(nibType: $0) }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(with type: T.Type, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: type.className, for: indexPath) as! T
    }
}

public extension UITableView {
    func tableHeaderViewSizeToFit() {
        tableHeaderOrFooterViewSizeToFit(\.tableHeaderView)
    }

    func tableFooterViewSizeToFit() {
        tableHeaderOrFooterViewSizeToFit(\.tableFooterView)
    }

    private func tableHeaderOrFooterViewSizeToFit(_ keyPath: ReferenceWritableKeyPath<UITableView, UIView?>) {
        guard let headerOrFooterView = self[keyPath: keyPath] else { return }
        let height = headerOrFooterView
            .systemLayoutSizeFitting(CGSize(width: frame.width, height: 0),
                                     withHorizontalFittingPriority: .required,
                                     verticalFittingPriority: .fittingSizeLevel).height
        guard headerOrFooterView.frame.height != height else { return }
        headerOrFooterView.frame.size.height = height
        self[keyPath: keyPath] = headerOrFooterView
    }

    func deselectSelectedRow(animated: Bool) {
        guard let indexPathForSelectedRow = indexPathForSelectedRow else { return }
        deselectRow(at: indexPathForSelectedRow, animated: animated)
    }

    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
}
