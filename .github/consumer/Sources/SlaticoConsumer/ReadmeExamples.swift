// Mirrors the usage examples in README.md so that documented APIs are compiled by a real consumer.
import SwiftUI
import SlaticoIcons

public struct ExampleView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 16) {
            SlaticoIcon(.bell, style: .regular, size: 24)

            SlaticoIcon(
                .arrowUpRight,
                style: .bold,
                size: 24,
                color: Color(red: 0.004, green: 0.020, blue: 0.125),
                accessibilityLabel: "Open Link"
            )

            SlaticoIcon(
                .shieldCheck,
                style: .duotone,
                size: 28,
                color: Color(red: 0.004, green: 0.020, blue: 0.125),
                secondaryColor: Color(red: 1.0, green: 0.376, blue: 0.251),
                secondaryOpacity: 0.25,
                accessibilityLabel: "Verified Security"
            )

            SlaticoIcon(.wallet, style: .color, size: 28, accessibilityLabel: "Wallet")

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

public struct EnvironmentExampleView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 12) {
            SlaticoIcon(.house)
            SlaticoIcon(.bell)
            SlaticoIcon(.gear)
        }
        .slaticoIconStyle(.duotone)
        .slaticoIconSize(24)
        .slaticoIconColor(.indigo)
        .slaticoIconSecondaryColor(.orange, opacity: 0.25)
    }
}

#if canImport(UIKit) && !os(watchOS)
import UIKit

public enum UIKitExamples {
    public static func makeImages() -> [UIImage] {
        let bellImage = UIImage.slatico(.bell, style: .regular, size: 24)
        let imageView = UIImageView(image: bellImage)
        imageView.tintColor = .label

        let shieldImage = UIImage.slatico(
            .shieldCheck,
            style: .duotone,
            size: 28,
            color: .systemIndigo,
            secondaryColor: .systemOrange,
            secondaryOpacity: 0.25
        )

        let walletImage = UIImage.slatico(
            .wallet,
            style: .color,
            size: 32,
            color: UIColor(red: 1.0, green: 0.376, blue: 0.251, alpha: 1.0),
            secondaryColor: .black
        )
        return [bellImage, shieldImage, walletImage]
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public enum AppKitExamples {
    public static func makeImages() -> [NSImage] {
        let regularImage = NSImage.slatico(.bell, style: .regular, size: 20)

        let duotoneImage = NSImage.slatico(
            .layoutDashboard,
            style: .duotone,
            size: 24,
            color: .systemBlue,
            secondaryColor: .systemTeal,
            secondaryOpacity: 0.3
        )

        let colorImage = NSImage.slatico(.wallet, style: .color, size: 24)
        return [regularImage, duotoneImage, colorImage]
    }
}
#endif

public enum ResourceExamples {
    public static func shieldCheckDuotoneSVG() -> (URL, String)? {
        if let url = SlaticoResources.svgURL(for: .shieldCheck, style: .duotone),
           let svgMarkup = SlaticoResources.svgString(for: .shieldCheck, style: .duotone) {
            return (url, svgMarkup)
        }
        return nil
    }
}
