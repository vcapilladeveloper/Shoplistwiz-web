import Vapor

struct UserModel: Codable, Content {
    var name: String
    var email: String
    var password: String
}
