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

    init() {
        config = SharedStore.loadConfig()
        selection = SharedStore.loadSelection()
        authorizationStatus = AuthorizationCenter.shared.authorizationStatus
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
