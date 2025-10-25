# CurrencyTextFieldKit

**Tags:** apple-watch • apple-watch-keyboard • apple-watch-keypad • decimal • keyboard • keypad • number-pad • swift • swiftui • watchOS • ios • ipados • macos • visionos • currency • amount • money • finance • numberfield

## Description
A simple and lightweight SwiftUI component for handling currency input seamlessly across all Apple platforms (iOS, iPadOS, macOS, visionOS, and watchOS 26+).

On iOS, iPadOS and visionOS, CurrencyTextField uses the native decimalPad keyboard while still enforcing smart formatting rules.  
On macOS, it validates input characters manually since the decimalPad isn’t available.  
On watchOS, it introduces a fully custom numeric keyboard — not available natively on watchOS — called `CurrencyKeyboardView`, which can also be used independently of `CurrencyTextField` if desired.

![Screenshot](https://github.com/matvdg/CurrencyTextFieldKit/blob/9d696ceeb9aa73d30b47283cd9755cb531cc8ec0/Screenshots/watchOS%2B.png)
![Screenshot](https://github.com/matvdg/CurrencyTextFieldKit/blob/9d696ceeb9aa73d30b47283cd9755cb531cc8ec0/Screenshots/watchOS-.png)


## Install

Add the following dependency to your Package.swift:
```swift
dependencies: [
    .package(url: "https://github.com/matvdg/CurrencyTextField.git", from: "1.0.0")
]
```

### Localization

To fully support localization of placeholders and toggle labels, add the following keys to your String Catalog (or `Localizable.strings`) in your project:

```text
"amount" = "Amount";
"overdrawn" = "Overdrawn";
```

Then import it in your SwiftUI file:
```swift
import CurrencyTextFieldKit
```

![Screenshot](https://github.com/matvdg/CurrencyTextFieldKit/blob/9d696ceeb9aa73d30b47283cd9755cb531cc8ec0/Screenshots/watchOS_recording.mov)


## Usage Example

You can easily initialize a `CurrencyTextField` in your SwiftUI view:

```swift
import SwiftUI
import CurrencyTextField

struct ContentView: View {
    @State private var amount: Double?
    @State private var signMode: SignMode = .both

    var body: some View {
        CurrencyTextField(value: $amount, signMode: signMode)
            .padding()
    }
}
```

You can also wrap it in a `NavigationStack` and a `Form`, which is **required on watchOS** to enable pushing the `CurrencyKeyboardView`:

```swift
NavigationStack {
    Form {
        CurrencyTextField(amount: $amount)
    }
}
// ⚠️ Necessary for watchOS to push the CurrencyKeyboardView.
```

When `signMode` is set to `.both`, a toggle (or a dedicated ± button on Apple Watch) allows switching between positive and negative values.  
When you use `.positiveOnly` or `.negativeOnly`, the toggle is automatically hidden, and the sign is forced accordingly.

### 💡 watchOS-only usage
If your project targets **only watchOS**, or you want to build a specific watchOS view inside a cross-platform app, you can directly use the custom `CurrencyKeyboardView`:

```swift
#if os(watchOS)
import SwiftUI
import CurrencyTextField

struct WatchCurrencyView: View {
    @State private var amount: Double?

    var body: some View {
        CurrencyKeyboardView(value: $amount)
    }
}
#endif
```

You can also hide the currency symbol inside the decimal pad if needed using the optional parameter `displayCurrency`:

```swift
CurrencyKeyboardView(value: $amount, signMode: .both, displayCurrency: false)
```

This approach gives you a full numeric keyboard experience on watchOS, which does not exist natively.

## Key Features
* ✅ Smart currency formatting with optional minus sign and dynamic color (red, primary, or green)
* ✅ Supports multiple currency symbols ($, €, …)
* ✅ Automatically inserts thousands separators (X XXX XXX.XX)
* ✅ Prevents leading zeros (e.g. 00 → 0, 06 → 6, 0.6 → 0.6)
* ✅ Adds a zero before a starting decimal point (.6 → 0.6)
* ✅ Converts "." to the appropriate decimal separator according to Locale *(on macOS, input comes from a physical keyboard)*
* ✅ Limits decimals to two digits (e.g. 0.999 → 0.99)
* ✅ Rejects non-numeric characters and enforces valid input rules on all platforms
* ✅ Includes a custom watchOS numeric keyboard (`CurrencyKeyboardView`) usable on its own or embedded in `CurrencyTextField`
* ✅ Includes a toggle to switch between positive and negative values when `signMode = .both`, since the native decimalPad does not support +/− input. On watchOS, a dedicated button is available in the `CurrencyKeyboardView` for sign switching.



## Feedbacks / feature request / bug

Feel free to create an issue on GitHub or contact me: matvdg@me.com
