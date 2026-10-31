import SwiftUI

/// Native SwiftUI vector icon view supporting all 23 Tier 1 Slatico icon families
/// across all 7 official styles (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, and `color`).
///
/// - Monochrome styles (`.thin`, `.light`, `.regular`, `.bold`, `.fill`) tint using `color` (or `.primary`).
/// - `.duotone` renders its primary layer using `color` and its secondary layer using `secondaryColor`
///   (or `color`) with `secondaryOpacity` (defaulting to the SVG's authored 20% opacity).
/// - `.color` preserves its intrinsic multi-tone sRGB palette without destructive tinting unless
///   an explicit `color` override is passed.
public struct SlaticoIcon: View {
    public let name: SlaticoIconName
    public let style: SlaticoStyle?
    public let size: CGFloat?
    public let color: Color?
    public let secondaryColor: Color?
    public let secondaryOpacity: Double?
    public let accessibilityLabel: Text?

    @Environment(\.slaticoIconTheme) private var theme

    /// Creates a `SlaticoIcon` view with an optional `Text` accessibility label.
    /// When `accessibilityLabel` is `nil`, the icon is treated as decorative and hidden from accessibility.
    public init(
        _ name: SlaticoIconName,
        style: SlaticoStyle? = nil,
        size: CGFloat? = nil,
        color: Color? = nil,
        secondaryColor: Color? = nil,
        secondaryOpacity: Double? = nil,
        accessibilityLabel: Text? = nil
    ) {
        self.name = name
        self.style = style
        self.size = size
        self.color = color
        self.secondaryColor = secondaryColor
        self.secondaryOpacity = secondaryOpacity
        self.accessibilityLabel = accessibilityLabel
    }

    /// Creates a `SlaticoIcon` view with a `String` accessibility label.
    public init(
        _ name: SlaticoIconName,
        style: SlaticoStyle? = nil,
        size: CGFloat? = nil,
        color: Color? = nil,
        secondaryColor: Color? = nil,
        secondaryOpacity: Double? = nil,
        accessibilityLabel: String
    ) {
        self.init(
            name,
            style: style,
            size: size,
            color: color,
            secondaryColor: secondaryColor,
            secondaryOpacity: secondaryOpacity,
            accessibilityLabel: Text(accessibilityLabel)
        )
    }

    public var body: some View {
        let resolvedStyle = style ?? theme.style
        let resolvedSize = max(1, size ?? theme.size)
        let resolvedPrimary = color ?? theme.color
        let resolvedSecondary = secondaryColor ?? theme.secondaryColor
        let resolvedSecOpacity = secondaryOpacity ?? theme.secondaryOpacity
        let spec = SlaticoVectorCatalog.spec(for: name, style: resolvedStyle)
        let scaleFactor = resolvedSize / 24.0

        let vectorCanvas = ZStack(alignment: .topLeading) {
            ForEach(Array(spec.layers.enumerated()), id: \.offset) { _, layer in
                Path(layer.cgPath)
                    .scale(scaleFactor, anchor: .topLeading)
                    .fill(
                        resolveFillColor(
                            for: layer,
                            style: resolvedStyle,
                            primaryColor: resolvedPrimary,
                            secondaryColor: resolvedSecondary,
                            secondaryOpacity: resolvedSecOpacity
                        ),
                        style: FillStyle(eoFill: layer.isEvenOdd)
                    )
            }
        }
        .frame(width: resolvedSize, height: resolvedSize)
        .aspectRatio(1, contentMode: .fit)

        if let label = accessibilityLabel {
            vectorCanvas
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(label)
                .accessibilityAddTraits(.isImage)
        } else {
            vectorCanvas
                .accessibilityHidden(true)
        }
    }

    private func resolveFillColor(
        for layer: SlaticoVectorLayerSpec,
        style: SlaticoStyle,
        primaryColor: Color?,
        secondaryColor: Color?,
        secondaryOpacity: Double?
    ) -> Color {
        switch layer.role {
        case .primary:
            return (primaryColor ?? .primary).opacity(layer.defaultOpacity)

        case .secondary:
            let base = secondaryColor ?? primaryColor ?? .primary
            let alpha = min(1.0, max(0.0, secondaryOpacity ?? layer.defaultOpacity))
            return base.opacity(alpha)

        case let .fixedColor(hex, red, green, blue):
            if hex.uppercased() == "#000000" {
                if let explicitSecondary = secondaryColor {
                    return explicitSecondary.opacity(layer.defaultOpacity)
                }
            } else if let explicitPrimary = primaryColor {
                return explicitPrimary.opacity(layer.defaultOpacity)
            }
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: layer.defaultOpacity)
        }
    }
}
