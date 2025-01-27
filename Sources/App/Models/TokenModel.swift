import Vapor

struct TokenModel: Codable, Content {
    let value: String
    let userId: UUID?
    let user: [String: String]
    enum CodingKeys: String, CodingKey {
        case value, user
        case userId = "user_id"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.value = try container.decode(String.self, forKey: .value)
        self.user = try container.decode([String: String].self, forKey: .user)
        self.userId = UUID.init(uuidString: user["id"] ?? "") ?? nil
    }
}
