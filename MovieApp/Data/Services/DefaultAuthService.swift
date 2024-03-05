
import Foundation

final class DefaultAuthService {
    private let apiClient: APIClient
    private let cache: UserStorage
    
    init(apiClient: APIClient = APIClient.shared, cache: UserStorage = UserStorage()) {
        self.apiClient = apiClient
        self.cache = cache
    }
}

extension DefaultAuthService : AuthService {
    func logIn(email: String, password: String, completion: @escaping (Result<(token: String, user: User), Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let parameters = ["email": email, "password": password]
            apiClient.request(endpoint: "/api/auth/login", method: .post, parameters: parameters)
            { (result : Result<LoginResponseDTO, Error> ) in
                switch result {
                case .success(let responseDTO):
                    self.cache.save(object: responseDTO.user)
                    self.cache.saveToken(token: responseDTO.token)
                    completion(.success(responseDTO.toDomain()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        
    }
    
    func register(email: String, username: String, password: String, completion: @escaping (Result<Any?, Error>) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self  = self else { return }
            let params = [ "email": email, "password": password, "username": username]
            apiClient.request(endpoint: "/api/auth/register", method: .post, parameters: params)
            { (result : Result<EmptyResponse, Error>) in
                switch result {
                case .success(_):
                    completion(.success(nil))
                case .failure(let error):
                    completion(.failure(error))
                }
                
            }
        }
    }
    
    func logOut(completion: @escaping (Result<Any?, Error>) -> Void) {
        cache.remove()
        completion(.success(nil))
    }
}
