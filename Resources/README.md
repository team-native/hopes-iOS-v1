# Hopes design resources

These files were audited and extracted from the Figma page `Hopes iOS App Design`
(`zplHxamGxpqzCmlN5xhV1y`, page `0:1`).

## Included

- `Assets.xcassets`
  - Figma's two swipe-chevron vectors
  - App accent and semantic Hopes colors
  - Hero gradient endpoint colors
- `Fonts`
  - Inter Regular
  - Inter SemiBold
  - Inter Bold
  - Inter license
  - `FontRegistration.plist`, containing the `UIAppFonts` entries to merge into
    the app target's Info.plist
- `DesignTokens.json`
  - Exact colors, gradients, shadows, fonts, source node IDs, and the list of
    system-rendered elements

## Intentionally not exported

The Figma file contains no image fills. Its iOS status bars, cellular/Wi-Fi/battery
indicators, home indicators, text fields, switches, and tab bar materials are
platform UI and must be rendered by SwiftUI/UIKit rather than shipped as images.

The Hopes logo is built from a rounded rectangle and text, so it remains a
code-native SwiftUI component instead of a bitmap asset.
