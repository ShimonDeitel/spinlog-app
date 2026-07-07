import Foundation

struct ClassEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var classtype: String   // Class Type
    var value1: Int   // Duration (min)
    var value2: Int   // Resistance (1-10)
    var note: String = ""
}

enum SpinlogOptions {
    static let all: [String] = ["Endurance", "Hill Climb", "HIIT", "Recovery", "Sprint"]
}
