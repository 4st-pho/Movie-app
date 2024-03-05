import Foundation

class UserStorage : Cacheable {
    private let userDefaults = UserDefaults.standard
    private let cacheKey = "UserCache"
    private let tokenCacheKey = "TokenCache"
    
    func save(object: UserDTO) {
        if let encodedData = try? JSONEncoder().encode(object) {
            userDefaults.set(encodedData, forKey: cacheKey)
        }
    }
    
    func load() -> UserDTO? {
        if let savedData = userDefaults.data(forKey: cacheKey),
           let cachedMovies = try? JSONDecoder().decode(UserDTO.self, from: savedData) {
            return cachedMovies
        }
        return nil
    }
    
    func saveToken(token: String) {
        userDefaults.set(token, forKey: tokenCacheKey)
    }
    
    func loadToken() -> String? {
        return userDefaults.string(forKey: tokenCacheKey)
    }
    
    func remove() {
        userDefaults.removeObject(forKey: cacheKey)
        userDefaults.removeObject(forKey: tokenCacheKey)
    }
    
    typealias ObjectType = UserDTO
}
