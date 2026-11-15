import Foundation

enum CashCurrency: String, CaseIterable, Identifiable, Codable {
    case eur = "EUR"
    case dkk = "DKK"

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .eur: return "€"
        case .dkk: return "kr"
        }
    }

    var title: String {
        switch self {
        case .eur: return "Наличные EUR"
        case .dkk: return "Наличные DKK"
        }
    }
}

struct CashTransaction: Identifiable, Codable {
    var id = UUID()
    var currency: CashCurrency
    var amount: Double // + пополнение, − снятие
    var note: String
    var date = Date()

    var isIncome: Bool { amount >= 0 }
}
