import SwiftUI

struct WorkHoursView: View {
    @Environment(AppModel.self) private var model

    /// Weekday indices (0 = Sunday) in the user's locale order.
    private var orderedDays: [Int] {
        let first = Calendar.current.firstWeekday - 1
        return (0..<7).map { (first + $0) % 7 }
    }

    var body: some View {
        @Bindable var model = model

        List {
            Section {
                ForEach(orderedDays, id: \.self) { index in
                    DayRow(name: Calendar.current.weekdaySymbols[index], day: $model.config.week[index])
                }
            } footer: {
                Text("Work apps are available during these hours and blocked in the evening, early morning and on days that aren't workdays.")
            }

            Section {
                Button("Copy Monday's hours to all workdays") {
                    let monday = model.config.week[1]
                    for i in model.config.week.indices where model.config.week[i].isWorkday {
                        model.config.week[i].start = monday.start
                        model.config.week[i].end = monday.end
                    }
                }
            }
        }
        .navigationTitle("Work hours")
    }
}

private struct DayRow: View {
    let name: String
    @Binding var day: WorkDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(name, isOn: $day.isWorkday)
            if day.isWorkday {
                HStack {
                    DatePicker("From", selection: $day.start.asDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                    Text("–")
                    DatePicker("To", selection: $day.end.asDate, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                if !day.hasValidHours {
                    Text("End must be after start. This day is treated as blocked.")
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
        }
    }
}

extension Binding where Value == TimeOfDay {
    var asDate: Binding<Date> {
        Binding<Date>(
            get: { wrappedValue.date(on: .now, calendar: .current) ?? .now },
            set: { newValue in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                wrappedValue = TimeOfDay(hour: c.hour ?? 0, minute: c.minute ?? 0)
            }
        )
    }
}
