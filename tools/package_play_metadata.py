"""Create five localized Google Play listings and a fastlane import tree."""
from pathlib import Path
import json
import zipfile
import unicodedata

ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / 'output' / 'google-play-localized-metadata'
DEST.mkdir(parents=True, exist_ok=True)

LISTINGS = [{'language': 'en-US',
  'title': 'Saving Goals: Budgeting Tool',
  'shortDescription': 'Set savings goals, log deposits, and see your progress grow.',
  'fullDescription': 'Give every dollar a purpose. Saving Goals is a savings tracker that helps you set '
                     'a target, record money saved, and see how far you have come.\n'
                     '\n'
                     'Whether you are building an emergency fund, saving for a vacation, or planning '
                     'your next purchase, keep your savings goals in one place. Add your own records as '
                     'you save in real life and watch each goal move forward.\n'
                     '\n'
                     'SET A CLEAR SAVINGS GOAL\n'
                     'Choose a goal name, target amount, and target date. Track more than one goal and '
                     'see what is saved and what is left.\n'
                     '\n'
                     'RECORD EACH SMALL STEP\n'
                     'Add savings and withdrawals with an optional note and date. Readable amounts and '
                     'a preview of your updated balance help you check an entry before saving it.\n'
                     '\n'
                     'FIND YOUR SAVING PACE\n'
                     'View a suggested daily, weekly, or monthly saving pace based on your goal. '
                     'Progress rings, milestones, and saving streaks help make your efforts visible. '
                     'Suggestions are estimates, not financial advice or promises of results.\n'
                     '\n'
                     'LOOK BACK AT YOUR PROGRESS\n'
                     'Review deposits and withdrawals in your activity history. See monthly savings '
                     'totals and a deposits chart to understand how your recorded progress adds up.\n'
                     '\n'
                     'BUILD A HABIT YOUR WAY\n'
                     'Set an optional daily reminder. Choose light, dark, or black appearance and hide '
                     'balances when you want more privacy on screen.\n'
                     '\n'
                     'SHARE A SMALL WIN\n'
                     'Create a progress card when you want to celebrate a milestone. Amounts, '
                     'transaction dates, and notes stay off the card. Including the goal name is your '
                     'choice.\n'
                     '\n'
                     'YOUR RECORDS STAY ON YOUR DEVICE\n'
                     'No account is needed. Savings records are stored locally, with no '
                     'developer-operated cloud sync. The current app has no advertising or analytics '
                     'SDKs. Device backups depend on your operating-system settings; keep separate '
                     'records you need.\n'
                     '\n'
                     'Choose USD, GBP, EUR, or PKR display labels. Changing the currency label does not '
                     'convert balances. The app records entries you make; it does not hold money, '
                     'connect to your bank, or transfer funds.\n'
                     '\n'
                     'Language settings currently offer English and Urdu. Store-listing translations do '
                     'not add more in-app interface languages.\n'
                     '\n'
                     'Small steps. A clearer view of your savings.\n'
                     '\n'
                     'MAKE YOUR SAVINGS PLAN PRACTICAL\n'
                     '\n'
                     'Use this budgeting tool to plan money for individual savings goals rather than to '
                     'manage a complete household expense budget.\n'
                     '\n'
                     'Give a short-term purchase and a longer-term plan separate goals so each has a '
                     'clear target and its own progress view.\n'
                     '\n'
                     'A goal can represent a new laptop, study materials, a trip, or money set aside '
                     'for an unexpected cost.\n'
                     '\n'
                     'Open a goal when you want a closer look at its target date, saved balance, '
                     'remaining amount, and recent activity.\n'
                     '\n'
                     'If you take money out of a goal, add a withdrawal so the saved balance continues '
                     'to reflect your own records.\n'
                     '\n'
                     'Use an optional note to add context, such as where a contribution came from or '
                     'why you recorded a withdrawal.\n'
                     '\n'
                     'Check the date and amount on each entry to keep your savings history useful when '
                     'you look back later.\n'
                     '\n'
                     'The balance preview lets you see the effect of an entry before it becomes part of '
                     'your recorded history.\n'
                     '\n'
                     'A target date gives your plan a timeframe, while the saving-pace view breaks the '
                     'remaining target into smaller amounts.\n'
                     '\n'
                     'Switch between daily, weekly, and monthly views to understand the suggested pace '
                     'in the format that suits your routine.\n'
                     '\n'
                     'Revisit your goal details when your plans change, and use the edit screen to '
                     'update the information you entered.\n'
                     '\n'
                     'Progress is based on your recorded amounts, so keeping entries accurate makes the '
                     'overview more useful.\n'
                     '\n'
                     'A progress card is optional: you can celebrate a milestone without publishing the '
                     'balance behind it.\n'
                     '\n'
                     'You choose the destination in your device share sheet; the app does not '
                     'automatically post to social media.\n'
                     '\n'
                     'Turning on a reminder schedules a local notification on your device at the time '
                     'you choose.\n'
                     '\n'
                     'You can turn reminders off when you prefer to check your goals without a daily '
                     'prompt.\n'
                     '\n'
                     'Website: https://savingsgoals.site/\n'
                     'Privacy: https://savingsgoals.site/privacy-policy.html\n'
                     'Support: info@savingsgoals.site'},
 {'language': 'en-GB',
  'title': 'Saving Goals: Savings Tracker',
  'shortDescription': 'Set savings goals, log deposits, and see your progress grow.',
  'fullDescription': 'Give every pound a purpose. Saving Goals is a savings tracker that helps you set '
                     'a target, record money saved, and see how far you have come.\n'
                     '\n'
                     'Whether you are building an emergency fund, saving for a holiday, or planning '
                     'your next purchase, organise your savings goals in one place. Add your own '
                     'records as you save in real life and follow each goal as it grows.\n'
                     '\n'
                     'SET A CLEAR SAVINGS GOAL\n'
                     'Choose a goal name, target amount, and target date. Track several goals and see '
                     'what you have saved and how much is left to reach each target.\n'
                     '\n'
                     'RECORD EVERY CONTRIBUTION\n'
                     'Log savings and withdrawals with an optional note and date. Readable amounts and '
                     'a preview of your updated balance help you check each entry before saving it.\n'
                     '\n'
                     'PLAN YOUR SAVING PACE\n'
                     'View a suggested daily, weekly, or monthly saving pace based on your goal. '
                     'Progress rings, milestones, and saving streaks make your recorded progress easier '
                     'to see. Suggestions are estimates, not financial advice or guaranteed outcomes.\n'
                     '\n'
                     'REVIEW YOUR SAVINGS HISTORY\n'
                     'Look back at deposits and withdrawals in your activity history. Monthly savings '
                     'totals and a deposits chart show how your recorded contributions add up.\n'
                     '\n'
                     'MAKE IT YOUR OWN\n'
                     'Set an optional daily reminder, choose a light, dark, or black appearance, and '
                     'hide balances for more privacy on screen.\n'
                     '\n'
                     'SHARE A MILESTONE\n'
                     'Create a progress card to celebrate a small win. Amounts, transaction dates, and '
                     'notes are excluded. You decide whether to include the goal name and where to '
                     'share the card.\n'
                     '\n'
                     'KEEP RECORDS ON YOUR DEVICE\n'
                     'No account is required. Savings records are stored locally, without '
                     'developer-operated cloud sync. The current app has no advertising or analytics '
                     'SDKs. Operating-system backups depend on your device settings; keep separate '
                     'records you need.\n'
                     '\n'
                     'Select GBP, USD, EUR, or PKR display labels. Currency changes update labels and '
                     'do not convert balances. This app tracks the amounts you enter; it does not hold '
                     'money, connect to a bank, or move funds.\n'
                     '\n'
                     'Language settings currently offer English and Urdu. Translated store text does '
                     'not add further in-app interface languages.\n'
                     '\n'
                     'Small steps. A clearer view of your savings.\n'
                     '\n'
                     'MAKE YOUR SAVINGS PLAN PRACTICAL\n'
                     '\n'
                     'Give a short-term purchase and a longer-term plan separate goals so each has a '
                     'clear target and its own progress view.\n'
                     '\n'
                     'A goal can represent a new laptop, study materials, a trip, or money set aside '
                     'for an unexpected cost.\n'
                     '\n'
                     'Choose names that mean something to you, so your list reflects your own '
                     'priorities instead of a fixed set of categories.\n'
                     '\n'
                     'Open a goal when you want a closer look at its target date, saved balance, '
                     'remaining amount, and recent activity.\n'
                     '\n'
                     'Record a contribution after you have actually set money aside; the entry is a '
                     'record of your action, not an automatic transfer.\n'
                     '\n'
                     'If you take money out of a goal, add a withdrawal so the saved balance continues '
                     'to reflect your own records.\n'
                     '\n'
                     'Use an optional note to add context, such as where a contribution came from or '
                     'why you recorded a withdrawal.\n'
                     '\n'
                     'Check the date and amount on each entry to keep your savings history useful when '
                     'you look back later.\n'
                     '\n'
                     'The balance preview lets you see the effect of an entry before it becomes part of '
                     'your recorded history.\n'
                     '\n'
                     'A target date gives your plan a timeframe, while the saving-pace view breaks the '
                     'remaining target into smaller amounts.\n'
                     '\n'
                     'Switch between daily, weekly, and monthly views to understand the suggested pace '
                     'in the format that suits your routine.\n'
                     '\n'
                     'Revisit your goal details when your plans change, and use the edit screen to '
                     'update the information you entered.\n'
                     '\n'
                     'Progress is based on your recorded amounts, so keeping entries accurate makes the '
                     'overview more useful.\n'
                     '\n'
                     'Your activity view puts contributions and withdrawals together, with separate '
                     'filters when you want to focus on one type.\n'
                     '\n'
                     'A progress card is optional: you can celebrate a milestone without publishing the '
                     'balance behind it.\n'
                     '\n'
                     'Website: https://savingsgoals.site/\n'
                     'Privacy: https://savingsgoals.site/privacy-policy.html\n'
                     'Support: info@savingsgoals.site'},
 {'language': 'de-DE',
  'title': 'Saving Goals: Sparziele',
  'shortDescription': 'Sparziele planen, Summen erfassen und Fortschritte verfolgen',
  'fullDescription': 'Gib deinem Ersparten ein klares Ziel. Mit Saving Goals legst du Sparziele fest, '
                     'erfasst zurückgelegte Beträge und siehst, wie viel bis zu deinem Wunschbetrag '
                     'noch fehlt.\n'
                     '\n'
                     'Ob Notgroschen, Urlaub oder eine größere Anschaffung: Behalte mehrere Sparziele '
                     'an einem Ort im Blick. Du sparst im Alltag und trägst deine Beträge selbst in die '
                     'App ein.\n'
                     '\n'
                     'SPARZIELE FESTLEGEN\n'
                     'Gib jedem Ziel einen Namen, einen Zielbetrag und ein Zieldatum. Sieh auf einen '
                     'Blick, wie viel du bereits gespart hast und welcher Betrag noch offen ist.\n'
                     '\n'
                     'EINZAHLUNGEN UND ENTNAHMEN ERFASSEN\n'
                     'Halte deine Sparbeträge und Entnahmen mit Datum und optionaler Notiz fest. Gut '
                     'lesbare Beträge und eine Vorschau des neuen Stands helfen dir, Einträge vor dem '
                     'Speichern zu prüfen.\n'
                     '\n'
                     'DEIN SPARTEMPO FINDEN\n'
                     'Sieh einen vorgeschlagenen täglichen, wöchentlichen oder monatlichen Sparbetrag '
                     'für dein Ziel. Fortschrittsringe, Meilensteine und Sparserien machen deine '
                     'Schritte sichtbar. Die Vorschläge sind Schätzungen, keine Finanzberatung oder '
                     'Erfolgsgarantie.\n'
                     '\n'
                     'VERLAUF IM BLICK BEHALTEN\n'
                     'Prüfe Einzahlungen und Entnahmen im Aktivitätsverlauf. Monatliche Übersichten und '
                     'ein Diagramm deiner Einzahlungen zeigen, wie sich deine erfassten Sparbeträge '
                     'entwickeln.\n'
                     '\n'
                     'PASSEND ZU DEINEM ALLTAG\n'
                     'Aktiviere bei Bedarf eine tägliche Erinnerung. Wähle eine helle, dunkle oder '
                     'schwarze Darstellung und blende Beträge auf dem Bildschirm aus, wenn du mehr '
                     'Privatsphäre möchtest.\n'
                     '\n'
                     'FORTSCHRITTE TEILEN\n'
                     'Erstelle eine Karte für einen erreichten Meilenstein. Geldbeträge, Buchungsdaten '
                     'und Notizen erscheinen nicht auf der Karte. Du entscheidest, ob der Zielname '
                     'enthalten ist und wo du die Karte teilst.\n'
                     '\n'
                     'LOKALE DATEN, OHNE KONTO\n'
                     'Deine Sparaufzeichnungen bleiben auf deinem Gerät. Es gibt keine vom Anbieter '
                     'betriebene Cloud-Synchronisierung. Die aktuelle App enthält keine Werbung oder '
                     'Analyse-SDKs. Gerätesicherungen richten sich nach deinen Systemeinstellungen; '
                     'bewahre wichtige Aufzeichnungen zusätzlich auf.\n'
                     '\n'
                     'Wähle EUR, USD, GBP oder PKR als Währungsanzeige. Ein Wechsel ändert nur die '
                     'Beschriftung und rechnet keine Beträge um. Die App verwahrt kein Geld, verbindet '
                     'sich nicht mit deiner Bank und führt keine Überweisungen aus.\n'
                     '\n'
                     'Die App bietet derzeit Spracheinstellungen für Englisch und Urdu. Dieser deutsche '
                     'Store-Text bedeutet nicht, dass die App-Oberfläche auf Deutsch verfügbar ist.\n'
                     '\n'
                     'SPARZIELE IM ALLTAG NUTZEN\n'
                     '\n'
                     'Dieses Budgeting Tool hilft dir bei einzelnen Sparzielen und ersetzt keine '
                     'vollständige Haushaltsbuchführung mit Ausgabenkategorien.\n'
                     '\n'
                     'Lege kurzfristige Wünsche und längerfristige Vorhaben als eigene Ziele an, damit '
                     'jeder Plan einen klaren Bezugspunkt hat.\n'
                     '\n'
                     'Ein Ziel kann für einen Laptop, Lernmaterial, eine Reise oder eine Rücklage für '
                     'unerwartete Kosten stehen.\n'
                     '\n'
                     'Öffne ein Ziel, um Zieltermin, gesparten Betrag, Restbetrag und letzte Einträge '
                     'genauer anzusehen.\n'
                     '\n'
                     'Erfasse eine Einzahlung, nachdem du tatsächlich Geld zurückgelegt hast: Der '
                     'Eintrag dokumentiert den Schritt und bewegt kein Geld.\n'
                     '\n'
                     'Wenn du Geld aus einer Rücklage verwendest, hält ein Entnahme-Eintrag deinen '
                     'erfassten Stand nachvollziehbar.\n'
                     '\n'
                     'Mit einer freiwilligen Notiz kannst du den Anlass einer Einzahlung oder den Grund '
                     'einer Entnahme festhalten.\n'
                     '\n'
                     'Prüfe Datum und Betrag, damit der Verlauf auch bei einem späteren Blick auf deine '
                     'Aufzeichnungen verständlich bleibt.\n'
                     '\n'
                     'Ein Zieldatum gibt deinem Vorhaben einen zeitlichen Rahmen; die Sparansicht teilt '
                     'den offenen Betrag in kleinere Schritte auf.\n'
                     '\n'
                     'Wechsle zwischen Tages-, Wochen- und Monatsansicht, um den vorgeschlagenen '
                     'Sparbetrag passend zu deinem Alltag zu betrachten.\n'
                     '\n'
                     'Wenn sich deine Pläne ändern, kannst du die selbst eingegebenen Angaben auf der '
                     'Bearbeitungsseite anpassen.\n'
                     '\n'
                     'Im Aktivitätsverlauf stehen Einzahlungen und Entnahmen zusammen; mit Filtern '
                     'betrachtest du gezielt einen der beiden Typen.\n'
                     '\n'
                     'Eine Fortschrittskarte ist freiwillig und zeigt keine Geldbeträge aus deinen '
                     'Sparaufzeichnungen.\n'
                     '\n'
                     'Website: https://savingsgoals.site/\n'
                     'Datenschutz: https://savingsgoals.site/privacy-policy.html\n'
                     'Kontakt: info@savingsgoals.site'},
 {'language': 'it-IT',
  'title': 'Saving Goals: Risparmio',
  'shortDescription': 'Crea obiettivi, registra i risparmi e segui i tuoi progressi',
  'fullDescription': 'Dai uno scopo ai tuoi risparmi. Saving Goals ti aiuta a fissare un obiettivo, '
                     'registrare il denaro messo da parte e vedere quanto manca al traguardo.\n'
                     '\n'
                     'Un fondo per gli imprevisti, una vacanza o un nuovo acquisto: tieni i tuoi '
                     'obiettivi di risparmio in un unico posto. Risparmia nella vita di tutti i giorni '
                     'e aggiungi manualmente i tuoi importi nell’app.\n'
                     '\n'
                     'SCEGLI UN OBIETTIVO CHIARO\n'
                     'Imposta nome, importo da raggiungere e data prevista. Segui più obiettivi e '
                     'controlla quanto hai già risparmiato e quanto resta da mettere da parte.\n'
                     '\n'
                     'REGISTRA OGNI PASSO\n'
                     'Aggiungi risparmi e prelievi con data e nota facoltativa. Gli importi leggibili e '
                     'l’anteprima del nuovo saldo ti aiutano a verificare ogni registrazione prima di '
                     'salvarla.\n'
                     '\n'
                     'TROVA IL TUO RITMO\n'
                     'Consulta un importo di risparmio suggerito per giorno, settimana o mese. '
                     'Indicatori di avanzamento, traguardi intermedi e serie di giorni di risparmio '
                     'rendono visibili i tuoi progressi. I suggerimenti sono stime, non consulenza '
                     'finanziaria né garanzie di risultato.\n'
                     '\n'
                     'CONSULTA LA CRONOLOGIA\n'
                     'Rivedi versamenti e prelievi nel registro delle attività. I totali mensili e il '
                     'grafico dei versamenti mostrano come si sommano gli importi registrati.\n'
                     '\n'
                     'PERSONALIZZA LA TUA ESPERIENZA\n'
                     'Attiva un promemoria giornaliero facoltativo. Scegli il tema chiaro, scuro o nero '
                     'e nascondi i saldi per una maggiore riservatezza sullo schermo.\n'
                     '\n'
                     'CONDIVIDI UN TRAGUARDO\n'
                     'Crea una scheda con i tuoi progressi. Importi, date delle operazioni e note non '
                     'vengono inclusi. Decidi tu se mostrare il nome dell’obiettivo e dove condividere '
                     'la scheda.\n'
                     '\n'
                     'DATI SUL TUO DISPOSITIVO\n'
                     'Non serve un account. I dati dei risparmi sono conservati localmente, senza '
                     'sincronizzazione cloud gestita dal fornitore. La versione attuale non contiene '
                     'pubblicità o SDK di analisi. I backup dipendono dalle impostazioni del sistema '
                     'operativo: conserva a parte le registrazioni importanti.\n'
                     '\n'
                     'Puoi scegliere EUR, USD, GBP o PKR come valuta visualizzata. Cambiare valuta '
                     'modifica soltanto l’etichetta, senza convertire gli importi. L’app non custodisce '
                     'denaro, non si collega alla banca e non trasferisce fondi.\n'
                     '\n'
                     'Le impostazioni linguistiche dell’app offrono attualmente inglese e urdu. La '
                     'traduzione di questa scheda non rende l’interfaccia dell’app disponibile in '
                     'italiano.\n'
                     '\n'
                     'IL TUO PIANO NELLA VITA QUOTIDIANA\n'
                     '\n'
                     'Questo budgeting tool ti aiuta a pianificare singoli obiettivi di risparmio e non '
                     'sostituisce un bilancio completo delle spese familiari.\n'
                     '\n'
                     'Un obiettivo può rappresentare un computer, materiale di studio, un viaggio o una '
                     'riserva per un imprevisto.\n'
                     '\n'
                     'Scegli nomi che abbiano significato per te, senza adattare i tuoi progetti a un '
                     'elenco fisso di categorie.\n'
                     '\n'
                     'Apri un obiettivo per vedere più da vicino la data prevista, il saldo registrato, '
                     'l’importo restante e le attività recenti.\n'
                     '\n'
                     'Se utilizzi una parte della riserva, aggiungi un prelievo per mantenere il saldo '
                     'coerente con le tue registrazioni.\n'
                     '\n'
                     'Una nota facoltativa può spiegare l’origine di un contributo oppure il motivo di '
                     'un prelievo.\n'
                     '\n'
                     'Controlla la data e l’importo per rendere la cronologia utile anche quando la '
                     'consulterai in seguito.\n'
                     '\n'
                     'L’anteprima del saldo mostra l’effetto di una registrazione prima che venga '
                     'aggiunta alla cronologia.\n'
                     '\n'
                     'La data prevista dà un orizzonte al progetto e il ritmo suggerito suddivide '
                     'l’importo restante in passi più piccoli.\n'
                     '\n'
                     'Quando cambiano i tuoi progetti, torna ai dettagli e modifica le informazioni '
                     'inserite nella schermata di modifica.\n'
                     '\n'
                     'I progressi dipendono dagli importi registrati: tenere aggiornate le voci rende '
                     'il riepilogo più utile.\n'
                     '\n'
                     'La cronologia riunisce versamenti e prelievi e permette di concentrarsi su un '
                     'solo tipo con i filtri dedicati.\n'
                     '\n'
                     'La scheda dei progressi è facoltativa: puoi condividere un traguardo senza '
                     'pubblicare il saldo del tuo obiettivo.\n'
                     '\n'
                     'Scegli la destinazione nel menu di condivisione del dispositivo; l’app non '
                     'pubblica automaticamente sui social.\n'
                     '\n'
                     'Sito: https://savingsgoals.site/\n'
                     'Privacy: https://savingsgoals.site/privacy-policy.html\n'
                     'Assistenza: info@savingsgoals.site'},
 {'language': 'hi-IN',
  'title': 'Saving Goals: बचत ट्रैकर',
  'shortDescription': 'बचत लक्ष्य बनाएँ, जमा और निकासी दर्ज करें, अपनी प्रगति देखें',
  'fullDescription': 'अपनी बचत को एक स्पष्ट मकसद दें। Saving Goals में बचत का लक्ष्य तय करें, बचाए गए '
                     'पैसे दर्ज करें और देखें कि लक्ष्य तक पहुँचने में कितनी रकम बाकी है।\n'
                     '\n'
                     'चाहे इमरजेंसी फंड बनाना हो, छुट्टियों के लिए बचाना हो या कोई जरूरी चीज खरीदनी हो, '
                     'अपने बचत के लक्ष्यों को एक जगह रखें। आप असल जिंदगी में पैसे बचाते हैं और ऐप में '
                     'उनका रिकॉर्ड खुद जोड़ते हैं।\n'
                     '\n'
                     'अपना बचत लक्ष्य बनाएँ\n'
                     'लक्ष्य का नाम, कुल रकम और तारीख तय करें। कई लक्ष्य रखें और हर लक्ष्य के लिए बचाई '
                     'गई और बाकी रकम देखें।\n'
                     '\n'
                     'जमा और निकासी का रिकॉर्ड रखें\n'
                     'बचत में जोड़े गए पैसे और निकाली गई रकम को तारीख और वैकल्पिक नोट के साथ दर्ज करें। '
                     'साफ दिखने वाली रकम और नए बैलेंस का प्रीव्यू सेव करने से पहले एंट्री जाँचने में '
                     'मदद करते हैं।\n'
                     '\n'
                     'बचत की रफ्तार समझें\n'
                     'अपने लक्ष्य के अनुसार रोजाना, हर हफ्ते या हर महीने बचाने की सुझाई गई रकम देखें। '
                     'प्रगति का घेरा, पड़ाव और लगातार बचत वाले दिनों का रिकॉर्ड आपकी मेहनत दिखाते हैं। '
                     'ये सुझाव अनुमान हैं, वित्तीय सलाह या नतीजे की गारंटी नहीं।\n'
                     '\n'
                     'अपनी प्रगति पर नजर रखें\n'
                     'एक्टिविटी हिस्ट्री में जमा और निकासी देखें। महीने के कुल आँकड़े और जमा का चार्ट '
                     'बताते हैं कि आपकी दर्ज की गई बचत कैसे बढ़ रही है।\n'
                     '\n'
                     'अपने हिसाब से इस्तेमाल करें\n'
                     'चाहें तो रोजाना का रिमाइंडर लगाएँ। लाइट, डार्क या ब्लैक थीम चुनें। स्क्रीन पर '
                     'ज्यादा प्राइवेसी के लिए बैलेंस छिपाएँ।\n'
                     '\n'
                     'छोटी जीत साझा करें\n'
                     'अपनी प्रगति का शेयर करने योग्य कार्ड बनाएँ। रकम, लेन-देन की तारीखें और नोट कार्ड '
                     'में शामिल नहीं होते। लक्ष्य का नाम दिखाना है या नहीं और कार्ड कहाँ शेयर करना है, '
                     'यह आप तय करते हैं।\n'
                     '\n'
                     'आपका रिकॉर्ड आपके डिवाइस पर\n'
                     'अकाउंट बनाने की जरूरत नहीं। बचत के रिकॉर्ड डिवाइस पर रहते हैं; डेवलपर की क्लाउड '
                     'सिंक सेवा नहीं है। मौजूदा ऐप में विज्ञापन या एनालिटिक्स SDK नहीं हैं। बैकअप आपके '
                     'फोन की सिस्टम सेटिंग पर निर्भर करते हैं। जरूरी रिकॉर्ड की अलग कॉपी रखें।\n'
                     '\n'
                     'करेंसी लेबल में USD, GBP, EUR या PKR चुन सकते हैं। INR लेबल अभी उपलब्ध नहीं है। '
                     'लेबल बदलने से रकम का करेंसी कन्वर्जन नहीं होता। ऐप पैसे नहीं रखता, बैंक से कनेक्ट '
                     'नहीं होता और पैसे ट्रांसफर नहीं करता।\n'
                     '\n'
                     'ऐप की भाषा सेटिंग में अभी अंग्रेजी और उर्दू हैं। यह हिंदी स्टोर विवरण ऐप के अंदर '
                     'हिंदी इंटरफेस उपलब्ध होने का दावा नहीं करता।\n'
                     '\n'
                     'अपनी बचत योजना को रोजमर्रा में इस्तेमाल करें\n'
                     '\n'
                     'यह बजट बनाने का टूल अलग-अलग बचत लक्ष्यों की योजना के लिए है, पूरे घर के रोजाना '
                     'खर्च और आय का बजट बनाने के लिए नहीं।\n'
                     '\n'
                     'जल्दी पूरा होने वाला लक्ष्य और लंबी अवधि का सपना अलग रखें, ताकि दोनों की रकम और '
                     'प्रगति आसानी से समझ आए।\n'
                     '\n'
                     'लैपटॉप, पढ़ाई की सामग्री, यात्रा या अचानक आने वाली जरूरत के लिए अलग लक्ष्य बना '
                     'सकते हैं।\n'
                     '\n'
                     'लक्ष्य का ऐसा नाम रखें जो आपके लिए मायने रखता हो। आपको किसी तय कैटेगरी के अनुसार '
                     'अपना सपना बदलने की जरूरत नहीं।\n'
                     '\n'
                     'किसी लक्ष्य को खोलकर उसकी तारीख, दर्ज की गई बचत, बाकी रकम और हाल की एक्टिविटी '
                     'देखें।\n'
                     '\n'
                     'बचत में से रकम इस्तेमाल हो जाए तो निकासी दर्ज करें, ताकि ऐप का बैलेंस आपकी अपनी '
                     'एंट्री से मेल खाए।\n'
                     '\n'
                     'वैकल्पिक नोट में लिख सकते हैं कि पैसे कहाँ से आए या निकासी किस वजह से दर्ज की '
                     'गई।\n'
                     '\n'
                     'हर एंट्री की रकम और तारीख जाँचें, ताकि बाद में रिकॉर्ड देखते समय पूरी बात समझ '
                     'आए।\n'
                     '\n'
                     'नए बैलेंस का प्रीव्यू बताता है कि सेव करने पर आपके दर्ज किए गए हिसाब में क्या '
                     'बदलाव होगा।\n'
                     '\n'
                     'लक्ष्य की तारीख योजना को समय देती है और सुझाई गई बचत की रफ्तार बाकी रकम को छोटे '
                     'कदमों में समझाती है।\n'
                     '\n'
                     'रोजाना, हफ्ते या महीने की व्यू चुनकर सुझाई गई रकम को अपनी दिनचर्या के हिसाब से '
                     'देखें।\n'
                     '\n'
                     'योजना बदलने पर लक्ष्य की डिटेल में वापस जाएँ और एडिट स्क्रीन में अपनी दर्ज की गई '
                     'जानकारी बदलें।\n'
                     '\n'
                     'प्रगति आपकी एंट्री पर आधारित है। इसलिए सही रिकॉर्ड रखने से लक्ष्य की तस्वीर '
                     'ज्यादा उपयोगी बनती है।\n'
                     '\n'
                     'एक्टिविटी में जमा और निकासी साथ दिखती हैं। अलग फिल्टर से केवल एक तरह की एंट्री पर '
                     'ध्यान दे सकते हैं।\n'
                     '\n'
                     'फोन के शेयर मेन्यू में आप जगह चुनते हैं। ऐप अपने आप सोशल मीडिया पर कुछ पोस्ट नहीं '
                     'करता।\n'
                     '\n'
                     'रिमाइंडर चालू करने पर चुने हुए समय के लिए आपके फोन पर लोकल नोटिफिकेशन तय होता '
                     'है।\n'
                     '\n'
                     'बैलेंस छिपाने का विकल्प केवल स्क्रीन की जानकारी छिपाता है। यह ऐप लॉक या अलग '
                     'एन्क्रिप्टेड वॉल्ट नहीं है।\n'
                     '\n'
                     'थीम बदलने पर आपके लक्ष्य और रिकॉर्ड वही रहते हैं। नया हिसाब शुरू करने की जरूरत '
                     'नहीं होती।\n'
                     '\n'
                     'डिवाइस पर सेव किया रिकॉर्ड देखने के लिए प्रोफाइल बनाना या क्लाउड सेवा में साइन इन '
                     'करना जरूरी नहीं।\n'
                     '\n'
                     'वेबसाइट: https://savingsgoals.site/\n'
                     'प्राइवेसी: https://savingsgoals.site/privacy-policy.html\n'
                     'सहायता: info@savingsgoals.site'}]

