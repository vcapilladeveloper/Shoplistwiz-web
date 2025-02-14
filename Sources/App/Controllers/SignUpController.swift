import Vapor

struct SignUpController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webSignup = routes.grouped("signup")
        webSignup.get { req -> View in
            let currentPath = req.url.string  // or req.url.path if you only want the path without query
            let error = req.session.data["error"]
            req.session.data["error"] = nil
            // Read the selected language from session (if any), default to "en"
            let selectedLang = req.cookies["lang"]?.string ?? "en"

            guard let localizationService = req.application.storage[LocalizationServiceKey.self] else {
                throw Abort(.internalServerError, reason: "LocalizationService is not available.")
            }

            // Retrieve localized strings
            let title = localizationService.translate(
                language: selectedLang, key: "signup_screen.title")
            let email = localizationService.translate(language: selectedLang, key: "common.email")
            let password = localizationService.translate(language: selectedLang, key: "common.password")
            let name = localizationService.translate(language: selectedLang, key: "common.name")
            let loginLink = localizationService.translate(language: selectedLang, key: "signup_screen.login_link_title")
            let loginRedirectMessage = localizationService.translate(language: selectedLang, key: "signup_screen.login_redirect_message")
            var errorMessage: String?
            if let error {
                errorMessage = localizationService.translate(
                    language: selectedLang, key: error)
            }

            // Pass the current path into the Leaf context so the template has it
            let context: [String: String] = [
                "title": title,
                "currentPath": currentPath,
                "errorMessage": errorMessage ?? "",
                "email": email,
                "password": password,
                "name": name,
                "loginLink": loginLink,
                "loginRedirectMessage": loginRedirectMessage
                
            ]

            return try await req.view.render("Auth/signup", context)
        }

        webSignup.post { req async throws -> Response in
            do {
                let credentials = try req.content.decode(UserModel.self)

                let passwordRegex =
                    "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
                guard
                    credentials.password.range(
                        of: passwordRegex, options: .regularExpression) != nil
                else {
                    return try await req.view.render(
                        "signup",
                        [
                            "error":
                                "signup_screen.invalid_password"
                        ]
                    ).encodeResponse(for: req)
                }

                let url = URI(string: "http://localhost:8081/api/signup")
                let signupModel = SignupModel(
                    name: credentials.name, email: credentials.email, password: credentials.password)

                // Make the POST request
                let result = try await req.client.post(
                    url, content: signupModel
                )
                guard
                    let tokenModel = try? result.content.decode(TokenModel.self)
                else {
                    let error = try result.content.decode(ErrorModel.self)
                    req.session.data["error"] = error.reason
                    return req.redirect(to: "/signup")
                }
                
                let response = req.redirect(to: "/dashboard")
                response.cookies["token"] = HTTPCookies.Value(
                    string: tokenModel.value,
                    expires: Date().addingTimeInterval(60 * 60 * 24 * 30), // 30 days
                    path: "/",
                    isSecure: false // Set to `true` if using HTTPS
                )
                
                return response

            } catch let error as AbortError {
                // Store error message in session before redirect
                req.session.data["error"] = error.reason
                return req.redirect(to: "/signup")
            } catch {
                // Store generic error message in session before redirect
                req.session.data["error"] =
                    "signup_screen.default_error"
                return req.redirect(to: "/signup")
            }
        }
    }
}
