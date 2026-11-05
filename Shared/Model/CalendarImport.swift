import Foundation

/// A calendar event reduced to what OffHours needs, so the import rules stay testable without EventKit.
struct CalendarEntry: Hashable {
    var calendarID: String
    var title: String
    var start: Date
    var end: Date
    var isAllDay: Bool
    /// Shown as "free" rather than "busy".
    var isFree: Bool = false
    /// The current user declined the invitation.
    var isDeclined: Bool = false
}

/// Turns calendar events into on-call shifts and days off.
///
/// - Every event in a *holiday* calendar marks the days it covers as days off.
/// - An event in a *work* calendar whose title contains an on-call keyword becomes an on-call shift.
/// - An event in a *work* calendar whose title contains a day-off keyword marks its days as days off.
///   (On-call keywords win if a title matches both.)
/// - If enabled, any other timed, busy, non-declined event in a *work* calendar that reaches outside
///   work hours becomes a meeting window, during which work apps are available.
enum CalendarImport {
    struct Result: Equatable {
        var onCall: [OnCallShift] = []
        var daysOff: [DayOff] = []
        var meetings: [OnCallShift] = []
    }

    static let defaultOnCallKeywords = ["on call", "on-call", "oncall", "pikett", "bereitschaft"]
    static let defaultDayOffKeywords = ["vacation", "holiday", "out of office", "ooo", "pto", "ferien", "urlaub", "frei"]

    static func classify(_ entries: [CalendarEntry], config: Config, calendar: Calendar) -> Result {
        let holidayIDs = Set(config.holidayCalendarIDs)
        let workIDs = Set(config.workCalendarIDs)
        let onCallKeywords = normalized(config.onCallKeywords)
        let dayOffKeywords = normalized(config.dayOffKeywords)

        var onCall: [OnCallShift] = []
        var daysOff: [DayOff] = []
        var meetings: [OnCallShift] = []

        for entry in entries where entry.end > entry.start {
            let title = entry.title.lowercased()
            let key = "\(entry.calendarID)|\(entry.title)|\(entry.start.timeIntervalSince1970)|\(entry.end.timeIntervalSince1970)"

            if workIDs.contains(entry.calendarID), onCallKeywords.contains(where: title.contains) {
                onCall.append(OnCallShift(id: stableUUID(key), start: entry.start, end: entry.end, note: entry.title))
                continue
            }

            let isHoliday = holidayIDs.contains(entry.calendarID)
            let isWorkDayOff = workIDs.contains(entry.calendarID) && dayOffKeywords.contains(where: title.contains)
            if isHoliday || isWorkDayOff {
                // All-day events end at 23:59:59 (or next midnight); timed events may end exactly at midnight.
                let lastMoment = max(entry.start, entry.end.addingTimeInterval(-1))
                daysOff.append(DayOff(id: stableUUID(key),
                                      name: entry.title,
                                      firstDay: DayStamp(entry.start, calendar: calendar),
                                      lastDay: DayStamp(lastMoment, calendar: calendar)))
                continue
            }

            if config.meetingsExtendHours, workIDs.contains(entry.calendarID),
               !entry.isAllDay, !entry.isFree, !entry.isDeclined,
               !isInsideWorkHours(entry, config: config, calendar: calendar) {
                meetings.append(OnCallShift(id: stableUUID(key), start: entry.start, end: entry.end, note: entry.title))
            }
        }

        return Result(onCall: onCall.sorted { $0.start < $1.start },
                      daysOff: daysOff.sorted { $0.firstDay < $1.firstDay },
                      meetings: meetings.sorted { $0.start < $1.start })
    }

    /// Meetings fully inside a workday's hours (buffer included) change nothing, so they aren't imported.
    private static func isInsideWorkHours(_ entry: CalendarEntry, config: Config, calendar: Calendar) -> Bool {
        let start = entry.start.addingTimeInterval(-config.meetingBuffer)
        guard calendar.isDate(start, inSameDayAs: entry.end) else { return false }
        let workDay = config.workDay(for: start, calendar: calendar)
        guard workDay.isWorkday, workDay.hasValidHours,
              let workStart = workDay.start.date(on: start, calendar: calendar),
              let workEnd = workDay.end.date(on: start, calendar: calendar) else { return false }
        return start >= workStart && entry.end <= workEnd
    }

    static func normalized(_ keywords: [String]) -> [String] {
        keywords.map { $0.trimmingCharacters(in: .whitespaces).lowercased() }.filter { !$0.isEmpty }
    }

    /// Deterministic UUID so re-importing the same event doesn't count as a change.
    static func stableUUID(_ string: String) -> UUID {
        func fnv1a(_ seed: UInt64) -> UInt64 {
            var hash = seed
            for byte in string.utf8 {
                hash ^= UInt64(byte)
                hash = hash &* 0x100000001b3
            }
            return hash
        }
        let a = fnv1a(0xcbf29ce484222325), b = fnv1a(0x84222325cbf29ce4)
        var bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<8 {
            bytes[i] = UInt8(truncatingIfNeeded: a >> (UInt64(i) * 8))
            bytes[i + 8] = UInt8(truncatingIfNeeded: b >> (UInt64(i) * 8))
        }
        return UUID(uuid: (bytes[0], bytes[1], bytes[2], bytes[3], bytes[4], bytes[5], bytes[6], bytes[7],
                           bytes[8], bytes[9], bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]))
    }
}
