import Vapor

struct LanguageSelection: Content {
    let language: String
    let returnTo: String
}