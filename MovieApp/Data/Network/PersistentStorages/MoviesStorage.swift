import RealmSwift
import Foundation
import RealmSwift

class MoviesStorage : Cacheable {
    private let storage = RealmManager.shared
    enum CacheKey : String {
        case newestMoviesCacheKey
        case watchList
        case popularMoviesCacheKey
        case searchMoviesCacheKey
    }
    
    func saveList(object: [MovieDTO], with key: String) {
        storage.saveList(object: object, with: key)
    }
    
    func loadList(with key: String) -> [MovieDTO]? {
        return storage.loadList(with: key)
    }
    
    
    func load(with key: CacheKey) -> [MovieDTO]?{
        return loadList(with: key.rawValue)
    }
    
    func save(object: [MovieDTO], with key: CacheKey) {
        saveList(object: object, with: key.rawValue)
    }
    
    typealias ObjectType = [MovieDTO]
}
