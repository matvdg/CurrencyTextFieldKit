import Foundation

extension NumberFormatter {
    
    static func getCurrencyFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        return formatter
    }
}

extension Double {
    
    var currencyAmount: String {
        NumberFormatter.getCurrencyFormatter().string(from: NSNumber(value: self)) ?? String(localized: "amount")
    }
}

extension Double? {
    var currencyAmount: String {
        guard let amount = self else { return String(localized: "amount") }
        return amount.currencyAmount
    }
}

extension String {
    var cleanComa: String {
        replacingOccurrences(of: ",", with: ".").cleanSpaces
    }
    var cleanSpaces: String {
        replacingOccurrences(of: "\\s", with: "", options: .regularExpression)
    }
}
