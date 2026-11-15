import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CashStore
    @State private var selected: CashCurrency = .eur
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Балансы
                HStack(spacing: 12) {
                    BalanceCard(currency: .eur, balance: store.balanceEUR, selected: selected == .eur)
                        .onTapGesture { selected = .eur }
                    BalanceCard(currency: .dkk, balance: store.balanceDKK, selected: selected == .dkk)
                        .onTapGesture { selected = .dkk }
                }
                .padding(.horizontal)

                // История
                List {
                    ForEach(store.history(for: selected)) { t in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(t.note.isEmpty ? (t.isIncome ? "Пополнение" : "Снятие") : t.note)
                                    .font(.body)
                                Text(t.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(format(t.amount, currency: t.currency))
                                .foregroundColor(t.isIncome ? .green : .red)
                                .font(.body.bold())
                        }
                    }
                    .onDelete { indexSet in
                        let items = store.history(for: selected)
                        for i in indexSet { store.delete(items[i]) }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Наличные")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddTransactionView(currency: selected)
                    .environmentObject(store)
            }
        }
    }

    private func format(_ value: Double, currency: CashCurrency) -> String {
        let sign = value >= 0 ? "+" : "−"
        return "\(sign)\(abs(value).formatted(.number.precision(.fractionLength(0...2)))) \(currency.symbol)"
    }
}

struct BalanceCard: View {
    var currency: CashCurrency
    var balance: Double
    var selected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currency.title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("\(balance.formatted(.number.precision(.fractionLength(0...2)))) \(currency.symbol)")
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(selected ? Color.blue.opacity(0.15) : Color(.systemGray6))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(selected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct AddTransactionView: View {
    @EnvironmentObject var store: CashStore
    @Environment(\.dismiss) var dismiss

    var currency: CashCurrency
    @State private var amountText = ""
    @State private var isIncome = true
    @State private var note = ""

    var body: some View {
        NavigationStack {
            Form {
                Picker("Валюта", selection: .constant(currency)) {
                    Text(currency.title).tag(currency)
                }
                Picker("Тип", selection: $isIncome) {
                    Text("Отложить").tag(true)
                    Text("Взять").tag(false)
                }
                .pickerStyle(.segmented)

                TextField("Сумма", text: $amountText)
                    .keyboardType(.decimalPad)

                TextField("Заметка", text: $note)
            }
            .navigationTitle("Операция")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
                        if let amount = Double(normalized), amount > 0 {
                            store.add(currency: currency, amount: amount, isIncome: isIncome, note: note)
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
