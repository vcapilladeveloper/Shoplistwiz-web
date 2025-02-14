import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: LoginController())
    try app.register(collection: SignUpController())
    try app.register(collection: DashboardController())
    try app.register(collection: LandingController())
    try app.register(collection: RequestChangePasswordController())
    try app.register(collection: ChangePasswordController())
    try app.register(collection: LanguageController())
    try app.register(collection: IngredientsController())
}
