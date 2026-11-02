// Runtime smoke test executed on macOS by CI against the consumed SlaticoIcons package.
import Foundation
import CoreGraphics
import SwiftUI
import SlaticoIcons
import SlaticoConsumer
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

var failures: [String] = []

@MainActor
func check(_ condition: @autoclosure () -> Bool, _ message: String) {
    if !condition() { failures.append(message) }
}

/// Redraws any CGImage into a known RGBA8 (premultiplied-last, sRGB) buffer.
func rgbaPixels(_ image: CGImage) -> [UInt8] {
    let width = image.width, height = image.height
    var buffer = [UInt8](repeating: 0, count: width * height * 4)
    let space = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
    buffer.withUnsafeMutableBytes { raw in
        guard let context = CGContext(
            data: raw.baseAddress, width: width, height: height, bitsPerComponent: 8,
            bytesPerRow: width * 4, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }
        context.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
    }
    return buffer
}

/// Counts pixels with non-zero alpha.
func paintedPixelCount(_ image: CGImage) -> Int {
    let bytes = rgbaPixels(image)
    return stride(from: 3, to: bytes.count, by: 4).reduce(0) { $0 + (bytes[$1] > 0 ? 1 : 0) }
}

/// Collects distinct opaque RGB colors (quantized) to prove multi-layer rendering.
func distinctColors(_ image: CGImage) -> Set<Int> {
    let bytes = rgbaPixels(image)
    var colors = Set<Int>()
    for y in 0..<image.height {
        for x in 0..<image.width {
            let i = (y * image.width + x) * 4
            guard bytes[i + 3] == 255 else { continue }
            colors.insert((Int(bytes[i]) >> 4) << 8 | (Int(bytes[i + 1]) >> 4) << 4 | (Int(bytes[i + 2]) >> 4))
        }
    }
    return colors
}

setvbuf(stdout, nil, _IOLBF, 0)

// 1. Catalog shape
check(SlaticoIconName.allCases.count == 27, "Expected 27 icon families, got \(SlaticoIconName.allCases.count)")
check(SlaticoStyle.allCases.count == 7, "Expected 7 styles, got \(SlaticoStyle.allCases.count)")

// 2. Every variant renders through CoreGraphics and every SVG resource loads from Bundle.module
var renderedVariants = 0
var loadedResources = 0
for icon in SlaticoIconName.allCases {
    for style in SlaticoStyle.allCases {
        if let image = SlaticoCoreGraphicsRenderer.cgImage(for: icon, style: style, size: 24, scale: 2),
           image.width == 48, paintedPixelCount(image) > 0 {
            renderedVariants += 1
        } else {
            failures.append("CGImage render failed or empty: \(icon.rawValue) / \(style.rawValue)")
        }
        if let svg = SlaticoResources.svgString(for: icon, style: style), svg.contains("<svg") {
            loadedResources += 1
        } else {
            failures.append("Bundled SVG resource missing: svg/\(style.rawValue)/\(icon.rawValue).svg")
        }
    }
}
check(renderedVariants == 189, "Expected 189 rendered variants, got \(renderedVariants)")
check(loadedResources == 189, "Expected 189 bundled SVG resources, got \(loadedResources)")

// 3. Duotone: secondary layer honours a custom secondaryColor (two distinct colors on screen)
let red = CGColor(srgbRed: 1, green: 0, blue: 0, alpha: 1)
let blue = CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)
if let duo = SlaticoCoreGraphicsRenderer.cgImage(
    for: .shieldCheck, style: .duotone, size: 48, primaryColor: red, secondaryColor: blue, secondaryOpacity: 1, scale: 2
) {
    check(distinctColors(duo).count >= 2, "Duotone did not render separate primary/secondary colors")
} else {
    failures.append("Duotone render returned nil")
}

// 4. Color: default intrinsic palette renders more than one color
if let colorImage = SlaticoCoreGraphicsRenderer.cgImage(for: .wallet, style: .color, size: 48, scale: 2) {
    check(distinctColors(colorImage).count >= 2, "Color style did not render its multi-tone palette")
} else {
    failures.append("Color render returned nil")
}

// 5. README resource example
check(ResourceExamples.shieldCheckDuotoneSVG() != nil, "README SlaticoResources example returned nil")

// 6. AppKit
#if canImport(AppKit) && !targetEnvironment(macCatalyst)
let nsImages = AppKitExamples.makeImages()
check(nsImages.count == 3, "AppKit examples did not produce 3 images")
check(nsImages[0].isTemplate, "Monochrome NSImage without color should be a template image")
check(!nsImages[1].isTemplate && !nsImages[2].isTemplate, "Duotone/Color NSImage should not be template images")
for (index, image) in nsImages.enumerated() {
    var rect = NSRect(origin: .zero, size: image.size)
    if let cg = image.cgImage(forProposedRect: &rect, context: nil, hints: nil) {
        check(cg.width > 0, "AppKit image \(index) has zero width")
    } else {
        failures.append("AppKit image \(index) could not produce a CGImage")
    }
}
#endif

// 7. SwiftUI rendering via ImageRenderer.
// ImageRenderer requires Metal, which headless GitHub-hosted macOS VMs do not provide, so this
// pixel check is opt-in (SLATICO_SWIFTUI_IMAGE_RENDERER=1) for machines with a GPU. On CI, SwiftUI
// coverage comes from compiling the README views here and from the package's XCTest suite.
@available(macOS 13.0, *)
@MainActor
func renderSwiftUI() -> (CGImage?, CGImage?) {
    let single = ImageRenderer(content: SlaticoIcon(.shieldCheck, style: .duotone, size: 48, color: .red, secondaryColor: .blue, secondaryOpacity: 1))
    single.scale = 2
    let row = ImageRenderer(content: ExampleView().padding())
    return (single.cgImage, row.cgImage)
}

let swiftUIPixelCheck = ProcessInfo.processInfo.environment["SLATICO_SWIFTUI_IMAGE_RENDERER"] == "1"
if swiftUIPixelCheck, #available(macOS 13.0, *) {
    let rendered = await renderSwiftUI()
    if let icon = rendered.0 {
        check(paintedPixelCount(icon) > 0, "SwiftUI SlaticoIcon rendered an empty image")
    } else {
        failures.append("SwiftUI ImageRenderer returned nil for SlaticoIcon")
    }
    check(rendered.1 != nil, "SwiftUI ImageRenderer returned nil for README ExampleView")
}

if failures.isEmpty {
    print("✅ SlaticoIcons consumer check passed: 27 families, 7 styles, \(renderedVariants) rendered variants, \(loadedResources) bundled SVGs, Duotone/Color, AppKit rendering, README SwiftUI views compiled\(swiftUIPixelCheck ? ", SwiftUI ImageRenderer pixels" : "").")
} else {
    print("❌ SlaticoIcons consumer check failed (\(failures.count)):")
    failures.forEach { print("  - \($0)") }
    exit(1)
}
