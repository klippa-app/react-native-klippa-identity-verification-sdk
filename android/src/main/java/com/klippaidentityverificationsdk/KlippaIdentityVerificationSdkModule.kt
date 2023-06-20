package com.klippaidentityverificationsdk

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.klippa.identity_verification.model.KlippaError
import com.klippa.identity_verification.modules.base.IdentityBuilder

class KlippaIdentityVerificationSdkModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext), IdentityBuilder.IdentityBuilderListener {

    private val E_UNKNOWN = "E_UNKNOWN_ERROR"
    private val E_CANCELED = "E_CANCELED"
    private val E_SUPPORT_PRESSED = "E_SUPPORT_PRESSED"

    private var _promise: Promise? = null

    override fun getName(): String {
        return NAME
    }

    @ReactMethod
    fun startSession(
        config: ReadableMap,
        sessionToken: String,
        promise: Promise
    ) {
        this._promise = promise

        val builder = setupIdentityBuilder(sessionToken, config.toHashMap())

        val intent = builder.getIntent(reactContext)

        currentActivity?.startActivity(intent)

    }

    private fun setupIdentityBuilder(sessionToken: String, config: Map<String, Any>) : IdentityBuilder {
        val builder = IdentityBuilder(this, sessionToken)

        setBuilderLanguage(config, builder)

        setBuilderOptionalScreens(config, builder)

        (config["isDebug"] as? Boolean)?.also { isDebug ->
            builder.isDebug = isDebug
        }

        setVerificationLists(config, builder)

        return builder
    }

    private fun setVerificationLists(
        config: Map<String, Any>,
        builder: IdentityBuilder
    ) {
        @Suppress("UNCHECKED_CAST")
        (config["verifyIncludeList"] as? List<String>)?.also { verifyIncludeList ->
            builder.kivIncludeList = verifyIncludeList
        }

        @Suppress("UNCHECKED_CAST")
        (config["verifyExcludeList"] as? List<String>)?.also { verifyExcludeList ->
            builder.kivExcludeList = verifyExcludeList
        }
    }

    private fun setBuilderOptionalScreens(
        config: Map<String, Any>,
        builder: IdentityBuilder
    ) {
        (config["hasIntroScreen"] as? Boolean)?.also { hasIntroScreen ->
            builder.hasIntroScreen = hasIntroScreen
        }

        (config["hasSuccessScreen"] as? Boolean)?.also { hasSuccessScreen ->
            builder.hasSuccessScreen = hasSuccessScreen
        }
    }

    private fun setBuilderLanguage(
        config: Map<String, Any>,
        builder: IdentityBuilder
    ) {
        (config["language"] as? String)?.also { language ->
            when (language) {
                "English" -> builder.language = IdentityBuilder.KIVLanguage.English
                "Dutch" -> builder.language = IdentityBuilder.KIVLanguage.Dutch
                "Spanish" -> builder.language = IdentityBuilder.KIVLanguage.Spanish
            }
        }
    }

    companion object {
        const val NAME = "KlippaIdentityVerificationSdk"
    }

    override fun identityVerificationFinished() {
        _promise?.resolve(null)
        _promise = null
    }

    override fun identityVerificationCanceled(error: KlippaError) {
        when (error) {
            KlippaError.InsufficientPermissions -> {
                _promise?.reject(E_CANCELED, "Insufficient permissions")
            }
            KlippaError.InvalidSessionToken -> {
                _promise?.reject(E_CANCELED, "Invalid session token")
            }
            KlippaError.UserCanceled -> {
                _promise?.reject(E_CANCELED, "User canceled session")
            }
            KlippaError.NoInternetConnection -> {
                _promise?.reject(E_CANCELED, "No active internet connection")
            }
            KlippaError.DeviceDoesNotSupportNFC -> {
                _promise?.reject(E_CANCELED, "Device does not support NFC")
            }
            KlippaError.DeviceNFCDisabled -> {
                _promise?.reject(E_CANCELED, "NFC is disabled on device")
            }
            else -> {
                _promise?.reject(E_UNKNOWN, "Failed with unknown error")
            }
        }
        _promise = null
    }

    override fun identityVerificationContactSupportPressed() {
        _promise?.reject(E_SUPPORT_PRESSED, "Contact support pressed")
        _promise =  null
    }

}
