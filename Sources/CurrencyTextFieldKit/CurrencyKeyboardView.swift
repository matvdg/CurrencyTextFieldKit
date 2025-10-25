#if os(watchOS)

import SwiftUI
import WatchKit

/// A custom numeric keyboard view designed for watchOS to input currency amounts.
///
/// This view provides a keypad with digits, a decimal separator, and an OK button, allowing users to input currency values.
/// It works in conjunction with `CurrencyTextField` to enable currency input on watchOS devices.
/// The keyboard supports toggling between positive and negative values depending on the `signMode`.
/// It can also display the currency symbol either as a prefix or suffix based on locale conventions.
///
/// - Note: The keyboard layout and behavior are optimized for the limited screen space of watchOS.
///
/// Usage:
/// ```swift
/// @State private var amount: Double?
/// CurrencyKeyboardView(amount: $amount, signMode: .both, displayCurrency: true)
/// ```
///
///
/// - Parameter amount: The optional `Double` value representing the currency amount to display. If `nil`, a placeholder text is shown.
/// - Parameter signMode: Defines whether the input allows positive, negative, or both types of values.
/// - Parameter displayCurrency: A Boolean indicating whether to show the currency symbol next to the value.
public struct CurrencyKeyboardView: View {
    
    /// The currency symbol to display alongside the input amount.
    /// This is determined from the current locale's currency symbol, defaulting to "€" if unavailable.
    private let currencySymbol: String = Locale.current.currencySymbol ?? "€"
    
    @Environment(\.dismiss) private var dismiss
    
    /// A binding to the currency amount entered by the user.
    /// This value updates as the user interacts with the keyboard.
    @Binding var amount: Double?
    
    /// The current input string representing the user's raw input before conversion to a Double.
    /// This string is updated as the user taps keys on the keyboard.
    @State private var inputString: String = ""
    
    /// A boolean indicating whether the current amount is positive (`true`) or negative (`false`).
    /// This toggles when the user switches the sign mode (if allowed).
    @State var isPositive = true
    
    /// Defines the allowed sign modes for the keyboard input.
    /// - `.positiveOnly`: only positive values allowed.
    /// - `.negativeOnly`: only negative values allowed.
    /// - `.both`: both positive and negative values allowed.
    public var signMode: SignMode = .both
    
    /// Determines whether the currency symbol should be displayed alongside the input.
    public var displayCurrency: Bool = true

    /// Initializes a new `CurrencyKeyboardView`.
    ///
    /// - Parameters:
    ///   - amount: A binding to a `Double?` representing the currency amount.
    ///   - signMode: The allowed sign modes for input (default is `.both`).
    ///   - displayCurrency: A Boolean indicating whether to display the currency symbol (default is `true`).
    public init(amount: Binding<Double?>, signMode: SignMode = .both, displayCurrency: Bool = true) {
        self._amount = amount
        self.signMode = signMode
        self.displayCurrency = displayCurrency
    }
    
    /// The decimal separator string used according to the current locale.
    /// Defaults to "." if the locale does not provide one.
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."
    
    /// Defines the layout of keys displayed on the keyboard.
    ///
    /// The keyboard consists of three rows:
    /// - First row: digits 1 to 4
    /// - Second row: digits 5 to 8
    /// - Third row: digits 9, 0, decimal separator, and an "OK" button
    private var keys: [[String]] {
        [
            ["1","2","3", "4"],
            ["5","6","7","8"],
            ["9","0",decimalSeparator,"OK"]
        ]
    }

