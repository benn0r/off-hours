import DeviceActivity
import Foundation

/// Woken by the system at each scheduled transition (and the daily heartbeat),
/// even when the OffHours app is not running.
final class MonitorExtension: DeviceActivityMonitor {
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        Enforcer.refresh(triggeredBy: activity)
    }
}
