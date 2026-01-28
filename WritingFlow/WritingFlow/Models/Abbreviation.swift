import SwiftData
import Foundation

@Model
final class Abbreviation {
    var id: UUID
    var shortForm: String
    var expansion: String
    var category: String?
    var createdAt: Date

    init(shortForm: String, expansion: String, category: String? = nil) {
        self.id = UUID()
        self.shortForm = shortForm
        self.expansion = expansion
        self.category = category
        self.createdAt = Date()
    }

    static var defaultAbbreviations: [Abbreviation] {
        [
            Abbreviation(shortForm: "MfG", expansion: "Mit freundlichen Grüßen", category: "German"),
            Abbreviation(shortForm: "LG", expansion: "Liebe Grüße", category: "German"),
            Abbreviation(shortForm: "VG", expansion: "Viele Grüße", category: "German"),
            Abbreviation(shortForm: "bzgl", expansion: "bezüglich", category: "German"),
            Abbreviation(shortForm: "ggf", expansion: "gegebenenfalls", category: "German"),
            Abbreviation(shortForm: "usw", expansion: "und so weiter", category: "German"),
            Abbreviation(shortForm: "z.B.", expansion: "zum Beispiel", category: "German"),
            Abbreviation(shortForm: "d.h.", expansion: "das heißt", category: "German"),
            Abbreviation(shortForm: "ASAP", expansion: "as soon as possible", category: "English"),
            Abbreviation(shortForm: "FYI", expansion: "for your information", category: "English"),
            Abbreviation(shortForm: "BTW", expansion: "by the way", category: "English"),
            Abbreviation(shortForm: "TBD", expansion: "to be determined", category: "English")
        ]
    }
}
