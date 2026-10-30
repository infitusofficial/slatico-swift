import CoreGraphics
import Foundation

/// Defines how a single vector path layer resolves its fill color at render time.
public enum SlaticoLayerRole: Equatable, Sendable {
    /// Uses the primary icon tint color.
    case primary

    /// Uses the Duotone secondary tint color (falling back to primary color with secondary opacity).
    case secondary

    /// Uses an intrinsic sRGB color from a multi-tone `color` icon unless explicitly overridden.
    case fixedColor(hex: String, red: Double, green: Double, blue: Double)
}

/// Represents a single ordered vector path layer within a 24×24 Slatico icon.
public struct SlaticoVectorLayerSpec: Equatable, Sendable {
    /// W3C SVG 1.1 path data string (`d` attribute) in the 24×24 coordinate space.
    public let pathData: String

    /// Semantic color role for this path layer.
    public let role: SlaticoLayerRole

    /// Default layer opacity in `[0.0, 1.0]` (e.g., `0.2` for Duotone secondary layers, `1.0` for primary).
    public let defaultOpacity: Double

    /// Whether this path uses the even-odd winding rule (`true`) or non-zero winding rule (`false`).
    public let isEvenOdd: Bool

    public init(
        pathData: String,
        role: SlaticoLayerRole,
        defaultOpacity: Double,
        isEvenOdd: Bool
    ) {
        self.pathData = pathData
        self.role = role
        self.defaultOpacity = defaultOpacity
        self.isEvenOdd = isEvenOdd
    }

    /// Constructs (or retrieves from cache) the Core Graphics `CGPath` in the 24×24 coordinate space.
    public var cgPath: CGPath {
        SlaticoCGPathParser.cgPath(from: pathData)
    }
}

/// Complete 24×24 vector specification for a specific Slatico icon family and style variant.
public struct SlaticoVectorIconSpec: Equatable, Sendable {
    /// Canonical icon family identifier.
    public let name: SlaticoIconName

    /// Architectural visual style.
    public let style: SlaticoStyle

    /// Master coordinate canvas size (`24×24`).
    public let viewBoxSize: CGSize

    /// Ordered vector path layers in back-to-front painter's order.
    public let layers: [SlaticoVectorLayerSpec]

    public init(
        name: SlaticoIconName,
        style: SlaticoStyle,
        viewBoxSize: CGSize = CGSize(width: 24, height: 24),
        layers: [SlaticoVectorLayerSpec]
    ) {
        self.name = name
        self.style = style
        self.viewBoxSize = viewBoxSize
        self.layers = layers
    }
}
