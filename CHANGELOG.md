# Changelog

## 0.1.0 — 2026-11-02

- First public release of `SlaticoIcons` for Apple platforms, distributed via Swift Package Manager from `https://github.com/infitusofficial/slatico-swift`.
- Supports all 27 Tier 1 production icon families across all 7 official styles (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, and `color`), totaling 189 native vector variants and 189 bundled SVG resources.
- Pure Swift/CoreGraphics `CGPath` vector engine (`SlaticoCGPathParser` and `SlaticoCoreGraphicsRenderer`) with zero external dependencies.
- `SlaticoIcon` SwiftUI view with monochrome tinting, independent two-color `Duotone` customization (`color`, `secondaryColor`, `secondaryOpacity`), dual-color `Color` customization (`color`, `secondaryColor`), environment modifiers, and VoiceOver accessibility support.
- `SlaticoUIImageRenderer` / `UIImage.slatico(...)` for iOS, iPadOS, tvOS, and Mac Catalyst.
- `SlaticoNSImageRenderer` / `NSImage.slatico(...)` for macOS AppKit.
