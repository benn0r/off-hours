"""Writes OffHours/Localizable.xcstrings and OffHours/InfoPlist.xcstrings from the tables below.

Run `python3 scripts/translations.py` after changing a translation, then build. New strings found by Xcode
(xcodebuild -exportLocalizations) must be added here as well, or they stay English.
"""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LANGS = ["fr", "it", "es", "nl"]

# key: (fr, it, es, nl)
T = {
    "%@ until %@": ("%1$@ jusqu'à %2$@", "%1$@ fino alle %2$@", "%1$@ hasta las %2$@", "%1$@ tot %2$@"),
    "%@ – %@": ("%1$@ – %2$@",) * 4,
    "%lld days, %@–%@": (
        "%1$lld jours, %2$@–%3$@",
        "%1$lld giorni, %2$@–%3$@",
        "%1$lld días, %2$@–%3$@",
        "%1$lld dagen, %2$@–%3$@",
    ),
    "%lld min": ("%lld min",) * 4,
    "1 day": ("1 jour", "1 giorno", "1 día", "1 dag"),
    "1 week": ("1 semaine", "1 settimana", "1 semana", "1 week"),
    "Add": ("Ajouter", "Aggiungi", "Añadir", "Voeg toe"),
    "Allow Screen Time access": (
        "Autoriser l'accès à Temps d'écran",
        "Consenti l'accesso a Tempo di utilizzo",
        "Permitir acceso a Tiempo de uso",
        "Geef toegang tot Schermtijd",
    ),
    "Allow calendar access": (
        "Autoriser l'accès aux calendriers",
        "Consenti l'accesso ai calendari",
        "Permitir acceso a los calendarios",
        "Geef toegang tot agenda's",
    ),
    "Allow work apps for 1 hour": (
        "Autoriser les apps pro pendant 1 heure",
        "Consenti le app di lavoro per 1 ora",
        "Permitir apps de trabajo durante 1 hora",
        "Werk-apps 1 uur toestaan",
    ),
    "Available at %@": ("Disponibles à %@", "Disponibili alle %@", "Disponibles a las %@", "Beschikbaar om %@"),
    "Available on %@ at %@": (
        "Disponibles %1$@ à %2$@",
        "Disponibili %1$@ alle %2$@",
        "Disponibles el %1$@ a las %2$@",
        "Beschikbaar op %1$@ om %2$@",
    ),
    "Available tomorrow at %@": (
        "Disponibles demain à %@",
        "Disponibili domani alle %@",
        "Disponibles mañana a las %@",
        "Morgen om %@ beschikbaar",
    ),
    "Block work apps for 1 hour": (
        "Bloquer les apps pro pendant 1 heure",
        "Blocca le app di lavoro per 1 ora",
        "Bloquear apps de trabajo durante 1 hora",
        "Werk-apps 1 uur blokkeren",
    ),
    "Blocked at %@": ("Bloquées à %@", "Bloccate alle %@", "Bloqueadas a las %@", "Geblokkeerd om %@"),
    "Blocked on %@ at %@": (
        "Bloquées %1$@ à %2$@",
        "Bloccate %1$@ alle %2$@",
        "Bloqueadas el %1$@ a las %2$@",
        "Geblokkeerd op %1$@ om %2$@",
    ),
    "Blocked tomorrow at %@": (
        "Bloquées demain à %@",
        "Bloccate domani alle %@",
        "Bloqueadas mañana a las %@",
        "Morgen om %@ geblokkeerd",
    ),
    "Calendar access was denied. Enable it in Settings › Privacy & Security › Calendars.": (
        "L'accès aux calendriers a été refusé. Activez-le dans Réglages › Confidentialité et sécurité › Calendriers.",
        "L'accesso ai calendari è stato negato. Attivalo in Impostazioni › Privacy e sicurezza › Calendari.",
        "Se denegó el acceso a los calendarios. Actívalo en Ajustes › Privacidad y seguridad › Calendarios.",
        "Toegang tot agenda's is geweigerd. Schakel het in via Instellingen › Privacy en beveiliging › Agenda's.",
    ),
    "Calendars": ("Calendriers", "Calendari", "Calendarios", "Agenda's"),
    "Calendars are read on this device only.": (
        "Les calendriers sont lus uniquement sur cet appareil.",
        "I calendari vengono letti solo su questo dispositivo.",
        "Los calendarios solo se leen en este dispositivo.",
        "Agenda's worden alleen op dit apparaat gelezen.",
    ),
    "Cancel": ("Annuler", "Annulla", "Cancelar", "Annuleer"),
    "Clear past days off": (
        "Effacer les congés passés",
        "Elimina i giorni liberi passati",
        "Borrar días libres pasados",
        "Wis eerdere vrije dagen",
    ),
    "Clear past shifts": (
        "Effacer les astreintes passées",
        "Elimina i turni passati",
        "Borrar guardias pasadas",
        "Wis eerdere piketdiensten",
    ),
    "Comma separated, not case sensitive. If a title matches both, it counts as on call.": (
        "Séparés par des virgules, sans tenir compte de la casse. Si un titre correspond aux deux, il compte comme astreinte.",
        "Separate da virgole, senza distinzione tra maiuscole e minuscole. Se un titolo corrisponde a entrambe, conta come reperibilità.",
        "Separadas por comas, sin distinguir mayúsculas. Si un título coincide con ambas, cuenta como guardia.",
        "Gescheiden door komma's, niet hoofdlettergevoelig. Past een titel bij beide, dan telt hij als piket.",
    ),
    "Copy Monday's hours to all workdays": (
        "Copier les horaires du lundi sur tous les jours ouvrés",
        "Copia l'orario del lunedì su tutti i giorni lavorativi",
        "Copiar el horario del lunes a todos los días laborables",
        "Kopieer de uren van maandag naar alle werkdagen",
    ),
    "Day off": ("Jour de congé", "Giorno libero", "Día libre", "Vrije dag"),
    "Day off: %@": ("Congé : %@", "Giorno libero: %@", "Día libre: %@", "Vrije dag: %@"),
    "Days off": ("Congés", "Giorni liberi", "Días libres", "Vrije dagen"),
    "Days off & holidays": (
        "Congés et jours fériés",
        "Giorni liberi e festivi",
        "Días libres y festivos",
        "Vrije dagen en feestdagen",
    ),
    "Edit these in your calendar.": (
        "Modifiez-les dans votre calendrier.",
        "Modificali nel tuo calendario.",
        "Edítalos en tu calendario.",
        "Wijzig deze in je agenda.",
    ),
    "End must be after start. This day is treated as blocked.": (
        "La fin doit être après le début. Ce jour est considéré comme bloqué.",
        "La fine deve essere dopo l'inizio. Questo giorno è considerato bloccato.",
        "El final debe ser posterior al inicio. Este día se considera bloqueado.",
        "Het einde moet na het begin liggen. Deze dag geldt als geblokkeerd.",
    ),
    "End override": ("Terminer l'exception", "Termina l'eccezione", "Terminar la excepción", "Beëindig uitzondering"),
    "Ends": ("Fin", "Fine", "Fin", "Einde"),
    "First day": ("Premier jour", "Primo giorno", "Primer día", "Eerste dag"),
    "Flip until next scheduled change": (
        "Inverser jusqu'au prochain changement",
        "Inverti fino al prossimo cambio",
        "Invertir hasta el próximo cambio",
        "Omdraaien tot de volgende wijziging",
    ),
    "From": ("De", "Dalle", "Desde", "Van"),
    "From calendars": ("Depuis les calendriers", "Dai calendari", "De los calendarios", "Uit agenda's"),
    "From work calendar": (
        "Depuis le calendrier professionnel",
        "Dal calendario di lavoro",
        "Del calendario de trabajo",
        "Uit werkagenda",
    ),
    "Holiday calendar": (
        "Calendrier des jours fériés",
        "Calendario festività",
        "Calendario de festivos",
        "Feestdagenagenda",
    ),
    "Imported": ("Importés", "Importati", "Importados", "Geïmporteerd"),
    "Last day": ("Dernier jour", "Ultimo giorno", "Último día", "Laatste dag"),
    "Meeting until %@": ("Réunion jusqu'à %@", "Riunione fino alle %@", "Reunión hasta las %@", "Vergadering tot %@"),
    "Meetings": ("Réunions", "Riunioni", "Reuniones", "Vergaderingen"),
    "Meetings extend work hours": (
        "Les réunions prolongent les horaires",
        "Le riunioni estendono l'orario",
        "Las reuniones amplían el horario",
        "Vergaderingen verlengen werktijd",
    ),
    "Name, e.g. Christmas, Vacation": (
        "Nom, p. ex. Noël, Vacances",
        "Nome, ad es. Natale, Vacanze",
        "Nombre, p. ej. Navidad, Vacaciones",
        "Naam, bijv. Kerstmis, Vakantie",
    ),
    "No upcoming days off": (
        "Aucun congé à venir",
        "Nessun giorno libero in programma",
        "No hay días libres próximos",
        "Geen geplande vrije dagen",
    ),
    "No upcoming shifts": (
        "Aucune astreinte à venir",
        "Nessun turno in programma",
        "No hay guardias próximas",
        "Geen geplande piketdiensten",
    ),
    "No workdays": ("Aucun jour ouvré", "Nessun giorno lavorativo", "Sin días laborables", "Geen werkdagen"),
    "None": ("Aucun", "Nessuno", "Ninguno", "Geen"),
    "None selected": ("Aucune sélection", "Nessuna selezione", "Sin seleccionar", "Niets geselecteerd"),
    "Not a workday": ("Jour non ouvré", "Giorno non lavorativo", "Día no laborable", "Geen werkdag"),
    "Note (optional)": ("Note (facultatif)", "Nota (facoltativa)", "Nota (opcional)", "Notitie (optioneel)"),
    "Nothing in the next %lld days": (
        "Rien dans les %lld prochains jours",
        "Niente nei prossimi %lld giorni",
        "Nada en los próximos %lld días",
        "Niets in de komende %lld dagen",
    ),
    "Off-hours": ("Off-hours",) * 4,
    "Off-hours uses Screen Time to block your work apps. Nothing leaves your device.": (
        "Off-hours utilise Temps d'écran pour bloquer vos apps professionnelles. Rien ne quitte votre appareil.",
        "Off-hours usa Tempo di utilizzo per bloccare le tue app di lavoro. Nulla lascia il tuo dispositivo.",
        "Off-hours usa Tiempo de uso para bloquear tus apps de trabajo. Nada sale de tu dispositivo.",
        "Off-hours gebruikt Schermtijd om je werk-apps te blokkeren. Er verlaat niets je apparaat.",
    ),
    "On call": ("Astreinte", "Reperibilità", "Guardia", "Piket"),
    "On call until %@": ("D'astreinte jusqu'à %@", "Reperibile fino a %@", "De guardia hasta %@", "Piket tot %@"),
    "On-call shift": ("Astreinte", "Turno di reperibilità", "Turno de guardia", "Piketdienst"),
    "Open before meeting": (
        "Ouvrir avant la réunion",
        "Apri prima della riunione",
        "Abrir antes de la reunión",
        "Openen vóór vergadering",
    ),
    "Optional. Events whose title contains one of the keywords below become on-call shifts or days off.": (
        "Facultatif. Les événements dont le titre contient l'un des mots-clés ci-dessous deviennent des astreintes ou des congés.",
        "Facoltativo. Gli eventi il cui titolo contiene una delle parole chiave qui sotto diventano turni di reperibilità o giorni liberi.",
        "Opcional. Los eventos cuyo título contiene una de las palabras clave de abajo se convierten en guardias o días libres.",
        "Optioneel. Afspraken met een van de onderstaande trefwoorden in de titel worden piketdiensten of vrije dagen.",
    ),
    "Optional. Every day with an event in this calendar counts as a day off, e.g. a public holidays calendar.": (
        "Facultatif. Chaque jour avec un événement dans ce calendrier compte comme congé, p. ex. un calendrier des jours fériés.",
        "Facoltativo. Ogni giorno con un evento in questo calendario conta come giorno libero, ad es. un calendario delle festività.",
        "Opcional. Cada día con un evento en este calendario cuenta como día libre, p. ej. un calendario de festivos.",
        "Optioneel. Elke dag met een afspraak in deze agenda telt als vrije dag, bijv. een feestdagenagenda.",
    ),
    "Outside work hours": (
        "En dehors des horaires de travail",
        "Fuori orario di lavoro",
        "Fuera del horario laboral",
        "Buiten werktijd",
    ),
    "Override": ("Exception", "Eccezione", "Excepción", "Uitzondering"),
    "Override until %@": ("Exception jusqu'à %@", "Eccezione fino alle %@", "Excepción hasta las %@", "Uitzondering tot %@"),
    "Overrides beat every schedule, including on-call and days off.": (
        "Les exceptions priment sur tous les horaires, y compris les astreintes et les congés.",
        "Le eccezioni hanno la precedenza su tutti gli orari, inclusi reperibilità e giorni liberi.",
        "Las excepciones prevalecen sobre cualquier horario, incluidas guardias y días libres.",
        "Uitzonderingen gaan voor elk schema, ook piketdiensten en vrije dagen.",
    ),
    "Past": ("Passés", "Passati", "Pasados", "Verleden"),
    "Pick the apps, categories and websites to block outside work hours, e.g. Slack, Teams, Mail, Outlook.": (
        "Choisissez les apps, catégories et sites web à bloquer en dehors des horaires de travail, p. ex. Slack, Teams, Mail, Outlook.",
        "Scegli le app, le categorie e i siti web da bloccare fuori orario di lavoro, ad es. Slack, Teams, Mail, Outlook.",
        "Elige las apps, categorías y sitios web que se bloquean fuera del horario laboral, p. ej. Slack, Teams, Mail, Outlook.",
        "Kies de apps, categorieën en websites die buiten werktijd worden geblokkeerd, bijv. Slack, Teams, Mail, Outlook.",
    ),
    "Quick length": ("Durée rapide", "Durata rapida", "Duración rápida", "Snelle duur"),
    "Reset keywords": (
        "Réinitialiser les mots-clés",
        "Ripristina le parole chiave",
        "Restablecer palabras clave",
        "Herstel trefwoorden",
    ),
    "Save": ("Enregistrer", "Salva", "Guardar", "Bewaar"),
    "Schedule": ("Horaires", "Programma", "Horario", "Schema"),
    "Scheduling is turned off": (
        "La planification est désactivée",
        "La pianificazione è disattivata",
        "La programación está desactivada",
        "Planning staat uit",
    ),
    "Scheduling on": ("Planification activée", "Pianificazione attiva", "Programación activada", "Planning aan"),
    "Starts": ("Début", "Inizio", "Inicio", "Begin"),
    "To": ("À", "Alle", "Hasta", "Tot"),
    "Tonight": ("Ce soir", "Stasera", "Esta noche", "Vannacht"),
    "Unavailable calendar": (
        "Calendrier indisponible",
        "Calendario non disponibile",
        "Calendario no disponible",
        "Agenda niet beschikbaar",
    ),
    "Untitled": ("Sans titre", "Senza titolo", "Sin título", "Naamloos"),
    "Upcoming": ("À venir", "In programma", "Próximos", "Gepland"),
    "Weekend": ("Week-end", "Weekend", "Fin de semana", "Weekend"),
    "While on call, work apps stay available, even in the evening, on weekends and on days off.": (
        "Pendant une astreinte, les apps professionnelles restent disponibles, même le soir, le week-end et les jours de congé.",
        "Durante la reperibilità, le app di lavoro restano disponibili, anche la sera, nel weekend e nei giorni liberi.",
        "Durante una guardia, las apps de trabajo siguen disponibles, incluso por la noche, los fines de semana y los días libres.",
        "Tijdens piket blijven werk-apps beschikbaar, ook 's avonds, in het weekend en op vrije dagen.",
    ),
    "Work apps": ("Apps professionnelles", "App di lavoro", "Apps de trabajo", "Werk-apps"),
    "Work apps are available during these hours and blocked in the evening, early morning and on days that aren't workdays.": (
        "Les apps professionnelles sont disponibles pendant ces horaires et bloquées le soir, tôt le matin et les jours non ouvrés.",
        "Le app di lavoro sono disponibili in questi orari e bloccate la sera, la mattina presto e nei giorni non lavorativi.",
        "Las apps de trabajo están disponibles en este horario y bloqueadas por la noche, a primera hora de la mañana y los días no laborables.",
        "Werk-apps zijn tijdens deze uren beschikbaar en geblokkeerd in de avond, vroeg in de ochtend en op dagen die geen werkdag zijn.",
    ),
    "Work apps are blocked all day on vacation days and holidays, unless you're on call.": (
        "Les apps professionnelles sont bloquées toute la journée pendant les vacances et les jours fériés, sauf en astreinte.",
        "Le app di lavoro sono bloccate tutto il giorno nei giorni di vacanza e festivi, salvo reperibilità.",
        "Las apps de trabajo se bloquean todo el día en vacaciones y festivos, salvo si estás de guardia.",
        "Werk-apps zijn de hele dag geblokkeerd op vakantie- en feestdagen, behalve als je piket hebt.",
    ),
    "Work apps available": (
        "Apps professionnelles disponibles",
        "App di lavoro disponibili",
        "Apps de trabajo disponibles",
        "Werk-apps beschikbaar",
    ),
    "Work apps blocked": (
        "Apps professionnelles bloquées",
        "App di lavoro bloccate",
        "Apps de trabajo bloqueadas",
        "Werk-apps geblokkeerd",
    ),
    "Work apps open for meetings outside work hours, including weekends, but not on days off or holidays. All-day, free and declined events are ignored.": (
        "Les apps professionnelles s'ouvrent pour les réunions en dehors des horaires, y compris le week-end, mais pas pendant les congés ou les jours fériés. Les événements sur toute la journée, disponibles ou refusés sont ignorés.",
        "Le app di lavoro si aprono per le riunioni fuori orario, anche nel weekend, ma non nei giorni liberi o festivi. Gli eventi di tutto il giorno, liberi o rifiutati vengono ignorati.",
        "Las apps de trabajo se abren para reuniones fuera del horario, también los fines de semana, pero no en días libres ni festivos. Se ignoran los eventos de todo el día, libres o rechazados.",
        "Werk-apps gaan open voor vergaderingen buiten werktijd, ook in het weekend, maar niet op vrije dagen of feestdagen. Hele-dag-, vrije en afgewezen afspraken worden genegeerd.",
    ),
    "Work calendar": ("Calendrier professionnel", "Calendario di lavoro", "Calendario de trabajo", "Werkagenda"),
    "Work calendar keywords": (
        "Mots-clés du calendrier professionnel",
        "Parole chiave del calendario di lavoro",
        "Palabras clave del calendario de trabajo",
        "Trefwoorden werkagenda",
    ),
    "Work hours": ("Horaires de travail", "Orario di lavoro", "Horario laboral", "Werktijden"),
    "–": ("–",) * 4,
}

