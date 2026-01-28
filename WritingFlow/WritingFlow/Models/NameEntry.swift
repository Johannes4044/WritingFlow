import SwiftData
import Foundation

@Model
final class NameEntry {
    var id: UUID
    var name: String
    var context: String?
    var notes: String?
    var createdAt: Date

    init(name: String, context: String? = nil, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.context = context
        self.notes = notes
        self.createdAt = Date()
    }
}
