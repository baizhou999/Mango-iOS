import Foundation

// MARK: - 自动回复规则

public struct MangoAutoReplyRule: Codable, Equatable {
    public var keyword: String
    public var replyMessages: [String]
    public init(keyword: String = "", replyMessages: [String] = []) {
        self.keyword = keyword
        self.replyMessages = replyMessages
    }
}

// MARK: - 芒果设置数据模型（对齐 Android Mango v5.0.0 全量功能）

public struct MangoSettingsState: Equatable {
    // 已有功能
    public var keywordAlertsEnabled: Bool
    public var keywords: [String]
    public var alertMutedChatsOnKeywordMatch: Bool
    public var sendConfirmationEnabled: Bool
    public var antiRecallEnabled: Bool
    public var adBlockEnabled: Bool
    public var adBlockWhitelistPeerIds: [Int64]
    public var hideProxyIcon: Bool
    public var autoCleanupEnabled: Bool
    public var autoCleanupIntervalDays: Int
    public var lastAutoCleanupTimestamp: Double

    // 聊天行为类（FeatureRegistry）
    public var disableDoubleTapReactions: Bool
    public var expandQuotes: Bool
    public var revealSpoilers: Bool
    public var disableSentSound: Bool
    public var disableReceivedSound: Bool
    public var silentSendDefault: Bool
    public var confirmVoice: Bool
    public var confirmBotCommand: Bool
    public var hideReactionList: Bool
    public var hideReactionNotifications: Bool
    public var collapseKeyboardAfterSend: Bool
    public var collapseMessageMenu: Bool

    // 隐私类
    public var hideStories: Bool
    public var hideMyStories: Bool
    public var hideOnlineStatus: Bool
    public var hideTypingStatus: Bool
    public var hideReadStatus: Bool
    public var forceForward: Bool
    public var unlimitedPin: Bool
    public var unreadDialogsTab: Bool

    // 媒体类
    public var keepVideoMuted: Bool
    public var hideStickerTime: Bool
    public var downloadSpeedBoost: Int
    public var uploadSpeedBoost: Int
    public var customDownloadPath: String
    public var stickerMessageSize: Int
    public var messageTextSize: Int
    public var defaultHighQualityMedia: Bool
    public var hideChannelSendAs: Bool

    // 自动化类
    public var autoRead: Bool
    public var autoReadRandomReply: Bool
    public var autoReadReplyGroups: Bool

    // 外观类
    public var disablePullDownSearch: Bool
    public var inputBarText: String
    public var dialogsTitleText: String
    public var appIdentityName: String
    public var appIdentityIcon: String
    public var builtinThemeId: String
    public var crossAccountInbox: Bool
    public var accountsExpand: Bool

    // 关键词屏蔽 + 自动回复
    public var keywordFilterEnabled: Bool
    public var keywordFilterRemoteUpdates: Bool
    public var keywordFilterKeywords: [String]
    public var keywordFilterWhitelist: [String]
    public var autoReplyEnabled: Bool
    public var autoReplyAnyMessageEnabled: Bool
    public var autoReplyAnyMessageText: String
    public var autoReplyRules: [MangoAutoReplyRule]

    // 身份伪装类
    public var localPremiumStatus: Bool
    public var localPremiumEmoji: String
    public var customStarBalance: Int

    // 工具类
    public var proxySubscriptionSource: String
    public var firstLaunchProxyGuideShown: Bool

    // 独立模块
    public var scamUserWarningEnabled: Bool
    public var largeFileGuardEnabled: Bool
    public var notificationRulesEnabled: Bool
    public var performanceMonitorEnabled: Bool
    public var settingsSyncEnabled: Bool
    public var pinnedSearchChannelsEnabled: Bool
    public var autoJoinChannelsEnabled: Bool
    public var autoTranslateMessages: Bool
    public var outgoingTranslationEnabled: Bool
    public var messageReminderEnabled: Bool

