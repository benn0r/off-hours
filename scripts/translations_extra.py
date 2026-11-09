"""German, Portuguese (Portugal) and Portuguese (Brazil): key -> (de, pt-PT, pt-BR).

Merged into the string catalogs by scripts/translations.py.
"""

X_LANGS = ["de", "pt-PT", "pt-BR"]

X = {
    "%@ until %@": ("%1$@ bis %2$@", "%1$@ até às %2$@", "%1$@ até %2$@"),
    "%@ – %@": ("%1$@ – %2$@",) * 3,
    "%lld days, %@–%@": (
        "%1$lld Tage, %2$@–%3$@",
        "%1$lld dias, %2$@–%3$@",
        "%1$lld dias, %2$@–%3$@",
    ),
    "%lld min": ("%lld Min.", "%lld min", "%lld min"),
    "1 day": ("1 Tag", "1 dia", "1 dia"),
    "1 week": ("1 Woche", "1 semana", "1 semana"),
    "Add": ("Hinzufügen", "Adicionar", "Adicionar"),
    "Continue": (
        "Weiter",
        "Continuar",
        "Continuar",
    ),
    "Open Settings": (
        "Einstellungen öffnen",
        "Abrir Definições",
        "Abrir Ajustes",
    ),
    "Allow work apps for 1 hour": (
        "Arbeits-Apps 1 Stunde erlauben",
        "Permitir apps de trabalho durante 1 hora",
        "Permitir apps de trabalho por 1 hora",
    ),
    "Available at %@": ("Verfügbar um %@", "Disponíveis às %@", "Disponíveis às %@"),
    "Available on %@ at %@": (
        "Verfügbar am %1$@ um %2$@",
        "Disponíveis %1$@ às %2$@",
        "Disponíveis %1$@ às %2$@",
    ),
    "Available tomorrow at %@": (
        "Morgen um %@ verfügbar",
        "Disponíveis amanhã às %@",
        "Disponíveis amanhã às %@",
    ),
    "Block work apps for 1 hour": (
        "Arbeits-Apps 1 Stunde sperren",
        "Bloquear apps de trabalho durante 1 hora",
        "Bloquear apps de trabalho por 1 hora",
    ),
    "Blocked at %@": ("Gesperrt um %@", "Bloqueadas às %@", "Bloqueados às %@"),
    "Blocked on %@ at %@": (
        "Gesperrt am %1$@ um %2$@",
        "Bloqueadas %1$@ às %2$@",
        "Bloqueados %1$@ às %2$@",
    ),
    "Blocked tomorrow at %@": (
        "Morgen um %@ gesperrt",
        "Bloqueadas amanhã às %@",
        "Bloqueados amanhã às %@",
    ),
    "Calendar access was denied. Enable it in Settings › Privacy & Security › Calendars.": (
        "Der Kalenderzugriff wurde abgelehnt. Aktiviere ihn unter Einstellungen › Datenschutz & Sicherheit › Kalender.",
        "O acesso aos calendários foi recusado. Ative-o em Definições › Privacidade e segurança › Calendários.",
        "O acesso aos calendários foi negado. Ative-o em Ajustes › Privacidade e Segurança › Calendários.",
    ),
    "Calendars": ("Kalender", "Calendários", "Calendários"),
    "Calendars are read on this device only.": (
        "Kalender werden nur auf diesem Gerät gelesen.",
        "Os calendários são lidos apenas neste dispositivo.",
        "Os calendários são lidos apenas neste aparelho.",
    ),
    "Cancel": ("Abbrechen", "Cancelar", "Cancelar"),
    "Clear past days off": (
        "Vergangene freie Tage löschen",
        "Limpar folgas passadas",
        "Limpar folgas passadas",
    ),
    "Clear past shifts": (
        "Vergangene Bereitschaften löschen",
        "Limpar turnos de prevenção passados",
        "Limpar plantões passados",
    ),
    "Comma separated, not case sensitive. If a title matches both, it counts as on call.": (
        "Durch Kommas getrennt, Groß- und Kleinschreibung egal. Passt ein Titel zu beidem, zählt er als Bereitschaft.",
        "Separadas por vírgulas, sem distinguir maiúsculas. Se um título corresponder a ambas, conta como prevenção.",
        "Separadas por vírgulas, sem diferenciar maiúsculas. Se um título corresponder a ambas, conta como plantão.",
    ),
    "Copy Monday's hours to all workdays": (
        "Montagszeiten für alle Arbeitstage übernehmen",
        "Copiar o horário de segunda-feira para todos os dias úteis",
        "Copiar o horário de segunda-feira para todos os dias úteis",
    ),
    "Day off": ("Freier Tag", "Folga", "Folga"),
    "Day off: %@": ("Frei: %@", "Folga: %@", "Folga: %@"),
    "Days off": ("Freie Tage", "Folgas", "Folgas"),
    "Days off & holidays": (
        "Freie Tage & Feiertage",
        "Folgas e feriados",
        "Folgas e feriados",
    ),
    "Edit these in your calendar.": (
        "Bearbeite sie in deinem Kalender.",
        "Edite-os no seu calendário.",
        "Edite-os no seu calendário.",
    ),
    "End must be after start. This day is treated as blocked.": (
        "Das Ende muss nach dem Beginn liegen. Dieser Tag gilt als gesperrt.",
        "O fim tem de ser depois do início. Este dia é considerado bloqueado.",
        "O fim precisa ser depois do início. Este dia é considerado bloqueado.",
    ),
    "End override": ("Ausnahme beenden", "Terminar exceção", "Encerrar exceção"),
    "Ends": ("Ende", "Fim", "Fim"),
    "First day": ("Erster Tag", "Primeiro dia", "Primeiro dia"),
    "Flip until next scheduled change": (
        "Umkehren bis zur nächsten Änderung",
        "Inverter até à próxima mudança",
        "Inverter até a próxima mudança",
    ),
    "From": ("Von", "De", "De"),
    "From calendars": ("Aus Kalendern", "Dos calendários", "Dos calendários"),
    "From work calendar": (
        "Aus dem Arbeitskalender",
        "Do calendário de trabalho",
        "Do calendário de trabalho",
    ),
    "Holiday calendar": (
        "Feiertagskalender",
        "Calendário de feriados",
        "Calendário de feriados",
    ),
    "Imported": ("Importiert", "Importados", "Importados"),
    "Last day": ("Letzter Tag", "Último dia", "Último dia"),
    "Meeting until %@": ("Meeting bis %@", "Reunião até às %@", "Reunião até %@"),
    "Meetings": ("Meetings", "Reuniões", "Reuniões"),
    "Meetings extend work hours": (
        "Meetings verlängern die Arbeitszeit",
        "As reuniões prolongam o horário",
        "Reuniões estendem o expediente",
    ),
    "Name, e.g. Christmas, Vacation": (
        "Name, z. B. Weihnachten, Ferien",
        "Nome, p. ex. Natal, Férias",
        "Nome, ex.: Natal, Férias",
    ),
    "No upcoming days off": (
        "Keine anstehenden freien Tage",
        "Sem folgas previstas",
        "Nenhuma folga prevista",
    ),
    "No upcoming shifts": (
        "Keine anstehenden Bereitschaften",
        "Sem turnos de prevenção previstos",
        "Nenhum plantão previsto",
    ),
    "No workdays": ("Keine Arbeitstage", "Sem dias úteis", "Nenhum dia útil"),
    "None": ("Keine", "Nenhum", "Nenhum"),
    "None selected": ("Nichts ausgewählt", "Nada selecionado", "Nada selecionado"),
    "Not a workday": ("Kein Arbeitstag", "Não é dia útil", "Não é dia útil"),
    "Note (optional)": ("Notiz (optional)", "Nota (opcional)", "Observação (opcional)"),
    "Nothing in the next %lld days": (
        "Nichts in den nächsten %lld Tagen",
        "Nada nos próximos %lld dias",
        "Nada nos próximos %lld dias",
    ),
    "Off-hours": ("Off-hours",) * 3,
    "Off-hours uses Screen Time to block your work apps. Nothing leaves your device.": (
        "Off-hours sperrt deine Arbeits-Apps mit Bildschirmzeit. Nichts verlässt dein Gerät.",
        "A Off-hours usa o Tempo de ecrã para bloquear as suas apps de trabalho. Nada sai do seu dispositivo.",
        "O Off-hours usa o Tempo de Uso para bloquear seus apps de trabalho. Nada sai do seu aparelho.",
    ),
    "On call": ("Bereitschaft", "Prevenção", "Plantão"),
    "On call until %@": ("Bereitschaft bis %@", "De prevenção até %@", "De plantão até %@"),
    "On-call shift": ("Bereitschaftsdienst", "Turno de prevenção", "Plantão"),
    "Open before meeting": (
        "Vor dem Meeting öffnen",
        "Abrir antes da reunião",
        "Abrir antes da reunião",
    ),
    "Optional. Events whose title contains one of the keywords below become on-call shifts or days off.": (
        "Optional. Termine, deren Titel eines der Stichwörter unten enthält, werden zu Bereitschaften oder freien Tagen.",
        "Opcional. Os eventos cujo título contém uma das palavras-chave abaixo passam a turnos de prevenção ou folgas.",
        "Opcional. Eventos cujo título contém uma das palavras-chave abaixo viram plantões ou folgas.",
    ),
    "Optional. Every day with an event in this calendar counts as a day off, e.g. a public holidays calendar.": (
        "Optional. Jeder Tag mit einem Termin in diesem Kalender gilt als freier Tag, z. B. ein Feiertagskalender.",
        "Opcional. Cada dia com um evento neste calendário conta como folga, p. ex. um calendário de feriados.",
        "Opcional. Cada dia com um evento neste calendário conta como folga, ex.: um calendário de feriados.",
    ),
    "Outside work hours": ("Außerhalb der Arbeitszeit", "Fora do horário de trabalho", "Fora do expediente"),
    "Override": ("Ausnahme", "Exceção", "Exceção"),
    "Override until %@": ("Ausnahme bis %@", "Exceção até às %@", "Exceção até %@"),
    "Overrides beat every schedule, including on-call and days off.": (
        "Ausnahmen haben Vorrang vor jedem Plan, auch vor Bereitschaft und freien Tagen.",
        "As exceções prevalecem sobre qualquer horário, incluindo prevenção e folgas.",
        "Exceções valem mais que qualquer horário, inclusive plantões e folgas.",
    ),
    "Past": ("Vergangen", "Passados", "Passados"),
    "Pick the apps, categories and websites to block outside work hours, e.g. Slack, Teams, Mail, Outlook.": (
        "Wähle die Apps, Kategorien und Websites, die außerhalb der Arbeitszeit gesperrt werden, z. B. Slack, Teams, Mail, Outlook.",
        "Escolha as apps, categorias e sites a bloquear fora do horário de trabalho, p. ex. Slack, Teams, Mail, Outlook.",
        "Escolha os apps, categorias e sites a bloquear fora do expediente, ex.: Slack, Teams, Mail, Outlook.",
    ),
    "Quick length": ("Schnelle Dauer", "Duração rápida", "Duração rápida"),
    "Reset keywords": (
        "Stichwörter zurücksetzen",
        "Repor palavras-chave",
        "Redefinir palavras-chave",
    ),
    "Save": ("Sichern", "Guardar", "Salvar"),
    "Schedule": ("Zeitplan", "Horário", "Horário"),
    "Scheduling is turned off": (
        "Zeitplan ist ausgeschaltet",
        "O horário está desativado",
        "O horário está desativado",
    ),
    "Scheduling on": ("Zeitplan aktiv", "Horário ativo", "Horário ativo"),
    "Starts": ("Beginn", "Início", "Início"),
    "To": ("Bis", "Até", "Até"),
    "Tonight": ("Heute Nacht", "Esta noite", "Hoje à noite"),
    "Unavailable calendar": (
        "Kalender nicht verfügbar",
        "Calendário indisponível",
        "Calendário indisponível",
    ),
    "Untitled": ("Ohne Titel", "Sem título", "Sem título"),
    "Upcoming": ("Anstehend", "Próximos", "Próximos"),
    "Weekend": ("Wochenende", "Fim de semana", "Fim de semana"),
    "While on call, work apps stay available, even in the evening, on weekends and on days off.": (
        "Während der Bereitschaft bleiben Arbeits-Apps verfügbar, auch abends, am Wochenende und an freien Tagen.",
        "Durante a prevenção, as apps de trabalho continuam disponíveis, mesmo à noite, ao fim de semana e nas folgas.",
        "Durante o plantão, os apps de trabalho continuam disponíveis, mesmo à noite, nos fins de semana e nas folgas.",
    ),
    "Work apps": ("Arbeits-Apps", "Apps de trabalho", "Apps de trabalho"),
    "Work apps are available during these hours and blocked in the evening, early morning and on days that aren't workdays.": (
        "Arbeits-Apps sind in diesen Zeiten verfügbar und abends, frühmorgens und an Tagen ohne Arbeit gesperrt.",
        "As apps de trabalho estão disponíveis neste horário e bloqueadas à noite, de manhã cedo e nos dias que não são úteis.",
        "Os apps de trabalho ficam disponíveis neste horário e bloqueados à noite, de manhã cedo e nos dias que não são úteis.",
    ),
    "Work apps are blocked all day on vacation days and holidays, unless you're on call.": (
        "An Ferien- und Feiertagen sind Arbeits-Apps den ganzen Tag gesperrt, außer du hast Bereitschaft.",
        "As apps de trabalho ficam bloqueadas o dia todo nas férias e feriados, exceto se estiver de prevenção.",
        "Os apps de trabalho ficam bloqueados o dia todo nas férias e feriados, a menos que você esteja de plantão.",
    ),
    "Work apps available": (
        "Arbeits-Apps verfügbar",
        "Apps de trabalho disponíveis",
        "Apps de trabalho disponíveis",
    ),
    "Work apps blocked": (
        "Arbeits-Apps gesperrt",
        "Apps de trabalho bloqueadas",
        "Apps de trabalho bloqueados",
    ),
    "Work apps open for meetings outside work hours, including weekends, but not on days off or holidays. All-day, free and declined events are ignored.": (
        "Arbeits-Apps öffnen sich für Meetings außerhalb der Arbeitszeit, auch am Wochenende, aber nicht an freien Tagen oder Feiertagen. Ganztägige, freie und abgelehnte Termine werden ignoriert.",
        "As apps de trabalho abrem para reuniões fora do horário, também ao fim de semana, mas não nas folgas nem feriados. Eventos de dia inteiro, livres ou recusados são ignorados.",
        "Os apps de trabalho abrem para reuniões fora do expediente, inclusive nos fins de semana, mas não em folgas nem feriados. Eventos de dia inteiro, livres ou recusados são ignorados.",
    ),
    "Work calendar": ("Arbeitskalender", "Calendário de trabalho", "Calendário de trabalho"),
    "Work calendar keywords": (
        "Stichwörter für den Arbeitskalender",
        "Palavras-chave do calendário de trabalho",
        "Palavras-chave do calendário de trabalho",
    ),
    "Work hours": ("Arbeitszeiten", "Horário de trabalho", "Expediente"),
    "–": ("–",) * 3,
}

