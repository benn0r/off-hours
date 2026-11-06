import SwiftUI

struct StatusCard: View {
  @Environment(AppModel.self) private var model

  var body: some View {
    TimelineView(.periodic(from: .now, by: 30)) { context in
      let policy = model.policy
      let now = Self.now(context.date)
      let status = policy.status(at: now)
      let next = policy.transitions(after: now, limit: 1).first

      HStack(spacing: 16) {
        Image(systemName: status.blocked ? "moon.zzz.fill" : "briefcase.fill")
          .font(.system(size: 34))
          .foregroundStyle(status.blocked ? Color.indigo : Color.orange)
          .frame(width: 48)

        VStack(alignment: .leading, spacing: 4) {
          (status.blocked ? Text("Work apps blocked") : Text("Work apps available"))
            .font(.headline)
          Text(describe(status.reason))
            .font(.subheadline)
            .foregroundStyle(.secondary)
          if let next {
            Text(nextChange(blocked: status.blocked, at: next, from: now))
              .font(.footnote)
              .foregroundStyle(.secondary)
          }
        }
      }
      .padding(.vertical, 8)
    }
  }

  private static func now(_ date: Date) -> Date {
    #if DEBUG
      if let demo = DemoData.referenceDate { return demo }
    #endif
    return date
  }

  private func describe(_ reason: Policy.Reason) -> String {
    switch reason {
    case .disabled: String(localized: "Scheduling is turned off")
    case .override(let until):
      String(localized: "Override until \(until.formatted(date: .omitted, time: .shortened))")
    case .onCall(let until):
      String(localized: "On call until \(until.formatted(.dateTime.weekday().hour().minute()))")
    case .meeting(let title, let until):
      title.isEmpty
        ? String(localized: "Meeting until \(until.formatted(date: .omitted, time: .shortened))")
        : String(
          localized: "\(title) until \(until.formatted(date: .omitted, time: .shortened))",
          comment: "Status line during a meeting: meeting title, end time")
    case .dayOff(let name):
      name.isEmpty ? String(localized: "Day off") : String(localized: "Day off: \(name)")
    case .notWorkday: String(localized: "Not a workday")
    case .outsideHours: String(localized: "Outside work hours")
    case .workHours: String(localized: "Work hours")
    }
  }

  private func nextChange(blocked: Bool, at date: Date, from now: Date) -> String {
    let calendar = Calendar.current
    let time = date.formatted(date: .omitted, time: .shortened)
    if calendar.isDate(date, inSameDayAs: now) {
      return blocked
        ? String(localized: "Available at \(time)") : String(localized: "Blocked at \(time)")
    }
    if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now),
      calendar.isDate(date, inSameDayAs: tomorrow)
    {
      return blocked
        ? String(localized: "Available tomorrow at \(time)")
        : String(localized: "Blocked tomorrow at \(time)")
    }
    let day = date.formatted(.dateTime.weekday(.wide).day().month())
    return blocked
      ? String(localized: "Available on \(day) at \(time)")
      : String(localized: "Blocked on \(day) at \(time)")
  }
}
