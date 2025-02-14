import Vapor

struct SignupModel: Content, Codable {
    let name: String
    let email: String
    let password: String
}
