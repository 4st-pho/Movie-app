import Foundation
protocol BaseViewModel {
    func load(showLoading: Bool, completion: (() -> Void)?)
}

extension BaseViewModel {
    func load(showLoading: Bool, completion: (() -> Void)? = nil){
        
    }
}
