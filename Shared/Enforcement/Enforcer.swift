import DeviceActivity
import FamilyControls
import Foundation
import ManagedSettings

/// Storage shared between the app and the DeviceActivity monitor extension.
enum SharedStore {
    static let appGroup = "group.ch.qni.OffHours"

    private static let configKey = "config"
    private static let selectionKey = "selection"
    private static let scheduledKey = "scheduledTransitions"

    static var defaults: UserDefaults { UserDefaults(suiteName: appGroup) ?? .standard }

    static func loadConfig() -> Config {
        guard let data = defaults.data(forKey: configKey),
              let config = try? JSONDecoder().decode(Config.self, from: data) else { return .default }
        return config
    }

    static func save(_ config: Config) {
        defaults.set(try? JSONEncoder().encode(config), forKey: configKey)
    }

    static func loadSelection() -> FamilyActivitySelection {
        guard let data = defaults.data(forKey: selectionKey),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        else { return FamilyActivitySelection() }
        return selection
    }

    static func save(_ selection: FamilyActivitySelection) {
        defaults.set(try? JSONEncoder().encode(selection), forKey: selectionKey)
    }

    /// Activity name → the transition time it was scheduled for.
    static var scheduledTransitions: [String: Date] {
        get { (defaults.dictionary(forKey: scheduledKey) as? [String: Date]) ?? [:] }
        set { defaults.set(newValue, forKey: scheduledKey) }
    }
}

extension ManagedSettingsStore.Name {
    static let work = Self("work")
}

extension DeviceActivityName {
    static let heartbeat = Self("heartbeat")
    static func transition(_ index: Int) -> Self { Self("transition-\(index)") }
}

/// Applies the current shield and schedules wake-ups for the monitor extension.
///
/// DeviceActivity can only wake the extension at the start/end of a monitored interval,
/// so every upcoming policy flip gets its own short, non-repeating interval that *starts*
/// at the flip. When it fires, the extension calls `refresh` again, which re-applies the
/// shield and schedules the next batch. A daily heartbeat keeps the chain alive.
enum Enforcer {
    static let maxScheduledTransitions = 10
    /// DeviceActivity rejects intervals shorter than 15 minutes.
    private static let intervalLength: TimeInterval = 16 * 60

    static func refresh(triggeredBy activity: DeviceActivityName? = nil, now: Date = .now) {
        var evaluationDate = now
        if let activity, let scheduled = SharedStore.scheduledTransitions[activity.rawValue] {
            // Wake-ups can arrive a moment early; evaluate just after the intended flip.
            evaluationDate = max(now, scheduled.addingTimeInterval(1))
        }

        var config = SharedStore.loadConfig()
        if let override = config.override, override.until <= evaluationDate {
            config.override = nil
            SharedStore.save(config)
        }

        let policy = Policy(config: config)
        apply(blocked: policy.status(at: evaluationDate).blocked, selection: SharedStore.loadSelection())
        schedule(policy.transitions(after: evaluationDate, limit: maxScheduledTransitions))
    }

    static func apply(blocked: Bool, selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore(named: .work)
        guard blocked else {
            store.clearAllSettings()
            return
        }
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
        store.shield.webDomainCategories = selection.categoryTokens.isEmpty
            ? nil : .specific(selection.categoryTokens)
    }

    private static func schedule(_ transitions: [Date]) {
        let center = DeviceActivityCenter()
        center.stopMonitoring()

        let calendar = Calendar.current
        let components: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        var scheduled: [String: Date] = [:]

        for (index, date) in transitions.enumerated() {
            let name = DeviceActivityName.transition(index)
            let schedule = DeviceActivitySchedule(
                intervalStart: calendar.dateComponents(components, from: date),
                intervalEnd: calendar.dateComponents(components, from: date.addingTimeInterval(intervalLength)),
                repeats: false
            )
            do {
                try center.startMonitoring(name, during: schedule)
                scheduled[name.rawValue] = date
            } catch {
                print("OffHours: could not schedule \(name.rawValue) at \(date): \(error)")
            }
        }

        let heartbeat = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 5),
            intervalEnd: DateComponents(hour: 0, minute: 25),
            repeats: true
        )
        try? center.startMonitoring(.heartbeat, during: heartbeat)

        SharedStore.scheduledTransitions = scheduled
    }
}