    public init() {
        keywordAlertsEnabled = false
        keywords = []
        alertMutedChatsOnKeywordMatch = true
        sendConfirmationEnabled = false
        antiRecallEnabled = false
        adBlockEnabled = false
        adBlockWhitelistPeerIds = []
        hideProxyIcon = false
        autoCleanupEnabled = false
        autoCleanupIntervalDays = 7
        lastAutoCleanupTimestamp = 0

        disableDoubleTapReactions = false
        expandQuotes = false
        revealSpoilers = false
        disableSentSound = false
        disableReceivedSound = false
        silentSendDefault = false
        confirmVoice = false
        confirmBotCommand = false
        hideReactionList = false
        hideReactionNotifications = false
        collapseKeyboardAfterSend = false
        collapseMessageMenu = false

        hideStories = false
        hideMyStories = false
        hideOnlineStatus = false
        hideTypingStatus = false
        hideReadStatus = false
        forceForward = false
        unlimitedPin = false
        unreadDialogsTab = false

        keepVideoMuted = false
        hideStickerTime = false
        downloadSpeedBoost = 0
        uploadSpeedBoost = 0
        customDownloadPath = ""
        stickerMessageSize = 100
        messageTextSize = 0
        defaultHighQualityMedia = false
        hideChannelSendAs = false

        autoRead = false
        autoReadRandomReply = false
        autoReadReplyGroups = false

        disablePullDownSearch = false
        inputBarText = ""
        dialogsTitleText = ""
        appIdentityName = ""
        appIdentityIcon = ""
        builtinThemeId = ""
        crossAccountInbox = false
        accountsExpand = false

        keywordFilterEnabled = false
        keywordFilterRemoteUpdates = false
        keywordFilterKeywords = []
        keywordFilterWhitelist = []
        autoReplyEnabled = false
        autoReplyAnyMessageEnabled = false
        autoReplyAnyMessageText = ""
        autoReplyRules = []

        localPremiumStatus = false
        localPremiumEmoji = ""
        customStarBalance = -1

        proxySubscriptionSource = ""
        firstLaunchProxyGuideShown = false

        scamUserWarningEnabled = false
        largeFileGuardEnabled = false
        notificationRulesEnabled = false
        performanceMonitorEnabled = false
        settingsSyncEnabled = false
        pinnedSearchChannelsEnabled = false
        autoJoinChannelsEnabled = false
        autoTranslateMessages = false
        outgoingTranslationEnabled = false
        messageReminderEnabled = false
    }
}

