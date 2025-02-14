import Vapor

struct IngredientsDTO: Codable {
    let ingredients: [IngredientDTO]
}

// MARK: - Ingredient
struct IngredientDTO: Codable, Content {
    var id: UUID?
    let english, spanish, catalan: String
    let nutritionalValuesPer100G: NutritionalValuesPer100G
    let isGlutenFree, isVegan, isVegetarian: Bool

    enum CodingKeys: String, CodingKey {
        case english, spanish, catalan, id
        case nutritionalValuesPer100G = "nutritional_values_per_100g"
        case isGlutenFree = "is_gluten_free"
        case isVegan = "is_vegan"
        case isVegetarian = "is_vegetarian"
    }

    func toFrontend() -> [String: String] {
        [
            "id": id?.uuidString ?? "",
            "english": english,
            "spanish": spanish,
            "catalan": catalan,
            "calories": String(
                nutritionalValuesPer100G.calories
            ),
            "carbohydratesG": String(
                nutritionalValuesPer100G.carbohydratesG
            ),
            "proteinG": String(
                nutritionalValuesPer100G.proteinG
            ),
            "fatG": String(
                nutritionalValuesPer100G.fatG
            ),
            "fiberG": String(
                nutritionalValuesPer100G.fiberG
            ),
            "isGlutenFree": isGlutenFree ? "Yes" : "No",
            "isVegan": isVegan ? "Yes" : "No",
            "isVegetarian": isVegetarian ? "Yes" : "No",
        ]
    }
}

// MARK: - NutritionalValuesPer100G
struct NutritionalValuesPer100G: Codable {
    let calories: Int
    let carbohydratesG, proteinG, fatG, fiberG: Double

    enum CodingKeys: String, CodingKey {
        case calories
        case carbohydratesG = "carbohydrates_g"
        case proteinG = "protein_g"
        case fatG = "fat_g"
        case fiberG = "fiber_g"
    }
}
