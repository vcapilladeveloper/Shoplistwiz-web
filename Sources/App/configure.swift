import Leaf
import Vapor

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
     app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))
    // Set up session driver
    app.sessions.use(.memory)
    let localizationService = LocalizationService()
    try localizationService.loadTranslations(app: app)
    app.storage[LocalizationServiceKey.self] = localizationService
    // Add sessions middleware
    app.middleware.use(SessionsMiddleware(session: app.sessions.driver))
    app.views.use(.leaf)

    app.http.server.configuration.port = 8080

    // register routes
    try routes(app)
}

struct LocalizationServiceKey: StorageKey, Sendable {
    typealias Value = LocalizationService
}