    /// The main view body describing the keyboard UI layout and behavior.
    ///
    /// The view consists of:
    /// - A display area showing the current input amount with optional currency symbol and sign.
    /// - A grid of buttons corresponding to digits, decimal separator, and an OK button.
    /// - Toolbar buttons for deleting characters and toggling the sign (if allowed).
    ///
    /// The input display updates dynamically based on the user's input and sign selection.
    /// Pressing keys updates the input string and amount accordingly.
    public var body: some View {
        VStack(spacing: 5) {
            HStack(spacing: 0) {
                if !inputString.isEmpty {
                    if !isPositive {
                        Text("-")
                    }
                    let prefixSymbols: Set<String> = ["$", "£", "¥", "₹", "฿", "₩", "₦", "₱", "₫", "CHF"]
                    let symbol = currencySymbol
                    let formattedInput = inputString.replacingOccurrences(of: ".", with: decimalSeparator)
                    if !displayCurrency {
                        Text(formattedInput)
                    } else if prefixSymbols.contains(symbol) {
                        Text(symbol)
                        Text(formattedInput)
                    } else {
                        Text(formattedInput)
                        Text(" \(symbol)")
                    }
                }
            }
            .frame(height: 20)
            .bold()
            .foregroundColor(isPositive ? .green : .red)
            ForEach(keys, id: \.self) { row in
                HStack {
                    ForEach(row, id: \.self) { key in
                        Button {
                            handleKey(key)
                        } label: {
                            if key == "OK" {
                                Image(systemName: "checkmark").bold().foregroundColor(.green)
                            } else {
                                Text(key)
                                    .font(.headline)
                            }
                        }
                        .buttonStyle(.glass)
                    }
                }
            }
        }
        .padding(13)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("", systemImage: "delete.left", role: .destructive) {
                    if !inputString.isEmpty {
                        inputString.removeLast()
                        updateAmountFromInput()
                    }
                }.foregroundColor(.red)
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("", systemImage: isPositive ? "plus.forwardslash.minus" : "minus.forwardslash.plus", role: .confirm) {
                    isPositive.toggle()
                    if let amt = amount {
                        amount = -amt
                    }
                }
                .foregroundColor(isPositive ? .green : .red)
                .disabled(signMode != .both)
                .opacity((signMode == .both) ? 1 : 0)
            }
            
        }
        .onAppear {
            if let amount {
                isPositive = amount >= 0
                if amount.truncatingRemainder(dividingBy: 1) == 0 {
                    inputString = String(Int(abs(amount)))
                } else {
                    inputString = String(abs(amount))
                }
            } else {
                inputString = ""
            }
        }
        .onChange(of: inputString) {
            print(inputString)
        }
    }
    
    /// Updates the bound `amount` property based on the current `inputString` and `isPositive` state.
    ///
    /// This method attempts to convert the `inputString` to a `Double` value, handling cases where the input is invalid.
    /// It enforces the sign rules specified by `signMode`:
    /// - For `.positiveOnly`, the amount is always positive.
    /// - For `.negativeOnly`, the amount is always negative.
    /// - For `.both`, the amount sign depends on `isPositive`.
    ///
    /// If the input string is invalid or just a decimal point, the amount is set to `nil`.
    private func updateAmountFromInput() {
        guard let number = Double(inputString), inputString != "." else {
            amount = nil
            return
        }
        let absValue = abs(number)
        switch signMode {
        case .positiveOnly:
            amount = absValue
            isPositive = true
        case .negativeOnly:
            amount = -absValue
            isPositive = false
        case .both:
            amount = isPositive ? absValue : -absValue
        }
    }
    
    /// Handles the action triggered by tapping a key on the keyboard.
    ///
    /// - Parameter key: The string value of the key that was tapped.
    ///
    /// The method performs the following actions based on the key:
    /// - `"OK"`: Dismisses the keyboard.
    /// - Decimal separator: Adds it to the input if not already present, ensuring proper formatting.
    /// - Numeric keys: Appends the digit to the input string, enforcing rules such as:
    ///   - Maximum of 7 digits before the decimal point.
    ///   - Maximum of 2 digits after the decimal point.
    ///   - Preventing leading zeros unless followed by a decimal.
    private func handleKey(_ key: String) {
        WKInterfaceDevice.current().play(.click)
        switch key {
        case "OK":
            dismiss()
        case decimalSeparator:
            if !inputString.contains(".") {
                if inputString.isEmpty {
                    inputString = "0" + "."
                } else {
                    inputString.append(".")
                }
                updateAmountFromInput()
            }
        default:
            let parts = inputString.split(separator: ".", omittingEmptySubsequences: false)
            let integerPartCount = parts.first?.count ?? 0
            if integerPartCount >= 7 && !inputString.contains(".") {
                return
            }
            if key.allSatisfy({ $0.isNumber }) {
                if inputString == "0" {
                    inputString.removeFirst()
                }
                if let dotIndex = inputString.firstIndex(of: ".") {
                    let decimals = inputString[dotIndex...].dropFirst()
                    if decimals.count >= 2 {
                        return
                    }
                }
                inputString.append(key)
                updateAmountFromInput()
            }
        }
    }
}

#Preview {
    @Previewable @State var amount: Double? = 44.99
    TabView {
        NavigationStack {
            CurrencyKeyboardView(amount: $amount, signMode: .both)
        }
        NavigationStack {
            CurrencyKeyboardView(amount: $amount, signMode: .positiveOnly)
        }
        NavigationStack {
            CurrencyKeyboardView(amount: $amount, signMode: .both, displayCurrency: false)
        }
    }
}

#endif
