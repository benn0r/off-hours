import SwiftUI

struct StatusCard: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        TimelineView(.periodic(from: .now, by: 30)) { context in
            let policy = model.policy
            let status = policy.status(at: context.date)
            let next = policy.transitions(after: context.date, limit: 1).first

            HStack(spacing: 16) {
                Image(systemName: status.blocked ? "moon.zzz.fill" : "briefcase.fill")
                    .font(.system(size: 34))
                    .foregroundStyle(status.blocked ? Color.indigo : Color.orange)
                    .frame(width: 48)

                VStack(alignment: .leading, spacing: 4) {
                    Text(status.blocked ? "Work apps blocked" : "Work apps available")
                        .font(.headline)
                    Text(describe(status.reason))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let next {
                        Text("\(status.blocked ? "Available" : "Blocked") \(relative(next, from: context.date))")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }

    private func describe(_ reason: Policy.Reason) -> String {
        switch reason {
        case .disabled: "Scheduling is turned off"
        case .override(let until): "Override until \(until.formatted(date: .omitted, time: .shortened))"
        case .onCall(let until): "On call until \(until.formatted(.dateTime.weekday().hour().minute()))"
        case .meeting(let title, let until):
            "\(title.isEmpty ? "Meeting" : title) until \(until.formatted(date: .omitted, time: .shortened))"
        case .dayOff(let name): name.isEmpty ? "Day off" : "Day off: \(name)"
        case .notWorkday: "Not a workday"
        case .outsideHours: "Outside work hours"
        case .workHours: "Work hours"
        }
    }

    private func relative(_ date: Date, from now: Date) -> String {
        let calendar = Calendar.current
        let time = date.formatted(date: .omitted, time: .shortened)
        if calendar.isDate(date, inSameDayAs: now) { return "at \(time)" }
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: now), calendar.isDate(date, inSameDayAs: tomorrow) {
            return "tomorrow at \(time)"
        }
        return "on \(date.formatted(.dateTime.weekday(.wide).day().month())) at \(time)"
    }
}
