# ``CurrencyTextFieldKit``

CurrencyTextFieldKit is a Swift package designed to simplify the input and formatting of currency values in iOS, iPadOS, macOS, visionOS, and watchOS applications. It provides a customizable text field component that automatically handles locale-aware currency formatting, user input validation, and editing behaviors, making it easier for developers to integrate currency input fields with minimal effort.

## Overview

CurrencyTextFieldKit offers a reusable and locale-aware currency input field that adapts to the user's locale and preferences. It supports multiple currencies and locales, real-time input validation, and provides a seamless user experience across Apple platforms.

## Installation

Add CurrencyTextFieldKit to your project using Swift Package Manager by adding the following URL to your dependencies:

```swift
https://github.com/matvdg/CurrencyTextFieldKit.git
```

Alternatively, clone the repository and include the package manually in your project.

## Localization

CurrencyTextFieldKit automatically detects and applies the user's current locale settings, including currency symbol, decimal separators, and grouping separators. You can also customize the locale and currency settings programmatically to support multiple currencies within your app.

## Usage Example (iOS, iPadOS, macOS, visionOS, watchOS)

```swift
import SwiftUI
import CurrencyTextFieldKit

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

This example demonstrates how to use `CurrencyTextField` in a SwiftUI view. The text field automatically formats the input as currency based on the current locale.

## Usage Example (watchOS)

For Apple Watch, CurrencyTextFieldKit provides a custom keyboard view called `CurrencyKeyboardView` to facilitate currency input on the smaller screen, since .decimalPad keyboard is not available on watchOS.

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
```

This view presents a currency keyboard optimized for watchOS, allowing users to input currency values efficiently.

## Notes on Sign Modes and Forms

CurrencyTextFieldKit supports different sign modes to control how positive and negative signs are displayed and handled:

- `.both`: Always show the sign.
- `.onlyPositive`: Never show the sign.
- `.onlyNegative`: Show the sign only when negative.

Additionally, the text field supports different forms of currency display, such as standard, accounting, or custom formats, which can be configured to suit your app’s requirements.

## Navigation Stack Compatibility

When using CurrencyTextFieldKit within a`NavigationStack` , the component maintains consistent behavior and formatting during navigation transitions and view updates.

## Key Features

- Locale-aware currency formatting and symbol display  
- Real-time input validation and formatting  
- Support for multiple currencies and locales  
- Easy integration with SwiftUI  
- Compatible across iOS, iPadOS, macOS, visionOS, and watchOS  
- Custom currency keyboard for watchOS  
- Configurable sign modes and currency display forms  
