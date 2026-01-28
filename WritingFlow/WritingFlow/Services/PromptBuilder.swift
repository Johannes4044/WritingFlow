import Foundation

class PromptBuilder {
    static let shared = PromptBuilder()

    private init() {}

    func buildKnowledgeContext(
        abbreviations: [Abbreviation],
        names: [NameEntry]
    ) -> String {
        var context: [String] = []

        // Abbreviations section
        if !abbreviations.isEmpty {
            let abbrevList = abbreviations.map { "- \($0.shortForm) = \($0.expansion)" }
                .joined(separator: "\n")
            context.append("""
            ABBREVIATIONS (expand these when encountered):
            \(abbrevList)
            """)
        }

        // Names section
        if !names.isEmpty {
            let namesList = names.map { entry in
                var line = "- \(entry.name)"
                if let ctx = entry.context, !ctx.isEmpty {
                    line += " (\(ctx))"
                }
                return line
            }.joined(separator: "\n")
            context.append("""
            KNOWN NAMES (ensure correct spelling):
            \(namesList)
            """)
        }

        return context.joined(separator: "\n\n")
    }
}
