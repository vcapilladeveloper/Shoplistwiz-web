import Vapor

final class LocalizationService: Sendable {
    private var translations: [String: [String: Any]] = [:]
    // e.g., translations["en"] = ["greeting": "Hello!", "home_page": [...]]
    
    /// Loads all JSON files from your `Resources/Localization` folder.
    func loadTranslations(app: Application) throws {
        let localizationFolder = app.directory.resourcesDirectory + "Localization"
        
        // For each file in that folder, parse JSON and store in dictionary
        let fm = FileManager.default
        let files = try fm.contentsOfDirectory(atPath: localizationFolder)
        for file in files where file.hasSuffix(".json") {
            let languageCode = file.replacingOccurrences(of: ".json", with: "")
            let filePath = localizationFolder + "/" + file
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let dictionary = jsonObject as? [String: Any] {
                translations[languageCode] = dictionary
            }
        }
    }
    
    /// Retrieves a translation for a given language and key path (e.g. "home_page.title")
    func translate(language: String, key: String) -> String {
        guard let languageDict = translations[language] else {
            return key // fallback to the key if language is not found
        }
        
        var current: Any? = languageDict
        for part in key.split(separator: ".") {
            if let dict = current as? [String: Any], let next = dict[String(part)] {
                current = next
            } else {
                return key // fallback to the key if subkey not found
            }
        }
        
        return current as? String ?? key
    }
}
