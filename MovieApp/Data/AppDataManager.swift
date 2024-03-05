import Foundation

class AppDataManager {
    private var currentUser: User?
    private let userCached = UserStorage()
    private var watchListIds: [String] = []
    private static let privateInstance = AppDataManager()
    static var shared : AppDataManager {
        return privateInstance
    }
    
    private init() {}
    
    func initialize(){
        let user = userCached.load()?.toDomain()
        watchListIds = user?.watchList ?? []
        setCurrentUser(user)
    }
    
    func setCurrentUser(_ user: User?) {
        currentUser = user
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func setWatchListIds(_ ids: [String]){
        watchListIds = ids
    }
    
    func getsWatchListIds() -> [String] {
        return watchListIds
    }
}
