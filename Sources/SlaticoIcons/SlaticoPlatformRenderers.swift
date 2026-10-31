import CoreGraphics
import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

/// Shared Core Graphics vector renderer used across UIKit (`UIImage`), AppKit (`NSImage`),
/// and bitmap `CGImage` generation.
public enum SlaticoCoreGraphicsRenderer {
    /// Draws `spec` into `context` assuming a top-left `(0, 0)` origin (`+Y` downward) scaled to `size`.
    public static func draw(
        spec: SlaticoVectorIconSpec,
        in context: CGContext,
        size: CGFloat,
        primaryColor: CGColor?,
        secondaryColor: CGColor? = nil,
        secondaryOpacity: CGFloat? = nil
    ) {
        let clampedSize = max(1.0, size)
        let scale = clampedSize / 24.0
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()
        let defaultBlack = CGColor(colorSpace: colorSpace, components: [0, 0, 0, 1])!

        context.saveGState()
        context.scaleBy(x: scale, y: scale)

        for layer in spec.layers {
            context.saveGState()
            context.addPath(layer.cgPath)

            let resolvedColor: CGColor
            let resolvedAlpha: CGFloat

            switch layer.role {
            case .primary:
                resolvedColor = primaryColor ?? defaultBlack
                resolvedAlpha = CGFloat(layer.defaultOpacity)

            case .secondary:
                resolvedColor = secondaryColor ?? primaryColor ?? defaultBlack
                let alphaVal = secondaryOpacity ?? CGFloat(layer.defaultOpacity)
                resolvedAlpha = min(1.0, max(0.0, alphaVal))

            case let .fixedColor(hex, red, green, blue):
                if hex.uppercased() == "#000000", let explicitSecondary = secondaryColor {
                    resolvedColor = explicitSecondary
                } else if hex.uppercased() != "#000000", let explicitPrimary = primaryColor {
                    resolvedColor = explicitPrimary
                } else {
                    resolvedColor = CGColor(
                        colorSpace: colorSpace,
                        components: [CGFloat(red), CGFloat(green), CGFloat(blue), 1.0]
                    ) ?? defaultBlack
                }
                resolvedAlpha = CGFloat(layer.defaultOpacity)
            }

            context.setFillColor(resolvedColor)
            context.setAlpha(resolvedAlpha)
            context.fillPath(using: layer.isEvenOdd ? .evenOdd : .winding)
            context.restoreGState()
        }

        context.restoreGState()
    }

    /// Renders a Slatico icon directly into a `CGImage` at the specified point `size` and pixel `scale`.
    public static func cgImage(
        for icon: SlaticoIconName,
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        primaryColor: CGColor? = nil,
        secondaryColor: CGColor? = nil,
        secondaryOpacity: CGFloat? = nil,
        scale: CGFloat = 2.0
    ) -> CGImage? {
        let clampedSize = max(1.0, size)
        let clampedScale = max(1.0, scale)
        let pixelWidth = max(1, Int(ceil(clampedSize * clampedScale)))
        let pixelHeight = max(1, Int(ceil(clampedSize * clampedScale)))
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        // Flip Core Graphics bitmap context so (0, 0) is top-left (+Y downward)
        context.translateBy(x: 0, y: CGFloat(pixelHeight))
        context.scaleBy(x: clampedScale, y: -clampedScale)

        let spec = SlaticoVectorCatalog.spec(for: icon, style: style)
        draw(
            spec: spec,
            in: context,
            size: clampedSize,
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            secondaryOpacity: secondaryOpacity
        )

        return context.makeImage()
    }
}

