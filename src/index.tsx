import { NativeModules } from 'react-native';

const { KlippaIdentityVerificationSdk } = NativeModules;

export default KlippaIdentityVerificationSdk

export function startSession(builder: IdentityBuilder, sessionToken: string): Promise<void> {
    return KlippaIdentityVerificationSdk.startSession(builder, sessionToken)
}

export enum KIVLanguage {
    English = "English",
    Dutch = "Dutch",
    Spanish = "Spanish"
}

export class KIVFonts {
    fontName?: string
    boldFontName?: string
}

export class KIVColors {
    textColor?: string;

    backgroundColor?: string;

    buttonSuccessColor?: string;

    buttonErrorColor?: string;

    buttonOtherColor?: string;

    progressBarBackground?: string;

    progressBarForeground?: string;
}

export class IdentityBuilder {

    colors: KIVColors = new KIVColors()

    fonts: KIVFonts = new KIVFonts()

    language?: KIVLanguage

    verifyIncludeList?: Array<string>

    verifyExcludeList?: Array<string>

    hasIntroScreen?: boolean

    hasSuccessScreen?: boolean

    isDebug?: boolean
}

