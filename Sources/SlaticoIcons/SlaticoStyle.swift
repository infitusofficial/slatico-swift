import Foundation

/// The seven official architectural styles supported across every Slatico icon family.
public enum SlaticoStyle: String, CaseIterable, Codable, Sendable, Identifiable {
    /// 1px optical stroke weight.
    case thin = "thin"

    /// 1.5px optical stroke weight.
    case light = "light"

    /// 2px balanced default stroke weight.
    case regular = "regular"

    /// 3px high-emphasis stroke weight.
    case bold = "bold"

    /// Solid geometric silhouette with negative-space compound cutouts.
    case fill = "fill"

    /// Layered primary structure paired with a translucent secondary tone.
    case duotone = "duotone"

    /// Multi-tone semantic vector artwork.
    case color = "color"

    /// Unique identifier for SwiftUI `ForEach` and `Identifiable` conformance.
    public var id: String { rawValue }

    /// Human-readable display label for UI pickers and documentation.
    public var label: String {
        switch self {
        case .thin: return "Thin"
        case .light: return "Light"
        case .regular: return "Regular"
        case .bold: return "Bold"
        case .fill: return "Fill"
        case .duotone: return "Duotone"
        case .color: return "Color"
        }
    }

    /// Indicates whether this style is a single-tone monochrome style (`thin` through `fill`).
    public var isMonochrome: Bool {
        switch self {
        case .thin, .light, .regular, .bold, .fill:
            return true
        case .duotone, .color:
            return false
        }
    }

    /// Resolves a `SlaticoStyle` from its lowercase identifier, or returns `nil`.
    public init?(id: String) {
        self.init(rawValue: id.lowercased())
    }
}
