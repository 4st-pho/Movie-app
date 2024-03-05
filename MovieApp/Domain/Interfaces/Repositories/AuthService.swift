import Foundation

protocol AuthService {
    func logIn(email: String, password: String, completion: @escaping (Result<(token: String, user: User), Error>) -> Void)
    func register(email: String, username: String, password: String, completion: @escaping (Result<Any?, Error>) -> Void)
    func logOut(completion: @escaping (Result<Any?, Error>) -> Void)
}
