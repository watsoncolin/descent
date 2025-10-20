import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

    /// The "DangerRed" asset catalog color resource.
    static let dangerRed = DeveloperToolsSupport.ColorResource(name: "DangerRed", bundle: resourceBundle)

    /// The "PrimaryBackground" asset catalog color resource.
    static let primaryBackground = DeveloperToolsSupport.ColorResource(name: "PrimaryBackground", bundle: resourceBundle)

    /// The "SuccessGreen" asset catalog color resource.
    static let successGreen = DeveloperToolsSupport.ColorResource(name: "SuccessGreen", bundle: resourceBundle)

    /// The "TextPrimary" asset catalog color resource.
    static let textPrimary = DeveloperToolsSupport.ColorResource(name: "TextPrimary", bundle: resourceBundle)

    /// The "UIAccent" asset catalog color resource.
    static let uiAccent = DeveloperToolsSupport.ColorResource(name: "UIAccent", bundle: resourceBundle)

    /// The "WarningYellow" asset catalog color resource.
    static let warningYellow = DeveloperToolsSupport.ColorResource(name: "WarningYellow", bundle: resourceBundle)

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "coal" asset catalog image resource.
    static let coal = DeveloperToolsSupport.ImageResource(name: "coal", bundle: resourceBundle)

    /// The "copper" asset catalog image resource.
    static let copper = DeveloperToolsSupport.ImageResource(name: "copper", bundle: resourceBundle)

    /// The "dark_matter" asset catalog image resource.
    static let darkMatter = DeveloperToolsSupport.ImageResource(name: "dark_matter", bundle: resourceBundle)

    /// The "descent-launch-background" asset catalog image resource.
    static let descentLaunchBackground = DeveloperToolsSupport.ImageResource(name: "descent-launch-background", bundle: resourceBundle)

    /// The "descent-launch-background 1" asset catalog image resource.
    static let descentLaunchBackground1 = DeveloperToolsSupport.ImageResource(name: "descent-launch-background 1", bundle: resourceBundle)

    /// The "descent-launch-icon" asset catalog image resource.
    static let descentLaunchIcon = DeveloperToolsSupport.ImageResource(name: "descent-launch-icon", bundle: resourceBundle)

    /// The "descent-launch-icon 1" asset catalog image resource.
    static let descentLaunchIcon1 = DeveloperToolsSupport.ImageResource(name: "descent-launch-icon 1", bundle: resourceBundle)

    /// The "descent-launch-logo" asset catalog image resource.
    static let descentLaunchLogo = DeveloperToolsSupport.ImageResource(name: "descent-launch-logo", bundle: resourceBundle)

    /// The "descent-launch-logo 1" asset catalog image resource.
    static let descentLaunchLogo1 = DeveloperToolsSupport.ImageResource(name: "descent-launch-logo 1", bundle: resourceBundle)

    /// The "descent-launch-pod" asset catalog image resource.
    static let descentLaunchPod = DeveloperToolsSupport.ImageResource(name: "descent-launch-pod", bundle: resourceBundle)

    /// The "descent-launch-pod 1" asset catalog image resource.
    static let descentLaunchPod1 = DeveloperToolsSupport.ImageResource(name: "descent-launch-pod 1", bundle: resourceBundle)

    /// The "descent-launch-subtitle" asset catalog image resource.
    static let descentLaunchSubtitle = DeveloperToolsSupport.ImageResource(name: "descent-launch-subtitle", bundle: resourceBundle)

    /// The "descent-launch-subtitle 1" asset catalog image resource.
    static let descentLaunchSubtitle1 = DeveloperToolsSupport.ImageResource(name: "descent-launch-subtitle 1", bundle: resourceBundle)

    /// The "gold" asset catalog image resource.
    static let gold = DeveloperToolsSupport.ImageResource(name: "gold", bundle: resourceBundle)

    /// The "iron" asset catalog image resource.
    static let iron = DeveloperToolsSupport.ImageResource(name: "iron", bundle: resourceBundle)

    /// The "silicon" asset catalog image resource.
    static let silicon = DeveloperToolsSupport.ImageResource(name: "silicon", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    /// The "DangerRed" asset catalog color.
    static var dangerRed: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .dangerRed)
#else
        .init()
#endif
    }

    /// The "PrimaryBackground" asset catalog color.
    static var primaryBackground: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .primaryBackground)
#else
        .init()
#endif
    }

    /// The "SuccessGreen" asset catalog color.
    static var successGreen: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .successGreen)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "UIAccent" asset catalog color.
    static var uiAccent: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .uiAccent)
#else
        .init()
#endif
    }

    /// The "WarningYellow" asset catalog color.
    static var warningYellow: AppKit.NSColor {
#if !targetEnvironment(macCatalyst)
        .init(resource: .warningYellow)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    /// The "DangerRed" asset catalog color.
    static var dangerRed: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .dangerRed)
#else
        .init()
#endif
    }

    /// The "PrimaryBackground" asset catalog color.
    static var primaryBackground: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .primaryBackground)
#else
        .init()
#endif
    }

    /// The "SuccessGreen" asset catalog color.
    static var successGreen: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .successGreen)
#else
        .init()
#endif
    }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .textPrimary)
#else
        .init()
#endif
    }

    /// The "UIAccent" asset catalog color.
    static var uiAccent: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .uiAccent)
#else
        .init()