#if canImport(UIKit) && !os(watchOS)
/// UIKit renderer producing high-DPI `UIImage` instances for `UIImageView`, `UIButton`, and `UIBarButtonItem`.
public enum SlaticoUIImageRenderer {
    /// Renders a Slatico icon into a `UIImage`.
    /// - When `style` is monochrome (`thin`–`fill`) and `color` is `nil`, the returned image uses
    ///   `.alwaysTemplate` rendering mode so `UIImageView.tintColor` tints the icon dynamically.
    /// - When `style` is `.color`, `.duotone`, or an explicit `color` is supplied, the returned image
    ///   uses `.alwaysOriginal` rendering mode to prevent destructive tinting.
    public static func image(
        for icon: SlaticoIconName,
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        color: UIColor? = nil,
        secondaryColor: UIColor? = nil,
        secondaryOpacity: CGFloat? = nil,
        scale: CGFloat = 0
    ) -> UIImage {
        let clampedSize = max(1.0, size)
        let targetSize = CGSize(width: clampedSize, height: clampedSize)
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = false
        if scale > 0 {
            format.scale = scale
        }

        let spec = SlaticoVectorCatalog.spec(for: icon, style: style)
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        let rendered = renderer.image { rendererContext in
            SlaticoCoreGraphicsRenderer.draw(
                spec: spec,
                in: rendererContext.cgContext,
                size: clampedSize,
                primaryColor: color?.cgColor,
                secondaryColor: secondaryColor?.cgColor,
                secondaryOpacity: secondaryOpacity
            )
        }

        let shouldUseTemplate = style.isMonochrome && color == nil
        return rendered.withRenderingMode(shouldUseTemplate ? .alwaysTemplate : .alwaysOriginal)
    }
}

public extension UIImage {
    /// Creates a `UIImage` for a Slatico icon family and style.
    static func slatico(
        _ icon: SlaticoIconName,
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        color: UIColor? = nil,
        secondaryColor: UIColor? = nil,
        secondaryOpacity: CGFloat? = nil,
        scale: CGFloat = 0
    ) -> UIImage {
        SlaticoUIImageRenderer.image(
            for: icon,
            style: style,
            size: size,
            color: color,
            secondaryColor: secondaryColor,
            secondaryOpacity: secondaryOpacity,
            scale: scale
        )
    }
}
#endif

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
/// AppKit renderer producing vector-backed `NSImage` instances for `NSImageView`, `NSButton`, and `NSMenuItem`.
public enum SlaticoNSImageRenderer {
    /// Renders a Slatico icon into a resolution-independent `NSImage`.
    /// - When `style` is monochrome (`thin`–`fill`) and `color` is `nil`, `isTemplate` is set to `true`
    ///   so AppKit automatically adapts the icon to light/dark appearances and control states.
    /// - When `style` is `.color`, `.duotone`, or an explicit `color` is supplied, `isTemplate` is `false`.
    public static func image(
        for icon: SlaticoIconName,
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        color: NSColor? = nil,
        secondaryColor: NSColor? = nil,
        secondaryOpacity: CGFloat? = nil
    ) -> NSImage {
        let clampedSize = max(1.0, size)
        let targetSize = NSSize(width: clampedSize, height: clampedSize)
        let spec = SlaticoVectorCatalog.spec(for: icon, style: style)

        let nsImage = NSImage(size: targetSize, flipped: true) { _ in
            guard let cgContext = NSGraphicsContext.current?.cgContext else {
                return false
            }
            SlaticoCoreGraphicsRenderer.draw(
                spec: spec,
                in: cgContext,
                size: clampedSize,
                primaryColor: color?.cgColor,
                secondaryColor: secondaryColor?.cgColor,
                secondaryOpacity: secondaryOpacity
            )
            return true
        }

        nsImage.isTemplate = style.isMonochrome && color == nil
        return nsImage
    }
}

public extension NSImage {
    /// Creates an `NSImage` for a Slatico icon family and style.
    static func slatico(
        _ icon: SlaticoIconName,
        style: SlaticoStyle = .regular,
        size: CGFloat = 24,
        color: NSColor? = nil,
        secondaryColor: NSColor? = nil,
        secondaryOpacity: CGFloat? = nil
    ) -> NSImage {
        SlaticoNSImageRenderer.image(
            for: icon,
            style: style,
            size: size,
            color: color,
            secondaryColor: secondaryColor,
            secondaryOpacity: secondaryOpacity
        )
    }
}
#endif
