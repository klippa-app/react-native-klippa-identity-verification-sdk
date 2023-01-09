import KlippaIdentityVerification

@objc(KlippaIdentityVerificationSdk)
class KlippaIdentityVerificationSdk: NSObject {

    private let E_UNKNOWN = "E_UNKNOWN_ERROR"
    private let E_CANCELED = "E_CANCELED"
    private let E_SUPPORT_PRESSED = "E_SUPPORT_PRESSED"

    var _resolve: RCTPromiseResolveBlock? = nil
    var _reject: RCTPromiseRejectBlock? = nil

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

        if let isDebug = config["IsDebug"] as? Bool {
            builder.isDebug =  isDebug
        }

        setBuilderColors(config, builder)

        setBuilderFonts(config, builder)

        setVerificationLists(config, builder)

        return builder
    }

    private func hexColorToUIColor(hex: String) -> UIColor? {
        let r, g, b, a: CGFloat

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count == 8 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                a = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                r = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                g = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                b = CGFloat(hexNumber & 0x000000ff) / 255

                return UIColor.init(red: r, green: g, blue: b, alpha: a)
            }
        }

        return nil
    }

    // MARK: - Customize Colors

    fileprivate func setBuilderColors(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let textColor = config["Colors.textColor"] as? String {
            builder.kivColors.textColor = hexColorToUIColor(hex: textColor)
        }

        if let backgroundColor = config["Colors.backgroundColor"] as? String {
            builder.kivColors.backgroundColor = hexColorToUIColor(hex: backgroundColor)
        }

        if let buttonSuccessColor = config["Colors.buttonSuccessColor"] as? String {
            builder.kivColors.buttonSuccessColor = hexColorToUIColor(hex: buttonSuccessColor)
        }

        if let buttonErrorColor = config["Colors.buttonErrorColor"] as? String {
            builder.kivColors.buttonErrorColor = hexColorToUIColor(hex: buttonErrorColor)
        }

        if let buttonOtherColor = config["Colors.buttonOtherColor"] as? String {
            builder.kivColors.buttonOtherColor = hexColorToUIColor(hex: buttonOtherColor)
        }

        if let progressBarBackground = config["Colors.progressBarBackground"] as? String {
            builder.kivColors.progressBarBackground = hexColorToUIColor(hex: progressBarBackground)
        }

        if let progressBarForeground = config["Colors.progressBarForeground"] as? String {
            builder.kivColors.progressBarForeground = hexColorToUIColor(hex: progressBarForeground)
        }
    }

    // MARK: Customize Language

    fileprivate func setBuilderLanguage(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let language = config["Language"] as? String {
            if language == "KIVLanguage.English" {
                builder.kivLanguage = .English
            } else if language == "KIVLanguage.Dutch" {
                builder.kivLanguage = .Dutch
            } else if language == "KIVLanguage.Spanish" {
                builder.kivLanguage = .Spanish
            }
        }
    }

    // MARK: Customize Optional Screens

    fileprivate func setBuilderOptionalScreens(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let hasInstroScreen = config["HasIntroScreen"] as? Bool {
            builder.hasIntroScreen = hasInstroScreen
        }

        if let hasSuccessScreen = config["HasSuccessScreen"] as? Bool {
            builder.hasSuccessScreen = hasSuccessScreen
        }
    }

    // MARK: Customize Verification lists

    fileprivate func setVerificationLists(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let verifyIncludeList = config["VerifyIncludeList"] as? [String] {
            builder.kivVerifyExcludeList = verifyIncludeList
        }

        if let verifyExcludeList = config["VerifyExcludeList"] as? [String] {
            builder.kivVerifyExcludeList = verifyExcludeList
        }
    }

    // MARK: Customize Fonts

    fileprivate func setBuilderFonts(_ config: [String : Any], _ builder: IdentityBuilder) {
        if let fontName = config["Fonts.fontName"] as? String{
            builder.kivFonts.fontName = fontName
        }

        if let boldFontName = config["Fonts.boldFontName"] as? String{
            builder.kivFonts.boldFontName = boldFontName
        }
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
            _reject?(E_CANCELED, "User cancelled session", nil)
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
