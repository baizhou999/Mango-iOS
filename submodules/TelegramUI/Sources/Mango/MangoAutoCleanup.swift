import Foundation
import AccountContext
import TelegramCore
import MangoSettings

// MARK: - 媒体缓存自动清理（启动时按需执行一次）

enum MangoAutoCleanup {
    private static var didRunThisLaunch = false

    static func runIfNeeded(context: AccountContext) {
        if didRunThisLaunch {
            return
        }
        didRunThisLaunch = true

        let settings = MangoSettingsStore.shared
        guard settings.autoCleanupEnabled else {
            return
        }

        let interval = TimeInterval(max(settings.autoCleanupIntervalDays, 1)) * 24.0 * 60.0 * 60.0
        let now = Date().timeIntervalSince1970
        guard now - settings.lastAutoCleanupTimestamp >= interval else {
            return
        }

        let categories: [StorageUsageStats.CategoryKey] = [.photos, .videos, .files, .music, .stickers, .avatars, .misc, .stories]
        let _ = context.engine.resources.clearStorage(peerId: nil, categories: categories, includeMessages: [], excludeMessages: []).start()
        MangoSettingsStore.update { $0.lastAutoCleanupTimestamp = now }
    }
}
