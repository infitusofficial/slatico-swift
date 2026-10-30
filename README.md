# SlaticoIcons (Apple Native SDK)

**SlaticoIcons** is the official Apple native icon package for **Slatico by Infitus Creative Studio**, engineered for **SwiftUI**, **UIKit**, and **AppKit** across **iOS**, **iPadOS**, **macOS**, **Mac Catalyst**, **tvOS**, and **watchOS**.

It ships **23 Tier 1 icon families** across all **7 official styles** (**161 vector variants**) with zero external dependencies, powered by a deterministic `CGPath` vector engine (`SlaticoCGPathParser` + `SlaticoCoreGraphicsRenderer`) and bundled canonical `.svg` resources.

---

## Supported Platforms & Tooling

| Platform | Minimum Deployment Target | Frameworks Supported |
| :--- | :--- | :--- |
| **iOS / iPadOS** | iOS 15.0+ | SwiftUI, UIKit (`UIImage`), CoreGraphics |
| **macOS** | macOS 12.0+ (Monterey) | SwiftUI, AppKit (`NSImage`), CoreGraphics |
| **Mac Catalyst** | Mac Catalyst 15.0+ | SwiftUI, UIKit (`UIImage`), CoreGraphics |
| **tvOS** | tvOS 15.0+ | SwiftUI, UIKit (`UIImage`), CoreGraphics |
| **watchOS** | watchOS 8.0+ | SwiftUI, CoreGraphics |
| **Swift Tools** | Swift 5.9+ (Xcode 15+) | Swift Package Manager (`Package.swift`) |

---

## Installation (Swift Package Manager)

### Option 1: Local Path / Monorepo Integration (Immediate)

Because Slatico is structured as a multi-platform monorepo with the Swift package located in `packages/swift/`, you can reference `packages/swift` directly as a local Swift Package in Xcode (**File → Add Package Dependencies… → Add Local…**) or in your `Package.swift`:

```swift
dependencies: [
    .package(path: "path/to/slatico/packages/swift")
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

### Option 2: Remote GitHub URL & Monorepo Distribution Strategy

> **Important Note on Swift Package Manager & Monorepo Subdirectories:**  
> Standard Swift Package Manager remote Git URL resolution (`.package(url: "https://github.com/infitusofficial/slatico.git", from: "0.1.0")`) expects `Package.swift` at the **root** of the Git repository.
>
> For public release tagging, Slatico supports two clean distribution strategies without moving `packages/swift/`:
> 1. **Dedicated Read-Only Mirror Repository (`slatico-swift`):** Sync `packages/swift/` to `https://github.com/infitusofficial/slatico-swift.git` via `git subtree split --prefix=packages/swift` on release tags so Xcode users can add `https://github.com/infitusofficial/slatico-swift.git`.
> 2. **Root-Level Forwarding `Package.swift`:** Alternatively, a lightweight root `Package.swift` pointing target `path: "packages/swift/Sources/SlaticoIcons"` can be added at release time if single-repo URL consumption is desired.

---

## Quick Start

### 1. SwiftUI (`SlaticoIcon`)

```swift
import SwiftUI
import SlaticoIcons

struct DashboardHeaderView: View {
    var body: some View {
        HStack(spacing: 16) {
            // 1. Monochrome style (Thin, Light, Regular, Bold, Fill)
            // Automatically inherits .foregroundStyle / environment color when color is nil
            SlaticoIcon(.house, style: .regular, size: 24, color: .blue)

            // 2. Duotone style with independent primary & secondary colors + opacity
            SlaticoIcon(
                .bell,
                style: .duotone,
                size: 28,
                color: .primary,
                secondaryColor: .orange,
                secondaryOpacity: 0.25,
                accessibilityLabel: "Notifications"
            )

            // 3. Multi-tone Color style (preserves original sRGB artwork palette)
            SlaticoIcon(
                .wallet,
                style: .color,
                size: 32,
                accessibilityLabel: "Wallet balance"
            )
        }
    }
}
```

#### Environment-Driven Theming (`SlaticoIconTheme`)

Configure default style, size, and Duotone colors for an entire SwiftUI view hierarchy:

```swift
VStack {
    SlaticoIcon(.cloudCheck)
    SlaticoIcon(.layoutDashboard)
    SlaticoIcon(.shieldCheck)
}
.slaticoIconTheme(
    SlaticoIconTheme(
        style: .duotone,
        size: 24,
        color: .indigo,
        secondaryColor: .cyan,
        secondaryOpacity: 0.22
    )
)
```

---

### 2. UIKit (`UIImage.slatico` & `SlaticoUIImageRenderer`)

Available on iOS, iPadOS, Mac Catalyst, and tvOS:

```swift
import UIKit
import SlaticoIcons

// Monochrome UIImage (explicit color)
let houseImage = UIImage.slatico(
    .house,
    style: .regular,
    size: 24,
    color: .label
)

// Template image for UIImageView.tintColor (pass color: nil on monochrome styles)
let templateImage = UIImage.slatico(
    .gear,
    style: .bold,
    size: 24
)

// Two-tone Duotone UIImage
let duotoneBell = UIImage.slatico(
    .bell,
    style: .duotone,
    size: 32,
    color: .label,
    secondaryColor: .systemOrange,
    secondaryOpacity: 0.25
)

// Multi-tone Color UIImage (preserves brand palette)
let colorShield = UIImage.slatico(
    .shieldCheck,
    style: .color,
    size: 32
)
```

