import Foundation

struct WatchListActionRequestValue {
    let userId: String
    let movieId: String
}

struct FetchMoviesUseCaseRequestValue {
    var page: Int
    var pageSize: Int = 10
    mutating func increamentPage(){
        page += 1
    }
}

struct FetchCommentsRequestValue {
    var page: Int
    var pageSize: Int = 10
    var movieId: String
    mutating func increamentPage(){
        page += 1
    }
}
