import * as React from 'react';

import { StyleSheet, View, Text, Button, Alert } from 'react-native';
import { IdentityBuilder, startSession, KIVLanguage } from 'react-native-klippa-identity-verification-sdk';




export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  function _startSession() {

    const builder = new IdentityBuilder()


    builder.language = KIVLanguage.English
    builder.colors.textColor = "#A020F0"
    builder.colors.backgroundColor = "#262c96"
    builder.colors.buttonErrorColor = "#967126"
    builder.colors.buttonOtherColor = "#967126"
    builder.colors.buttonSuccessColor = "#352696"
    builder.colors.progressBarBackground = "#090521"
    builder.colors.progressBarForeground = "#e6c5d3"


    builder.hasIntroScreen = true
    builder.hasSuccessScreen = true

    builder.verifyIncludeList = ["Surname"]
    builder.verifyExcludeList = ["Face"]


    startSession(builder, "{your-session-token}")
      .then(() => {
        setResult("Finished")
      })
      .catch((reject) => {
        console.log(reject.toString())
        Alert.alert(reject.toString())
      })
  }

  return (
    <View style={styles.container}>
      <Text>Result: {result}</Text>
      <Button
        title="Start session"
        color="#00BC4A"
        onPress={() => _startSession()} />
    </View >
  );
}



const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