# Counts on their own: key: {lang: (one, other)}
PLURALS = {
    "%lld days": {
        "fr": ("%lld jour", "%lld jours"),
        "it": ("%lld giorno", "%lld giorni"),
        "es": ("%lld día", "%lld días"),
        "nl": ("%lld dag", "%lld dagen"),
        "en": ("%lld day", "%lld days"),
    },
    "%lld selected": {
        "fr": ("%lld sélectionné", "%lld sélectionnés"),
        "it": ("%lld selezionato", "%lld selezionati"),
        "es": ("%lld seleccionado", "%lld seleccionados"),
        "nl": ("%lld geselecteerd", "%lld geselecteerd"),
    },
    "%lld upcoming": {
        "fr": ("%lld à venir", "%lld à venir"),
        "it": ("%lld in programma", "%lld in programma"),
        "es": ("%lld próximo", "%lld próximos"),
        "nl": ("%lld gepland", "%lld gepland"),
    },
}

# Demo data (Debug builds with -demo only); not found by the string extractor.
DEMO = {
    "Work": ("Travail", "Lavoro", "Trabajo", "Werk"),
    "Holidays (CH)": ("Jours fériés (CH)", "Festività (CH)", "Festivos (CH)", "Feestdagen (CH)"),
    "Platform on-call": ("Astreinte plateforme", "Reperibilità piattaforma", "Guardia de plataforma", "Piket platform"),
    "Dentist": ("Dentiste", "Dentista", "Dentista", "Tandarts"),
    "Ski week": ("Semaine de ski", "Settimana bianca", "Semana de esquí", "Skivakantie"),
    "On call – Payments": ("Astreinte – Paiements", "Reperibilità – Pagamenti", "Guardia – Pagos", "Piket – Betalingen"),
    "Release sync with US team": (
        "Point release avec l'équipe US",
        "Allineamento release con il team USA",
        "Reunión de release con el equipo de EE. UU.",
        "Release-overleg met US-team",
    ),
    "Incident review": ("Revue d'incident", "Revisione incidente", "Revisión de incidente", "Incidentevaluatie"),
    "Christmas Day": ("Noël", "Natale", "Navidad", "Eerste Kerstdag"),
    "St. Stephen's Day": ("Saint-Étienne", "Santo Stefano", "San Esteban", "Tweede Kerstdag"),
    "New Year's Day": ("Nouvel An", "Capodanno", "Año Nuevo", "Nieuwjaarsdag"),
    "Berchtold's Day": ("Saint-Berchtold", "San Bertoldo", "San Bertoldo", "Berchtoldsdag"),
}

