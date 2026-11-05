import EventKit
import FamilyControls
import Foundation
import Observation

@MainActor
@Observable
final class AppModel {
    var config: Config {
        didSet {
            guard config != oldValue else { return }
            SharedStore.save(config)
            Enforcer.refresh()
            if config.holidayCalendarIDs != oldValue.holidayCalendarIDs
                || config.workCalendarIDs != oldValue.workCalendarIDs
                || config.onCallKeywords != oldValue.onCallKeywords
                || config.dayOffKeywords != oldValue.dayOffKeywords {
                syncCalendars()
            }
        }
    }

    var selection: FamilyActivitySelection {
        didSet {
            guard selection != oldValue else { return }
            SharedStore.save(selection)
            Enforcer.refresh()
        }
    }

    private(set) var authorizationStatus: AuthorizationStatus
    var authorizationError: String?

    @ObservationIgnored let eventStore = EKEventStore()
    private(set) var calendarAccess: EKAuthorizationStatus
    private(set) var calendars: [EKCalendar] = []
    @ObservationIgnored private var eventStoreObserver: NSObjectProtocol?

    init() {
        config = SharedStore.loadConfig()
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

    var hasCalendarAccess: Bool { calendarAccess == .fullAccess }

    func requestCalendarAccess() async {
        _ = try? await eventStore.requestFullAccessToEvents()
        syncCalendars()
    }

    /// Reloads the calendar list and re-imports holidays / on-call shifts from the selected calendars.
    func syncCalendars() {
        calendarAccess = EKEventStore.authorizationStatus(for: .event)
        let current = hasCalendarAccess
            ? eventStore.calendars(for: .event).sorted {
                ($0.source.title, $0.title) < ($1.source.title, $1.title)
            }
            : []
        // Only publish a new list when it actually changed, to avoid needless view rebuilds.
        if current.map(\.calendarIdentifier) != calendars.map(\.calendarIdentifier)
            || current.map(\.title) != calendars.map(\.title) {
            calendars = current
        }
        let synced = CalendarSync.syncing(config, store: eventStore)
        if synced != config { config = synced }
    }

    func calendarName(for id: String) -> String {
        calendars.first { $0.calendarIdentifier == id }?.title ?? "Unavailable calendar"
    }

    var policy: Policy { Policy(config: config) }

    var isAuthorized: Bool { authorizationStatus == .approved }

    var selectionCount: Int {
        selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
    }

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationError = nil
        } catch {
            authorizationError = error.localizedDescription
        }
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        Enforcer.refresh()
    }

    /// Re-reads shared state (the extension may have cleared an expired override) and re-applies.
    func reload() {
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
        Enforcer.refresh()
        config = SharedStore.loadConfig()
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
