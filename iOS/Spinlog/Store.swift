import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var entries: [ClassEntry] = []
    @Published var isPro: Bool = false

    // Free-tier cap. Kept comfortably above seed-data count so a fresh
    // install never trips the paywall immediately.
    static let freeLimit = 40

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("spinlog_entries.json")
        load()
    }

    func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([ClassEntry].self, from: data) {
            entries = decoded
        } else {
            entries = [
            ClassEntry(date: Date().addingTimeInterval(-0), classtype: "Endurance", value1: 5, value2: 3),
            ClassEntry(date: Date().addingTimeInterval(-86400), classtype: "Hill Climb", value1: 6, value2: 4),
            ClassEntry(date: Date().addingTimeInterval(-172800), classtype: "HIIT", value1: 7, value2: 5)
            ]
            save()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(entries) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    var canAddMore: Bool {
        isPro || entries.count < Store.freeLimit
    }

    var totalValue1: Int { entries.reduce(0) { $0 + $1.value1 } }

    @discardableResult
    func add(classtype: String, value1: Int, value2: Int, note: String = "") -> Bool {
        guard canAddMore else { return false }
        entries.insert(ClassEntry(classtype: classtype, value1: value1, value2: value2, note: note), at: 0)
        save()
        Haptics.success()
        return true
    }

    func update(_ entry: ClassEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func delete(_ entry: ClassEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
}
