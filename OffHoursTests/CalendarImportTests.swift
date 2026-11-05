import XCTest

final class CalendarImportTests: XCTestCase {
    private var calendar: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "Europe/Zurich")!
        return c
    }()

    private func date(_ day: Int, _ hour: Int, _ minute: Int = 0, second: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 12, day: day, hour: hour, minute: minute, second: second))!
    }

    private func config(holiday: String? = nil, work: String? = nil) -> Config {
        var c = Config.default
        c.holidayCalendarIDs = holiday.map { [$0] } ?? []
        c.workCalendarIDs = work.map { [$0] } ?? []
        return c
    }

    func testHolidayCalendarAllDayEventsBecomeDaysOff() {
        // All-day events from EventKit end at 23:59:59 on the last day.
        let entries = [CalendarEntry(calendarID: "hol", title: "Christmas", start: date(25, 0),
                                     end: date(26, 23, 59, second: 59), isAllDay: true)]
        let result = CalendarImport.classify(entries, config: config(holiday: "hol"), calendar: calendar)
        XCTAssertEqual(result.daysOff.count, 1)
        XCTAssertEqual(result.daysOff[0].firstDay, DayStamp(year: 2026, month: 12, day: 25))
        XCTAssertEqual(result.daysOff[0].lastDay, DayStamp(year: 2026, month: 12, day: 26))
        XCTAssertTrue(result.onCall.isEmpty)
    }

    func testEventEndingAtMidnightDoesNotSpillIntoNextDay() {
        let entries = [CalendarEntry(calendarID: "hol", title: "X", start: date(24, 0), end: date(25, 0), isAllDay: true)]
        let result = CalendarImport.classify(entries, config: config(holiday: "hol"), calendar: calendar)
        XCTAssertEqual(result.daysOff[0].lastDay, DayStamp(year: 2026, month: 12, day: 24))
    }

    func testWorkCalendarKeywords() {
        let entries = [
            CalendarEntry(calendarID: "work", title: "Pikett Team A", start: date(7, 17), end: date(14, 8), isAllDay: false),
            CalendarEntry(calendarID: "work", title: "Vacation 🏝", start: date(21, 0), end: date(31, 23, 59, second: 59), isAllDay: true),
            CalendarEntry(calendarID: "work", title: "Sprint planning", start: date(8, 10), end: date(8, 11), isAllDay: false),
            CalendarEntry(calendarID: "work", title: "On-call handover (holiday cover)", start: date(3, 9), end: date(3, 10), isAllDay: false),
        ]
        let result = CalendarImport.classify(entries, config: config(work: "work"), calendar: calendar)
        XCTAssertEqual(result.onCall.map(\.note), ["On-call handover (holiday cover)", "Pikett Team A"])
        XCTAssertEqual(result.daysOff.map(\.name), ["Vacation 🏝"])
    }

    func testUnselectedCalendarsAndNoHolidayCalendarAreIgnored() {
        let entries = [
            CalendarEntry(calendarID: "hol", title: "Christmas", start: date(25, 0), end: date(25, 23, 59), isAllDay: true),
            CalendarEntry(calendarID: "private", title: "On call for mum", start: date(5, 0), end: date(6, 0), isAllDay: false),
        ]
        // Only a work calendar selected, no holiday calendar.
        let result = CalendarImport.classify(entries, config: config(work: "work"), calendar: calendar)
        XCTAssertTrue(result.onCall.isEmpty)
        XCTAssertTrue(result.daysOff.isEmpty)
    }

    func testImportIsDeterministic() {
        let entries = [CalendarEntry(calendarID: "hol", title: "X", start: date(1, 0), end: date(1, 23, 59), isAllDay: true)]
        let a = CalendarImport.classify(entries, config: config(holiday: "hol"), calendar: calendar)
        let b = CalendarImport.classify(entries, config: config(holiday: "hol"), calendar: calendar)
        XCTAssertEqual(a.daysOff, b.daysOff)
    }

    func testImportedEntriesAffectPolicy() {
        var c = Config.default
        c.importedDaysOff = [DayOff(name: "Holiday", firstDay: DayStamp(year: 2026, month: 12, day: 8),
                                    lastDay: DayStamp(year: 2026, month: 12, day: 8))]
        c.importedOnCall = [OnCallShift(start: date(9, 20), end: date(9, 23))]
        let p = Policy(config: c, calendar: calendar)
        XCTAssertEqual(p.status(at: date(8, 10)).blocked, true)   // Tuesday, imported holiday
        XCTAssertEqual(p.status(at: date(9, 21)).blocked, false)  // Wednesday evening, imported on-call
    }

    func testOldSavedConfigStillDecodes() throws {
        let old = #"{"isEnabled":true,"week":[],"onCall":[],"daysOff":[]}"#
        let decoded = try JSONDecoder().decode(Config.self, from: Data(old.utf8))
        XCTAssertTrue(decoded.holidayCalendarIDs.isEmpty)
        XCTAssertEqual(decoded.onCallKeywords, CalendarImport.defaultOnCallKeywords)
    }
}
