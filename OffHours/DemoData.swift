#if DEBUG
  import Foundation

  /// Fictional schedule for screenshots and manual testing: launch a Debug build with `-demo`.
  /// Nothing is saved or enforced while it is active, and calendars are not read.
  enum DemoData {
    static let workCalendarID = "demo-work"
    static let holidayCalendarID = "demo-holidays"

    static var isRequested: Bool { ProcessInfo.processInfo.arguments.contains("-demo") }

    /// In demo mode the app's "now" is today at 21:30, so screenshots always show the
    /// evening state, whenever they are taken.
    static var referenceDate: Date? {
      guard isRequested else { return nil }
      return Calendar.current.date(bySettingHour: 21, minute: 30, second: 0, of: .now)
    }

    /// `-demo-screen work-hours|on-call|days-off|calendars` opens that screen at launch (for screenshots).
    static var initialScreen: Screen? {
      let arguments = ProcessInfo.processInfo.arguments
      guard let index = arguments.firstIndex(of: "-demo-screen"), index + 1 < arguments.count else {
        return nil
      }
      return Screen(rawValue: arguments[index + 1])
    }

    static func calendarName(for id: String) -> String? {
      switch id {
      case workCalendarID: String(localized: "Work", comment: "Demo calendar name")
      case holidayCalendarID: String(localized: "Holidays (CH)", comment: "Demo calendar name")
      default: nil
      }
    }

    static func config(now: Date = .now, calendar: Calendar = .current) -> Config {
      let today = calendar.startOfDay(for: now)
      func at(_ days: Int, _ hour: Int = 0, _ minute: Int = 0) -> Date {
        let day = calendar.date(byAdding: .day, value: days, to: today) ?? today
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
      }
      func stamp(_ days: Int) -> DayStamp { DayStamp(at(days), calendar: calendar) }
      func nextDate(month: Int, day: Int) -> DayStamp {
        let year = calendar.component(.year, from: now)
        let candidate = DayStamp(year: year, month: month, day: day)
        return candidate < DayStamp(now, calendar: calendar)
          ? DayStamp(year: year + 1, month: month, day: day) : candidate
      }

      let platformOnCall = String(localized: "Platform on-call", comment: "Demo on-call shift")
      // The evening meeting falls on the next workday, so "available tomorrow" reads 8:00
      // in screenshots taken on any day.
      let nextWorkday =
        (1...7).first { offset in
          let weekday = calendar.component(.weekday, from: at(offset))
          return Config.default.workDay(for: at(offset), calendar: calendar).isWorkday
            && weekday != 0
        } ?? 1
      var config = Config.default
      config.onCall = [
        OnCallShift(start: at(-12, 17), end: at(-5, 8), note: platformOnCall),
        OnCallShift(start: at(8, 17), end: at(15, 8), note: platformOnCall),
      ]
      config.daysOff = [
        DayOff(
          name: String(localized: "Dentist", comment: "Demo day off"), firstDay: stamp(12),
          lastDay: stamp(12)),
        DayOff(
          name: String(localized: "Ski week", comment: "Demo day off"), firstDay: stamp(30),
          lastDay: stamp(34)),
      ]
      config.holidayCalendarIDs = [holidayCalendarID]
      config.workCalendarIDs = [workCalendarID]
      config.meetingsExtendHours = true
      config.importedOnCall = [
        OnCallShift(
          start: at(22, 17), end: at(29, 8),
          note: String(localized: "On call – Payments", comment: "Demo on-call event"))
      ]
      config.importedMeetings = [
        OnCallShift(
          start: at(nextWorkday, 19), end: at(nextWorkday, 20),
          note: String(localized: "Release sync with US team", comment: "Demo meeting")),
        OnCallShift(
          start: at(6, 7, 30), end: at(6, 8, 30),
          note: String(localized: "Incident review", comment: "Demo meeting")),
      ]
      config.importedDaysOff = [
        (String(localized: "Christmas Day", comment: "Demo holiday"), nextDate(month: 12, day: 25)),
        (
          String(localized: "St. Stephen's Day", comment: "Demo holiday"),
          nextDate(month: 12, day: 26)
        ),
        (String(localized: "New Year's Day", comment: "Demo holiday"), nextDate(month: 1, day: 1)),
        (String(localized: "Berchtold's Day", comment: "Demo holiday"), nextDate(month: 1, day: 2)),
      ].map { DayOff(name: $0.0, firstDay: $0.1, lastDay: $0.1) }
        .sorted { $0.firstDay < $1.firstDay }
      return config
    }
  }
#endif
