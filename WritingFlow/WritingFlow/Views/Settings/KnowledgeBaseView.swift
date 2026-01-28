import SwiftUI
import SwiftData

struct KnowledgeBaseView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text("Abbreviations").tag(0)
                Text("Names").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            Divider()

            if selectedTab == 0 {
                AbbreviationsListView()
            } else {
                NamesListView()
            }
        }
    }
}

// MARK: - Abbreviations

struct AbbreviationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Abbreviation.shortForm) private var abbreviations: [Abbreviation]

    @State private var isAdding = false
    @State private var newShortForm = ""
    @State private var newExpansion = ""
    @State private var newCategory = ""

    var body: some View {
        VStack(spacing: 0) {
            // List
            List {
                ForEach(abbreviations) { abbrev in
                    AbbreviationRow(abbreviation: abbrev)
                }
                .onDelete(perform: deleteAbbreviations)
            }
            .listStyle(.inset)

            Divider()

            // Add new
            if isAdding {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Short form", text: $newShortForm)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)

                        TextField("Expansion", text: $newExpansion)
                            .textFieldStyle(.roundedBorder)

                        TextField("Category", text: $newCategory)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 100)
                    }

                    HStack {
                        Button("Cancel") {
                            isAdding = false
                            clearFields()
                        }

                        Spacer()

                        Button("Add") {
                            addAbbreviation()
                        }
                        .vibrantButton()
                        .disabled(newShortForm.isEmpty || newExpansion.isEmpty)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            } else {
                HStack {
                    Button(action: { isAdding = true }) {
                        Label("Add Abbreviation", systemImage: "plus")
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }

    private func deleteAbbreviations(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(abbreviations[index])
        }
        try? modelContext.save()
    }

    private func addAbbreviation() {
        let abbrev = Abbreviation(
            shortForm: newShortForm,
            expansion: newExpansion,
            category: newCategory.isEmpty ? nil : newCategory
        )
        modelContext.insert(abbrev)
        try? modelContext.save()
        isAdding = false
        clearFields()
    }

    private func clearFields() {
        newShortForm = ""
        newExpansion = ""
        newCategory = ""
    }
}

struct AbbreviationRow: View {
    @Bindable var abbreviation: Abbreviation
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        HStack {
            Text(abbreviation.shortForm)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(WritingFlowColors.primaryAccent)
                .frame(width: 60, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)

            Text(abbreviation.expansion)
                .font(.system(size: 13))
                .lineLimit(1)

            Spacer()

            if let category = abbreviation.category {
                Text(category)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Names

struct NamesListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \NameEntry.name) private var names: [NameEntry]

    @State private var isAdding = false
    @State private var newName = ""
    @State private var newContext = ""
    @State private var newNotes = ""

    var body: some View {
        VStack(spacing: 0) {
            // List
            List {
                ForEach(names) { name in
                    NameRow(nameEntry: name)
                }
                .onDelete(perform: deleteNames)
            }
            .listStyle(.inset)

            Divider()

            // Add new
            if isAdding {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        TextField("Name", text: $newName)
                            .textFieldStyle(.roundedBorder)

                        TextField("Context (e.g., colleague)", text: $newContext)
                            .textFieldStyle(.roundedBorder)
                    }

                    TextField("Notes (optional)", text: $newNotes)
                        .textFieldStyle(.roundedBorder)

                    HStack {
                        Button("Cancel") {
                            isAdding = false
                            clearFields()
                        }

                        Spacer()

                        Button("Add") {
                            addName()
                        }
                        .vibrantButton()
                        .disabled(newName.isEmpty)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            } else {
                HStack {
                    Button(action: { isAdding = true }) {
                        Label("Add Name", systemImage: "plus")
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }

    private func deleteNames(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(names[index])
        }
        try? modelContext.save()
    }

    private func addName() {
        let entry = NameEntry(
            name: newName,
            context: newContext.isEmpty ? nil : newContext,
            notes: newNotes.isEmpty ? nil : newNotes
        )
        modelContext.insert(entry)
        try? modelContext.save()
        isAdding = false
        clearFields()
    }

    private func clearFields() {
        newName = ""
        newContext = ""
        newNotes = ""
    }
}

struct NameRow: View {
    let nameEntry: NameEntry

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(WritingFlowColors.primaryAccent)

            Text(nameEntry.name)
                .font(.system(size: 13, weight: .medium))

            if let context = nameEntry.context {
                Text("(\(context))")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let notes = nameEntry.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
