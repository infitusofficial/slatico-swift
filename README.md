# Slatico Swift Package for iOS & macOS (Planned)

> **Status:** Planned (Phase 3 Native Expansion). Not yet published or functional.

## Overview

This directory is reserved for the native **Swift Package Manager (SwiftUI & UIKit / AppKit)** distribution of **Slatico by Infitus Creative Studio**.

## Planned Architecture

- **Package Name:** `SlaticoIcons`
- **Platforms:** iOS 15+, macOS 12+, watchOS 8+, tvOS 15+
- **Excluded from `pnpm-workspace.yaml`:** Managed via Swift Package Manager (`Package.swift`), not Node/pnpm.
- **Rendering Strategy:**
  - Generated `.xcassets` symbol sets and type-safe SwiftUI `SlaticoIcon` views supporting all 7 styles (`thin`, `light`, `regular`, `bold`, `fill`, `duotone`, `color`).
