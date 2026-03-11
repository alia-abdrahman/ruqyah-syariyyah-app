import Foundation

extension String {
    /// Converts Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩) to Western numerals (0123456789)
    var arabicToWesternNumerals: String {
        let arabicNumerals: [Character: Character] = [
            "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4",
            "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"
        ]
        return String(self.map { arabicNumerals[$0] ?? $0 })
    }
}
