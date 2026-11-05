import Foundation

/// A wall-clock time (hour + minute), independent of any date.
struct TimeOfDay: Codable, Hashable, Comparable {
    var hour: Int
    var minute: Int

    var minutes: Int { hour * 60 + minute }

    static func < (lhs: TimeOfDay, rhs: TimeOfDay) -> Bool { lhs.minutes < rhs.minutes }

    func date(on day: Date, calendar: Calendar) -> Date? {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day)
    }

    var formatted: String { String(format: "%02d:%02d", hour, minute) }
}

/// A calendar day (no time, no time zone), used for days off and holidays.
struct DayStamp: Codable, Hashable, Comparable {
    var year: Int
    var month: Int
    var day: Int

    init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }

    init(_ date: Date, calendar: Calendar) {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        self.init(year: c.year ?? 0, month: c.month ?? 1, day: c.day ?? 1)
    }

    func startDate(calendar: Calendar) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? .distantPast
    }

    static func < (lhs: DayStamp, rhs: DayStamp) -> Bool {
        (lhs.year, lhs.month, lhs.day) < (rhs.year, rhs.month, rhs.day)
    }
}

/// One weekday in the regular weekly schedule.
struct WorkDay: Codable, Hashable {
    var isWorkday: Bool
    var start: TimeOfDay
    var end: TimeOfDay

    var hasValidHours: Bool { start < end }
}

/// A period during which work apps stay available regardless of the weekly schedule.
struct OnCallShift: Codable, Hashable, Identifiable {
    var id = UUID()
    var start: Date
    var end: Date
    var note: String = ""

    func contains(_ date: Date) -> Bool { start <= date && date < end }
}

/// One day or a range of days (inclusive) on which work apps are blocked all day.
struct DayOff: Codable, Hashable, Identifiable {
    var id = UUID()
    var name: String
    var firstDay: DayStamp
    var lastDay: DayStamp

    func contains(_ day: DayStamp) -> Bool { firstDay <= day && day <= lastDay }
}

/// A temporary manual decision that beats every schedule until it expires.
struct Override: Codable, Hashable {
    var blocked: Bool
    var until: Date
}

struct Config: Codable, Equatable {
    var isEnabled: Bool = true
    /// Indexed by `Calendar.weekday - 1` (0 = Sunday … 6 = Saturday).
    var week: [WorkDay]
    var onCall: [OnCallShift] = []
    var daysOff: [DayOff] = []
    var override: Override?

    static let `default`: Config = {
        let office = WorkDay(isWorkday: true,
                             start: TimeOfDay(hour: 8, minute: 0),
                             end: TimeOfDay(hour: 18, minute: 0))
        var weekend = office
        weekend.isWorkday = false
        // Sun, Mon, Tue, Wed, Thu, Fri, Sat
        return Config(week: [weekend, office, office, office, office, office, weekend])
    }()

    func workDay(for date: Date, calendar: Calendar) -> WorkDay {
        let index = calendar.component(.weekday, from: date) - 1
        return week.indices.contains(index) ? week[index] : Config.default.week[index]
    }
}
