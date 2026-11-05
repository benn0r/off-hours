import SwiftUI

struct DaysOffView: View {
    @Environment(AppModel.self) private var model
    @State private var editing: DayOff?

    private var today: DayStamp { DayStamp(.now, calendar: .current) }

    private var upcoming: [DayOff] {
        model.config.daysOff.filter { $0.lastDay >= today }.sorted { $0.firstDay < $1.firstDay }
    }

    private var past: [DayOff] {
        model.config.daysOff.filter { $0.lastDay < today }.sorted { $0.firstDay > $1.firstDay }
    }

    var body: some View {
        List {
            Section {
                if upcoming.isEmpty {
                    Text("No upcoming days off").foregroundStyle(.secondary)
                }
                ForEach(upcoming) { row($0) }
                    .onDelete { delete(upcoming, at: $0) }
            } header: {
                Text("Upcoming")
            } footer: {
                Text("Work apps are blocked all day on vacation days and holidays, unless you're on call.")
            }

            let imported = model.config.importedDaysOff.filter { $0.lastDay >= today }
            if !imported.isEmpty {
                Section {
                    ForEach(imported) { dayOff in
                        ImportedRow(icon: "calendar", tint: .indigo, title: dayOff.name, detail: dayOff.rangeText)
                    }
                } header: {
                    Text("From calendars")
                } footer: {
                    Text("Edit these in your calendar.")
                }
            }

            if !past.isEmpty {
                Section("Past") {
                    ForEach(past) { row($0) }
                        .onDelete { delete(past, at: $0) }
                    Button("Clear past days off", role: .destructive) {
                        let today = today
                        model.config.daysOff.removeAll { $0.lastDay < today }
                    }
                }
            }
        }
        .navigationTitle("Days off")
        .toolbar {
            Button("Add", systemImage: "plus") {
                let today = DayStamp(.now, calendar: .current)
                editing = DayOff(name: "", firstDay: today, lastDay: today)
            }
        }
        .sheet(item: $editing) { dayOff in
            DayOffEditor(dayOff: dayOff) { saved in
                if let i = model.config.daysOff.firstIndex(where: { $0.id == saved.id }) {
                    model.config.daysOff[i] = saved
                } else {
                    model.config.daysOff.append(saved)
                }
            }
        }
    }

    private func row(_ dayOff: DayOff) -> some View {
        Button {
            editing = dayOff
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(dayOff.name.isEmpty ? "Day off" : dayOff.name).foregroundStyle(.primary)
                Text(dayOff.rangeText).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }

    private func delete(_ list: [DayOff], at offsets: IndexSet) {
        let ids = Set(offsets.map { list[$0].id })
        model.config.daysOff.removeAll { ids.contains($0.id) }
    }
}

private struct DayOffEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State var dayOff: DayOff
    let onSave: (DayOff) -> Void

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name, e.g. Christmas, Vacation", text: $dayOff.name)
                DatePicker("First day", selection: $dayOff.firstDay.asDate, displayedComponents: .date)
                DatePicker("Last day", selection: $dayOff.lastDay.asDate,
                           in: dayOff.firstDay.startDate(calendar: .current)...,
                           displayedComponents: .date)
            }
            .onChange(of: dayOff.firstDay) { _, first in
                if dayOff.lastDay < first { dayOff.lastDay = first }
            }
            .navigationTitle("Day off")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(dayOff)
                        dismiss()
                    }
                }
            }
        }
    }
}

extension Binding where Value == DayStamp {
    var asDate: Binding<Date> {
        Binding<Date>(
            get: { wrappedValue.startDate(calendar: .current) },
            set: { wrappedValue = DayStamp($0, calendar: .current) }
        )
    }
}
