# App Store — Submission iOS e Android

App Store Connect: https://developer.apple.com/app-store-connect
Google Play Console: https://play.google.com/console

## APP STORE iOS

### Prerequisiti (da fare una sola volta)
1. **Apple Developer Account**: developer.apple.com — $99/anno
2. **Crea App ID** in App Store Connect
3. **Certificati**: EAS gestisce automaticamente con `eas credentials`

### Asset richiesti da Apple

| Asset | Dimensioni | Note |
|---|---|---|
| Icona app | 1024×1024 px | PNG, no trasparenza, no angoli arrotondati |
| Screenshot iPhone 6.9" | 1320×2868 px | Obbligatorio (iPhone 16 Pro Max) |
| Screenshot iPhone 6.5" | 1284×2778 px | Obbligatorio (iPhone 12/13/14 Plus) |
| Screenshot iPad 12.9" | 2048×2732 px | Se supporti iPad |
| Preview video | 15-30s, 1080p | Opzionale ma consigliato |

### Metadati richiesti

```markdown
## Informazioni App Store (preparare prima della submission)

**Nome app**: [max 30 caratteri]
**Sottotitolo**: [max 30 caratteri — keyword rich]
**Categoria**: [principale + secondaria opzionale]
**Prezzo**: Gratuita / [prezzo]
**Disponibilità**: Tutti i paesi / [lista paesi]

**Descrizione** (max 4000 caratteri):
[Paragrafo 1: cosa fa l'app in 2-3 frasi]
[Paragrafo 2: funzionalità principali]
[Paragrafo 3: per chi è]

**Parole chiave** (max 100 caratteri totali, separate da virgola):
[keyword1, keyword2, ...]

**URL supporto**: [url/support o email]
**URL privacy policy**: [URL obbligatorio]
**URL marketing**: [opzionale]

**Nota per revisori Apple**:
Account demo: email@test.com / password: TestPass123
[Istruzioni per testare le funzionalità principali]
[Spiega eventuali funzionalità non ovvie]

**Classificazione età**: [4+ / 9+ / 12+ / 17+]
[Compila il questionario sul contenuto]
```

### Processo submission iOS

```bash
# 1. Build produzione
eas build --profile production --platform ios

# 2. Submit automatico su TestFlight
eas submit --platform ios --latest

# 3. Su App Store Connect:
#    - Vai su TestFlight → aspetta elaborazione (~10 min)
#    - Aggiungi tester interni → distribuisci per test
#    - Quando pronto: App Store → New Version → seleziona build
#    - Compila tutti i metadati
#    - Submit for Review → attendi approvazione (1-3 giorni)
```

### Motivi comuni di rejection Apple (e come evitarli)

| Motivo | Come evitare |
|---|---|
| Privacy policy mancante | Aggiungi sempre URL privacy policy |
| Login richiesto senza account demo | Fornisci account test nelle note per revisori |
| Crash durante revisione | Testa su dispositivo fisico, non solo simulator |
| Funzionalità descritta non funzionante | Verifica che TUTTO quello scritto nella descrizione funzioni |
| Uso improprio di API Apple | Richiedi solo i permessi che usi davvero |
| Design non conforme alle HIG | Usa componenti nativi, segui Human Interface Guidelines |

---

## GOOGLE PLAY STORE Android

### Prerequisiti (da fare una sola volta)
1. **Google Play Developer Account**: play.google.com/apps/publish — $25 una tantum
2. **Crea app** nella Play Console
3. **Service Account** per submission automatica con EAS

### Asset richiesti da Google

| Asset | Dimensioni | Note |
|---|---|---|
| Icona hi-res | 512×512 px | PNG, 32-bit |
| Feature graphic | 1024×500 px | Obbligatoria |
| Screenshot (min 2) | min 320px | Max 8 screenshot per tipo |
| Screenshot tablet (7") | 1024×600 px | Consigliato |

### Metadati Play Store

```markdown
## Play Store Listing

**Titolo**: [max 30 caratteri]
**Breve descrizione**: [max 80 caratteri — visibile nella lista]
**Descrizione completa**: [max 4000 caratteri]

**Categoria**: [seleziona da lista Google]
**Tipo**: App / Gioco
**Tag**: [aggiungi fino a 5 tag]

**Privacy policy URL**: [obbligatorio]
**Email contatto**: [obbligatorio]
**Website**: [opzionale]

**Classificazione contenuti**: [compila il questionario]
**Dichiarazione pubblicità**: [dichiarazione se c'è pubblicità]
```

### Processo submission Android

```bash
# 1. Build App Bundle (formato preferito da Google)
eas build --profile production --platform android

# 2. Submit su internal testing track
eas submit --platform android --latest

# 3. Sulla Play Console:
#    - Testing → Internal testing → verifica build
#    - Aggiungi tester (email) → distribuisci
#    - Quando pronto: Production → Create new release → seleziona build
#    - Compila roll-out (inizia con 10-20% per safety)
#    - Submit for review → approvazione in 24-72h
```

### Dichiarazioni obbligatorie Play Store

```
□ Privacy Policy URL: [inserisci]
□ Data Safety Form: dichiara quali dati raccogli e perché
   - Dati account: [sì/no] → [perché]
   - Dati posizione: [sì/no]
   - Info finanziarie: [sì/no — se hai pagamenti]
   - Contatti: [sì/no]
□ Target audience: [età minima, adulti]
□ App content rating: [compila questionario IARC]
□ Dichiarazione pubblicità: [usi ads?]
```

---

## OTA UPDATES — Aggiornamenti senza App Store

Con Expo Updates puoi aggiornare il JS/assets senza passare per App Store/Play Store (solo cambio logica, non codice nativo).

```bash
# Pubblica update OTA
eas update --branch production --message "Fix: bottone login"
# L'app scarica l'update al prossimo avvio
```

**Quando DEVI fare una nuova submission (non basta OTA):**
- Aggiungi una libreria nativa
- Cambi icona, nome app, bundle ID
- Modifichi `app.json` in sezioni native
- Aggiungi/rimuovi permessi

---

## CHECKLIST APP STORE READY

### Pre-build
- [ ] `app.json`: bundleIdentifier iOS e package Android corretti
- [ ] Icona 1024×1024 px preparata (niente trasparenza)
- [ ] Splash screen preparato
- [ ] `.env` con valori produzione impostati
- [ ] `eas.json` configurato con profile production

### Pre-submission (entrambi i store)
- [ ] Privacy policy URL online e accessibile
- [ ] Account demo funzionante per i revisori
- [ ] Screenshot di ogni schermata principale (min 2, max 8)
- [ ] Descrizione scritta (tradotta nelle lingue target)
- [ ] Parole chiave (App Store) o tag (Play Store) scelti
- [ ] Classificazione età/contenuti completata

### iOS specifico
- [ ] Apple Developer Account attivo ($99/anno)
- [ ] Build caricata su TestFlight
- [ ] Testata su min 2 dispositivi fisici diversi
- [ ] Note per revisori Apple scritte (account demo + istruzioni)
- [ ] Human Interface Guidelines rispettate

### Android specifico
- [ ] Google Play Developer Account attivo ($25 una tantum)
- [ ] App Bundle (.aab) generato (non .apk)
- [ ] Data Safety Form completata
- [ ] Testata su min Android 8+ (API 26+)
- [ ] Feature graphic 1024×500 preparata

### Post-submission
- [ ] Monitoraggio crash con Sentry o Expo Crashlytics
- [ ] Risposta alle review degli utenti
- [ ] Piano aggiornamenti (minimo 1 update/mese per mantenere ranking)
