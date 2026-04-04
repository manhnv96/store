// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen
// !! Do not edit manually – run `swiftgen run` to regenerate !!

import SwiftUI
import UIKit

// MARK: - ImageAsset

internal struct ImageAsset {
    internal let name: String

    internal var uiImage: UIImage {
        guard let image = UIImage(named: name, in: BundleToken.bundle, compatibleWith: nil) else {
            fatalError("Unable to load image asset '\(name)'.")
        }
        return image
    }

    internal var swiftUIImage: SwiftUI.Image {
        SwiftUI.Image(name, bundle: BundleToken.bundle)
    }
}

// MARK: - ColorAsset

internal struct ColorAsset {
    internal let name: String

    internal var color: SwiftUI.Color {
        SwiftUI.Color(name, bundle: BundleToken.bundle)
    }

    internal var uiColor: UIColor {
        guard let color = UIColor(named: name, in: BundleToken.bundle, compatibleWith: nil) else {
            fatalError("Unable to load color asset '\(name)'.")
        }
        return color
    }
}

// MARK: - Asset

internal enum Asset {

    // MARK: Images
    internal enum Images {
        internal static let launch = ImageAsset(name: "Launch")
        internal static let appIcon = ImageAsset(name: "AppIcon")
    }

    // MARK: Colors
    // Add named colors from Assets.xcassets here as the project grows.
    // Example: internal static let accentColor = ColorAsset(name: "AccentColor")
}

// MARK: - BundleToken

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }()
}

// swiftlint:enable all
