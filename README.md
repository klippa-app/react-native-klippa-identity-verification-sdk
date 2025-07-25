[![Npm version][npm-version]][npm-url]
[![Build Status][build-status]][build-url]

[build-status]:https://github.com/klippa-app/react-native-klippa-identity-verification-sdk/actions/workflows/build.yml/badge.svg
[build-url]:https://github.com/klippa-app/react-native-klippa-identity-verification-sdk/actions
[npm-version]:https://img.shields.io/npm/v/@klippa/react-native-klippa-identity-verification-sdk.svg
[npm-url]:https://www.npmjs.com/package/@klippa/react-native-klippa-identity-verification-sdk

### SDK usage
Please be aware you need to have a Klippa Identity Verification OCR API key to use this SDK.
If you would like to use our Identity Verification SDK, please contact us [here](https://www.klippa.com/en/contact-en/)

### Getting started
#### Android

Edit the file `android/key.properties`, if it doesn't exist yet, create it. Add the SDK credentials:

```bash
klippa.identity_verification.sdk.username={your-username}
klippa.identity_verification.sdk.password={your-password}
```

Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

#### iOS

Edit the file `ios/Podfile`, add the Klippa CocoaPod:

```ruby
// Add this to the top of your file:
// Edit the platform to a minimum of 13.0, our SDK doesn't support earlier versions.
platform :ios, '13.0'

if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_USERNAME']}" == ""
  ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_USERNAME"'] = '{your-username}'
end
if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_PASSWORD']}" == ""
  ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_PASSWORD"'] = '{your-password}'
end

// Edit the Runner config to add the pod:

target 'KlippaIdentityVerificationSdkExample' do
  // ... other instructions

  // Add this below `use_react_native`

  if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_URL']}" == ""
    file_path = File.expand_path('../node_modules/@klippa/react-native-klippa-identity-verification-sdk/ios/.sdk_repo', __dir__)
    ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_URL'] = File.read(file_path).strip
  end

  if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_VERSION']}" == ""
    file_path = File.expand_path('../node_modules/@klippa/react-native-klippa-identity-verification-sdk/ios/.sdk_version', __dir__)
    ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_VERSION'] = File.read(file_path).strip
  end

  pod 'Klippa-Identity-Verification', podspec: "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_URL']}/#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_USERNAME']}/#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_PASSWORD']}/KlippaIdentityVerification/#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_VERSION']}.podspec"

end
```
Replace the `{your-username}` and `{your-password}` values with the ones provided by Klippa.

Edit the file `ios/{project-name}/Info.plist` and add the `NSCameraUsageDescription` key:
```xml
...
<key>NSCameraUsageDescription</key>
<string>Access to your camera is needed to photograph documents.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Access to your photo library is used to save the images of documents.</string>
...
```

In case you would like to use NFC also add the `com.apple.developer.nfc.readersession.iso7816.select-identifiers` key:

```xml
...
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
<string>A0000002471001</string>
<string>A0000002472001</string>
<string>00000000000000</string>
</array>
...
```

**Important**: When using NFC also add "Near Field Communication Tag Reading" capability to your app using the Signing & Capabilities pane of the project editor.

#### React Native

`$ npm i @klippa/react-native-klippa-identity-verification-sdk`

Don't forget to run `pod install` in the ios folder when running the iOS app.

#### Mostly automatic installation (only for versions of React Native lower than 0.60, later versions have auto-linking)

`$ react-native link @klippa/react-native-klippa-idendity-verification-sdk`

### Usage

```javascript
import { IdentityBuilder, startSession } from 'react-native-klippa-identity-verification-sdk';

const identityBuilder = new IdentityBuilder()
// @todo: get a session token from the API through your backend here.
startSession(identityBuilder, "{your-session-token}")
  .then(() => {
    // The session has finished
    console.log("Finished")
  })
  .catch((reject) => {
    // The session failed.
    console.log(reject.toString())
  })

```

After returning from the SDK you can use the API to validate the session in your backend.

The reject reason object has a code and a message, the codes user are:

- E_CANCELED
- E_UNKNOWN
- E_SUPPORT_PRESSED
- E_CONTACT_SUPPORT_PRESSED

### Specify SDK Version

#### Android

Edit the file `android/build.gradle`, add the following:

```groovy
allprojects {
  // ... other definitions
  project.ext {
      klippaIdentityVerificationVersion = "{version}"
  }
}
```

Replace the {version} value with the version you want to use.

If you want to change the repository:

Edit the file `android/key.properties`, add the following repository URL:

```bash
klippa.identity_verification.sdk.url={repository-url}
```

Replace `{repository-url}` with the version you want to use.

#### iOS

Edit the file ios/Podfile, add the following line below the username/password if you want to change the version:
```ruby
ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_VERSION'] = '{version}'
```
Replace {version} with the version that you want to use.

If you want to change the repository:

Edit the file ios/Podfile, add the following line below the username/password if you want to change the URL:
```ruby
ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_URL'] = '{repository-url}'
```
Replace {repository-url} with the URL that you want to use.

### Customize SDK

#### Debug

To display extra debug info, add the following to the builder:

```javascript
identityBuilder.isDebug = true
```

#### Intro / Success screens

To configure whether to show intro/success screens, add the following to the builder:

```javascript
    identityBuilder.hasIntroScreen = true
    identityBuilder.hasSuccessScreen = true
```

#### Retry Threshold

To configure how often a user can attempt a task before the `contact support` button is shown to the user.

```javascript
identityBuilder.retryThreshold = 1
```

To configure if the SDK should quit instead of showing the support button you can set the following:
```javascript
identityBuilder.exitOnRetryThresholdReached = true
```

#### Allow Camera On NFC Task

To configure whether a user can skip NFC and use OCR instead.
```javascript
identityBuilder.allowCameraOnNFCTask = true
```

#### NFC Timeout Threshold

To configure how long the NFC detecting stays active you can set a timeout.
```javascript
identityBuilder.nfcTimeoutThreshold = 5.0
```

#### Enable Auto Capture

To configure if the camera should automatically take a photo if the conditions are right.

```javascript
identityBuilder.enableAutoCapture = true
```

#### Language

Add the following to the builder:

``` javascript
// We support English, Dutch, Spanish, German and French
identityBuilder.language = KIVLanguage.Dutch
```

#### Include & Exclude lists

You can edit the include list: The extracted data keys that will be shown to the user after document pictures are processed. 
Or the exclude list: The extracted data keys that will be hidden for the user after document pictures are processed.

```javascript
identityBuilder.verifyIncludeList = [
     "DateOfBirth",
     "DateOfIssue",
     "DateOfExpiry",
     "DocumentNumber",
     "DocumentSubtype",
     "DocumentType",
     "Face",
     "Gender",
     "GivenNames",
     "Height",
     "IssuingCountry",
     "IssuingInstitution",
     "Nationality",
     "PersonalNumber",
     "PlaceOfBirth",
     "Residency",
     "Signature",
     "Surname"
]

identityBuilder.verifyExcludeList = []
```

#### Validation Include & Exclude lists

You can edit the validation include list: the failed validations that are shown to the user Or the validation exclude list: the failed validations that are hidden from the user.
For more information regarding validations check out the [API documentation](https://custom-ocr.klippa.com/docs#tag/IdentityVerification/operation/createIdentityVerificationSession). 

```javascript
identityBuilder.validationIncludeList = [
    "DetectFace",
    "CompareFace",
    "DetectSignature",
    "CompareSignature",
    "CheckRequiredField",
    "MatchSidesFront",
    "MatchSidesBack",
    "FieldValidation",
    "MatchVizMrz",
    "MrzChecksum"
]

identityBuilder.validationExcludeList = []
```

### Customize the colours

#### Android

Add or edit the file android/app/src/main/res/values/colors.xml, add the following:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="kiv_text_color">#808080</color>
    <color name="kiv_background_color">#FFFFFF</color>
    <color name="kiv_button_success_color">#00CC00</color>
    <color name="kiv_button_error_color">#FF0000</color>
    <color name="kiv_button_other_color">#333333</color>
    <color name="kiv_progress_bar_background_color">#EBEFEF</color>
    <color name="kiv_progress_bar_foreground_color">#00CC00</color>
</resources>
```

You can also replace the fonts by adding the files:
```bash
android/app/src/main/res/font/kiv_font.ttf
android/app/src/main/res/font/kiv_font_bold.ttf
```

#### iOS

Use the following properties in the builder:

```javascript

// Colors:

identityBuilder.colors.textColor = "#808080"
identityBuilder.colors.backgroundColor = "#FFFFFF"
identityBuilder.colors.buttonSuccessColor = "#00CC00"
identityBuilder.colors.buttonErrorColor = "#FF0000"
identityBuilder.colors.buttonOtherColor = "#333333"
identityBuilder.colors.progressBarBackground = "#EBEFEF"
identityBuilder.colors.progressBarForeground = "#00CC00"

// Fonts:

identityBuilder.fonts.fontName = "Avenir next"
identityBuilder.fonts.boldFontName = "Avenir next Bold"

```

### Important iOS notes

Older iOS versions do not ship the Swift libraries. To make sure the SDK works on older iOS versions, you can configure the build to embed the Swift libraries using the build setting EMBEDDED_CONTENT_CONTAINS_SWIFT = YES.

We use XCFrameworks, you need CocoaPod version 1.9.0 or higher to be able to use it.

### Running the Example

#### Android

Edit the file `android/key.properties`, and add the SDK credentials:

```bash
klippa.identity_verification.sdk.username={your-username}
klippa.identity_verification.sdk.password={your-password}
```

Replace the {your-username} and {your-password} values with the ones provided by Klippa.

Afterwards run the following command in the root directory of this repository:

```bash
yarn example android
```

#### iOS

Replace {your-username} and {your-password} values with the ones provided by Klippa in the `example/ios/Podfile`

```ruby
if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_USERNAME']}" == ""
  ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_USERNAME'] = '{your-username}'
end

if "#{ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_PASSWORD']}" == ""
  ENV['KLIPPA_IDENTITY_VERIFICATION_SDK_PASSWORD'] = '{your-password}'
end
```

Afterwards run the command `pod install` in the `example/ios` directory.

Finally run the command `yarn example ios` in the root directory of this repository.

### About Klippa

[Klippa](https://www.klippa.com/en) is a scale-up from [Groningen, The Netherlands](https://goo.gl/maps/CcCGaPTBz3u8noSd6) and was founded in 2015 by six Dutch IT specialists with the goal to digitize paper processes with modern technologies.

We help clients enhance the effectiveness of their organization by using machine learning and OCR. Since 2015 more than a 1000 happy clients have been served with a variety of the software solutions that Klippa offers. Our passion is to help our clients to digitize paper processes by using smart apps, accounts payable software and data extraction by using OCR.

## License

The MIT License (MIT)