extension MangoSettingsState: Codable {
    private enum CodingKeys: String, CodingKey {
        case keywordAlertsEnabled, keywords, alertMutedChatsOnKeywordMatch
        case sendConfirmationEnabled, antiRecallEnabled, adBlockEnabled, adBlockWhitelistPeerIds
        case hideProxyIcon, autoCleanupEnabled, autoCleanupIntervalDays, lastAutoCleanupTimestamp
        case disableDoubleTapReactions, expandQuotes, revealSpoilers
        case disableSentSound, disableReceivedSound, silentSendDefault
        case confirmVoice, confirmBotCommand, hideReactionList, hideReactionNotifications
        case collapseKeyboardAfterSend, collapseMessageMenu
        case hideStories, hideMyStories, hideOnlineStatus, hideTypingStatus, hideReadStatus
        case forceForward, unlimitedPin, unreadDialogsTab
        case keepVideoMuted, hideStickerTime, downloadSpeedBoost, uploadSpeedBoost
        case customDownloadPath, stickerMessageSize, messageTextSize
        case defaultHighQualityMedia, hideChannelSendAs
        case autoRead, autoReadRandomReply, autoReadReplyGroups
        case disablePullDownSearch, inputBarText, dialogsTitleText
        case appIdentityName, appIdentityIcon, builtinThemeId
        case crossAccountInbox, accountsExpand
        case keywordFilterEnabled, keywordFilterRemoteUpdates, keywordFilterKeywords, keywordFilterWhitelist
        case autoReplyEnabled, autoReplyAnyMessageEnabled, autoReplyAnyMessageText, autoReplyRules
        case localPremiumStatus, localPremiumEmoji, customStarBalance
        case proxySubscriptionSource, firstLaunchProxyGuideShown
        case scamUserWarningEnabled, largeFileGuardEnabled, notificationRulesEnabled
        case performanceMonitorEnabled, settingsSyncEnabled, pinnedSearchChannelsEnabled
        case autoJoinChannelsEnabled, autoTranslateMessages, outgoingTranslationEnabled, messageReminderEnabled
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = MangoSettingsState()
        keywordAlertsEnabled = try c.decodeIfPresent(Bool.self, forKey: .keywordAlertsEnabled) ?? d.keywordAlertsEnabled
        keywords = try c.decodeIfPresent([String].self, forKey: .keywords) ?? d.keywords
        alertMutedChatsOnKeywordMatch = try c.decodeIfPresent(Bool.self, forKey: .alertMutedChatsOnKeywordMatch) ?? d.alertMutedChatsOnKeywordMatch
        sendConfirmationEnabled = try c.decodeIfPresent(Bool.self, forKey: .sendConfirmationEnabled) ?? d.sendConfirmationEnabled
        antiRecallEnabled = try c.decodeIfPresent(Bool.self, forKey: .antiRecallEnabled) ?? d.antiRecallEnabled
        adBlockEnabled = try c.decodeIfPresent(Bool.self, forKey: .adBlockEnabled) ?? d.adBlockEnabled
        adBlockWhitelistPeerIds = try c.decodeIfPresent([Int64].self, forKey: .adBlockWhitelistPeerIds) ?? d.adBlockWhitelistPeerIds
        hideProxyIcon = try c.decodeIfPresent(Bool.self, forKey: .hideProxyIcon) ?? d.hideProxyIcon
        autoCleanupEnabled = try c.decodeIfPresent(Bool.self, forKey: .autoCleanupEnabled) ?? d.autoCleanupEnabled
        autoCleanupIntervalDays = try c.decodeIfPresent(Int.self, forKey: .autoCleanupIntervalDays) ?? d.autoCleanupIntervalDays
        lastAutoCleanupTimestamp = try c.decodeIfPresent(Double.self, forKey: .lastAutoCleanupTimestamp) ?? d.lastAutoCleanupTimestamp
        disableDoubleTapReactions = try c.decodeIfPresent(Bool.self, forKey: .disableDoubleTapReactions) ?? d.disableDoubleTapReactions
        expandQuotes = try c.decodeIfPresent(Bool.self, forKey: .expandQuotes) ?? d.expandQuotes
        revealSpoilers = try c.decodeIfPresent(Bool.self, forKey: .revealSpoilers) ?? d.revealSpoilers
        disableSentSound = try c.decodeIfPresent(Bool.self, forKey: .disableSentSound) ?? d.disableSentSound
        disableReceivedSound = try c.decodeIfPresent(Bool.self, forKey: .disableReceivedSound) ?? d.disableReceivedSound
        silentSendDefault = try c.decodeIfPresent(Bool.self, forKey: .silentSendDefault) ?? d.silentSendDefault
        confirmVoice = try c.decodeIfPresent(Bool.self, forKey: .confirmVoice) ?? d.confirmVoice
        confirmBotCommand = try c.decodeIfPresent(Bool.self, forKey: .confirmBotCommand) ?? d.confirmBotCommand
        hideReactionList = try c.decodeIfPresent(Bool.self, forKey: .hideReactionList) ?? d.hideReactionList
        hideReactionNotifications = try c.decodeIfPresent(Bool.self, forKey: .hideReactionNotifications) ?? d.hideReactionNotifications
        collapseKeyboardAfterSend = try c.decodeIfPresent(Bool.self, forKey: .collapseKeyboardAfterSend) ?? d.collapseKeyboardAfterSend
        collapseMessageMenu = try c.decodeIfPresent(Bool.self, forKey: .collapseMessageMenu) ?? d.collapseMessageMenu
        hideStories = try c.decodeIfPresent(Bool.self, forKey: .hideStories) ?? d.hideStories
        hideMyStories = try c.decodeIfPresent(Bool.self, forKey: .hideMyStories) ?? d.hideMyStories
        hideOnlineStatus = try c.decodeIfPresent(Bool.self, forKey: .hideOnlineStatus) ?? d.hideOnlineStatus
        hideTypingStatus = try c.decodeIfPresent(Bool.self, forKey: .hideTypingStatus) ?? d.hideTypingStatus
        hideReadStatus = try c.decodeIfPresent(Bool.self, forKey: .hideReadStatus) ?? d.hideReadStatus
        forceForward = try c.decodeIfPresent(Bool.self, forKey: .forceForward) ?? d.forceForward
        unlimitedPin = try c.decodeIfPresent(Bool.self, forKey: .unlimitedPin) ?? d.unlimitedPin
        unreadDialogsTab = try c.decodeIfPresent(Bool.self, forKey: .unreadDialogsTab) ?? d.unreadDialogsTab
        keepVideoMuted = try c.decodeIfPresent(Bool.self, forKey: .keepVideoMuted) ?? d.keepVideoMuted
        hideStickerTime = try c.decodeIfPresent(Bool.self, forKey: .hideStickerTime) ?? d.hideStickerTime
        downloadSpeedBoost = try c.decodeIfPresent(Int.self, forKey: .downloadSpeedBoost) ?? d.downloadSpeedBoost
        uploadSpeedBoost = try c.decodeIfPresent(Int.self, forKey: .uploadSpeedBoost) ?? d.uploadSpeedBoost
        customDownloadPath = try c.decodeIfPresent(String.self, forKey: .customDownloadPath) ?? d.customDownloadPath
        stickerMessageSize = try c.decodeIfPresent(Int.self, forKey: .stickerMessageSize) ?? d.stickerMessageSize
        messageTextSize = try c.decodeIfPresent(Int.self, forKey: .messageTextSize) ?? d.messageTextSize
        defaultHighQualityMedia = try c.decodeIfPresent(Bool.self, forKey: .defaultHighQualityMedia) ?? d.defaultHighQualityMedia
        hideChannelSendAs = try c.decodeIfPresent(Bool.self, forKey: .hideChannelSendAs) ?? d.hideChannelSendAs
        autoRead = try c.decodeIfPresent(Bool.self, forKey: .autoRead) ?? d.autoRead
        autoReadRandomReply = try c.decodeIfPresent(Bool.self, forKey: .autoReadRandomReply) ?? d.autoReadRandomReply
        autoReadReplyGroups = try c.decodeIfPresent(Bool.self, forKey: .autoReadReplyGroups) ?? d.autoReadReplyGroups
        disablePullDownSearch = try c.decodeIfPresent(Bool.self, forKey: .disablePullDownSearch) ?? d.disablePullDownSearch
        inputBarText = try c.decodeIfPresent(String.self, forKey: .inputBarText) ?? d.inputBarText
        dialogsTitleText = try c.decodeIfPresent(String.self, forKey: .dialogsTitleText) ?? d.dialogsTitleText
        appIdentityName = try c.decodeIfPresent(String.self, forKey: .appIdentityName) ?? d.appIdentityName
        appIdentityIcon = try c.decodeIfPresent(String.self, forKey: .appIdentityIcon) ?? d.appIdentityIcon
        builtinThemeId = try c.decodeIfPresent(String.self, forKey: .builtinThemeId) ?? d.builtinThemeId
        crossAccountInbox = try c.decodeIfPresent(Bool.self, forKey: .crossAccountInbox) ?? d.crossAccountInbox
        accountsExpand = try c.decodeIfPresent(Bool.self, forKey: .accountsExpand) ?? d.accountsExpand
        keywordFilterEnabled = try c.decodeIfPresent(Bool.self, forKey: .keywordFilterEnabled) ?? d.keywordFilterEnabled
        keywordFilterRemoteUpdates = try c.decodeIfPresent(Bool.self, forKey: .keywordFilterRemoteUpdates) ?? d.keywordFilterRemoteUpdates
        keywordFilterKeywords = try c.decodeIfPresent([String].self, forKey: .keywordFilterKeywords) ?? d.keywordFilterKeywords
        keywordFilterWhitelist = try c.decodeIfPresent([String].self, forKey: .keywordFilterWhitelist) ?? d.keywordFilterWhitelist
        autoReplyEnabled = try c.decodeIfPresent(Bool.self, forKey: .autoReplyEnabled) ?? d.autoReplyEnabled
        autoReplyAnyMessageEnabled = try c.decodeIfPresent(Bool.self, forKey: .autoReplyAnyMessageEnabled) ?? d.autoReplyAnyMessageEnabled
        autoReplyAnyMessageText = try c.decodeIfPresent(String.self, forKey: .autoReplyAnyMessageText) ?? d.autoReplyAnyMessageText
        autoReplyRules = try c.decodeIfPresent([MangoAutoReplyRule].self, forKey: .autoReplyRules) ?? d.autoReplyRules
        localPremiumStatus = try c.decodeIfPresent(Bool.self, forKey: .localPremiumStatus) ?? d.localPremiumStatus
        localPremiumEmoji = try c.decodeIfPresent(String.self, forKey: .localPremiumEmoji) ?? d.localPremiumEmoji
        customStarBalance = try c.decodeIfPresent(Int.self, forKey: .customStarBalance) ?? d.customStarBalance
        proxySubscriptionSource = try c.decodeIfPresent(String.self, forKey: .proxySubscriptionSource) ?? d.proxySubscriptionSource
        firstLaunchProxyGuideShown = try c.decodeIfPresent(Bool.self, forKey: .firstLaunchProxyGuideShown) ?? d.firstLaunchProxyGuideShown
        scamUserWarningEnabled = try c.decodeIfPresent(Bool.self, forKey: .scamUserWarningEnabled) ?? d.scamUserWarningEnabled
        largeFileGuardEnabled = try c.decodeIfPresent(Bool.self, forKey: .largeFileGuardEnabled) ?? d.largeFileGuardEnabled
        notificationRulesEnabled = try c.decodeIfPresent(Bool.self, forKey: .notificationRulesEnabled) ?? d.notificationRulesEnabled
        performanceMonitorEnabled = try c.decodeIfPresent(Bool.self, forKey: .performanceMonitorEnabled) ?? d.performanceMonitorEnabled
        settingsSyncEnabled = try c.decodeIfPresent(Bool.self, forKey: .settingsSyncEnabled) ?? d.settingsSyncEnabled
        pinnedSearchChannelsEnabled = try c.decodeIfPresent(Bool.self, forKey: .pinnedSearchChannelsEnabled) ?? d.pinnedSearchChannelsEnabled
        autoJoinChannelsEnabled = try c.decodeIfPresent(Bool.self, forKey: .autoJoinChannelsEnabled) ?? d.autoJoinChannelsEnabled
        autoTranslateMessages = try c.decodeIfPresent(Bool.self, forKey: .autoTranslateMessages) ?? d.autoTranslateMessages
        outgoingTranslationEnabled = try c.decodeIfPresent(Bool.self, forKey: .outgoingTranslationEnabled) ?? d.outgoingTranslationEnabled
        messageReminderEnabled = try c.decodeIfPresent(Bool.self, forKey: .messageReminderEnabled) ?? d.messageReminderEnabled
    }
}

