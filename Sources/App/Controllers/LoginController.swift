import Vapor

struct LoginController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webLogin = routes.grouped("login")
        webLogin.get { req -> View in
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
                language: selectedLang, key: "login_screen.title")
            let email = localizationService.translate(language: selectedLang, key: "common.email")
            let password = localizationService.translate(language: selectedLang, key: "common.password")
            let name = localizationService.translate(language: selectedLang, key: "common.name")
            let signUpRedirectMessage = localizationService.translate(language: selectedLang, key: "login_screen.signup_redirect_message")
            let signUpLinkTitle = localizationService.translate(language: selectedLang, key: "login_screen.signup_link_title")
            let resetPasswordRediectMessage = localizationService.translate(language: selectedLang, key: "login_screen.reset_password_redirect_message")
            let resetPasswordLinkTitle = localizationService.translate(language: selectedLang, key: "login_screen.reset_password_link_title")
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
                "signUpRedirectMessage": signUpRedirectMessage,
                "signUpLinkTitle": signUpLinkTitle,
                "resetPasswordRediectMessage": resetPasswordRediectMessage,
                "resetPasswordLinkTitle": resetPasswordLinkTitle
                
            ]
            return try await req.view.render("login", context)
        }
        
        webLogin.post { req async throws -> Response in
            let selectedLang = req.cookies["lang"]?.string ?? "en"
            
            guard let localizationService = req.application.storage[LocalizationServiceKey.self] else {
                throw Abort(.internalServerError, reason: "LocalizationService is not available.")
            }
            do {
                let credentials = try req.content.decode(LoginModel.self)
                
                // Validate password
                let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,}$"
                guard credentials.password.range(of: passwordRegex, options: .regularExpression) != nil else {
                    return try await req.view.render("login", [
                        "error":
                            "login_screen.invalid_password"
                    ]).encodeResponse(for: req)
                }
                
                let url = URI(string: "http://localhost:8081/api/login")
                
                let authString = Data(
                    "\(credentials.email):\(credentials.password)".utf8
                ).base64EncodedString()
                var headers = HTTPHeaders()
                headers.add(name: .authorization, value: "Basic \(authString)")
                
                let result = try await req.client.get(url, headers: headers)
                if result.status != .ok {
                    if result.status == .unauthorized {
                        let unauthorized = localizationService.translate(language: selectedLang, key: "login_screen.unauthorized")
                        req.session.data["error"] = unauthorized
                        return req.redirect(to: "/login")
                    } else {
                        req.session.data["error"] = "Something goes wrong"
                        return req.redirect(to: "/login")
                    }
                    
                } else {
                    let tokenModel = try result.content.decode(TokenModel.self)
                    let response = req.redirect(to: "/dashboard")
                    response.cookies["token"] = HTTPCookies.Value(
                        string: tokenModel.value,
                        expires: Date().addingTimeInterval(60 * 60 * 24 * 30), // 30 days
                        path: "/",
                        isSecure: false // Set to `true` if using HTTPS
                    )
                    
                    return response
                }
            } catch let error as AbortError {
                req.session.data["error"] = error.reason
                return req.redirect(to: "/login")
            } catch {
                let defaultError = localizationService.translate(language: selectedLang, key: "login_screen.default_error")
                req.session.data["error"] = defaultError
                return req.redirect(to: "/login")
            }
        }
    }
}