INFO = {
    "CFBundleDisplayName": ("Off-hours",) * 4,
    "NSCalendarsFullAccessUsageDescription": (
        "Off-hours lit vos calendriers des jours fériés et professionnel pour connaître vos congés et vos astreintes.",
        "Off-hours legge i tuoi calendari delle festività e di lavoro per conoscere i giorni liberi e i turni di reperibilità.",
        "Off-hours lee tus calendarios de festivos y de trabajo para conocer tus días libres y guardias.",
        "Off-hours leest je feestdagen- en werkagenda om je vrije dagen en piketdiensten te kennen.",
    ),
}


def unit(value: str) -> dict:
    return {"stringUnit": {"state": "translated", "value": value}}


def plural(one: str, other: str) -> dict:
    return {"variations": {"plural": {"one": unit(one), "other": unit(other)}}}


def catalog(table: dict, manual: set[str] = frozenset(), plurals: dict | None = None) -> dict:
    strings = {}
    for key, values in sorted(table.items()):
        entry: dict = {"localizations": {lang: unit(v) for lang, v in zip(LANGS, values)}}
        if key in manual:
            entry["extractionState"] = "manual"
        strings[key] = entry
    for key, forms in (plurals or {}).items():
        strings[key] = {"localizations": {lang: plural(*f) for lang, f in forms.items()}}
    return {"sourceLanguage": "en", "strings": dict(sorted(strings.items())), "version": "1.0"}


def write(path: Path, data: dict) -> None:
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2, separators=(",", " : ")) + "\n")


if __name__ == "__main__":
    for table in (T, DEMO, INFO):
        bad = [k for k, v in table.items() if len(v) != len(LANGS)]
        assert not bad, bad
    write(ROOT / "OffHours/Localizable.xcstrings", catalog({**T, **DEMO}, manual=set(DEMO), plurals=PLURALS))
    write(ROOT / "OffHours/InfoPlist.xcstrings", catalog(INFO))
    print(f"{len(T) + len(DEMO) + len(PLURALS)} strings, {len(INFO)} Info.plist keys")
