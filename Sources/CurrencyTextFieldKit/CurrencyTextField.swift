import SwiftUI

/// A SwiftUI view that provides a currency input text field with automatic formatting and sign control.
///
/// `CurrencyTextField` supports multiple platforms including iOS, macOS, and watchOS, adapting its UI accordingly:
/// - On watchOS, it presents a navigation link to a custom `CurrencyKeyboardView` for input.
/// - On other platforms, it displays a formatted `TextField` with real-time validation and styling.
///
/// Features include:
/// - Automatic formatting of currency input according to the current locale.
/// - Color styling of the text based on positive (green), negative (red), or zero/empty (primary) values.
/// - Support for toggling the sign of the amount when `signMode` is set to `.both`.
/// - Restricts input to valid currency formats (max 7 integer digits, max 2 decimal places).
///
/// This component binds to an optional `Double` representing the currency amount, updating as the user edits.
///
/// ```swift
/// import SwiftUI
///  import CurrencyTextField
///
/// struct ContentView: View {
///     @State private var amount: Double?
///     @State private var signMode: SignMode = .both
///
///
///     var body: some View {
///         NavigationStack {
///           Form {
///                 CurrencyTextField(value: $amount, signMode: signMode)
///                     .padding()
///           }
///         }
///     }
/// }
/// ```
///
/// - Parameter amount: The optional `Double` value representing the currency amount to display. If `nil`, a placeholder text is shown.
/// - Parameter signMode: Defines whether the input allows positive, negative, or both types of values.
public struct CurrencyTextField: View {
    
    /// The bound optional amount value represented by the text field.
    @Binding var amount: Double?
    
    /// The allowed sign mode for the amount.
    /// - `.both`: Allow positive and negative values with toggle.
    /// - `.positiveOnly`: Only allow positive values.
    /// - `.negativeOnly`: Only allow negative values.
    var signMode: SignMode = .both
    
    /// The current text representation of the amount, used for editing and display.
    @State private var textValue: String = ""
    
    /// Tracks whether the current amount is positive.
    @State var isPositive = true
    
    /// Focus state indicating whether the text field is currently being edited.
    @FocusState private var isEditing: Bool
    
    /// The decimal separator string for the current locale (e.g., "." or ",").
    private let decimalSeparator: String = Locale.current.decimalSeparator ?? "."

    /// Creates a new `CurrencyTextField` with a binding to an optional amount and an optional sign mode.
    ///
    /// - Parameters:
    ///   - amount: A binding to the optional `Double` value representing the currency amount.
    ///   - signMode: The allowed sign mode for the amount. Defaults to `.both`.
    public init(amount: Binding<Double?>, signMode: SignMode = .both) {
        self._amount = amount
        self.signMode = signMode
    }
    
    /// The content and behavior of the view.
    ///
    /// On watchOS, this view presents a `NavigationLink` to a `CurrencyKeyboardView` for input.
    /// On other platforms, it displays a formatted `TextField` with validation, sign toggling,
    /// and a confirmation button when editing.
    public var body: some View {
#if os(watchOS)
        NavigationLink {
            CurrencyKeyboardView(amount: $amount, signMode: signMode)
        } label: {
            CurrencyText(amount: amount)
        }
#else
        VStack(spacing: 20) {
            HStack {
                HStack(spacing: 0) {
#if !os(macOS)
                    if !isPositive, !textValue.isEmpty {
                        Text("-")
                    }
#endif
                    TextField("amount", text: $textValue)
                        .focused($isEditing)
#if !os(macOS)
                        .keyboardType(.decimalPad)
#endif
                        .onAppear {
                            textValue = formattedAmount(amount, withSymbol: true)
                        }
                        .onChange(of: textValue) {
                            guard isEditing else { return }
                            handleInput()
                            updateAmountFromInput()
                        }
                        .onChange(of: isEditing) { _, editing in
                            if !editing {
                                textValue = formattedAmount(amount, withSymbol: true)
                            } else {
                                textValue = formattedAmount(amount, withSymbol: false)
                            }
                        }
                }
                .foregroundColor(color(for: amount))
                .bold()
                if isEditing {
                    Button {
                        isEditing = false
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .bold()
                            .imageScale(.large)
                    }
                }
            }
            .onAppear {
                if let amount {
                    isPositive = amount >= 0
                }
            }
            if signMode == .both {
                Divider()
                Toggle("overdrawn", isOn: Binding(
                    get: { !isPositive },
                    set: { _,_ in
                        isPositive.toggle()
                        if let amt = amount {
                            amount = -amt
                        }
                    }
                ))
            }
        }
#endif
    }
    
