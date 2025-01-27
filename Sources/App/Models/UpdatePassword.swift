import Vapor

struct UpdatePassword: Codable, Content {
    var password: String
    var token: String
}
