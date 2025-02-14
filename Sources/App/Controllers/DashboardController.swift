import Vapor

struct DashboardController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webDashboard = routes.grouped("dashboard")
        webDashboard.get { req -> View in
            let currentPath = req.url.string
            guard let token = req.cookies["token"]?.string else {
                return try await req.view.render("login")
            }
            let userInfo = try await getUserInfo(token: token, req: req)
            let selectedLang = req.cookies["lang"]?.string ?? "en"
            
            guard let localizationService = req.application.storage[LocalizationServiceKey.self] else {
                throw Abort(.internalServerError, reason: "LocalizationService is not available.")
            }
            let logout = localizationService.translate(
                language: selectedLang, key: "dashboard.logout")
            // Create context with session data
            let context: [String: String] = [
                "currentPath": currentPath,
                "token": token,
                "email": userInfo.email,
                "password": userInfo.password,
                "id": userInfo.id,
                "logoutTitle": logout
            ]
            
            return try await req.view.render("dashboard", context)
        }
        
        routes.post("logout") { req -> Response in
            req.session.destroy()
            return req.redirect(to: "/login") // Redirect user to login page
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