    /// Handles and sanitizes the user input in `textValue` to enforce currency formatting rules.
    ///
    /// Rules enforced:
    /// - Limits integer digits to a maximum of 7.
    /// - Prevents leading zeros unless followed by a decimal separator.
    /// - Adds a leading zero if input starts with a decimal separator.
    /// - Converts '.' to the locale-specific decimal separator.
    /// - Limits decimal digits to a maximum of 2.
    /// - Removes invalid characters that cannot be parsed to a valid number.
    private func handleInput() {
        // Maximum 7 integer digits (X XXX XXX.XX)
        let parts = textValue.split(separator: decimalSeparator, omittingEmptySubsequences: false)
        let integerPartCount = parts.first?.count ?? 0
        if integerPartCount > 7 && !textValue.cleanComa.contains(".") {
            textValue.removeLast()
        }
        // Prevents 0X (00 -> 0, 06 -> 6, 0.6 -> 0.6)
        if textValue.count > 1 && textValue.hasPrefix("0") && !textValue.cleanComa.hasPrefix("0.") {
            textValue.removeFirst()
        }
        // Add 0 before .
        if textValue.cleanComa.hasPrefix(".") {
            textValue = "0\(decimalSeparator)"
        }
        
        // Convert . into decimalSeparator
        if textValue.hasSuffix(".") {
            textValue.removeLast()
            textValue.append(decimalSeparator)
        }
        
        // Prevents more than two decimal digits (0.999 -> 0.99)
        if let dotIndex = textValue.firstIndex(of: Character("\(decimalSeparator)")) ?? textValue.firstIndex(of: Character(".")) {
            let decimals = textValue[dotIndex...].dropFirst()
            if decimals.count > 2 {
                textValue.removeLast()
            }
        }
        // Prevents forbidden digits (everything excepts numerical digits)
        if Double(textValue.cleanComa) == nil, !textValue.isEmpty {
            textValue.removeLast()
        }
    }
    
    /// Updates the bound `amount` property based on the sanitized `textValue`.
    ///
    /// Converts the string to a `Double` and applies the sign rules based on `signMode` and `isPositive`.
    /// Sets `amount` to `nil` if the input is invalid or empty.
    private func updateAmountFromInput() {
        guard let number = Double(textValue.cleanComa), textValue != "." else {
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
    
    /// Formats a `Double` value into a localized currency string.
    ///
    /// - Parameters:
    ///   - value: The optional `Double` value to format.
    ///   - withSymbol: A Boolean indicating whether to include the currency symbol.
    /// - Returns: A formatted currency string, or an empty string if `value` is `nil`.
    private func formattedAmount(_ value: Double?, withSymbol: Bool) -> String {
        guard let value else { return "" }
        let formatter = NumberFormatter.getCurrencyFormatter()
        if !withSymbol {
            formatter.currencySymbol = ""
        }
        let result = formatter.string(from: NSNumber(value: abs(value)))?.trimmingCharacters(in: .whitespaces) ?? ""
        return withSymbol ? result : result.cleanSpaces
    }
    
    /// Determines the text color based on the value's sign.
    ///
    /// - Parameter value: The optional `Double` value to evaluate.
    /// - Returns: `.green` for positive, `.red` for negative, and `.primary` for zero or `nil`.
    private func color(for value: Double?) -> Color {
        guard let v = value else { return .primary }
        return v > 0 ? .green : (v < 0 ? .red : .primary)
    }
}

#Preview {
    @Previewable @State var amount0: Double? = nil
    @Previewable @State var amount1: Double? = 0
    @Previewable @State var amount2: Double? = 56.78
    @Previewable @State var amount3: Double? = -22
    NavigationStack {
        Form {
            Section("SignMode: both") {
                CurrencyTextField(amount: $amount0)
                CurrencyTextField(amount: $amount1)
                CurrencyTextField(amount: $amount2)
                CurrencyTextField(amount: $amount3)
            }
            Section("SignMode: positiveOnly") {
                CurrencyTextField(amount: $amount2, signMode: .positiveOnly)
            }
            Section("SignMode: negativeOnly") {
                CurrencyTextField(amount: $amount3, signMode: .negativeOnly)
            }
        }
    }
    .navigationTitle("Demo Form")
}
