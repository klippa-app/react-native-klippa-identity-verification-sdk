import KlippaIdentityVerification

@objc(KlippaIdentityVerificationSdk)
class KlippaIdentityVerificationSdk: NSObject {

    private let E_UNKNOWN = "E_UNKNOWN_ERROR"
    private let E_CANCELED = "E_CANCELED"
    private let E_SUPPORT_PRESSED = "E_SUPPORT_PRESSED"

    private var _resolve: RCTPromiseResolveBlock? = nil
    private var _reject: RCTPromiseRejectBlock? = nil

    // MARK: Start session

    @objc(startSession:withToken:withResolver:withRejecter:)
    func startSession(
        config: [String: Any],
        sessionToken: String,
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: @escaping RCTPromiseRejectBlock
    ) {
        _resolve = resolve
        _reject = reject

        let identityBuilder = setupIdentityBuilder(sessionToken: sessionToken, with: config)

        let viewController = identityBuilder.build()
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        rootViewController?.show(viewController, sender: self)

    }

    // MARK: Setup Identity Builder

    private func setupIdentityBuilder(sessionToken: String, with config: [String: Any]) -> IdentityBuilder {
        let builder = IdentityBuilder(builderDelegate: self, sessionKey: sessionToken)

        setBuilderLanguage(config, builder)

        setBuilderOptionalScreens(config, builder)

        if let isDebug = config["isDebug"] as? Bool {
            builder.isDebug =  isDebug
        }

        if let retryThreshold = config["retryThreshold"] as? Double {
            builder.retryThreshold = Int(retryThreshold)
        }

        if let enableAutoCapture = config["enableAutoCapture"] as? Bool {
            builder.enableAutoCapture = enableAutoCapture
        }

        setBuilderColors(config, builder)

        setBuilderFonts(config, builder)

        setVerificationLists(config, builder)

        setValidationLists(config, builder)

        return builder
    }



    // MARK: - Customize Colors

    fileprivate func setBuilderColors(_ config: [String : Any], _ builder: IdentityBuilder) {
        guard let colors = config["colors"] as? [String: String] else {
            return
        }

        if let textColor = colors["textColor"] {
            let txtColor = UIColor(hexString: textColor)
            builder.kivColors.textColor = txtColor
        }

        if let backgroundColor = colors["backgroundColor"] {
            builder.kivColors.backgroundColor = UIColor(hexString: backgroundColor)
        }

        if let buttonSuccessColor = colors["buttonSuccessColor"] {
            builder.kivColors.successColor = UIColor(hexString: buttonSuccessColor)
        }

        if let buttonErrorColor = colors["buttonErrorColor"] {
            builder.kivColors.errorColor = UIColor(hexString: buttonErrorColor)
        }

        if let buttonOtherColor = colors["buttonOtherColor"] {
            builder.kivColors.otherColor = UIColor(hexString: buttonOtherColor)
        }

        if let progressBarBackground = colors["progressBarBackground"] {
            builder.kivColors.progressBarBackground = UIColor(hexString: progressBarBackground)
        }

        if let progressBarForeground = colors["progressBarForeground"] {
            builder.kivColors.progressBarForeground = UIColor(hexString: progressBarForeground)
        }
    }

    // MARK: Customize Language

    fileprivate func setBuilderLanguage(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let language = config["language"] as? String {
            if language == "English" {
                builder.kivLanguage = .English
            } else if language == "Dutch" {
                builder.kivLanguage = .Dutch
            } else if language == "Spanish" {
                builder.kivLanguage = .Spanish
            } else if language == "German" {
                builder.kivLanguage = .German
            } else if language == "French" {
                builder.kivLanguage = .French
            }
        }
    }

    // MARK: Customize Optional Screens

    fileprivate func setBuilderOptionalScreens(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let hasIntroScreen = config["hasIntroScreen"] as? Bool {
            builder.hasIntroScreen = hasIntroScreen
        }

        if let hasSuccessScreen = config["hasSuccessScreen"] as? Bool {
            builder.hasSuccessScreen = hasSuccessScreen
        }
    }

    // MARK: Customize Verification lists

    fileprivate func setVerificationLists(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let verifyIncludeList = config["verifyIncludeList"] as? [String] {
            builder.kivVerifyExcludeList = verifyIncludeList
        }

        if let verifyExcludeList = config["verifyExcludeList"] as? [String] {
            builder.kivVerifyExcludeList = verifyExcludeList
        }
    }

    fileprivate func setValidationLists(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let validationIncludeList = config["validationIncludeList"] as? [String] {
            builder.kivValidationIncludeList = validationIncludeList
        }

        if let validationExcludeList = config["validationExcludeList"] as? [String] {
            builder.kivValidationExcludeList = validationExcludeList
        }
    }

    // MARK: Customize Fonts

    fileprivate func setBuilderFonts(_ config: [String : Any], _ builder: IdentityBuilder) {
        guard let fonts = config["fonts"] as? [String: String] else {
            return
        }

        if let fontName = fonts["fontName"] {
            builder.kivFonts.fontName = fontName
        }

        if let boldFontName = fonts["boldFontName"] {
            builder.kivFonts.boldFontName = boldFontName
        }
    }
}

extension UIColor {
    convenience init(hexString: String) {
        var newString = hexString
        if newString.first != "#" {
            newString.insert("#", at: newString.startIndex)
        }
        let hex = newString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}

extension KlippaIdentityVerificationSdk: IdentityBuilderDelegate {

    // MARK: Builder Delegate

    func identityVerificationFinished() {
        _resolve?(nil)
        _resolve = nil
    }

    func identityVerificationCanceled(withError error: KlippaError) {
        let errorMessage: String = {
            switch error {
            case KlippaError.InsufficientPermissions:
                return "Insufficient permissions"
            case KlippaError.InputDeviceError:
                return "Invalid input device"
            case KlippaError.SessionToken:
                return "Invalid session token"
            case KlippaError.UserCanceled:
                return "User canceled session"
            case KlippaError.NoInternetConnection:
                return "No internet connection"
            }
        }()
        _reject?(E_CANCELED, errorMessage, nil)
        _reject = nil
    }

    func identityVerificationContactSupportPressed() {
        _reject?(E_SUPPORT_PRESSED, "Contact support pressed", nil)
        _reject = nil
    }


}
