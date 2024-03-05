import Foundation

// MARK: - UserDTO
struct LoginResponseDTO: Codable {
    let token: String
    let user: UserDTO
}

// MARK: - User
struct UserDTO: Codable {
    let id, username, password, email: String?
    let avatar: String?
    let watchList: [String]?
    let birthdate: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case username, password, email, avatar, watchList, birthdate
    }
}


extension UserDTO {
    
    func toDomain() -> User {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var date: Date? = nil
        if let birthdate = birthdate {
            date = dateFormatter.date(from: birthdate)
        }
        
        return User(
            id: id ?? "",
            email: email ?? "",
            username: username ?? "",
            avatar: avatar ?? "",
            watchList: watchList ?? [],
            birthdate: date
        )
    }
    
}

extension LoginResponseDTO{
    func toDomain() -> (token: String, user: User){
        return (token, user.toDomain())
    }
    
}