#endif
    }

    /// The "WarningYellow" asset catalog color.
    static var warningYellow: UIKit.UIColor {
#if !os(watchOS)
        .init(resource: .warningYellow)
#else
        .init()
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    /// The "DangerRed" asset catalog color.
    static var dangerRed: SwiftUI.Color { .init(.dangerRed) }

    /// The "PrimaryBackground" asset catalog color.
    static var primaryBackground: SwiftUI.Color { .init(.primaryBackground) }

    /// The "SuccessGreen" asset catalog color.
    static var successGreen: SwiftUI.Color { .init(.successGreen) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "UIAccent" asset catalog color.
    static var uiAccent: SwiftUI.Color { .init(.uiAccent) }

    /// The "WarningYellow" asset catalog color.
    static var warningYellow: SwiftUI.Color { .init(.warningYellow) }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    /// The "DangerRed" asset catalog color.
    static var dangerRed: SwiftUI.Color { .init(.dangerRed) }

    /// The "PrimaryBackground" asset catalog color.
    static var primaryBackground: SwiftUI.Color { .init(.primaryBackground) }

    /// The "SuccessGreen" asset catalog color.
    static var successGreen: SwiftUI.Color { .init(.successGreen) }

    /// The "TextPrimary" asset catalog color.
    static var textPrimary: SwiftUI.Color { .init(.textPrimary) }

    /// The "UIAccent" asset catalog color.
    static var uiAccent: SwiftUI.Color { .init(.uiAccent) }

    /// The "WarningYellow" asset catalog color.
    static var warningYellow: SwiftUI.Color { .init(.warningYellow) }

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "coal" asset catalog image.
    static var coal: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .coal)
#else
        .init()
#endif
    }

    /// The "copper" asset catalog image.
    static var copper: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .copper)
#else
        .init()
#endif
    }

    /// The "dark_matter" asset catalog image.
    static var darkMatter: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .darkMatter)
#else
        .init()
#endif
    }

    /// The "descent-launch-background" asset catalog image.
    static var descentLaunchBackground: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchBackground)
#else
        .init()
#endif
    }

    /// The "descent-launch-background 1" asset catalog image.
    static var descentLaunchBackground1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchBackground1)
#else
        .init()
#endif
    }

    /// The "descent-launch-icon" asset catalog image.
    static var descentLaunchIcon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchIcon)
#else
        .init()
#endif
    }

    /// The "descent-launch-icon 1" asset catalog image.
    static var descentLaunchIcon1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchIcon1)
#else
        .init()
#endif
    }

    /// The "descent-launch-logo" asset catalog image.
    static var descentLaunchLogo: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchLogo)
#else
        .init()
#endif
    }

    /// The "descent-launch-logo 1" asset catalog image.
    static var descentLaunchLogo1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchLogo1)
#else
        .init()
#endif
    }

    /// The "descent-launch-pod" asset catalog image.
    static var descentLaunchPod: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchPod)
#else
        .init()
#endif
    }

    /// The "descent-launch-pod 1" asset catalog image.
    static var descentLaunchPod1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchPod1)
#else
        .init()
#endif
    }

    /// The "descent-launch-subtitle" asset catalog image.
    static var descentLaunchSubtitle: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchSubtitle)
#else
        .init()
#endif
    }

    /// The "descent-launch-subtitle 1" asset catalog image.
    static var descentLaunchSubtitle1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .descentLaunchSubtitle1)
#else
        .init()
#endif
    }

    /// The "gold" asset catalog image.
    static var gold: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .gold)
#else
        .init()
#endif
    }

    /// The "iron" asset catalog image.
    static var iron: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .iron)
#else
        .init()
#endif
    }

    /// The "silicon" asset catalog image.
    static var silicon: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .silicon)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "coal" asset catalog image.
    static var coal: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .coal)
#else
        .init()
#endif
    }

    /// The "copper" asset catalog image.
    static var copper: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .copper)
#else
        .init()
#endif
    }

    /// The "dark_matter" asset catalog image.
    static var darkMatter: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .darkMatter)
#else
        .init()
#endif
    }

    /// The "descent-launch-background" asset catalog image.
    static var descentLaunchBackground: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchBackground)
#else
        .init()
#endif
    }

    /// The "descent-launch-background 1" asset catalog image.
    static var descentLaunchBackground1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchBackground1)
#else
        .init()
#endif
    }

    /// The "descent-launch-icon" asset catalog image.
    static var descentLaunchIcon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchIcon)
#else
        .init()
#endif
    }

    /// The "descent-launch-icon 1" asset catalog image.
    static var descentLaunchIcon1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchIcon1)
#else
        .init()
#endif
    }

    /// The "descent-launch-logo" asset catalog image.
    static var descentLaunchLogo: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchLogo)
#else
        .init()
#endif
    }

    /// The "descent-launch-logo 1" asset catalog image.
    static var descentLaunchLogo1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchLogo1)
#else
        .init()
#endif
    }

    /// The "descent-launch-pod" asset catalog image.
    static var descentLaunchPod: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchPod)
#else
        .init()
#endif
    }

    /// The "descent-launch-pod 1" asset catalog image.
    static var descentLaunchPod1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchPod1)
#else
        .init()
#endif
    }

    /// The "descent-launch-subtitle" asset catalog image.
    static var descentLaunchSubtitle: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchSubtitle)
#else
        .init()
#endif
    }

    /// The "descent-launch-subtitle 1" asset catalog image.
    static var descentLaunchSubtitle1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .descentLaunchSubtitle1)
#else
        .init()
#endif
    }

    /// The "gold" asset catalog image.
    static var gold: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .gold)
#else
        .init()
#endif
    }

    /// The "iron" asset catalog image.
    static var iron: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .iron)
#else
        .init()
#endif
    }

    /// The "silicon" asset catalog image.
    static var silicon: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .silicon)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

