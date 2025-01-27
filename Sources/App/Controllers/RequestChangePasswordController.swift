import Vapor

struct RequestChangePasswordController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webRequestPassword = routes.grouped("request-password")
        webRequestPassword.get { req -> View in
            return try await req.view.render("request_password")
        }
        
        webRequestPassword.post { req -> Response in
            let credentials = try req.content.decode(ResetPasswordModel.self)
            let url = URI(string: "http://localhost:8080/api/resetPassword?email=\(credentials.email)")
            let _ = try await req.client.get(url)
            return req.redirect(to: "/dashboard")
        }
    }
}
