import Vapor

struct DashboardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webDashboard = routes.grouped("dashboard")
        webDashboard.get { req -> View in
            guard let token = req.cookies["token"]?.string else {
                return try await req.view.render("login")
            }
            let userInfo = try await getUserInfo(token: token, req: req)
            // Create context with session data
            let context: [String: String] = [
                "token": token,
                "email": userInfo.email,
                "password": userInfo.password,
                "id": userInfo.id
            ]
            
            return try await req.view.render("dashboard", context)
        }
    }
    
    private func getUserInfo(token: String, req: Request) async throws -> UserInfo {
        let url = URI(string: "http://localhost:8081/api/me")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        return try await req.client.get(url, headers: headers).content.decode(UserInfo.self)
    }
}
