import SwiftUI

public struct CurrencyText: View {
    
    var amount: Double?

    public init(amount: Double?) {
        self.amount = amount
    }
    
    public var body: some View {
        Group {
            if let amount {
                switch amount {
                case ..<0:
                    Text(amount.currencyAmount).foregroundStyle(.red)
                case 0:
                    Text(amount.currencyAmount)
                default:
                    Text(amount.currencyAmount).foregroundStyle(.green)
                }
            } else {
                Text(amount.currencyAmount) // Placeholder "amount"
            }
        }
        .lineLimit(1)
        .bold()
        #if os(watchOS)
        .minimumScaleFactor(0.5)
        #endif
    }
}

#Preview {
    VStack {
        CurrencyText(amount: 2344.9999)
        CurrencyText(amount: 2344.99)
        CurrencyText(amount: 0)
        CurrencyText(amount: -2344.9999)
        CurrencyText(amount: nil)
    }
}
