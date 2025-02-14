import Vapor

struct IngredientsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let webSignup = routes.grouped("ingredients")
        webSignup.get { req -> View in
            guard let token = req.cookies["token"]?.string else {
                return try await req.view.render("settings")
            }
            
            let selectedLang = req.cookies["lang"]?.string ?? "en"
            guard let localizationService = req.application.storage[LocalizationServiceKey.self] else {
                throw Abort(.internalServerError, reason: "LocalizationService is not available.")
            }
            let title = localizationService.translate(
                language: selectedLang, key: "ingredients.title")
            let searchPlaceholder = localizationService.translate(
                language: selectedLang, key: "ingredients.search_placeholder")
            let modalTitle = localizationService.translate(
                language: selectedLang, key: "ingredients.modal_title")
            let modalCancel = localizationService.translate(
                language: selectedLang, key: "ingredients.modal_cancel")
            let modalSave = localizationService.translate(
                language: selectedLang, key: "ingredients.modal_save")
            let headerEnglish = localizationService.translate(
                language: selectedLang, key: "ingredients.header_english")
            let headerSpanish = localizationService.translate(
                language: selectedLang, key: "ingredients.header_spanish")
            let headerCatalan = localizationService.translate(
                language: selectedLang, key: "ingredients.header_catalan")
            let headerCalories = localizationService.translate(
                language: selectedLang, key: "ingredients.header_calories")
            let headerCarbohydrates = localizationService.translate(
                language: selectedLang, key: "ingredients.header_carbs")
            let headerProtein = localizationService.translate(
                language: selectedLang, key: "ingredients.header_protein")
            let headerFat = localizationService.translate(
                language: selectedLang, key: "ingredients.header_fat")
            let headerFiber = localizationService.translate(
                language: selectedLang, key: "ingredients.header_fiber")
            let headerGlutenFree = localizationService.translate(
                language: selectedLang, key: "ingredients.header_gluten")
            let headerVegan = localizationService.translate(
                language: selectedLang, key: "ingredients.header_vegan")
            let headerVegetarian = localizationService.translate(
                language: selectedLang, key: "ingredients.header_vegetarian")
            
            
            let c: [String: String] = [
                "title": title,
                "searchPlaceholder": searchPlaceholder,
                "modalTitle": modalTitle,
                "modalCancel": modalCancel,
                "modalSave": modalSave,
                "headerEnglish": headerEnglish,
                "headerSpanish": headerSpanish,
                "headerCatalan": headerCatalan,
                "headerCalories": headerCalories,
                "headerCarbohydrates": headerCarbohydrates,
                "headerProtein": headerProtein,
                "headerFat": headerFat,
                "headerFiber": headerFiber,
                "headerGlutenFree": headerGlutenFree,
                "headerVegan": headerVegan,
                "headerVegetarian": headerVegetarian
            ]
            
            
            let ingredients: [IngredientDTO] = try await getIngredients(token: token, req: req)
            let ingredientsDto: [[String: String]] = ingredients.sorted(by: { $0.spanish < $1.spanish }).map{ ingredient in
                ingredient.toFrontend()
            }
            struct Context: Codable {
                let ingredients: [[String: String]]
                let c: [String: String]
            }

            return try await req.view.render("ingredients", Context(ingredients: ingredientsDto, c: c))
        }
        routes.put("ingredient") { req async throws -> IngredientDTO in
            guard let token = req.cookies["token"]?.string else {
                throw Abort(.unauthorized)
            }
            
            let ingredient = try req.content.decode(IngredientDTO.self)
            return try await updateIngredient(token: token, ingredient: ingredient, req: req)
        }
    }
    
    private func getIngredients(token: String, req: Request) async throws -> [IngredientDTO] {
        let url = URI(string: "http://localhost:8081/api/ingredients")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]
        
        return try await req.client.get(url, headers: headers).content.decode([IngredientDTO].self)
    }
    
    private func updateIngredient(token: String, ingredient: IngredientDTO, req: Request) async throws -> IngredientDTO {
        let url = URI(string: "http://localhost:8081/api/ingredients/update")
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]
        
        let response = try await req.client.put(url, headers: headers, content: ingredient)
        
        if response.status == .ok {
            // Decode and return the updated ingredient
            return try response.content.decode(IngredientDTO.self)
        } else {
            // Handle errors appropriately, perhaps by throwing a custom error
            let errorReason = (try? response.content.decode(String.self)) ?? "Unknown error"
            throw Abort(.badRequest, reason: errorReason)
        }
    }
}
