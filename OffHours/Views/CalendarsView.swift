import EventKit
import SwiftUI

struct CalendarsView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        List {
            if !model.hasCalendarAccess {
                Section {
                    Button("Allow calendar access") {
                        Task { await model.requestCalendarAccess() }
                    }
                    if model.calendarAccess == .denied || model.calendarAccess == .restricted {
                        Text("Calendar access was denied. Enable it in Settings › Privacy & Security › Calendars.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                } footer: {
                    Text("Calendars are read on this device only.")
                }
            }

            Section {
                CalendarPicker(title: "Holiday calendar", selection: $model.config.holidayCalendarIDs)
            } footer: {
                Text("Optional. Every day with an event in this calendar counts as a day off, e.g. a public holidays calendar.")
            }

            Section {
                CalendarPicker(title: "Work calendar", selection: $model.config.workCalendarIDs)
            } footer: {
                Text("Optional. Events whose title contains one of the keywords below become on-call shifts or days off.")
            }

            if !model.config.workCalendarIDs.isEmpty {
                Section {
                    KeywordField(title: "On call", keywords: $model.config.onCallKeywords)
                    KeywordField(title: "Day off", keywords: $model.config.dayOffKeywords)
                    Button("Reset keywords") {
                        model.config.onCallKeywords = CalendarImport.defaultOnCallKeywords
                        model.config.dayOffKeywords = CalendarImport.defaultDayOffKeywords
                    }
                } header: {
                    Text("Work calendar keywords")
                } footer: {
                    Text("Comma separated, not case sensitive. If a title matches both, it counts as on call.")
                }
            }

            if model.config.usesCalendars && model.hasCalendarAccess {
                Section("Imported") {
                    if model.config.importedOnCall.isEmpty && model.config.importedDaysOff.isEmpty {
                        Text("Nothing in the next \(CalendarSync.lookaheadDays) days").foregroundStyle(.secondary)
                    }
                    ForEach(model.config.importedOnCall.prefix(10)) { shift in
                        ImportedRow(icon: "phone.fill", tint: .orange, title: shift.note,
                                    detail: "\(shift.start.formatted(date: .abbreviated, time: .shortened)) – \(shift.end.formatted(date: .abbreviated, time: .shortened))")
                    }
                    ForEach(model.config.importedDaysOff.prefix(10)) { dayOff in
                        ImportedRow(icon: "sun.max.fill", tint: .indigo, title: dayOff.name, detail: dayOff.rangeText)
                    }
                }
            }
        }
        .navigationTitle("Calendars")
        .refreshable { model.syncCalendars() }
    }
}

/// Picks zero or one calendar. Stored as an array so more could be supported later.
private struct CalendarPicker: View {
    @Environment(AppModel.self) private var model
    let title: String
    @Binding var selection: [String]

    var body: some View {
        NavigationLink {
            CalendarChoiceList(title: title, selection: $selection)
        } label: {
            LabeledContent(title, value: selection.first.map(model.calendarName(for:)) ?? "None")
        }
        .disabled(!model.hasCalendarAccess)
    }
}

/// A hand-rolled list instead of `Picker(.navigationLink)`, which renders blank when the
/// parent list changes shape (sections appearing) while the picker is pushed.
private struct CalendarChoiceList: View {
    @Environment(AppModel.self) private var model
    @Environment(\.dismiss) private var dismiss
    let title: String
    @Binding var selection: [String]

    var body: some View {
        List {
            Section {
                row(id: nil, name: "None", color: nil)
            }
            ForEach(sources, id: \.self) { source in
                Section(source) {
                    ForEach(model.calendars.filter { $0.source.title == source }, id: \.calendarIdentifier) { calendar in
                        row(id: calendar.calendarIdentifier, name: calendar.title, color: Color(cgColor: calendar.cgColor))
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var sources: [String] {
        var seen = Set<String>()
        return model.calendars.map(\.source.title).filter { seen.insert($0).inserted }
    }

    private func row(id: String?, name: String, color: Color?) -> some View {
        Button {
            selection = id.map { [$0] } ?? []
            dismiss()
        } label: {
            HStack(spacing: 12) {
                if let color {
                    Circle().fill(color).frame(width: 12, height: 12)
                }
                Text(name).foregroundStyle(.primary)
                Spacer()
                if selection.first == id {
                    Image(systemName: "checkmark").foregroundStyle(Color.accentColor)
                }
            }
        }
        .tint(.primary)
    }
}

private struct KeywordField: View {
    let title: String
    @Binding var keywords: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.footnote).foregroundStyle(.secondary)
            // Joined/split without trimming so typing spaces and commas round-trips exactly;
            // CalendarImport trims and lowercases when matching.
            TextField(title, text: Binding(
                get: { keywords.joined(separator: ",") },
                set: { keywords = $0.split(separator: ",", omittingEmptySubsequences: false).map(String.init) }
            ), axis: .vertical)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
    }
}

struct ImportedRow: View {
    let icon: String
    let tint: Color
    let title: String
    let detail: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(tint).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title.isEmpty ? "Untitled" : title)
                Text(detail).font(.footnote).foregroundStyle(.secondary)
            }
        }
    }
}

extension DayOff {
    var rangeText: String {
        let calendar = Calendar.current
        let first = firstDay.startDate(calendar: calendar).formatted(date: .abbreviated, time: .omitted)
        guard lastDay != firstDay else { return first }
        let last = lastDay.startDate(calendar: calendar).formatted(date: .abbreviated, time: .omitted)
        return "\(first) – \(last)"
    }
}