# key: {lang: (one, other)}
X_PLURALS = {
    "%lld days": {
        "de": ("%lld Tag", "%lld Tage"),
        "pt-PT": ("%lld dia", "%lld dias"),
        "pt-BR": ("%lld dia", "%lld dias"),
    },
    "%lld selected": {
        "de": ("%lld ausgewählt", "%lld ausgewählt"),
        "pt-PT": ("%lld selecionado", "%lld selecionados"),
        "pt-BR": ("%lld selecionado", "%lld selecionados"),
    },
    "%lld upcoming": {
        "de": ("%lld anstehend", "%lld anstehend"),
        "pt-PT": ("%lld previsto", "%lld previstos"),
        "pt-BR": ("%lld previsto", "%lld previstos"),
    },
}

X_DEMO = {
    "Work": ("Arbeit", "Trabalho", "Trabalho"),
    "Holidays (CH)": ("Feiertage (CH)", "Feriados (CH)", "Feriados (CH)"),
    "Platform on-call": ("Bereitschaft Plattform", "Prevenção plataforma", "Plantão plataforma"),
    "Dentist": ("Zahnarzt", "Dentista", "Dentista"),
    "Ski week": ("Skiferien", "Semana de esqui", "Semana de esqui"),
    "On call – Payments": ("Pikett – Payments", "Prevenção – Pagamentos", "Plantão – Pagamentos"),
    "Release sync with US team": (
        "Release-Abgleich mit US-Team",
        "Reunião de release com a equipa dos EUA",
        "Reunião de release com o time dos EUA",
    ),
    "Incident review": ("Incident-Review", "Revisão de incidente", "Revisão de incidente"),
    "Christmas Day": ("Weihnachten", "Natal", "Natal"),
    "St. Stephen's Day": ("Stephanstag", "Santo Estêvão", "Santo Estêvão"),
    "New Year's Day": ("Neujahr", "Ano Novo", "Ano Novo"),
    "Berchtold's Day": ("Berchtoldstag", "Dia de São Bertoldo", "Dia de São Bertoldo"),
}

X_INFO = {
    "CFBundleDisplayName": ("Off-hours",) * 3,
    "NSCalendarsFullAccessUsageDescription": (
        "Off-hours liest deinen Feiertags- und Arbeitskalender, um deine freien Tage und Bereitschaften zu kennen.",
        "A Off-hours lê os seus calendários de feriados e de trabalho para conhecer as suas folgas e turnos de prevenção.",
        "O Off-hours lê seus calendários de feriados e de trabalho para saber suas folgas e plantões.",
    ),
}
