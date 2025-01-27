import Vapor

struct UserModel: Codable, Content {
    var email: String
    var password: String
}
