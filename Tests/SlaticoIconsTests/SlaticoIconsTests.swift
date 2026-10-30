import XCTest
import CoreGraphics
import SwiftUI
@testable import SlaticoIcons
import SlaticoIconsExample

#if canImport(UIKit) && !os(watchOS)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

final class SlaticoIconsTests: XCTestCase {
    private static let tier1KebabNames: [String] = [
        "bell",
        "cloud",
        "cloud-check",
        "credit-card",
        "envelope",
        "envelope-open",
        "gear",
        "house",
        "layout-dashboard",
        "lock",
        "lock-open",
        "magnifying-glass",
        "minus",
        "pencil",
        "plus",
        "shield",
        "shield-check",
        "sliders-horizontal",
        "trash",
        "trash-x",
        "trend-up",
        "user",
        "wallet",
    ]

    func testExactTier1IconFamilyCountAndNames() {
        XCTAssertEqual(SlaticoIconName.allCases.count, 23, "Slatico Tier 1 must have exactly 23 icon families")
        XCTAssertEqual(SlaticoVectorCatalog.familyCount, 23)

        let actualKebabNames = SlaticoIconName.allCases.map(\.rawValue)
        XCTAssertEqual(actualKebabNames, Self.tier1KebabNames)

        for name in Self.tier1KebabNames {
            let resolved = SlaticoIconName(slug: name)
            XCTAssertNotNil(resolved, "Failed to look up SlaticoIconName(slug: \(name))")
            XCTAssertEqual(resolved?.slug, name)
            XCTAssertEqual(resolved?.id, name)
        }
    }

    func testNoRemovedDemoIconsExist() {
        let removedDemoIcons = ["cube", "heart", "sparkles", "sparkle"]
        for demo in removedDemoIcons {
            XCTAssertNil(SlaticoIconName(slug: demo), "Demo icon \(demo) must not exist in SlaticoIconName")
        }
    }

    func testAllSevenOfficialStylesExist() {
        XCTAssertEqual(SlaticoStyle.allCases.count, 7)
        XCTAssertEqual(SlaticoVectorCatalog.styleCount, 7)
        XCTAssertEqual(
            SlaticoStyle.allCases.map(\.rawValue),
            ["thin", "light", "regular", "bold", "fill", "duotone", "color"]
        )

        XCTAssertTrue(SlaticoStyle.thin.isMonochrome)
        XCTAssertTrue(SlaticoStyle.light.isMonochrome)
        XCTAssertTrue(SlaticoStyle.regular.isMonochrome)
        XCTAssertTrue(SlaticoStyle.bold.isMonochrome)
        XCTAssertTrue(SlaticoStyle.fill.isMonochrome)
        XCTAssertFalse(SlaticoStyle.duotone.isMonochrome)
        XCTAssertFalse(SlaticoStyle.color.isMonochrome)
    }

    func testAll161VectorCatalogEntriesAndCGPathsAreValid() {
        XCTAssertEqual(SlaticoVectorCatalog.totalVariants, 161)

        var verifiedCount = 0
        for icon in SlaticoIconName.allCases {
            for style in SlaticoStyle.allCases {
                let spec = SlaticoVectorCatalog.spec(for: icon, style: style)
                XCTAssertEqual(spec.name, icon)
                XCTAssertEqual(spec.style, style)
                XCTAssertEqual(spec.viewBoxSize, CGSize(width: 24, height: 24))
                XCTAssertFalse(spec.layers.isEmpty, "Layers for \(icon.rawValue)/\(style.rawValue) must not be empty")

                for (index, layer) in spec.layers.enumerated() {
                    XCTAssertFalse(
                        layer.pathData.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                        "Empty pathData in \(icon.rawValue)/\(style.rawValue) layer \(index)"
                    )
                    let cgPath = layer.cgPath
                    XCTAssertFalse(
                        cgPath.isEmpty,
                        "Parsed CGPath is empty for \(icon.rawValue)/\(style.rawValue) layer \(index)"
                    )
                    let bounds = cgPath.boundingBoxOfPath
                    XCTAssertFalse(bounds.isNull, "Bounding box is null for \(icon.rawValue)/\(style.rawValue)")
                    XCTAssertGreaterThanOrEqual(bounds.minX, -1.0)
                    XCTAssertGreaterThanOrEqual(bounds.minY, -1.0)
                    XCTAssertLessThanOrEqual(bounds.maxX, 25.0)
                    XCTAssertLessThanOrEqual(bounds.maxY, 25.0)
                }

                verifiedCount += 1
            }
        }

        XCTAssertEqual(verifiedCount, 161)
    }

