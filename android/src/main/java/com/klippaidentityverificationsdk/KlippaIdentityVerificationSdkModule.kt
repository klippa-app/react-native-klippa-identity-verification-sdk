package com.klippaidentityverificationsdk

import android.app.Activity
import android.content.Intent
import com.facebook.react.bridge.BaseActivityEventListener
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap
import com.klippa.identity_verification.modules.base.IdentitySession
import com.klippa.identity_verification.modules.base.IdentitySessionResultCode

class KlippaIdentityVerificationSdkModule(private val reactContext: ReactApplicationContext) :
    ReactContextBaseJavaModule(reactContext) {

    companion object {
        private const val NAME = "KlippaIdentityVerificationSdk"
        private const val REQUEST_CODE = 99991801

        private const val E_CANCELED = "E_CANCELED"
        private const val E_SUPPORT_PRESSED = "E_SUPPORT_PRESSED"
    }

    private var _promise: Promise? = null

    override fun getName(): String {
        return NAME
    }

    private val activityEventListener = object : BaseActivityEventListener() {
        override fun onActivityResult(
            activity: Activity?,
            requestCode: Int,
            resultCode: Int,
            data: Intent?
        ) {
            super.onActivityResult(activity, requestCode, resultCode, data)

            val mappedResultCode = IdentitySessionResultCode.mapResultCode(resultCode)
            when (mappedResultCode) {
                IdentitySessionResultCode.FINISHED -> identityVerificationFinished()
                IdentitySessionResultCode.CONTACT_SUPPORT_PRESSED -> identityVerificationContactSupportPressed(
                    mappedResultCode.message()
                )

                IdentitySessionResultCode.INSUFFICIENT_PERMISSIONS,
                IdentitySessionResultCode.INVALID_SESSION_TOKEN,
                IdentitySessionResultCode.USER_CANCELED,
                IdentitySessionResultCode.NO_INTERNET_CONNECTION,
                IdentitySessionResultCode.DEVICE_DOES_NOT_SUPPORT_NFC,
                IdentitySessionResultCode.DEVICE_NFC_DISABLED,
                IdentitySessionResultCode.UNKNOWN_ERROR,
                IdentitySessionResultCode.TAKING_PHOTO_FAILED -> identityVerificationCanceled(
                    mappedResultCode.message()
                )
            }
        }
    }

    init {
        reactContext.addActivityEventListener(activityEventListener)
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
        currentActivity?.startActivityForResult(intent, REQUEST_CODE)
    }


    private fun setupIdentityBuilder(
        sessionToken: String,
        config: Map<String, Any>
    ): IdentitySession {
        val identitySession = IdentitySession(sessionToken)

        setBuilderLanguage(config, identitySession)

        setBuilderOptionalScreens(config, identitySession)

        (config["isDebug"] as? Boolean)?.also { isDebug ->
            identitySession.isDebug = isDebug
        }

        (config["retryThreshold"] as? Double)?.let { retryThreshold ->
            identitySession.retryThreshold = retryThreshold.toInt()
        }

        (config["enableAutoCapture"] as? Boolean)?.let { enableAutoCapture ->
            identitySession.enableAutoCapture = enableAutoCapture
        }

        setVerificationLists(config, identitySession)

        setValidationLists(config, identitySession)

        return identitySession
    }

    private fun setVerificationLists(
        config: Map<String, Any>,
        identitySession: IdentitySession
    ) {
        @Suppress("UNCHECKED_CAST")
        (config["verifyIncludeList"] as? List<String>)?.also { verifyIncludeList ->
            identitySession.kivIncludeList = verifyIncludeList
        }

        @Suppress("UNCHECKED_CAST")
        (config["verifyExcludeList"] as? List<String>)?.also { verifyExcludeList ->
            identitySession.kivExcludeList = verifyExcludeList
        }
    }

        private fun setValidationLists(
        config: Map<String, Any>,
        identitySession: IdentitySession
    ) {
        @Suppress("UNCHECKED_CAST")
        (config["validationIncludeList"] as? List<String>)?.also { validationIncludeList ->
            identitySession.kivValidationIncludeList = validationIncludeList
        }

        @Suppress("UNCHECKED_CAST")
        (config["validationExcludeList"] as? List<String>)?.also { validationExcludeList ->
            identitySession.kivValidationExcludeList = validationExcludeList
        }
    }

    private fun setBuilderOptionalScreens(
        config: Map<String, Any>,
        identitySession: IdentitySession
    ) {
        (config["hasIntroScreen"] as? Boolean)?.also { hasIntroScreen ->
            identitySession.hasIntroScreen = hasIntroScreen
        }

        (config["hasSuccessScreen"] as? Boolean)?.also { hasSuccessScreen ->
            identitySession.hasSuccessScreen = hasSuccessScreen
        }
    }

    private fun setBuilderLanguage(
        config: Map<String, Any>,
        identitySession: IdentitySession
    ) {
        (config["language"] as? String)?.also { language ->
            when (language) {
                "English" -> identitySession.language = IdentitySession.KIVLanguage.English
                "Dutch" -> identitySession.language = IdentitySession.KIVLanguage.Dutch
                "Spanish" -> identitySession.language = IdentitySession.KIVLanguage.Spanish
                "German" -> identitySession.language = IdentitySession.KIVLanguage.German
                "French" -> identitySession.language = IdentitySession.KIVLanguage.French
            }
        }
    }

    private fun identityVerificationFinished() {
        _promise?.resolve(null)
        _promise = null
    }


    private fun identityVerificationCanceled(message: String) {
        _promise?.reject(E_CANCELED, message)
        _promise = null
    }

    private fun identityVerificationContactSupportPressed(message: String) {
        _promise?.reject(E_SUPPORT_PRESSED, message, null)
        _promise = null
    }

}
