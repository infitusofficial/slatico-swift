import Foundation

/// Provides direct access to the 189 optimized SVG files bundled in `Bundle.module`.
public enum SlaticoResources {
    /// Returns the file `URL` for the bundled `.svg` asset corresponding to `icon` and `style`.
    public static func svgURL(for icon: SlaticoIconName, style: SlaticoStyle = .regular) -> URL? {
        Bundle.module.url(
            forResource: icon.rawValue,
            withExtension: "svg",
            subdirectory: "svg/\(style.rawValue)"
        )
    }

    /// Loads and returns the UTF-8 SVG markup string for `icon` and `style` from `Bundle.module`.
    public static func svgString(for icon: SlaticoIconName, style: SlaticoStyle = .regular) -> String? {
        guard let url = svgURL(for: icon, style: style) else {
            return nil
        }
        return try? String(contentsOf: url, encoding: .utf8)
    }
}
