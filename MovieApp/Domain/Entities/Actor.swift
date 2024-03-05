import Foundation

class Actor {
    var id: String
    var name: String
    var avatar: String
    init(id: String = "", name: String, avatar: String) {
        self.id = id
        self.name = name
        self.avatar = avatar
    }
}
