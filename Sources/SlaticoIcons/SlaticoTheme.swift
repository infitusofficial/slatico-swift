import SwiftUI

/// Ambient styling configuration for `SlaticoIcon` views within a SwiftUI hierarchy.
public struct SlaticoIconTheme: Equatable, Sendable {
    public var style: SlaticoStyle
    public var size: CGFloat
    public var color: Color?
    public var secondaryColor: Color?
    public var secondaryOpacity: Double?

    public init(
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        color: Color? = nil,
        secondaryColor: Color? = nil,
        secondaryOpacity: Double? = nil
    ) {
        self.style = style
        self.size = size
        self.color = color
        self.secondaryColor = secondaryColor
        self.secondaryOpacity = secondaryOpacity
    }
}

private struct SlaticoIconThemeKey: EnvironmentKey {
    static let defaultValue = SlaticoIconTheme()
}

public extension EnvironmentValues {
    /// The current `SlaticoIconTheme` applied to descendant `SlaticoIcon` views.
    var slaticoIconTheme: SlaticoIconTheme {
        get { self[SlaticoIconThemeKey.self] }
        set { self[SlaticoIconThemeKey.self] = newValue }
    }
}

public extension View {
    /// Applies a `SlaticoIconTheme` to all descendant `SlaticoIcon` views.
    func slaticoIconTheme(_ theme: SlaticoIconTheme) -> some View {
        environment(\.slaticoIconTheme, theme)
    }

    /// Sets the default `SlaticoStyle` for descendant `SlaticoIcon` views.
    func slaticoIconStyle(_ style: SlaticoStyle) -> some View {
        transformEnvironment(\.slaticoIconTheme) { theme in
            theme.style = style
        }
    }

    /// Sets the default point size for descendant `SlaticoIcon` views.
    func slaticoIconSize(_ size: CGFloat) -> some View {
        transformEnvironment(\.slaticoIconTheme) { theme in
            theme.size = size
        }
    }

    /// Sets the default primary color for descendant `SlaticoIcon` views.
    func slaticoIconColor(_ color: Color?) -> some View {
        transformEnvironment(\.slaticoIconTheme) { theme in
            theme.color = color
        }
    }

    /// Sets the default Duotone secondary color and optional opacity for descendant `SlaticoIcon` views.
    func slaticoIconSecondaryColor(_ color: Color?, opacity: Double? = nil) -> some View {
        transformEnvironment(\.slaticoIconTheme) { theme in
            theme.secondaryColor = color
            if let opacity {
                theme.secondaryOpacity = opacity
            }
        }
    }
}
