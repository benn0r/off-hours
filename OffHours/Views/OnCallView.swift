import SwiftUI

struct OnCallView: View {
  @Environment(AppModel.self) private var model
  @State private var editing: OnCallShift?

  private var upcoming: [OnCallShift] {
    model.config.onCall.filter { $0.end > .now }.sorted { $0.start < $1.start }
  }

  private var past: [OnCallShift] {
    model.config.onCall.filter { $0.end <= .now }.sorted { $0.start > $1.start }
  }

  var body: some View {
    List {
      Section {
        if upcoming.isEmpty {
          Text("No upcoming shifts").foregroundStyle(.secondary)
        }
        ForEach(upcoming) { shift in
          row(shift)
        }
        .onDelete { delete(upcoming, at: $0) }
      } header: {
        Text("Upcoming")
      } footer: {
        Text(
          "While on call, work apps stay available, even in the evening, on weekends and on days off."
        )
      }

      let imported = model.config.importedOnCall.filter { $0.end > .now }
      if !imported.isEmpty {
        Section {
          ForEach(imported) { shift in
            ImportedRow(
              icon: "calendar", tint: .orange, title: shift.note,
              detail:
                "\(shift.start.formatted(date: .abbreviated, time: .shortened)) – \(shift.end.formatted(date: .abbreviated, time: .shortened))"
            )
          }
        } header: {
          Text("From work calendar")
        } footer: {
          Text("Edit these in your calendar.")
        }
      }

      if !past.isEmpty {
        Section("Past") {
          ForEach(past) { row($0) }
            .onDelete { delete(past, at: $0) }
          Button("Clear past shifts", role: .destructive) {
            model.config.onCall.removeAll { $0.end <= .now }
          }
        }
      }
    }
    .navigationTitle("On call")
    .toolbar {
      Button("Add", systemImage: "plus") { editing = .newShift() }
    }
    .sheet(item: $editing) { shift in
      OnCallEditor(shift: shift) { saved in
        if let i = model.config.onCall.firstIndex(where: { $0.id == saved.id }) {
          model.config.onCall[i] = saved
        } else {
          model.config.onCall.append(saved)
        }
      }
    }
  }

  private func row(_ shift: OnCallShift) -> some View {
    Button {
      editing = shift
    } label: {
      VStack(alignment: .leading, spacing: 2) {
        Text(shift.note.isEmpty ? "On call" : shift.note).foregroundStyle(.primary)
        Text(
          "\(shift.start.formatted(date: .abbreviated, time: .shortened)) – \(shift.end.formatted(date: .abbreviated, time: .shortened))"
        )
        .font(.footnote)
        .foregroundStyle(.secondary)
      }
    }
    .tint(.primary)
  }

  private func delete(_ list: [OnCallShift], at offsets: IndexSet) {
    let ids = Set(offsets.map { list[$0].id })
    model.config.onCall.removeAll { ids.contains($0.id) }
  }
}

extension OnCallShift {
  /// Default: a week-long rotation starting at the next 17:00.
  static func newShift() -> OnCallShift {
    let calendar = Calendar.current
    var start = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: .now) ?? .now
    if start < .now { start = calendar.date(byAdding: .day, value: 1, to: start) ?? start }
    let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
    return OnCallShift(start: start, end: end)
  }
}

private struct OnCallEditor: View {
  @Environment(\.dismiss) private var dismiss
  @State var shift: OnCallShift
  let onSave: (OnCallShift) -> Void

  var body: some View {
    NavigationStack {
      Form {
        TextField("Note (optional)", text: $shift.note)
        DatePicker("Starts", selection: $shift.start)
        DatePicker("Ends", selection: $shift.end, in: shift.start...)
        Section("Quick length") {
          HStack {
            ForEach([("Tonight", 0), ("1 day", 1), ("Weekend", 3), ("1 week", 7)], id: \.0) {
              label, days in
              Button(label) { setLength(days: days) }
                .buttonStyle(.bordered)
            }
          }
        }
      }
      .navigationTitle("On-call shift")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Save") {
            onSave(shift)
            dismiss()
          }
          .disabled(shift.end <= shift.start)
        }
      }
    }
  }

  private func setLength(days: Int) {
    let calendar = Calendar.current
    if days == 0 {
      // Until 08:00 the next morning.
      let nextDay = calendar.date(byAdding: .day, value: 1, to: shift.start) ?? shift.start
      shift.end = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: nextDay) ?? nextDay
    } else {
      shift.end = calendar.date(byAdding: .day, value: days, to: shift.start) ?? shift.start
    }
  }
}
