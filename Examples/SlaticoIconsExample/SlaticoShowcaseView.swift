import SwiftUI
import SlaticoIcons

/// Interactive SwiftUI showcase view demonstrating all 27 Tier 1 Slatico icon families
/// across all 7 styles (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, `color`),
/// live size and color controls, Duotone secondary tinting, search filtering,
/// light/dark color scheme preview, and VoiceOver accessibility.
public struct SlaticoShowcaseView: View {
    @State private var selectedStyle: SlaticoStyle = .regular
    @State private var searchQuery: String = ""
    @State private var iconSize: CGFloat = 28
    @State private var primaryColor: Color = Color(red: 0.06, green: 0.09, blue: 0.16)
    @State private var secondaryColor: Color = Color(red: 1.0, green: 0.376, blue: 0.251)
    @State private var secondaryOpacity: Double = 0.22
    @State private var isDarkPreview: Bool = false

    public init() {}

    private var filteredIcons: [SlaticoIconName] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else {
            return SlaticoIconName.allCases
        }
        return SlaticoIconName.allCases.filter { icon in
            icon.rawValue.lowercased().contains(query)
        }
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                controlsSection
                featuredVariantsSection
                accessibilityPreviewSection
                iconGridSection
            }
            .padding(20)
        }
        .preferredColorScheme(isDarkPreview ? .dark : .light)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("SlaticoIcons — Apple Native Showcase")
                .font(.title2.bold())
            Text("\(SlaticoVectorCatalog.familyCount) families × \(SlaticoVectorCatalog.styleCount) styles = \(SlaticoVectorCatalog.totalVariants) vector variants")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            TextField("Search \(SlaticoIconName.allCases.count) icons by name…", text: $searchQuery)
                .textFieldStyle(.roundedBorder)

            Picker("Style", selection: $selectedStyle) {
                ForEach(SlaticoStyle.allCases, id: \.self) { style in
                    Text(style.label).tag(style)
                }
            }
            .pickerStyle(.segmented)

            HStack(spacing: 16) {
                Text("Size: \(Int(iconSize)) pt")
                    .font(.caption.monospacedDigit())
                    .frame(width: 80, alignment: .leading)
                Slider(value: $iconSize, in: 16...64, step: 2)
            }

            HStack(spacing: 20) {
                ColorPicker("Primary", selection: $primaryColor)
                if selectedStyle == .duotone {
                    ColorPicker("Duotone Secondary", selection: $secondaryColor)
                }
                Toggle("Dark Mode", isOn: $isDarkPreview)
            }
            .font(.caption)
        }
        .padding(14)
        .background(Color.secondary.opacity(0.08))
        .cornerRadius(12)
    }

    private var featuredVariantsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("7-Style Comparison (house)")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(SlaticoStyle.allCases, id: \.self) { style in
                        VStack(spacing: 8) {
                            SlaticoIcon(
                                .house,
                                style: style,
                                size: 32,
                                color: style == .color ? nil : primaryColor,
                                secondaryColor: style == .duotone ? secondaryColor : nil,
                                secondaryOpacity: secondaryOpacity
                            )
                            Text(style.label)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(10)
                        .background(Color.secondary.opacity(0.06))
                        .cornerRadius(8)
                    }
                }
            }
        }
    }

    private var accessibilityPreviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Accessibility & Environment Theme Examples")
                .font(.headline)
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    // Semantic icon with VoiceOver label
                    SlaticoIcon(.shieldCheck, style: .color, size: 24, accessibilityLabel: "Security verified")
                    Text("Semantic (VoiceOver announced)")
                        .font(.caption)
                }
                HStack(spacing: 8) {
                    // Decorative icon hidden from VoiceOver
                    SlaticoIcon(.bell, style: .duotone, size: 24)
                    Text("Decorative (Accessibility hidden)")
                        .font(.caption)
                }
            }
            .slaticoIconTheme(
                SlaticoIconTheme(
                    style: .duotone,
                    size: 24,
                    color: primaryColor,
                    secondaryColor: secondaryColor,
                    secondaryOpacity: secondaryOpacity
                )
            )
        }
    }

    private var iconGridSection: some View {
        let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]
        return VStack(alignment: .leading, spacing: 10) {
            Text("Catalog (\(filteredIcons.count) of \(SlaticoIconName.allCases.count) families)")
                .font(.headline)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredIcons, id: \.self) { icon in
                    VStack(spacing: 8) {
                        SlaticoIcon(
                            icon,
                            style: selectedStyle,
                            size: iconSize,
                            color: selectedStyle == .color ? nil : primaryColor,
                            secondaryColor: selectedStyle == .duotone ? secondaryColor : nil,
                            secondaryOpacity: secondaryOpacity,
                            accessibilityLabel: "\(icon.rawValue) (\(selectedStyle.rawValue))"
                        )
                        Text(icon.rawValue)
                            .font(.caption2.monospaced())
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 8)
                    .background(Color.secondary.opacity(0.06))
                    .cornerRadius(10)
                }
            }
        }
    }
}
