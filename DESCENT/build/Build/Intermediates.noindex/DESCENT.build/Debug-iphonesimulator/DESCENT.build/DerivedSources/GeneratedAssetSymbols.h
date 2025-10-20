#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The resource bundle ID.
static NSString * const ACBundleID AC_SWIFT_PRIVATE = @"com.colinwatson.descent";

/// The "DangerRed" asset catalog color resource.
static NSString * const ACColorNameDangerRed AC_SWIFT_PRIVATE = @"DangerRed";

/// The "PrimaryBackground" asset catalog color resource.
static NSString * const ACColorNamePrimaryBackground AC_SWIFT_PRIVATE = @"PrimaryBackground";

/// The "SuccessGreen" asset catalog color resource.
static NSString * const ACColorNameSuccessGreen AC_SWIFT_PRIVATE = @"SuccessGreen";

/// The "TextPrimary" asset catalog color resource.
static NSString * const ACColorNameTextPrimary AC_SWIFT_PRIVATE = @"TextPrimary";

/// The "UIAccent" asset catalog color resource.
static NSString * const ACColorNameUIAccent AC_SWIFT_PRIVATE = @"UIAccent";

/// The "WarningYellow" asset catalog color resource.
static NSString * const ACColorNameWarningYellow AC_SWIFT_PRIVATE = @"WarningYellow";

/// The "coal" asset catalog image resource.
static NSString * const ACImageNameCoal AC_SWIFT_PRIVATE = @"coal";

/// The "copper" asset catalog image resource.
static NSString * const ACImageNameCopper AC_SWIFT_PRIVATE = @"copper";

/// The "dark_matter" asset catalog image resource.
static NSString * const ACImageNameDarkMatter AC_SWIFT_PRIVATE = @"dark_matter";

/// The "descent-launch-background" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchBackground AC_SWIFT_PRIVATE = @"descent-launch-background";

/// The "descent-launch-background 1" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchBackground1 AC_SWIFT_PRIVATE = @"descent-launch-background 1";

/// The "descent-launch-icon" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchIcon AC_SWIFT_PRIVATE = @"descent-launch-icon";

/// The "descent-launch-icon 1" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchIcon1 AC_SWIFT_PRIVATE = @"descent-launch-icon 1";

/// The "descent-launch-logo" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchLogo AC_SWIFT_PRIVATE = @"descent-launch-logo";

/// The "descent-launch-logo 1" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchLogo1 AC_SWIFT_PRIVATE = @"descent-launch-logo 1";

/// The "descent-launch-pod" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchPod AC_SWIFT_PRIVATE = @"descent-launch-pod";

/// The "descent-launch-pod 1" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchPod1 AC_SWIFT_PRIVATE = @"descent-launch-pod 1";

/// The "descent-launch-subtitle" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchSubtitle AC_SWIFT_PRIVATE = @"descent-launch-subtitle";

/// The "descent-launch-subtitle 1" asset catalog image resource.
static NSString * const ACImageNameDescentLaunchSubtitle1 AC_SWIFT_PRIVATE = @"descent-launch-subtitle 1";

/// The "gold" asset catalog image resource.
static NSString * const ACImageNameGold AC_SWIFT_PRIVATE = @"gold";

/// The "iron" asset catalog image resource.
static NSString * const ACImageNameIron AC_SWIFT_PRIVATE = @"iron";

/// The "silicon" asset catalog image resource.
static NSString * const ACImageNameSilicon AC_SWIFT_PRIVATE = @"silicon";

#undef AC_SWIFT_PRIVATE
