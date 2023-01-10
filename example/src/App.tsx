import * as React from 'react';

import { StyleSheet, View, Text, Button, Alert } from 'react-native';
import { IdentityBuilder, startSession } from 'react-native-klippa-identity-verification-sdk';

export default function App() {
  const [result, setResult] = React.useState<string | undefined>();

  function _startSession() {

    const identityBuilder = new IdentityBuilder()

    startSession(identityBuilder, "{your-session-token}")
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
