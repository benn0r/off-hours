import EventKit
import FamilyControls
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
  var config: Config {
    didSet {
      guard config != oldValue, !isDemo else { return }
      SharedStore.save(config)
      scheduleEnforce()
      if config.holidayCalendarIDs != oldValue.holidayCalendarIDs
        || config.workCalendarIDs != oldValue.workCalendarIDs
        || config.onCallKeywords != oldValue.onCallKeywords
        || config.dayOffKeywords != oldValue.dayOffKeywords
        || config.meetingsExtendHours != oldValue.meetingsExtendHours
        || config.meetingBufferMinutes != oldValue.meetingBufferMinutes
      {
        syncCalendars(debounce: true)
      }
    }
  }

  var selection: FamilyActivitySelection {
    didSet {
      guard selection != oldValue, !isDemo else { return }
      SharedStore.save(selection)
      scheduleEnforce()
    }
  }

  private(set) var authorizationStatus: AuthorizationStatus
  var authorizationError: String?

  @ObservationIgnored let eventStore = EKEventStore()
  private(set) var calendarAccess: EKAuthorizationStatus
  private(set) var calendars: [EKCalendar] = []
  @ObservationIgnored private var eventStoreObserver: NSObjectProtocol?
  @ObservationIgnored private var syncTask: Task<Void, Never>?

  /// Screen Time and DeviceActivity calls are slow; keep them off the main thread and coalesce bursts.
  @ObservationIgnored private let enforcementQueue = DispatchQueue(
    label: "offhours.enforcement", qos: .userInitiated)
  @ObservationIgnored private var pendingEnforcement: DispatchWorkItem?

  /// Debug builds launched with `-demo` show fictional data (see `DemoData`) and change nothing.
  @ObservationIgnored let isDemo: Bool

  init() {
    #if DEBUG
      isDemo = DemoData.isRequested
      config = isDemo ? DemoData.config() : SharedStore.loadConfig()
    #else
      isDemo = false
      config = SharedStore.loadConfig()
    #endif
    selection = SharedStore.loadSelection()
    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    calendarAccess = EKEventStore.authorizationStatus(for: .event)
    eventStoreObserver = NotificationCenter.default.addObserver(
      forName: .EKEventStoreChanged, object: eventStore, queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated { self?.syncCalendars() }
    }
    syncCalendars()
  }

  var hasCalendarAccess: Bool { isDemo || calendarAccess == .fullAccess }

  func requestCalendarAccess() async {
    _ = try? await eventStore.requestFullAccessToEvents()
    syncCalendars()
  }

  /// Applies the current config/selection (saved to the shared store) in the background.
  private func scheduleEnforce() {
    pendingEnforcement?.cancel()
    let work = DispatchWorkItem { Enforcer.refresh() }
    pendingEnforcement = work
    enforcementQueue.asyncAfter(deadline: .now() + 0.3, execute: work)
  }

  /// Reloads the calendar list and re-imports holidays / on-call shifts / meetings, off the main thread.
  func syncCalendars(debounce: Bool = false) {
    guard !isDemo else { return }
    syncTask?.cancel()
    syncTask = Task { [weak self] in
      if debounce { try? await Task.sleep(for: .milliseconds(400)) }
      guard let self, !Task.isCancelled else { return }

      let snapshot = self.config
      let store = self.eventStore
      let (current, synced) = await Task.detached(priority: .userInitiated) {
        let calendars =
          CalendarSync.isAuthorized
          ? store.calendars(for: .event).sorted {
            ($0.source.title, $0.title) < ($1.source.title, $1.title)
          }
          : []
        return (calendars, CalendarSync.syncing(snapshot, store: store))
      }.value
      guard !Task.isCancelled else { return }

      self.calendarAccess = EKEventStore.authorizationStatus(for: .event)
      // Only publish a new list when it actually changed, to avoid needless view rebuilds.
      if current.map(\.calendarIdentifier) != self.calendars.map(\.calendarIdentifier)
        || current.map(\.title) != self.calendars.map(\.title)
      {
        self.calendars = current
      }
      // Merge only the imported entries, so edits made while syncing aren't overwritten.
      var updated = self.config
      updated.importedOnCall = synced.importedOnCall
      updated.importedDaysOff = synced.importedDaysOff
      updated.importedMeetings = synced.importedMeetings
      if updated != self.config { self.config = updated }
    }
  }

  func calendarName(for id: String) -> String {
    #if DEBUG
      if let name = DemoData.calendarName(for: id) { return name }
    #endif
    return calendars.first { $0.calendarIdentifier == id }?.title
      ?? String(localized: "Unavailable calendar")
  }

  var policy: Policy { Policy(config: config) }

  var isAuthorized: Bool { isDemo || authorizationStatus == .approved }

  var selectionCount: Int {
    selection.applicationTokens.count + selection.categoryTokens.count
      + selection.webDomainTokens.count
  }

  func requestAuthorization() async {
    do {
      try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
      authorizationError = nil
    } catch {
      authorizationError = error.localizedDescription
    }
    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    scheduleEnforce()
  }

  /// Re-reads shared state (the extension may have cleared an expired override) and re-applies.
  func reload() {
    authorizationStatus = AuthorizationCenter.shared.authorizationStatus
    guard !isDemo else { return }
    config = SharedStore.loadConfig()
    scheduleEnforce()
    syncCalendars()
  }

  func setOverride(blocked: Bool, for duration: TimeInterval) {
    config.override = Override(blocked: blocked, until: .now.addingTimeInterval(duration))
  }

  /// Flip the current state until the schedule would next change anyway.
  func setOverrideUntilNextChange() {
    var withoutOverride = config
    withoutOverride.override = nil
    let policy = Policy(config: withoutOverride)
    let blocked = policy.status(at: .now).blocked
    guard let next = policy.transitions(after: .now, limit: 1).first else { return }
    config.override = Override(blocked: !blocked, until: next)
  }

  func clearOverride() {
    config.override = nil
  }
}