    func testDuotoneAndColorLayerRoles() {
        for icon in SlaticoIconName.allCases {
            let duotoneSpec = SlaticoVectorCatalog.spec(for: icon, style: .duotone)
            let hasSecondary = duotoneSpec.layers.contains { layer in
                if case .secondary = layer.role { return true }
                return false
            }
            let hasPrimary = duotoneSpec.layers.contains { layer in
                if case .primary = layer.role { return true }
                return false
            }
            XCTAssertTrue(hasSecondary, "Duotone \(icon.rawValue) must contain at least one .secondary tone layer")
            XCTAssertTrue(hasPrimary, "Duotone \(icon.rawValue) must contain at least one .primary structural layer")

            let colorSpec = SlaticoVectorCatalog.spec(for: icon, style: .color)
            for layer in colorSpec.layers {
                if case .fixedColor = layer.role {
                    // Expected fixed sRGB color for Color style
                } else {
                    XCTFail("Color asset \(icon.rawValue) layer must use .fixedColor role")
                }
            }
        }
    }

    func testAll161BundledSVGResourcesLoadFromBundleModule() {
        var loadedCount = 0
        for icon in SlaticoIconName.allCases {
            for style in SlaticoStyle.allCases {
                let relativePath = icon.resourceSubpath(for: style)
                XCTAssertEqual(relativePath, "svg/\(style.rawValue)/\(icon.rawValue).svg")

                guard let url = SlaticoResources.svgURL(for: icon, style: style) else {
                    XCTFail("Missing bundled SVG URL for \(icon.rawValue) (\(style.rawValue))")
                    continue
                }
                XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))

                guard let svgString = SlaticoResources.svgString(for: icon, style: style) else {
                    XCTFail("Failed to read UTF-8 SVG content for \(icon.rawValue) (\(style.rawValue))")
                    continue
                }
                XCTAssertTrue(svgString.contains("<svg"), "Invalid SVG content for \(icon.rawValue)/\(style.rawValue)")
                XCTAssertTrue(svgString.contains("viewBox=\"0 0 24 24\""), "SVG must preserve 24x24 viewBox")
                loadedCount += 1
            }
        }
        XCTAssertEqual(loadedCount, 161)
    }

    func testCoreGraphicsRenderingProducesNonEmptyImages() {
        for style in SlaticoStyle.allCases {
            let cgImage = SlaticoCoreGraphicsRenderer.cgImage(
                for: .wallet,
                style: style,
                size: 32,
                secondaryOpacity: 0.25,
                scale: 2.0
            )
            XCTAssertNotNil(cgImage, "Failed to render CGImage for wallet (\(style.rawValue))")
            XCTAssertEqual(cgImage?.width, 64)
            XCTAssertEqual(cgImage?.height, 64)
        }
    }

    func testSwiftUIIconAndShowcaseInitialization() {
        let monochromeIcon = SlaticoIcon(.house, style: .regular, size: 24, color: .blue)
        XCTAssertEqual(monochromeIcon.name, .house)
        XCTAssertEqual(monochromeIcon.style, .regular)
        XCTAssertEqual(monochromeIcon.size, 24)
        XCTAssertNil(monochromeIcon.accessibilityLabel)

        let duotoneIcon = SlaticoIcon(
            .bell,
            style: .duotone,
            size: 32,
            color: .primary,
            secondaryColor: .orange,
            secondaryOpacity: 0.3,
            accessibilityLabel: "Notifications"
        )
        XCTAssertEqual(duotoneIcon.name, .bell)
        XCTAssertEqual(duotoneIcon.style, .duotone)
        XCTAssertEqual(duotoneIcon.size, 32)
        XCTAssertNotNil(duotoneIcon.accessibilityLabel)

        let colorIcon = SlaticoIcon(.shieldCheck, style: .color, size: 28)
        XCTAssertEqual(colorIcon.name, .shieldCheck)
        XCTAssertEqual(colorIcon.style, .color)

        let showcase = SlaticoShowcaseView()
        XCTAssertNotNil(showcase)
    }

    #if canImport(UIKit) && !os(watchOS)
    func testUIKitRenderingAcrossStyles() {
        for style in SlaticoStyle.allCases {
            let image = UIImage.slatico(
                .house,
                style: style,
                size: 24,
                color: style == .color ? nil : .systemBlue,
                secondaryColor: .systemOrange,
                scale: 2.0
            )
            XCTAssertEqual(image.size.width, 24, accuracy: 0.01)
            XCTAssertEqual(image.size.height, 24, accuracy: 0.01)
            XCTAssertNotNil(image.cgImage)
        }
    }
    #endif

    #if canImport(AppKit) && !targetEnvironment(macCatalyst)
    func testAppKitRenderingAcrossStyles() {
        for style in SlaticoStyle.allCases {
            let image = NSImage.slatico(
                .house,
                style: style,
                size: 24,
                color: style == .color ? nil : .systemBlue,
                secondaryColor: .systemOrange
            )
            XCTAssertEqual(image.size.width, 24, accuracy: 0.01)
            XCTAssertEqual(image.size.height, 24, accuracy: 0.01)
            var proposedRect = CGRect(x: 0, y: 0, width: 24, height: 24)
            XCTAssertNotNil(image.cgImage(forProposedRect: &proposedRect, context: nil, hints: nil))
        }
    }
    #endif
}
