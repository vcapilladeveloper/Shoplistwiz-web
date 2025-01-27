import Vapor

struct LanguageController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.post("select-language") { req -> Response in
            let data = try req.content.decode(LanguageSelection.self)
            // Create a response and set the language cookie
            var response = req.redirect(to: data.returnTo) // Redirect to home or previous page
            response.cookies["lang"] = HTTPCookies.Value(
                string: data.language,
                expires: Date().addingTimeInterval(60 * 60 * 24 * 30), // 30 days
                path: "/",
                isSecure: false // Set to `true` if using HTTPS
            )
            return response
            
        }
    }
}
