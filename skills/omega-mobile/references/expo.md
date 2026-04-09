# Expo — Setup, Navigazione, Auth, Push Notifications

Doc ufficiale: https://docs.expo.dev
React Native: https://reactnative.dev/docs/getting-started
Expo Router: https://expo.github.io/router/docs
EAS Build: https://docs.expo.dev/build/introduction

## Scelta stack

| Scenario | Stack consigliato |
|---|---|
| App nuova, team web | **Expo (managed workflow)** + Expo Router |
| Funzionalità native avanzate | Expo (bare workflow) + React Native |
| Performance massima, team nativo | React Native puro |
| Prototipo rapido | Expo Snack o Expo Go |

**Regola:** Inizia sempre con Expo managed. Ejetti solo se serve una libreria nativa non supportata.

## Setup iniziale

```bash
# Crea nuovo progetto Expo con TypeScript e Router
npx create-expo-app@latest --template

# Scegli: "Blank (TypeScript)" con Expo Router
cd [nome-progetto]
npx expo install expo-router expo-constants expo-linking expo-status-bar

# Installa EAS CLI (per build e submission)
npm install -g eas-cli
eas login
eas init
```

### `app.json` — Configurazione base
```json
{
  "expo": {
    "name": "[Nome App]",
    "slug": "[nome-slug-url-friendly]",
    "version": "1.0.0",
    "orientation": "portrait",
    "icon": "./assets/icon.png",
    "userInterfaceStyle": "automatic",
    "splash": {
      "image": "./assets/splash.png",
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    },
    "ios": {
      "supportsTablet": false,
      "bundleIdentifier": "com.[azienda].[app]",
      "buildNumber": "1"
    },
    "android": {
      "adaptiveIcon": {
        "foregroundImage": "./assets/adaptive-icon.png",
        "backgroundColor": "#ffffff"
      },
      "package": "com.[azienda].[app]",
      "versionCode": 1
    },
    "plugins": ["expo-router"],
    "scheme": "[nome-schema]"
  }
}
```

## Navigazione — Expo Router (file-based)

```
app/
├── _layout.tsx          ← Root layout (provider, font, auth check)
├── index.tsx            ← Home screen
├── (auth)/
│   ├── _layout.tsx      ← Auth layout (redirect se loggato)
│   ├── login.tsx
│   └── register.tsx
├── (tabs)/
│   ├── _layout.tsx      ← Tab bar configuration
│   ├── home.tsx
│   ├── profilo.tsx
│   └── impostazioni.tsx
└── [id].tsx             ← Route dinamica
```

```typescript
// app/_layout.tsx — Root layout con providers
import { Stack } from 'expo-router'
import { AuthProvider } from '@/contexts/auth'
import { useFonts } from 'expo-font'
import * as SplashScreen from 'expo-splash-screen'
import { useEffect } from 'react'

SplashScreen.preventAutoHideAsync()

export default function RootLayout() {
  const [loaded] = useFonts({
    SpaceMono: require('../assets/fonts/SpaceMono-Regular.ttf'),
  })

  useEffect(() => {
    if (loaded) SplashScreen.hideAsync()
  }, [loaded])

  if (!loaded) return null

  return (
    <AuthProvider>
      <Stack screenOptions={{ headerShown: false }}>
        <Stack.Screen name="(auth)" />
        <Stack.Screen name="(tabs)" />
      </Stack>
    </AuthProvider>
  )
}

// app/(tabs)/_layout.tsx — Tab bar
import { Tabs } from 'expo-router'
import { Ionicons } from '@expo/vector-icons'

export default function TabsLayout() {
  return (
    <Tabs screenOptions={{ tabBarActiveTintColor: '#007AFF' }}>
      <Tabs.Screen
        name="home"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => <Ionicons name="home" size={24} color={color} />,
        }}
      />
      <Tabs.Screen
        name="profilo"
        options={{
          title: 'Profilo',
          tabBarIcon: ({ color }) => <Ionicons name="person" size={24} color={color} />,
        }}
      />
    </Tabs>
  )
}
```

## Auth Mobile

### Opzione A — Supabase Auth (consigliata per Expo)

```bash
npx expo install @supabase/supabase-js @react-native-async-storage/async-storage expo-secure-store
```

```typescript
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import * as SecureStore from 'expo-secure-store'

// SecureStore per i token (più sicuro di AsyncStorage)
const ExpoSecureStoreAdapter = {
  getItem: (key: string) => SecureStore.getItemAsync(key),
  setItem: (key: string, value: string) => SecureStore.setItemAsync(key, value),
  removeItem: (key: string) => SecureStore.deleteItemAsync(key),
}

export const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!,
  {
    auth: {
      storage: ExpoSecureStoreAdapter,
      autoRefreshToken: true,
      persistSession: true,
      detectSessionInUrl: false,  // ← IMPORTANTE: false su mobile
    },
  }
)
```

