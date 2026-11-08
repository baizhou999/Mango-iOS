import Foundation

// MARK: - 芒果设置数据模型

public struct MangoSettings: Codable, Equatable {
    // 关键词提醒
    public var keywordAlertsEnabled: Bool
    public var keywords: [String]
    public var alertMutedChatsOnKeywordMatch: Bool

    // 发送前确认
    public var sendConfirmationEnabled: Bool

    // 防撤回
    public var antiRecallEnabled: Bool

    // 广告屏蔽（含白名单）
    public var adBlockEnabled: Bool
    public var adBlockWhitelistPeerIds: [Int64]

    // 隐藏代理图标
    public var hideProxyIcon: Bool

    // 媒体自动清理
    public var autoCleanupEnabled: Bool
    public var autoCleanupIntervalDays: Int
    public var lastAutoCleanupTimestamp: Double

    public init(
        keywordAlertsEnabled: Bool = false,
        keywords: [String] = [],
        alertMutedChatsOnKeywordMatch: Bool = true,
        sendConfirmationEnabled: Bool = false,
        antiRecallEnabled: Bool = false,
        adBlockEnabled: Bool = false,
        adBlockWhitelistPeerIds: [Int64] = [],
        hideProxyIcon: Bool = false,
        autoCleanupEnabled: Bool = false,
        autoCleanupIntervalDays: Int = 7,
        lastAutoCleanupTimestamp: Double = 0
    ) {
        self.keywordAlertsEnabled = keywordAlertsEnabled
        self.keywords = keywords
        self.alertMutedChatsOnKeywordMatch = alertMutedChatsOnKeywordMatch
        self.sendConfirmationEnabled = sendConfirmationEnabled
        self.antiRecallEnabled = antiRecallEnabled
        self.adBlockEnabled = adBlockEnabled
        self.adBlockWhitelistPeerIds = adBlockWhitelistPeerIds
        self.hideProxyIcon = hideProxyIcon
        self.autoCleanupEnabled = autoCleanupEnabled
        self.autoCleanupIntervalDays = autoCleanupIntervalDays
        self.lastAutoCleanupTimestamp = lastAutoCleanupTimestamp
    }
}

// MARK: - 存储（App Group 共享，主 App 与扩展均可读写）

public enum MangoSettingsStore {
    private static let suiteName = "group.app.mango.im.ios"
    private static let storageKey = "mango.settings.v1"

    private static var defaults: UserDefaults {
        return UserDefaults(suiteName: suiteName) ?? .standard
    }

    public static func load() -> MangoSettings {
        guard let data = defaults.data(forKey: storageKey) else {
            return MangoSettings()
        }
        do {
            return try JSONDecoder().decode(MangoSettings.self, from: data)
        } catch {
            return MangoSettings()
        }
    }

    public static func save(_ settings: MangoSettings) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: storageKey)
        } catch {
        }
    }

    /// 每次访问都从磁盘读取，保证各进程（App / 扩展）拿到最新值
    public static var shared: MangoSettings {
        return load()
    }

    public static func update(_ transform: (inout MangoSettings) -> Void) {
        var settings = load()
        transform(&settings)
        save(settings)
    }
}

// MARK: - 关键词匹配

public enum MangoKeywordMatcher {
    public static func firstMatch(in text: String, keywords: [String]) -> String? {
        guard !text.isEmpty else {
            return nil
        }
        let foldedText = fold(text)
        for rawKeyword in keywords {
            let keyword = rawKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
            if keyword.isEmpty {
                continue
            }
            let haystack = foldedText
            let needle = fold(keyword)
            if haystack.contains(needle) {
                return rawKeyword
            }
        }
        return nil
    }

    public static func matchesKeywordAlert(text: String) -> Bool {
        let settings = MangoSettingsStore.shared
        guard settings.keywordAlertsEnabled else {
            return false
        }
        return firstMatch(in: text, keywords: settings.keywords) != nil
    }

    private static func fold(_ value: String) -> String {
        return value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "zh_Hans_CN"))
    }
}

// MARK: - 发送前确认（防重入标记，仅内存）

public enum MangoSendConfirmationGuard {
    private static var bypassOnce = false

    public static func shouldConfirm() -> Bool {
        let settings = MangoSettingsStore.shared
        guard settings.sendConfirmationEnabled else {
            return false
        }
        if bypassOnce {
            bypassOnce = false
            return false
        }
        return true
    }

    public static func bypassNextSend() {
        bypassOnce = true
    }
}

// MARK: - 防撤回

public enum MangoAntiRecall {
    public static var isEnabled: Bool {
        return MangoSettingsStore.shared.antiRecallEnabled
    }
}

// MARK: - 广告屏蔽

public enum MangoAdBlock {
    public static func shouldHideAds(peerId: Int64) -> Bool {
        let settings = MangoSettingsStore.shared
        guard settings.adBlockEnabled else {
            return false
        }
        if settings.adBlockWhitelistPeerIds.contains(peerId) {
            return false
        }
        return true
    }
}

// MARK: - 代理图标

public enum MangoProxyPreferences {
    public static var hideIcon: Bool {
        return MangoSettingsStore.shared.hideProxyIcon
    }
}
