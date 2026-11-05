import XCTest

final class PolicyTests: XCTestCase {
  private var calendar: Calendar = {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "Europe/Zurich")!
    return c
  }()

  /// 2026-11-02 is a Monday.
  private func date(_ day: Int, _ hour: Int, _ minute: Int = 0, month: Int = 11) -> Date {
    calendar.date(
      from: DateComponents(year: 2026, month: month, day: day, hour: hour, minute: minute))!
  }

  private func policy(_ configure: (inout Config) -> Void = { _ in }) -> Policy {
    var config = Config.default
    configure(&config)
    return Policy(config: config, calendar: calendar)
  }

  func testWorkHoursOnWeekday() {
    let p = policy()
    XCTAssertEqual(p.status(at: date(2, 10)), .init(blocked: false, reason: .workHours))
    XCTAssertEqual(p.status(at: date(2, 7, 59)).blocked, true)
    XCTAssertEqual(p.status(at: date(2, 18)), .init(blocked: true, reason: .outsideHours))
    XCTAssertEqual(p.status(at: date(2, 21)).blocked, true)
  }

  func testWeekendIsBlockedAllDay() {
    let p = policy()
    // Saturday
    XCTAssertEqual(p.status(at: date(7, 12)), .init(blocked: true, reason: .notWorkday))
    XCTAssertEqual(p.status(at: date(8, 12)).blocked, true)  // Sunday
  }

  func testDayOffBlocksWorkday() {
    let p = policy {
      $0.daysOff = [
        DayOff(
          name: "Vacation",
          firstDay: DayStamp(year: 2026, month: 11, day: 3),
          lastDay: DayStamp(year: 2026, month: 11, day: 4))
      ]
    }
    XCTAssertEqual(
      p.status(at: date(3, 10)), .init(blocked: true, reason: .dayOff(name: "Vacation")))
    XCTAssertEqual(p.status(at: date(4, 10)).blocked, true)
    XCTAssertEqual(p.status(at: date(5, 10)).blocked, false)
  }

  func testOnCallBeatsEveningsAndDaysOff() {
    let shiftEnd = date(9, 8)
    let p = policy {
      $0.onCall = [OnCallShift(start: date(6, 17), end: shiftEnd)]
      $0.daysOff = [
        DayOff(
          name: "Holiday",
          firstDay: DayStamp(year: 2026, month: 11, day: 7),
          lastDay: DayStamp(year: 2026, month: 11, day: 7))
      ]
    }
    XCTAssertEqual(
      p.status(at: date(6, 22)), .init(blocked: false, reason: .onCall(until: shiftEnd)))
    XCTAssertEqual(p.status(at: date(7, 12)).blocked, false)
    XCTAssertEqual(p.status(at: date(9, 8, 30)).blocked, false)  // Monday work hours after shift
    XCTAssertEqual(p.status(at: date(9, 7, 59)).blocked, false)  // still on call
  }

  func testOverrideBeatsEverything() {
    let p = policy {
      $0.override = Override(blocked: false, until: date(7, 14))
    }
    XCTAssertEqual(p.status(at: date(7, 12)).blocked, false)
    XCTAssertEqual(p.status(at: date(7, 14)).blocked, true)
  }

  func testDisabled() {
    let p = policy { $0.isEnabled = false }
    XCTAssertEqual(p.status(at: date(7, 12)), .init(blocked: false, reason: .disabled))
    XCTAssertTrue(p.transitions(after: date(2, 10), limit: 5).isEmpty)
  }

  func testTransitionsOnlyIncludeRealFlips() {
    let p = policy()
    // Friday 10:00 → blocked at 18:00, then available again Monday 08:00 (weekend midnights aren't flips).
    XCTAssertEqual(
      p.transitions(after: date(6, 10), limit: 3), [date(6, 18), date(9, 8), date(9, 18)])
  }

  func testTransitionsAroundOnCallShift() {
    let p = policy { $0.onCall = [OnCallShift(start: date(2, 20), end: date(3, 6))] }
    XCTAssertEqual(
      p.transitions(after: date(2, 10), limit: 4),
      [date(2, 18), date(2, 20), date(3, 6), date(3, 8)])
  }

  func testConfigRoundTrips() throws {
    var config = Config.default
    config.onCall = [OnCallShift(start: date(2, 20), end: date(3, 6), note: "Primary")]
    config.daysOff = [
      DayOff(
        name: "X", firstDay: DayStamp(year: 2026, month: 12, day: 25),
        lastDay: DayStamp(year: 2026, month: 12, day: 26))
    ]
    let decoded = try JSONDecoder().decode(Config.self, from: JSONEncoder().encode(config))
    XCTAssertEqual(decoded, config)
  }
}
