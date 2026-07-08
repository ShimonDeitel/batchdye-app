import Foundation

struct Session: Identifiable, Codable, Equatable {
    let id: UUID
    var itemName: String
    var foldPattern: String
    var colors: String
    var fabricPrep: String
    var createdDate: Date

    init(id: UUID = UUID(), itemName: String = "Cotton Tee", foldPattern: String = "Spiral", colors: String = "Fuchsia, Turquoise, Sun Yellow", fabricPrep: String = "Soda ash soak 20min", createdDate: Date = Date()) {
        self.id = id
        self.itemName = itemName
        self.foldPattern = foldPattern
        self.colors = colors
        self.fabricPrep = fabricPrep
        self.createdDate = createdDate
    }
}

/// Pro bonus feature entry: Soda-Ash & Dye Ratio Calculator.
struct BDProEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var fabricWeightOz: String
    var sodaAshCups: String
    var dyeColor: String
    var dyeTsp: String
    var createdDate: Date

    init(id: UUID = UUID(), fabricWeightOz: String = "6", sodaAshCups: String = "1", dyeColor: String = "Fuchsia", dyeTsp: String = "2", createdDate: Date = Date()) {
        self.id = id
        self.fabricWeightOz = fabricWeightOz
        self.sodaAshCups = sodaAshCups
        self.dyeColor = dyeColor
        self.dyeTsp = dyeTsp
        self.createdDate = createdDate
    }
}

enum BDFoldPatternOption {
    static let all = ["Spiral", "Crumple", "Bullseye", "Accordion", "Ice Dye"]
}