KEYWORDS = {
    'en-US': ['savings goals', 'savings tracker', 'money saver', 'save money', 'savings app', 'savings goal tracker', 'emergency fund tracker', 'vacation savings', 'saving habits', 'savings progress'],
    'en-GB': ['savings goals', 'savings tracker', 'money saver', 'save money', 'savings app', 'holiday savings', 'emergency fund', 'saving plan', 'savings progress', 'saving habits'],
    'de-DE': ['Sparziele', 'Sparziel App', 'Geld sparen', 'Spartracker', 'Sparplan', 'Sparfortschritt', 'Notgroschen', 'Urlaub sparen', 'Sparbeträge erfassen', 'Spargewohnheiten'],
    'it-IT': ['obiettivi di risparmio', 'risparmiare soldi', 'app risparmio', 'monitorare risparmi', 'piano di risparmio', 'fondo emergenza', 'risparmiare per vacanze', 'progressi risparmio', 'versamenti e prelievi', 'abitudini di risparmio'],
    'hi-IN': ['बचत लक्ष्य', 'बचत ट्रैकर', 'पैसे बचाना', 'बचत ऐप', 'बचत का हिसाब', 'बचत की प्रगति', 'इमरजेंसी फंड', 'जमा और निकासी', 'बचत की आदत', 'savings goal tracker'],
}

