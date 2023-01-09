import * as React from 'react';

import { StyleSheet, View, Text, Button, Alert } from 'react-native';
import { IdentityBuilder, startSession, KIVLanguage } from 'react-native-klippa-identity-verification-sdk';




export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  function _startSession() {
    const builder = new IdentityBuilder()

    builder.language = KIVLanguage.Dutch

    startSession(builder, "{your-token}")
      .then(() => {
        setResult("Finished")
      })
      .catch((reject) => {
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
