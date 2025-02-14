import Vapor

struct LoginModel: Codable, Content {
    var email: String
    var password: String
}