// MARK: - 存储（自签版改用标准 UserDefaults，去除 App Group 依赖）

public enum MangoSettingsStore {
    private static let storageKey = "mango.settings.v1"

    private static var defaults: UserDefaults {
        return .standard
    }

    public static func load() -> MangoSettingsState {
        guard let data = defaults.data(forKey: storageKey) else {
            return MangoSettingsState()
        }
        do {
            return try JSONDecoder().decode(MangoSettingsState.self, from: data)
        } catch {
            return MangoSettingsState()
        }
    }

    public static func save(_ settings: MangoSettingsState) {
        do {
            let data = try JSONEncoder().encode(settings)
            defaults.set(data, forKey: storageKey)
        } catch {
        }
    }

    public static var shared: MangoSettingsState {
        return load()
    }

    public static func update(_ transform: (inout MangoSettingsState) -> Void) {
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
            if foldedText.contains(fold(keyword)) {
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

// MARK: - 关键词屏蔽

public enum MangoKeywordFilter {
    public static func shouldHide(text: String, chatType: String) -> Bool {
        let settings = MangoSettingsStore.shared
        guard settings.keywordFilterEnabled else {
            return false
        }
        // 白名单（频道/群聊名）命中则不屏蔽
        if settings.keywordFilterWhitelist.contains(where: { chatType.localizedCaseInsensitiveContains($0) }) {
            return false
        }
        return MangoKeywordMatcher.firstMatch(in: text, keywords: settings.keywordFilterKeywords) != nil
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

// MARK: - 强制转发（绕过不可转发限制）

public enum MangoForceForward {
    public static var isEnabled: Bool {
        return MangoSettingsStore.shared.forceForward
    }
}

// MARK: - 无限置顶

public enum MangoUnlimitedPin {
    public static var isEnabled: Bool {
        return MangoSettingsStore.shared.unlimitedPin
    }
}

// MARK: - 隐藏状态

public enum MangoPrivacyStatus {
    public static var hideOnline: Bool { return MangoSettingsStore.shared.hideOnlineStatus }
    public static var hideTyping: Bool { return MangoSettingsStore.shared.hideTypingStatus }
    public static var hideRead: Bool { return MangoSettingsStore.shared.hideReadStatus }
}

// MARK: - 自动已读

public enum MangoAutoRead {
    public static var isEnabled: Bool { return MangoSettingsStore.shared.autoRead }
    public static var randomReplyEnabled: Bool { return MangoSettingsStore.shared.autoReadRandomReply }
}

// MARK: - 自动翻译

public enum MangoAutoTranslate {
    public static var isEnabled: Bool { return MangoSettingsStore.shared.autoTranslateMessages }
}

// MARK: - 诈骗用户警告

public enum MangoScamWarning {
    public static var isEnabled: Bool { return MangoSettingsStore.shared.scamUserWarningEnabled }
}

// MARK: - 大文件保护

public enum MangoLargeFileGuard {
    public static var isEnabled: Bool { return MangoSettingsStore.shared.largeFileGuardEnabled }
}
