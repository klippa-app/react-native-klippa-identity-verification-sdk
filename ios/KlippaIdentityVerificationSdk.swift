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
            let txtColor = hexStringToUIColor(hex: textColor)
            builder.kivColors.textColor = txtColor
        }

        if let backgroundColor = colors["backgroundColor"] {
            builder.kivColors.backgroundColor = hexStringToUIColor(hex: backgroundColor)
        }

        if let buttonSuccessColor = colors["buttonSuccessColor"] {
            builder.kivColors.buttonSuccessColor = hexStringToUIColor(hex: buttonSuccessColor)
        }

        if let buttonErrorColor = colors["buttonErrorColor"] {
            builder.kivColors.buttonErrorColor = hexStringToUIColor(hex: buttonErrorColor)
        }

        if let buttonOtherColor = colors["buttonOtherColor"] {
            builder.kivColors.buttonOtherColor = hexStringToUIColor(hex: buttonOtherColor)
        }

        if let progressBarBackground = colors["progressBarBackground"] {
            builder.kivColors.progressBarBackground = hexStringToUIColor(hex: progressBarBackground)
        }

        if let progressBarForeground = colors["progressBarForeground"] {
            builder.kivColors.progressBarForeground = hexStringToUIColor(hex: progressBarForeground)
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

    func hexStringToUIColor(hex:String) -> UIColor? {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return nil
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }


}

extension KlippaIdentityVerificationSdk: IdentityBuilderDelegate {

    // MARK: Builder Delegate

    func identityVerificationFinished() {
        _resolve?(nil)
        _resolve = nil
    }

    func identityVerificationCanceled(withError: KlippaIdentityVerification.KlippaError) {
        switch withError {
        case .InsufficientPermissions:
            _reject?(E_CANCELED, "Insufficient permissions", nil)
        case .NoInternetConnection:
            _reject?(E_CANCELED, "No internet connection", nil)
        case .SessionToken:
            _reject?(E_CANCELED, "Invalid session token", nil)
        case .UserCanceled:
            _reject?(E_CANCELED, "User canceled session", nil)
        default:
            _reject?(E_UNKNOWN, "Failed with unknown error", nil)
        }
        _reject = nil
    }

    func identityVerificationContactSupportPressed() {
        _reject?(E_SUPPORT_PRESSED, "Contact support pressed", nil)
        _reject = nil
    }


}
