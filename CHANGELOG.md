# Changelog

## 0.1.0

- Initial release of `SlaticoIcons` for Apple platforms (Swift Package Manager, SwiftUI, UIKit, and AppKit).
- Supports all 23 Tier 1 production icon families across all 7 official styles (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, and `color`), totaling 161 native vector variants and 161 bundled SVG resources.
- Pure Swift/CoreGraphics `CGPath` vector engine (`SlaticoCGPathParser` and `SlaticoCoreGraphicsRenderer`) with zero external dependencies.
- `SlaticoIcon` SwiftUI view with monochrome tinting, independent two-color `Duotone` customization (`color`, `secondaryColor`, `secondaryOpacity`), non-destructive `Color` rendering, environment modifiers, and VoiceOver accessibility support.
- `SlaticoUIImageRenderer` / `UIImage.slatico(...)` for iOS, iPadOS, tvOS, watchOS, and Mac Catalyst.
- `SlaticoNSImageRenderer` / `NSImage.slatico(...)` for macOS AppKit.
