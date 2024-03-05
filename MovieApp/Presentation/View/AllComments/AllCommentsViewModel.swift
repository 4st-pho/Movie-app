import Foundation

class AllCommentsViewModel: BaseViewModel {
    var fetchCommentsRequestValue = FetchCommentsRequestValue(page: 1, pageSize: 20, movieId: "");
    private var fetchCommentsUseCase : FetchCommentsUseCase = DefaultFetchCommentsUseCase()
    
    var loadingState: Observable<Bool>  = Observable(false)
    let error: Observable<String> = Observable("")
    var hasMoreData: Observable<Bool>  = Observable(false)
    let comments: Observable<[Comment]> = Observable([])
    
    func load(showLoading: Bool = true) {
        self.loadingState.value = showLoading
        fetchComments { [weak self] in
            self?.loadingState.value = false
        }
    }
    
    func fetchComments(done: @escaping () -> Void) {
            self.fetchCommentsUseCase.execute(requestValue: fetchCommentsRequestValue)
            { [weak self] result in
                guard let self  = self else { return }
                done()
                switch result {
                case .success(let comments):
                    handleHasMoreData(result: comments)
                    if fetchCommentsRequestValue.page == 1 {
                        self.comments.value = comments
                    } else{
                        self.comments.value.append(contentsOf: comments)
                    }
                case .failure(let error):
                    self.error.value = error.localizedDescription
                }
            }
        
    }
    
    func loadMore (){
        fetchCommentsRequestValue.increamentPage()
        fetchComments(){}
    }
    
    private func handleHasMoreData(result: [Comment]){
        if result.isEmpty || result.count < fetchCommentsRequestValue.pageSize {
            hasMoreData.value = false
        }
        else {
            hasMoreData.value = true
        }
    }
}
