import Foundation

class User {
    var id: String
    var email: String
    var username: String
    var password: String
    var avatar: String
    var birthdate: Date?
    var watchList: [String]
    
    init(id: String = "", email: String, username: String, password: String = "", avatar: String = "", watchList: [String], birthdate: Date?) {
        self.id = id
        self.email = email
        self.username = username
        self.password = password
        self.avatar = avatar
        self.watchList = watchList
        self.birthdate = birthdate
    }
}
