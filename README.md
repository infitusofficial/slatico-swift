# `SlaticoIcons` — Apple Swift Package (SwiftUI, UIKit & AppKit)

Official Swift Package Manager (`SwiftPM`) library for **Slatico by Infitus Creative Studio**.

Supports all **27 Tier 1 production icon families** across all **7 official styles** (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, and `color`), totaling **189 native vector variants** and **189 bundled SVG resources** on a unified `24×24` optical grid.

## Platform Requirements

- **Swift:** `5.9+`
- **iOS / iPadOS:** `15.0+`
- **macOS:** `12.0+`
- **tvOS:** `15.0+`
- **watchOS:** `8.0+`
- **Zero External Dependencies:** Pure Swift + CoreGraphics `CGPath` vector engine.

---

## Installation (Swift Package Manager)

### Local Monorepo / Relative Path Dependency

Because `Package.swift` resides at `packages/swift/Package.swift` inside the Slatico monorepo, reference it via a local package path when developing against the monorepo checkout:

```swift
dependencies: [
    .package(path: "../slatico/packages/swift")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "SlaticoIcons", package: "SlaticoIcons")
        ]
    )
]
```

### Git Repository Dependency (Release Distribution)

When consuming from the standalone Swift mirror repository or a root-manifest release tag:

```swift
dependencies: [
    .package(url: "https://github.com/infitusofficial/slatico-swift.git", from: "0.1.0")
]
```

---

## SwiftUI Usage

```swift
import SwiftUI
import SlaticoIcons

struct ExampleView: View {
    var body: some View {
        HStack(spacing: 16) {
            // 1. Monochrome icon (tints with Color.primary by default)
            SlaticoIcon(.bell, style: .regular, size: 24)

            // 2. Monochrome icon with custom size and color
            SlaticoIcon(
                .arrowUpRight,
                style: .bold,
                size: 24,
                color: Color(red: 0.004, green: 0.020, blue: 0.125),
                accessibilityLabel: "Open Link"
            )

            // 3. Duotone icon with independent primary color, secondaryColor & secondaryOpacity
            SlaticoIcon(
                .shieldCheck,
                style: .duotone,
                size: 28,
                color: Color(red: 0.004, green: 0.020, blue: 0.125),
                secondaryColor: Color(red: 1.0, green: 0.376, blue: 0.251),
                secondaryOpacity: 0.25,
                accessibilityLabel: "Verified Security"
            )

            // 4. Color icon with default brand palette (#FF6040 primary + #000000 secondary)
            SlaticoIcon(.wallet, style: .color, size: 28, accessibilityLabel: "Wallet")

            // 5. Color icon with two custom colors (`color` + `secondaryColor`)
            SlaticoIcon(
                .bell,
                style: .color,
                size: 28,
                color: Color(red: 1.0, green: 0.376, blue: 0.251),
                secondaryColor: Color(red: 0.004, green: 0.020, blue: 0.125),
                accessibilityLabel: "Alerts"
            )
        }
    }
}
```

### SwiftUI Environment Modifiers

```swift
HStack(spacing: 12) {
    SlaticoIcon(.house)
    SlaticoIcon(.bell)
    SlaticoIcon(.gear)
}
.slaticoIconStyle(.duotone)
.slaticoIconSize(24)
.slaticoIconColor(
    .indigo,
    secondaryColor: .orange,
    secondaryOpacity: 0.25
)
```

---

## UIKit Usage (`iOS`, `iPadOS`, `tvOS`, `Mac Catalyst`)

```swift
import UIKit
import SlaticoIcons

// 1. Monochrome template image (inherits UIImageView.tintColor)
let bellImage = UIImage.slatico(.bell, style: .regular, size: 24)
let imageView = UIImageView(image: bellImage)
imageView.tintColor = .label

// 2. Duotone UIImage with custom primary and secondary colors
let shieldImage = UIImage.slatico(
    .shieldCheck,
    style: .duotone,
    size: 28,
    color: .systemIndigo,
    secondaryColor: .systemOrange,
    secondaryOpacity: 0.25
)

// 3. Color UIImage with default or custom dual-color palette
let walletImage = UIImage.slatico(
    .wallet,
    style: .color,
    size: 32,
    color: UIColor(red: 1.0, green: 0.376, blue: 0.251, alpha: 1.0),
    secondaryColor: .black
)
```

---

## AppKit Usage (`macOS`)

```swift
import AppKit
import SlaticoIcons

// 1. Monochrome template NSImage (isTemplate == true when color is nil)
let regularImage = NSImage.slatico(.bell, style: .regular, size: 20)

// 2. Duotone NSImage
let duotoneImage = NSImage.slatico(
    .layoutDashboard,
    style: .duotone,
    size: 24,
    color: .systemBlue,
    secondaryColor: .systemTeal,
    secondaryOpacity: 0.3
)

// 3. Color NSImage
let colorImage = NSImage.slatico(.wallet, style: .color, size: 24)
```

---

## Accessing Raw Bundled SVG Resources (`189` SVGs)

All 189 master SVGs are bundled in `Bundle.module` under `Resources/svg/<style>/<name>.svg`:

```swift
if let url = SlaticoResources.svgURL(for: .shieldCheck, style: .duotone),
   let svgMarkup = SlaticoResources.svgString(for: .shieldCheck, style: .duotone) {
    print(url, svgMarkup.count)
}
```

## License

MIT © Infitus Creative Studio (`infitusofficial`)
