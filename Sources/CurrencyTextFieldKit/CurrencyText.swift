import SwiftUI

/// A view that displays a currency amount formatted as text, with color styling based on the value sign.
///
/// This view displays the given amount formatted as currency. Negative amounts are shown in red, zero amounts in the default text color primary, and positive amounts in green.
///
/// ```swift
/// CurrencyText(amount: 1234.56)
/// ```
///
/// - Note: On watchOS, the text scales down to fit smaller screen sizes.
///
/// - Parameter amount: The optional `Double` value representing the currency amount to display. If `nil`, a placeholder text is shown.
public struct CurrencyText: View {
    
    /// The optional currency amount to display.
    var amount: Double?

    /// Creates a new `CurrencyText` view with the specified amount.
    ///
    /// - Parameter amount: The optional `Double` value representing the currency amount to display.
    public init(amount: Double?) {
        self.amount = amount
    }
    
    /// The content and behavior of the view.
    ///
    /// Returns a text view displaying the currency amount with color styling:
    /// - Red for negative amounts
    /// - Default color for zero
    /// - Green for positive amounts
    ///
    /// If `amount` is `nil`, a placeholder text is shown.
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