### Opzione B — Clerk (social login semplice)

```bash
npx expo install @clerk/clerk-expo expo-secure-store
```

```typescript
// app/_layout.tsx
import { ClerkProvider, ClerkLoaded } from '@clerk/clerk-expo'
import * as SecureStore from 'expo-secure-store'

const tokenCache = {
  async getToken(key: string) { return SecureStore.getItemAsync(key) },
  async saveToken(key: string, value: string) { return SecureStore.setItemAsync(key, value) },
  async clearToken(key: string) { return SecureStore.deleteItemAsync(key) },
}

export default function RootLayout() {
  return (
    <ClerkProvider
      publishableKey={process.env.EXPO_PUBLIC_CLERK_PUBLISHABLE_KEY!}
      tokenCache={tokenCache}
    >
      <ClerkLoaded>
        {/* ... resto layout */}
      </ClerkLoaded>
    </ClerkProvider>
  )
}
```

## Push Notifications

```bash
npx expo install expo-notifications expo-device expo-constants
```

```typescript
// lib/notifications.ts
import * as Notifications from 'expo-notifications'
import * as Device from 'expo-device'
import Constants from 'expo-constants'

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: true,
  }),
})

export async function registerForPushNotifications(): Promise<string | null> {
  if (!Device.isDevice) {
    console.warn('Push notifications solo su dispositivo reale')
    return null
  }

  const { status: existing } = await Notifications.getPermissionsAsync()
  let finalStatus = existing

  if (existing !== 'granted') {
    const { status } = await Notifications.requestPermissionsAsync()
    finalStatus = status
  }

  if (finalStatus !== 'granted') return null

  const projectId = Constants.expoConfig?.extra?.eas?.projectId
  const token = (await Notifications.getExpoPushTokenAsync({ projectId })).data

  // Salva token nel backend
  await saveTokenToServer(token)
  return token
}

// Invia push via Expo Push API (server-side)
async function sendPushNotification(expoPushToken: string, title: string, body: string) {
  await fetch('https://exp.host/--/api/v2/push/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      to: expoPushToken,
      title,
      body,
      data: { screen: 'home' },
    }),
  })
}
```

## Permessi comuni

```bash
npx expo install expo-camera expo-image-picker expo-location expo-contacts
```

```typescript
// Pattern permesso + uso (esempio camera)
import { CameraView, useCameraPermissions } from 'expo-camera'

export function CameraScreen() {
  const [permission, requestPermission] = useCameraPermissions()

  if (!permission?.granted) {
    return (
      <View>
        <Text>Accesso alla camera necessario</Text>
        <Button title="Consenti" onPress={requestPermission} />
      </View>
    )
  }

  return <CameraView style={{ flex: 1 }} />
}
```

## Storage locale

```bash
# Dati sensibili (token, password)
npx expo install expo-secure-store

# Dati app generali (preferences, cache)
npx expo install @react-native-async-storage/async-storage

# Dati strutturati veloci (alternativa a AsyncStorage)
npm install react-native-mmkv  # ← richiede bare workflow o dev build
```

## Production Build — EAS Build

### `eas.json`

```json
{
  "cli": { "version": ">= 7.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": {
      "distribution": "internal",
      "ios": { "simulator": false },
      "android": { "buildType": "apk" }
    },
    "production": {
      "autoIncrement": true,
      "ios": { "credentialsSource": "remote" },
      "android": { "buildType": "app-bundle", "credentialsSource": "remote" }
    }
  },
  "submit": {
    "production": {
      "ios": {
        "appleId": "[apple-id@email.com]",
        "ascAppId": "[App Store Connect App ID]"
      },
      "android": {
        "serviceAccountKeyPath": "./google-service-account.json",
        "track": "internal"
      }
    }
  }
}
```

### Comandi build

```bash
# Build development client
eas build --profile development --platform all

# Build preview
eas build --profile preview --platform all

# Build produzione
eas build --profile production --platform ios
eas build --profile production --platform android

# Submit all'App Store / Play Store
eas submit --platform ios --latest
eas submit --platform android --latest

# OTA update (senza rebuild — solo JS/assets)
eas update --branch production --message "Fix: [descrizione]"
```

## Sicurezza mobile

```typescript
// 1. Mai hardcodare segreti — usa .env
EXPO_PUBLIC_API_URL=https://api.mioapp.com  // EXPO_PUBLIC_ → visibile al client
API_SECRET=xxx                               // Senza prefisso → solo server-side

// 2. Token in SecureStore, non AsyncStorage
import * as SecureStore from 'expo-secure-store'
await SecureStore.setItemAsync('user_token', token)  // ✅
// NON: await AsyncStorage.setItem('user_token', token)  ❌

// 3. Jailbreak/root detection (se l'app tratta dati finanziari/sanitari)
import * as Device from 'expo-device'
if (!Device.isDevice) {
  // Simulator — limita funzionalità sensibili in production
}
```