report = {'packageName': 'com.savings.goals.app', 'nameBasis': 'Fixed brand Saving Goals; market-specific title suffix; Budgeting Tool retained for en-US.', 'limits': {'title': 30, 'shortDescription': 80, 'fullDescription': 4000}, 'locales': []}
review = ['# Savings Goals — Google Play copy', '', 'Five listing localizations. Package: `com.savings.goals.app`.', '', 'Saving Goals is unchanged in all titles. The suffix is localized by market; the US retains Budgeting Tool. Metadata edits do not rename the installed app.', '', 'Store descriptions are translated; the app itself currently offers English and Urdu language settings. Hindi copy explicitly notes that INR is not yet supported.', '']
for listing in LISTINGS:
    listing = {k: unicodedata.normalize('NFC', v) for k, v in listing.items()}
    language = listing['language']
    counts = {key: len(listing[key]) for key in ['title', 'shortDescription', 'fullDescription']}
    utf16 = {key: len(listing[key].encode('utf-16-le')) // 2 for key in counts}
    for field, limit in report['limits'].items():
        assert counts[field] <= limit and utf16[field] <= limit, (language, field, counts[field], limit)
    assert counts['shortDescription'] == 60, (language, 'shortDescription', counts['shortDescription'])
    assert counts['fullDescription'] == 4000, (language, 'fullDescription', counts['fullDescription'])
    assert set(listing) == {'language', 'title', 'shortDescription', 'fullDescription'}
    assert 'com.savingsgoals.site' not in json.dumps(listing)
    json_dir = DEST / 'listings-json'
    json_dir.mkdir(exist_ok=True)
    (json_dir / f'{language}.json').write_text(json.dumps(listing, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    metadata = DEST / 'fastlane' / 'metadata' / 'android' / language
    metadata.mkdir(parents=True, exist_ok=True)
    for field, filename in [('title', 'title.txt'), ('shortDescription', 'short_description.txt'), ('fullDescription', 'full_description.txt')]:
        (metadata / filename).write_text(listing[field], encoding='utf-8')
    report['locales'].append({'language': language, 'characters': counts, 'utf16Units': utf16, 'valid': True})
    review += [f'## {language}', '', f'**Title:** {listing["title"]}', '', f'**Short description:** {listing["shortDescription"]}', '', listing['fullDescription'], '', f'Character counts: title {counts["title"]}/30; short description {counts["shortDescription"]}/80; full description {counts["fullDescription"]}/4000.', '']
(DEST / 'COPY-REVIEW.md').write_text('\n'.join(review), encoding='utf-8')
(DEST / 'validation.json').write_text(json.dumps(report, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')

research = ['# Keyword selection', '', 'Keywords are research notes, not an extra Google Play upload field. Relevant phrases are integrated naturally into the listing copy. No ranking or conversion outcome is guaranteed.', '', '## What the pasted report actually supports', '', 'The screenshot text names a different listing, "Money Saver: Spending Tracker". Its positions and ratings are not evidence about Savings Goals. It shows only page 1 (50 rows), although its header says 80 tracked keywords. No second-page metrics were supplied.', '', '| Relevant term in supplied US report | Traffic | Difficulty | Reported KEI |', '|---|---:|---:|---:|', '| savings tracker | 56 | 37 | 1.51 |', '| savings app | 50 | 33 | 1.52 |', '| savings goal | 54 | 45 | 1.20 |', '| Money Saver | 36 | 39 | 0.92 |', '', 'These are third-party figures pasted by the user, not independently verified Google Play search volumes. The source platform/store basis was not established. Use them as directional context, not Google Play rank evidence.', '', '## Terms deliberately excluded', '', 'Competitor names and brand variants such as SafeBudget and moneysaver go; subscription manager/cancel subscriptions; bill negotiator/lower bills; net worth tracker; debt payoff; accounting/ledger; bank sync; shared budgets; daily expense tracking. These either imply unimplemented features or attract a different intent. Currency exchange and INR support are not claimed.', '', '## Local keyword ideas', '', 'German, Italian and Hindi phrases below are localized relevance suggestions. No traffic, difficulty, or rank has been measured for them. They are not a literal list to paste into the description.', '']
for language, words in KEYWORDS.items():
    research += [f'### {language}', '', ', '.join(words), '']
research += ['## After launch', '', 'Measure store-listing visitors, acquisition conversion and relevant search terms in your own Play Console. Test one meaningful title/short-description change at a time. Do not add keyword blocks or unsupported features to increase coverage.', '']
(DEST / 'KEYWORD-PLAN.md').write_text('\n'.join(research), encoding='utf-8')

fastfile = '''default_platform(:android)

platform :android do
  private_lane :listing_options do
    {
      package_name: "com.savings.goals.app",
      metadata_path: File.expand_path("metadata/android", __dir__),
      json_key: ENV.fetch("PLAY_JSON_KEY"),
      skip_upload_apk: true,
      skip_upload_aab: true,
      skip_upload_images: true,
      skip_upload_screenshots: true,
      skip_upload_changelogs: true,
      skip_upload_metadata: false,
      rescue_changes_not_sent_for_review: false
    }
  end

  desc "Validate the five localized listings with Google Play"
  lane :validate_metadata do
    upload_to_play_store(**listing_options.merge(validate_only: true))
  end

  desc "Upload listing text and leave it awaiting manual review submission"
  lane :upload_metadata do
    upload_to_play_store(**listing_options.merge(changes_not_sent_for_review: true))
  end
end
'''
(DEST / 'fastlane' / 'Fastfile').write_text(fastfile, encoding='utf-8')
readme = '''# Import the five Google Play listings

Locales: en-US, en-GB, de-DE, it-IT, hi-IN.
Package: com.savings.goals.app.
Fixed brand: Saving Goals in every locale. US suffix: Budgeting Tool. Other suffixes: Savings Tracker (UK), Sparziele (German), Risparmio (Italian), बचत ट्रैकर (Hindi). Contact: info@savingsgoals.site.

## What to use

- COPY-REVIEW.md: all five titles, short descriptions and full descriptions for review or copy/paste.
- listings-json/: five Google Play Developer API Listing JSON bodies. These contain only language, title, shortDescription and fullDescription. They are not a Play Console drag-and-drop JSON format.
- fastlane/metadata/android/: standard fastlane supply directories for importing all five languages together.
- KEYWORD-PLAN.md: keyword rationale and localized suggestions, kept out of the uploaded fields.
- validation.json: verified 30/80/4000 limits, including UTF-16 counts.

Google Play has no separate App Store-style subtitle/keyword field. Use the short description as the subtitle-equivalent. Do not upload keyword notes as listing descriptions. No metadata has been sent to Google Play by this task.

## Automatic import using fastlane

Prerequisites: create the correct app in Play Console and upload its first build manually. Install fastlane using its official setup instructions. Enable the Google Play Developer API and grant a service account access to this app and its store listing. Keep the credential file on your computer; do not include it in this ZIP or share it in chat.

Extract the ZIP. Open a terminal at this folder (the one containing fastlane/).
Set PLAY_JSON_KEY to the absolute path of your service-account JSON credential.

PowerShell:

    $env:PLAY_JSON_KEY = 'C:\\private\\google-play-service-account.json'
    fastlane android validate_metadata
    fastlane android upload_metadata

macOS shell:

    export PLAY_JSON_KEY="/absolute/private/google-play-service-account.json"
    fastlane android validate_metadata
    fastlane android upload_metadata

The first lane asks Google to validate the edit. The second updates listing text only and requests changes not be sent for review. It does not upload an APK/AAB, change images, screenshots, pricing or releases, or delete other languages. Existing text for these five locales will be replaced; export a copy from Play Console if you need the old versions. Review the staged changes in Play Console before submitting them. If the current app state does not support holding changes for review, the lane stops instead of silently submitting them.

These commands require your authentication and an existing Play app; the ZIP alone cannot automatically populate a signed-in browser. If you prefer the browser, open Grow users > Store presence > Main store listing > Manage translations > Select languages, add the five languages, and paste the corresponding three fields from COPY-REVIEW.md. This uses the documented manual route; a made-up CSV import schema is not included.

## API alternative

With an authenticated Google Play Developer API client, create an edit for com.savings.goals.app. For each language, PUT its JSON body to:
https://androidpublisher.googleapis.com/androidpublisher/v3/applications/com.savings.goals.app/edits/{editId}/listings/{language}
Validate the edit before committing. The Fastfile above is the simpler bundled option. Do not put keyword notes in this API body.

## Language and feature accuracy

These are store-listing translations, not changes to the app's UI languages. English and Urdu are the current in-app language settings. German, Italian and Hindi descriptions disclose this. The Hindi description also notes that INR is not currently offered. Currency selection changes display labels rather than converting balances. No banking, bill negotiation, subscription cancellation or general expense tracker features are claimed. No permanent-free promise or invented search-volume figures are included.

## References

Google Play fields and limits: https://support.google.com/googleplay/android-developer/answer/9859152?hl=en
Languages/manual translations: https://support.google.com/googleplay/android-developer/answer/9844778?hl=en
API Listing fields: https://developers.google.com/android-publisher/api-ref/rest/v3/edits.listings
fastlane supply and setup: https://docs.fastlane.tools/actions/supply/
'''
(DEST / 'IMPORT-INSTRUCTIONS.md').write_text(readme, encoding='utf-8')

# Round-trip checks ensure translations and exact field values survive packaging.
for locale in report['locales']:
    language = locale['language']
    parsed = json.loads((DEST / 'listings-json' / f'{language}.json').read_text(encoding='utf-8'))
    for key, file in [('title', 'title.txt'), ('shortDescription', 'short_description.txt'), ('fullDescription', 'full_description.txt')]:
        assert parsed[key] == (DEST / 'fastlane' / 'metadata' / 'android' / language / file).read_text(encoding='utf-8')
archive = ROOT / 'output' / 'savings-goals-google-play-five-languages.zip'
with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as z:
    for file in sorted(DEST.rglob('*')):
        if file.is_file():
            z.write(file, file.relative_to(DEST).as_posix())
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
print(json.dumps(report, ensure_ascii=False, indent=2))
print(f'Built and verified: {archive}')
