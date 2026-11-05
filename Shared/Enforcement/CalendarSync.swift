import EventKit
import Foundation

/// Reads the selected calendars and refreshes `Config.importedOnCall` / `importedDaysOff`.
enum CalendarSync {
    /// How far ahead events are imported. The scheduler only looks 21 days ahead, so this is plenty.
    static let lookaheadDays = 60

    static var isAuthorized: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    /// Returns `config` with its imported entries replaced by what the calendars currently contain.
    /// Leaves `config` unchanged if calendar access is missing.
    static func syncing(_ config: Config, store: EKEventStore, now: Date = .now, calendar: Calendar = .current) -> Config {
        var config = config
        guard config.usesCalendars else {
            config.importedOnCall = []
            config.importedDaysOff = []
            config.importedMeetings = []
            return config
        }
        guard isAuthorized else { return config }

        let ids = Set(config.holidayCalendarIDs + config.workCalendarIDs)
        let calendars = store.calendars(for: .event).filter { ids.contains($0.calendarIdentifier) }
        guard !calendars.isEmpty,
              let start = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now)),
              let end = calendar.date(byAdding: .day, value: lookaheadDays, to: start)
        else {
            config.importedOnCall = []
            config.importedDaysOff = []
            config.importedMeetings = []
            return config
        }

        let predicate = store.predicateForEvents(withStart: start, end: end, calendars: calendars)
        let entries = store.events(matching: predicate).map {
            CalendarEntry(calendarID: $0.calendar.calendarIdentifier,
                          title: $0.title ?? "",
                          start: $0.startDate,
                          end: $0.endDate,
                          isAllDay: $0.isAllDay,
                          isFree: $0.availability == .free,
                          isDeclined: $0.attendees?.first(where: \.isCurrentUser)?.participantStatus == .declined)
        }

        let result = CalendarImport.classify(entries, config: config, calendar: calendar)
        config.importedOnCall = result.onCall
        config.importedDaysOff = result.daysOff
        config.importedMeetings = result.meetings
        return config
    }
}
