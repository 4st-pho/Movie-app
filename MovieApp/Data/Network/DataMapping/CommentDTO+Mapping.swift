import Foundation

// MARK: - Comment DTO
struct CommentDTO: Codable {
    let id: String?
    let movieId: String?
    let user: UserDTO?
    let content: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case user = "userId"
        case movieId, content
    }
}

extension CommentDTO {
    func toDomain() -> Comment {
        return Comment(id: id ?? "", movieId: movieId ?? "", user: user!.toDomain(), content: content ?? "")
    }
}

