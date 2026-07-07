import Foundation

@MainActor
final class BatchDyeStore: ObservableObject {
    @Published private(set) var sessions: [Session] = []
    @Published private(set) var proEntries: [BDProEntry] = []

    static let freeLimit = 30

    private let fileURL: URL
    private let proFileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.fileURL = dir.appendingPathComponent("batchdye_sessions.json")
        self.proFileURL = dir.appendingPathComponent("batchdye_pro.json")
        if ProcessInfo.processInfo.arguments.contains("-uiTestReset") {
            try? FileManager.default.removeItem(at: fileURL)
            try? FileManager.default.removeItem(at: proFileURL)
        }
        load()
        if sessions.isEmpty {
            seedDefaults()
        }
        if proEntries.isEmpty {
            seedProDefaults()
        }
    }

    private func seedDefaults() {
        sessions = [
            Session(itemName: "Cotton Tee", foldPattern: "Spiral", colors: "Fuchsia, Turquoise, Sun Yellow", fabricPrep: "Soda ash soak 20min"),
            Session(itemName: "Tote Bag", foldPattern: "Bullseye", colors: "Cobalt, White", fabricPrep: "Soda ash soak 20min")
        ]
        save()
    }

    private func seedProDefaults() {
        proEntries = [
            BDProEntry(fabricWeightOz: "6", sodaAshCups: "1", dyeColor: "Fuchsia", dyeTsp: "2"),
            BDProEntry(fabricWeightOz: "10", sodaAshCups: "1.5", dyeColor: "Turquoise", dyeTsp: "3")
        ]
        saveProEntries()
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || sessions.count < Self.freeLimit
    }

    @discardableResult
    func addSession(itemName: String, foldPattern: String, colors: String, fabricPrep: String, isPro: Bool) -> Bool {
        let trimmed = itemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, canAdd(isPro: isPro) else { return false }
        let item = Session(itemName: itemName, foldPattern: foldPattern, colors: colors, fabricPrep: fabricPrep)
        sessions.append(item)
        save()
        return true
    }

    func updateSession(_ id: UUID, itemName: String, foldPattern: String, colors: String, fabricPrep: String) {
        guard let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[idx].itemName = itemName
        sessions[idx].foldPattern = foldPattern
        sessions[idx].colors = colors
        sessions[idx].fabricPrep = fabricPrep
        save()
    }

    func deleteSession(_ id: UUID) {
        sessions.removeAll { $0.id == id }
        save()
    }

    func deleteAllData() {
        sessions = []
        proEntries = []
        seedDefaults()
        seedProDefaults()
    }

    // MARK: - Pro entries

    @discardableResult
    func addProEntry(fabricWeightOz: String, sodaAshCups: String, dyeColor: String, dyeTsp: String) -> Bool {
        let entry = BDProEntry(fabricWeightOz: fabricWeightOz, sodaAshCups: sodaAshCups, dyeColor: dyeColor, dyeTsp: dyeTsp)
        proEntries.append(entry)
        saveProEntries()
        return true
    }

    func deleteProEntry(_ id: UUID) {
        proEntries.removeAll { $0.id == id }
        saveProEntries()
    }

    // MARK: - Persistence

    private struct Snapshot: Codable {
        var items: [Session]
    }
    private struct ProSnapshot: Codable {
        var items: [BDProEntry]
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(Snapshot.self, from: data) {
            sessions = decoded.items
        }
        if let data = try? Data(contentsOf: proFileURL), let decoded = try? JSONDecoder().decode(ProSnapshot.self, from: data) {
            proEntries = decoded.items
        }
    }

    private func save() {
        let snapshot = Snapshot(items: sessions)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private func saveProEntries() {
        let snapshot = ProSnapshot(items: proEntries)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: proFileURL, options: .atomic)
    }
}
