import Vapor

struct LandingController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get { req -> View in
            let isLoggedIn: Bool = req.cookies["token"]?.string != nil
            return try await req.view.render("landing", ["isLoggedin": isLoggedIn])
        }
    }
}
