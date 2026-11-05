import FamilyControls
import SwiftUI

struct ContentView: View {
  @Environment(AppModel.self) private var model
  @State private var showingPicker = false

  var body: some View {
    @Bindable var model = model

    NavigationStack {
      List {
        Section {
          StatusCard()
        }

        if !model.isAuthorized {
          Section {
            Button("Allow Screen Time access") {
              Task { await model.requestAuthorization() }
            }
            if let error = model.authorizationError {
              Text(error).font(.footnote).foregroundStyle(.red)
            }
          } footer: {
            Text("Off-hours uses Screen Time to block your work apps. Nothing leaves your device.")
          }
        }

        Section {
          Button {
            showingPicker = true
          } label: {
            LabeledContent("Work apps") {
              Text(model.selectionCount == 0 ? "None selected" : "\(model.selectionCount) selected")
            }
          }
          .disabled(!model.isAuthorized)
          if model.selectionCount > 0 {
            SelectionPreview(selection: model.selection)
          }
        } footer: {
          Text(
            "Pick the apps, categories and websites to block outside work hours, e.g. Slack, Teams, Mail, Outlook."
          )
        }

        Section("Schedule") {
          NavigationLink {
            WorkHoursView()
          } label: {
            LabeledContent("Work hours", value: weekSummary)
          }
          NavigationLink {
            OnCallView()
          } label: {
            LabeledContent("On call", value: onCallSummary)
          }
          NavigationLink {
            DaysOffView()
          } label: {
            LabeledContent("Days off & holidays", value: daysOffSummary)
          }
          NavigationLink {
            CalendarsView()
          } label: {
            LabeledContent("Calendars", value: calendarsSummary)
          }
          Toggle("Scheduling on", isOn: $model.config.isEnabled)
        }

        Section {
          if model.config.override != nil {
            Button("End override", role: .destructive) { model.clearOverride() }
          } else {
            Button("Allow work apps for 1 hour") { model.setOverride(blocked: false, for: 3600) }
            Button("Block work apps for 1 hour") { model.setOverride(blocked: true, for: 3600) }
            Button("Flip until next scheduled change") { model.setOverrideUntilNextChange() }
          }
        } header: {
          Text("Override")
        } footer: {
          Text("Overrides beat every schedule, including on-call and days off.")
        }
      }
      .navigationTitle("Off-hours")
      .familyActivityPicker(isPresented: $showingPicker, selection: $model.selection)
    }
  }

  private var weekSummary: String {
    let days = model.config.week.filter(\.isWorkday)
    guard let first = days.first else { return "No workdays" }
    let sameHours = days.allSatisfy { $0.start == first.start && $0.end == first.end }
    return sameHours
      ? "\(days.count) days, \(first.start.formatted)–\(first.end.formatted)" : "\(days.count) days"
  }

  private var onCallSummary: String {
    let upcoming = model.config.allOnCall.filter { $0.end > .now }.count
    return upcoming == 0 ? "None" : "\(upcoming) upcoming"
  }

  private var calendarsSummary: String {
    let count = model.config.holidayCalendarIDs.count + model.config.workCalendarIDs.count
    return count == 0 ? "None" : "\(count) selected"
  }

  private var daysOffSummary: String {
    let today = DayStamp(.now, calendar: .current)
    let upcoming = model.config.allDaysOff.filter { $0.lastDay >= today }.count
    return upcoming == 0 ? "None" : "\(upcoming) upcoming"
  }
}

private struct SelectionPreview: View {
  let selection: FamilyActivitySelection

  var body: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 6) {
        ForEach(Array(selection.applicationTokens), id: \.self) { token in
          Label(token).labelStyle(.iconOnly)
            .scaleEffect(1.7)
            .frame(width: 40, height: 40)
        }
        ForEach(Array(selection.categoryTokens), id: \.self) { token in
          Label(token).labelStyle(.iconOnly)
            .scaleEffect(1.7)
            .frame(width: 40, height: 40)
        }
      }
      .padding(.vertical, 4)
    }
  }
}
