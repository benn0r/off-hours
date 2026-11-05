import Foundation

/// Decides whether work apps are blocked at a given moment, and when that next changes.
///
/// Precedence (highest first):
/// 1. Scheduling turned off  → available
/// 2. Manual override        → whatever the override says
/// 3. On-call shift          → available
/// 4. Day off / holiday      → blocked all day
/// 5. Not a workday          → blocked all day
/// 6. Weekly work hours      → available inside, blocked outside (evenings, mornings)
struct Policy {
    enum Reason: Equatable {
        case disabled
        case override(until: Date)
        case onCall(until: Date)
        case dayOff(name: String)
        case notWorkday
        case outsideHours
        case workHours
    }

    struct Status: Equatable {
        var blocked: Bool
        var reason: Reason
    }

    var config: Config
    var calendar: Calendar = .current

    func status(at date: Date) -> Status {
        guard config.isEnabled else { return Status(blocked: false, reason: .disabled) }

        if let override = config.override, date < override.until {
            return Status(blocked: override.blocked, reason: .override(until: override.until))
        }

        if let shift = config.onCall.filter({ $0.contains(date) }).max(by: { $0.end < $1.end }) {
            return Status(blocked: false, reason: .onCall(until: shift.end))
        }

        let day = DayStamp(date, calendar: calendar)
        if let off = config.daysOff.first(where: { $0.contains(day) }) {
            return Status(blocked: true, reason: .dayOff(name: off.name))
        }

        let workDay = config.workDay(for: date, calendar: calendar)
        guard workDay.isWorkday, workDay.hasValidHours else {
            return Status(blocked: true, reason: .notWorkday)
        }

        let c = calendar.dateComponents([.hour, .minute], from: date)
        let minutes = (c.hour ?? 0) * 60 + (c.minute ?? 0)
        if workDay.start.minutes <= minutes && minutes < workDay.end.minutes {
            return Status(blocked: false, reason: .workHours)
        }
        return Status(blocked: true, reason: .outsideHours)
    }

    /// The upcoming moments at which `status(at:).blocked` flips, in order.
    func transitions(after date: Date, limit: Int, horizonDays: Int = 21) -> [Date] {
        let startOfToday = calendar.startOfDay(for: date)
        guard let horizon = calendar.date(byAdding: .day, value: horizonDays, to: startOfToday) else { return [] }

        var candidates = Set<Date>()
        for offset in 0...horizonDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }
            candidates.insert(day) // midnight: day-off / weekday boundaries
            let workDay = config.workDay(for: day, calendar: calendar)
            if workDay.isWorkday {
                workDay.start.date(on: day, calendar: calendar).map { candidates.insert($0) }
                workDay.end.date(on: day, calendar: calendar).map { candidates.insert($0) }
            }
        }
        for shift in config.onCall {
            candidates.insert(shift.start)
            candidates.insert(shift.end)
        }
        if let override = config.override { candidates.insert(override.until) }

        var result: [Date] = []
        var current = status(at: date).blocked
        for candidate in candidates.filter({ $0 > date && $0 <= horizon }).sorted() {
            let blocked = status(at: candidate).blocked
            guard blocked != current else { continue }
            result.append(candidate)
            current = blocked
            if result.count == limit { break }
        }
        return result
    }
}
