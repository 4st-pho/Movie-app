import Foundation
import RxSwift

protocol AddCommentUseCase {
    func execute(
        movieId: String,
        content: String
    ) -> Observable<Result<Any?, Error>>
}

final class DefaultAddCommentUseCase: AddCommentUseCase {
    
    private let moviesRepository: MoviesRepository
    private let appData: AppDataManager
    
    init(moviesRepository: MoviesRepository, appData: AppDataManager) {
        self.moviesRepository = moviesRepository
        self.appData = appData
    }
    
    func execute(movieId: String, content: String) -> RxSwift.Observable<Result<Any?, Error>> {
        let data = ["movieId": movieId, "userId": appData.getCurrentUser()?.id ?? "", "content": content]
        return Observable.create { signal in
            self.moviesRepository.addComment(data: data) { result in
                signal.onNext(result)
                signal.onCompleted()
            }
            return Disposables.create()
        }
    }
}