---

### 3. AppKit (`NSImage.slatico` & `SlaticoNSImageRenderer`)

Available on macOS:

```swift
import AppKit
import SlaticoIcons

// Monochrome NSImage
let dashboardImage = NSImage.slatico(
    .layoutDashboard,
    style: .regular,
    size: 24,
    color: .labelColor
)

// Duotone NSImage
let duotoneTrend = NSImage.slatico(
    .trendUp,
    style: .duotone,
    size: 28,
    color: .controlAccentColor,
    secondaryColor: .systemTeal,
    secondaryOpacity: 0.22
)

// Multi-tone Color NSImage
let colorWallet = NSImage.slatico(
    .wallet,
    style: .color,
    size: 32
)
```

---

## All Seven Official Styles

Every icon family in `SlaticoIconName` is available in all 7 styles via `SlaticoStyle`:

| Style (`SlaticoStyle`) | Rendering Behavior | Tintable? |
| :--- | :--- | :--- |
| `.thin` | Crisp 1.25px structural contour paths converted to exact vector outlines | Yes (`color`) |
| `.light` | Balanced 1.5px contour paths | Yes (`color`) |
| `.regular` | Primary 1.75px interface weight (default) | Yes (`color`) |
| `.bold` | High-contrast 2.25px emphasis weight | Yes (`color`) |
| `.fill` | Solid silhouette with `evenOdd` negative-space cutouts preserved | Yes (`color`) |
| `.duotone` | Multi-layer vector asset with `.secondary` tone layer (default `0.2` opacity) + `.primary` foreground structure | Yes (independent `color` + `secondaryColor` + `secondaryOpacity`) |
| `.color` | Full multi-tone sRGB brand palette (`#FF6040` coral accent + `#000000` structural ink) | Fixed palette by default (not destructively flattened) |

---

## Tier 1 Icon Families (23 Families × 7 Styles = 161 Variants)

| Swift Case (`SlaticoIconName`) | Canonical Slug (`rawValue`) |
| :--- | :--- |
| `.bell` | `bell` |
| `.cloud` | `cloud` |
| `.cloudCheck` | `cloud-check` |
| `.creditCard` | `credit-card` |
| `.envelope` | `envelope` |
| `.envelopeOpen` | `envelope-open` |
| `.gear` | `gear` |
| `.house` | `house` |
| `.layoutDashboard` | `layout-dashboard` |
| `.lock` | `lock` |
| `.lockOpen` | `lock-open` |
| `.magnifyingGlass` | `magnifying-glass` |
| `.minus` | `minus` |
| `.pencil` | `pencil` |
| `.plus` | `plus` |
| `.shield` | `shield` |
| `.shieldCheck` | `shield-check` |
| `.slidersHorizontal` | `sliders-horizontal` |
| `.trash` | `trash` |
| `.trashX` | `trash-x` |
| `.trendUp` | `trend-up` |
| `.user` | `user` |
| `.wallet` | `wallet` |

---

## Accessibility (VoiceOver)

- **Decorative Icons (Default):** When `accessibilityLabel` is `nil`, `SlaticoIcon` applies `.accessibilityHidden(true)` so VoiceOver does not announce redundant decorative graphics next to text labels.
- **Semantic Icons:** When `accessibilityLabel` is non-empty, `SlaticoIcon` marks the element as `.isImage` and announces the localized label.

```swift
// Decorative (skipped by VoiceOver)
SlaticoIcon(.magnifyingGlass, style: .regular, size: 20)

// Semantic (announced by VoiceOver as "Search documents, Image")
SlaticoIcon(.magnifyingGlass, style: .regular, size: 20, accessibilityLabel: "Search documents")
```

---

## Accessing Bundled Canonical SVG Resources

All 161 canonical `.svg` files are bundled in `Bundle.module` under `Resources/svg/<style>/<icon-name>.svg` and can be inspected at runtime via `SlaticoResources`:

```swift
import SlaticoIcons

if let url = SlaticoResources.svgURL(for: .house, style: .duotone),
   let rawSVG = SlaticoResources.svgString(for: .house, style: .duotone) {
    print("Bundled SVG URL:", url)
    print("SVG markup bytes:", rawSVG.utf8.count)
}
```

---

## Code Generation & Testing

### Regenerating From `icons/`

From the monorepo root:

```bash
pnpm icons:generate
```

This runs `scripts/generate-swift.ts`, which:
1. Validates all 161 SVG variants in `icons/<style>/<name>.svg`.
2. Checks for unsupported SVG primitives (`<text>`, `<image>`, `<filter>`, `<foreignObject>`, `<mask>`, `<use>`, `<style>`, `<script>`) and fails loudly if any exist.
3. Generates `Sources/SlaticoIcons/Generated/SlaticoIconName.generated.swift` (with automatic backtick escaping for Swift reserved keywords as Tier 2 and Tier 3 expand).
4. Generates `Sources/SlaticoIcons/Generated/SlaticoVectorCatalog.generated.swift`.
5. Syncs all 161 `.svg` files into `Sources/SlaticoIcons/Resources/svg/<style>/<name>.svg`.

### Running Swift Package Tests (macOS / Xcode)

```bash
cd packages/swift
swift build
swift test
```

## License

MIT © Infitus Creative Studio
