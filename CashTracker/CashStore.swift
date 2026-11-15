import Foundation
import SwiftUI

@MainActor
final class CashStore: ObservableObject {
    @Published var transactions: [CashTransaction] = [] {
        didSet { save() }
    }

    private let key = "cash_transactions_v1"

    init() {
        load()
    }

    var balanceEUR: Double {
        transactions.filter { $0.currency == .eur }.reduce(0) { $0 + $1.amount }
    }

    var balanceDKK: Double {
        transactions.filter { $0.currency == .dkk }.reduce(0) { $0 + $1.amount }
    }

    func balance(for currency: CashCurrency) -> Double {
        currency == .eur ? balanceEUR : balanceDKK
    }

    func history(for currency: CashCurrency? = nil) -> [CashTransaction] {
        let list = currency == nil ? transactions : transactions.filter { $0.currency == currency }
        return list.sorted { $0.date > $1.date }
    }

    func add(currency: CashCurrency, amount: Double, isIncome: Bool, note: String) {
        let value = isIncome ? abs(amount) : -abs(amount)
        let t = CashTransaction(currency: currency, amount: value, note: note.trimmingCharacters(in: .whitespaces))
        transactions.append(t)
    }

    func delete(_ t: CashTransaction) {
        transactions.removeAll { $0.id == t.id }
    }

    // MARK: - Persistence

    private func save() {
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([CashTransaction].self, from: data) else { return }
        transactions = decoded
    }
}
