import Vapor

struct SignupModel: Content, Codable {
    let email: String
    let password: String
}
