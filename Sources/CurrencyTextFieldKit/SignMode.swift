
import Foundation

/// Determines the allowed sign input behavior for currency fields.
///
/// Use `SignMode` to specify whether a currency field should accept only positive values, only negative values, or both.
public enum SignMode {
    /// Only positive values are allowed.
    case positiveOnly
    /// Only negative values are allowed.
    case negativeOnly
    /// Both positive and negative values are allowed.
    case both
}
