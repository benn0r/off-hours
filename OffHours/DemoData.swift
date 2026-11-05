#if DEBUG
  import Foundation

  /// Fictional schedule for screenshots and manual testing: launch a Debug build with `-demo`.
  /// Nothing is saved or enforced while it is active, and calendars are not read.
  enum DemoData {
    static let workCalendarID = "demo-work"
    static let holidayCalendarID = "demo-holidays"

    static var isRequested: Bool { ProcessInfo.processInfo.arguments.contains("-demo") }

    static func calendarName(for id: String) -> String? {
      switch id {
      case workCalendarID: "Work"
      case holidayCalendarID: "Holidays (CH)"
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

      var config = Config.default
      config.onCall = [
        OnCallShift(start: at(-12, 17), end: at(-5, 8), note: "Platform on-call"),
        OnCallShift(start: at(8, 17), end: at(15, 8), note: "Platform on-call"),
      ]
      config.daysOff = [
        DayOff(name: "Dentist", firstDay: stamp(12), lastDay: stamp(12)),
        DayOff(name: "Ski week", firstDay: stamp(30), lastDay: stamp(34)),
      ]
      config.holidayCalendarIDs = [holidayCalendarID]
      config.workCalendarIDs = [workCalendarID]
      config.meetingsExtendHours = true
      config.importedOnCall = [
        OnCallShift(start: at(22, 17), end: at(29, 8), note: "Pikett – Payments")
      ]
      config.importedMeetings = [
        OnCallShift(start: at(1, 19), end: at(1, 20), note: "Release sync with US team"),
        OnCallShift(start: at(6, 7, 30), end: at(6, 8, 30), note: "Incident review"),
      ]
      config.importedDaysOff = [
        ("Weihnachten", nextDate(month: 12, day: 25)),
        ("Stephanstag", nextDate(month: 12, day: 26)),
        ("Neujahr", nextDate(month: 1, day: 1)),
        ("Berchtoldstag", nextDate(month: 1, day: 2)),
      ].map { DayOff(name: $0.0, firstDay: $0.1, lastDay: $0.1) }
        .sorted { $0.firstDay < $1.firstDay }
      return config
    }
  }
#endif
