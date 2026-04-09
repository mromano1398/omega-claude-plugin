# Blueprint: Mobile App (Expo)

## Struttura Cartelle
```
app/
├── (auth)/
│   ├── _layout.tsx
│   ├── login.tsx
│   └── register.tsx
├── (tabs)/
│   ├── _layout.tsx              # Tab navigator
│   ├── index.tsx                # Tab 1: Home
│   ├── explore.tsx              # Tab 2: Esplora
│   ├── profile.tsx              # Tab 3: Profilo
│   └── settings.tsx             # Tab 4: Impostazioni
├── [modulo]/
│   ├── _layout.tsx
│   ├── index.tsx                # Lista
│   └── [id].tsx                 # Dettaglio
└── _layout.tsx                  # Root layout (auth check)
components/
├── ui/
│   ├── Button.tsx
│   ├── Input.tsx
│   ├── Card.tsx
│   └── Loading.tsx
└── [modulo]/
hooks/
├── useAuth.ts
├── useSupabase.ts
└── use[Dominio].ts
lib/
├── supabase.ts
├── storage.ts
└── notifications.ts
assets/
├── images/
└── fonts/
eas.json                         # EAS Build config
app.json                         # Expo config
```

## Stack
```bash
npx create-expo-app --template expo-template-blank-typescript
npm install expo-router nativewind @supabase/supabase-js
npm install expo-secure-store expo-notifications expo-local-authentication
npm install @react-native-async-storage/async-storage
```

## Supabase Backend
```ts
// lib/supabase.ts
import { createClient } from '@supabase/supabase-js'
import * as SecureStore from 'expo-secure-store'

const ExpoSecureStoreAdapter = {
  getItem: (key: string) => SecureStore.getItemAsync(key),
  setItem: (key: string, value: string) => SecureStore.setItemAsync(key, value),
  removeItem: (key: string) => SecureStore.deleteItemAsync(key),
}

export const supabase = createClient(
  process.env.EXPO_PUBLIC_SUPABASE_URL!,
  process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!,
  { auth: { storage: ExpoSecureStoreAdapter, autoRefreshToken: true, persistSession: true } }
)
```

## NativeWind (Styling)
```tsx
// Tailwind per React Native
import { Text, View } from 'react-native'
export function Card({ children }) {
  return <View className="bg-white rounded-xl p-4 shadow-sm">{children}</View>
}
```

## Navigazione (expo-router)
```tsx
// app/_layout.tsx
import { useAuth } from '@/hooks/useAuth'
export default function RootLayout() {
  const { session, loading } = useAuth()
  if (loading) return <SplashScreen />
  return (
    <Stack>
      <Stack.Screen name="(auth)" redirect={!!session} />
      <Stack.Screen name="(tabs)" redirect={!session} />
    </Stack>
  )
}
```

## Notifiche Push
```ts
// lib/notifications.ts
import * as Notifications from 'expo-notifications'
import { supabase } from './supabase'

export async function registerForPushNotifications(userId: string) {
  const { status } = await Notifications.requestPermissionsAsync()
  if (status !== 'granted') return
  const token = (await Notifications.getExpoPushTokenAsync()).data
  await supabase.from('push_tokens').upsert({ user_id: userId, token })
}
```

## Biometria
```ts
import * as LocalAuthentication from 'expo-local-authentication'
export async function authenticateWithBiometrics(): Promise<boolean> {
  const hasHardware = await LocalAuthentication.hasHardwareAsync()
  if (!hasHardware) return false
  const result = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Sblocca con biometria',
    fallbackLabel: 'Usa PIN'
  })
  return result.success
}
```

## EAS Build Config
```json
// eas.json
{
  "cli": { "version": ">= 5.0.0" },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal"
    },
    "preview": { "distribution": "internal" },
    "production": { "autoIncrement": true }
  },
  "submit": {
    "production": {
      "ios": { "appleId": "tua@email.com", "ascAppId": "XXXXXXXXXX" },
      "android": { "serviceAccountKeyPath": "./google-service-account.json" }
    }
  }
}
```

## Store Submission Checklist

**iOS App Store:**
- Icon: 1024x1024px PNG senza trasparenza
- Screenshots: 6.7" (1290x2796), 6.5" (1242x2688), 5.5" (1242x2208), iPad Pro 12.9" (2048x2732), iPad Pro 12.9" 2nd gen
- Privacy manifest (PrivacyInfo.xcprivacy) obbligatorio
- App Privacy dichiarazione in App Store Connect

**Google Play:**
- Icon: 512x512px PNG
- Feature Graphic: 1024x500px
- Screenshots: phone + tablet (opzionale)
- Target API level: Android 14 (API 34) minimo

## AsyncStorage per Cache Locale
```ts
import AsyncStorage from '@react-native-async-storage/async-storage'
export async function cacheData(key: string, data: unknown, ttlMs = 300000) {
  await AsyncStorage.setItem(key, JSON.stringify({ data, expiry: Date.now() + ttlMs }))
}
export async function getCachedData<T>(key: string): Promise<T | null> {
  const raw = await AsyncStorage.getItem(key)
  if (!raw) return null
  const { data, expiry } = JSON.parse(raw)
  return Date.now() > expiry ? null : data as T
}
```
