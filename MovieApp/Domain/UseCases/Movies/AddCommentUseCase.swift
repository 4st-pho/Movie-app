import Foundation

protocol AddCommentUseCase {
    func execute(
        movieId: String,
        content: String,
        completion: @escaping (Result<Any?, Error>) -> Void
    )
}

final class DefaultAddCommentUseCase: AddCommentUseCase {
    private let moviesRepository: MoviesRepository
    private let appData = AppDataManager.shared
    
    init(moviesRepository: MoviesRepository = DefaultMovieRepository()) {
        self.moviesRepository = moviesRepository
    }
    
    func execute(movieId: String, content: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        let data = ["movieId": movieId, "userId": appData.getCurrentUser()?.id ?? "", "content": content]
        return moviesRepository.addComment(data: data, completion: completion)
    }
}
