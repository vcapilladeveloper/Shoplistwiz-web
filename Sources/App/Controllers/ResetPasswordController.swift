import Vapor

struct ChangePasswordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webResetPassword = routes.grouped("reset-password")
        webResetPassword.get { req -> View in
            guard let token = req.query[String.self, at: "token"] else {
                return try await req.view.render("dasboard")
            }
            let context: [String: String] = ["token": token]
            return try await req.view.render("reset_password", context)
        }
        
        webResetPassword.post { req -> Response in
            let credentials = try req.content.decode(UpdatePassword.self)
            let url = URI(string: "http://localhost:8081/api/resetPassword")
            let result = try await req.client.post(url, content: credentials)
            return req.redirect(to: "/dashboard")
        }
    }
}
