import Foundation
import UIKit
import Display
import SwiftSignalKit
import TelegramCore
import TelegramPresentationData
import ItemListUI
import PresentationDataUtils
import AccountContext
import UndoUI
import MangoSettings

private enum MangoTextInputField: String {
    case keywords
    case adWhitelist
    case customDownloadPath
    case inputBarText
    case dialogsTitleText
    case appIdentityName
    case autoReplyAnyMessageText
    case proxySubscriptionSource
    case keywordFilterKeywords
    case keywordFilterWhitelist
    case localPremiumEmoji
    case customStarBalance
    case stickerMessageSize
    case messageTextSize
    case downloadSpeedBoost
    case uploadSpeedBoost
    case autoCleanupIntervalDays
}

private enum MangoSettingsAction {
    case clearCacheNow
    case openProxySettings
}

private final class MangoSettingsControllerArguments {
    let update: ((inout MangoSettingsState) -> Void) -> Void
    let updateSearch: (String) -> Void
    let updateText: (MangoTextInputField, String) -> Void
    let performAction: (MangoSettingsAction) -> Void

    init(
        update: @escaping ((inout MangoSettingsState) -> Void) -> Void,
        updateSearch: @escaping (String) -> Void,
        updateText: @escaping (MangoTextInputField, String) -> Void,
        performAction: @escaping (MangoSettingsAction) -> Void
    ) {
        self.update = update
        self.updateSearch = updateSearch
        self.updateText = updateText
        self.performAction = performAction
    }
}

private enum MangoSettingsSection: Int32 {
    case search = 0
    case chat = 1
    case privacy = 2
    case keywordFilter = 3
    case autoReply = 4
    case media = 5
    case automation = 6
    case appearance = 7
    case tools = 8
    case modules = 9
    case about = 10
}

private enum MangoSettingsEntry: ItemListNodeEntry {
    case searchInput(String)
    case header(Int32, MangoSettingsSection, String)
    case switchRow(Int32, MangoSettingsSection, String, Bool, WritableKeyPath<MangoSettingsState, Bool>)
    case textRow(Int32, MangoSettingsSection, String, String, String, MangoTextInputField)
    case actionRow(Int32, MangoSettingsSection, String, MangoSettingsAction)
    case footer(Int32, MangoSettingsSection, String)
}

extension MangoSettingsEntry {
    var section: ItemListSectionId {
        switch self {
        case .searchInput:
            return MangoSettingsSection.search.rawValue
        case let .header(_, s, _), let .switchRow(_, s, _, _, _), let .textRow(_, s, _, _, _, _), let .actionRow(_, s, _, _), let .footer(_, s, _):
            return s.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .searchInput:
            return 0
        case let .header(id, _, _), let .switchRow(id, _, _, _, _), let .textRow(id, _, _, _, _, _), let .actionRow(id, _, _, _), let .footer(id, _, _):
            return id
        }
    }

    var searchableTitle: String {
        switch self {
        case let .switchRow(_, _, title, _, _), let .textRow(_, _, title, _, _, _), let .actionRow(_, _, title, _):
            return title
        default:
            return ""
        }
    }

    static func < (lhs: MangoSettingsEntry, rhs: MangoSettingsEntry) -> Bool {
        return lhs.stableId < rhs.stableId
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! MangoSettingsControllerArguments
        switch self {
        case let .searchInput(text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: "搜索芒果设置", maxLength: nil, sectionId: self.section, style: .blocks, minimalHeight: 40.0, textUpdated: { value in
                arguments.updateSearch(value)
            }, updatedFocus: nil, tag: nil, action: nil)
        case let .header(_, _, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .switchRow(_, _, title, value, keyPath):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { state in
                    state[keyPath: keyPath] = value
                }
            })
        case let .textRow(_, _, _, placeholder, text, field):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: placeholder, maxLength: nil, sectionId: self.section, style: .blocks, minimalHeight: 40.0, textUpdated: { value in
                arguments.updateText(field, value)
            }, updatedFocus: nil, tag: nil, action: nil)
        case let .actionRow(_, _, title, action):
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: title, kind: .generic, alignment: .center, sectionId: self.section, style: .blocks, action: {
                arguments.performAction(action)
            })
        case let .footer(_, _, text):
            return ItemListTextItem(presentationData: presentationData, text: .markdown(text), sectionId: self.section)
        }
    }
}
private func splitMangoList(_ value: String) -> [String] {
    return value.components(separatedBy: CharacterSet(charactersIn: ",，\n"))
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

private func initialMangoTextValues(_ settings: MangoSettingsState) -> [MangoTextInputField: String] {
    var values: [MangoTextInputField: String] = [:]
    values[.keywords] = settings.keywords.joined(separator: ", ")
    values[.adWhitelist] = settings.adBlockWhitelistPeerIds.map { String($0) }.joined(separator: ", ")
    values[.customDownloadPath] = settings.customDownloadPath
    values[.inputBarText] = settings.inputBarText
    values[.dialogsTitleText] = settings.dialogsTitleText
    values[.appIdentityName] = settings.appIdentityName
    values[.autoReplyAnyMessageText] = settings.autoReplyAnyMessageText
    values[.proxySubscriptionSource] = settings.proxySubscriptionSource
    values[.keywordFilterKeywords] = settings.keywordFilterKeywords.joined(separator: ", ")
    values[.keywordFilterWhitelist] = settings.keywordFilterWhitelist.joined(separator: ", ")
    values[.localPremiumEmoji] = settings.localPremiumEmoji
    values[.customStarBalance] = settings.customStarBalance == -1 ? "" : String(settings.customStarBalance)
    values[.stickerMessageSize] = String(settings.stickerMessageSize)
    values[.messageTextSize] = settings.messageTextSize == 0 ? "" : String(settings.messageTextSize)
    values[.downloadSpeedBoost] = settings.downloadSpeedBoost == 0 ? "" : String(settings.downloadSpeedBoost)
    values[.uploadSpeedBoost] = settings.uploadSpeedBoost == 0 ? "" : String(settings.uploadSpeedBoost)
    values[.autoCleanupIntervalDays] = String(settings.autoCleanupIntervalDays)
    return values
}

private func applyMangoTextUpdate(_ field: MangoTextInputField, _ value: String) {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    switch field {
    case .keywords:
        let list = splitMangoList(value)
        MangoSettingsStore.update { $0.keywords = list }
    case .adWhitelist:
        let ids = splitMangoList(value).compactMap { Int64($0) }
        MangoSettingsStore.update { $0.adBlockWhitelistPeerIds = ids }
    case .keywordFilterKeywords:
        MangoSettingsStore.update { $0.keywordFilterKeywords = splitMangoList(value) }
    case .keywordFilterWhitelist:
        MangoSettingsStore.update { $0.keywordFilterWhitelist = splitMangoList(value) }
    case .customDownloadPath:
        MangoSettingsStore.update { $0.customDownloadPath = trimmed }
    case .inputBarText:
        MangoSettingsStore.update { $0.inputBarText = trimmed }
    case .dialogsTitleText:
        MangoSettingsStore.update { $0.dialogsTitleText = trimmed }
    case .appIdentityName:
        MangoSettingsStore.update { $0.appIdentityName = trimmed }
    case .autoReplyAnyMessageText:
        MangoSettingsStore.update { $0.autoReplyAnyMessageText = trimmed }
    case .proxySubscriptionSource:
        MangoSettingsStore.update { $0.proxySubscriptionSource = trimmed }
    case .localPremiumEmoji:
        MangoSettingsStore.update { $0.localPremiumEmoji = trimmed }
    case .customStarBalance:
        MangoSettingsStore.update { $0.customStarBalance = Int(trimmed) ?? -1 }
    case .stickerMessageSize:
        MangoSettingsStore.update { $0.stickerMessageSize = Int(trimmed) ?? 100 }
    case .messageTextSize:
        MangoSettingsStore.update { $0.messageTextSize = Int(trimmed) ?? 0 }
    case .downloadSpeedBoost:
        MangoSettingsStore.update { $0.downloadSpeedBoost = Int(trimmed) ?? 0 }
    case .uploadSpeedBoost:
        MangoSettingsStore.update { $0.uploadSpeedBoost = Int(trimmed) ?? 0 }
    case .autoCleanupIntervalDays:
        MangoSettingsStore.update { $0.autoCleanupIntervalDays = Int(trimmed) ?? 7 }
    }
}

private func mangoSettingsEntries(
    settings: MangoSettingsState,
    searchText: String,
    textValues: [MangoTextInputField: String]
) -> [MangoSettingsEntry] {
    var entries: [MangoSettingsEntry] = []

    entries.append(.searchInput(searchText))

    let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let include: (MangoSettingsEntry) -> Bool = { entry in
        if query.isEmpty {
            return true
        }
        let title = entry.searchableTitle
        if title.isEmpty {
            return true
        }
        return title.lowercased().contains(query)
    }

    func add(_ entry: MangoSettingsEntry) {
        if include(entry) {
            entries.append(entry)
        }
    }
    func addHeader(_ id: Int32, _ s: MangoSettingsSection, _ text: String) {
        entries.append(.header(id, s, text))
    }
    func addSwitch(_ id: Int32, _ s: MangoSettingsSection, _ title: String, _ value: Bool, _ keyPath: WritableKeyPath<MangoSettingsState, Bool>) {
        add(.switchRow(id, s, title, value, keyPath))
    }
    func addText(_ id: Int32, _ s: MangoSettingsSection, _ title: String, _ placeholder: String, _ field: MangoTextInputField) {
        add(.textRow(id, s, title, placeholder, textValues[field] ?? "", field))
    }
    func addAction(_ id: Int32, _ s: MangoSettingsSection, _ title: String, _ action: MangoSettingsAction) {
        add(.actionRow(id, s, title, action))
    }
    func addFooter(_ id: Int32, _ s: MangoSettingsSection, _ text: String) {
        entries.append(.footer(id, s, text))
    }

    // 聊天行为
    addHeader(1, .chat, "聊天行为")
    addSwitch(2, .chat, "关键词提醒", settings.keywordAlertsEnabled, \.keywordAlertsEnabled)
    if settings.keywordAlertsEnabled {
        addText(3, .chat, "关键词列表", "关键词，用逗号分隔", .keywords)
        addSwitch(4, .chat, "静音会话也提醒", settings.alertMutedChatsOnKeywordMatch, \.alertMutedChatsOnKeywordMatch)
    }
    addSwitch(5, .chat, "发送前确认", settings.sendConfirmationEnabled, \.sendConfirmationEnabled)
    addSwitch(6, .chat, "防撤回", settings.antiRecallEnabled, \.antiRecallEnabled)
    addSwitch(7, .chat, "禁用双击表情", settings.disableDoubleTapReactions, \.disableDoubleTapReactions)
    addSwitch(8, .chat, "展开引用", settings.expandQuotes, \.expandQuotes)
    addSwitch(9, .chat, "展开剧透", settings.revealSpoilers, \.revealSpoilers)
    addSwitch(10, .chat, "关闭发送提示音", settings.disableSentSound, \.disableSentSound)
    addSwitch(11, .chat, "关闭接收提示音", settings.disableReceivedSound, \.disableReceivedSound)
    addSwitch(12, .chat, "默认静音发送", settings.silentSendDefault, \.silentSendDefault)
    addSwitch(13, .chat, "语音发送前确认", settings.confirmVoice, \.confirmVoice)
    addSwitch(14, .chat, "机器人命令确认", settings.confirmBotCommand, \.confirmBotCommand)
    addSwitch(15, .chat, "隐藏反应列表", settings.hideReactionList, \.hideReactionList)
    addSwitch(16, .chat, "隐藏反应通知", settings.hideReactionNotifications, \.hideReactionNotifications)
    addSwitch(17, .chat, "发送后收起键盘", settings.collapseKeyboardAfterSend, \.collapseKeyboardAfterSend)
    addSwitch(18, .chat, "折叠消息菜单", settings.collapseMessageMenu, \.collapseMessageMenu)
    addFooter(19, .chat, "关键词提醒会在收到含关键词的消息时强提醒；防撤回后对方撤回的消息仍保留在本机。")

    // 隐私
    addHeader(20, .privacy, "隐私")
    addSwitch(21, .privacy, "隐藏在线状态", settings.hideOnlineStatus, \.hideOnlineStatus)
    addSwitch(22, .privacy, "隐藏输入状态", settings.hideTypingStatus, \.hideTypingStatus)
    addSwitch(23, .privacy, "隐藏已读状态", settings.hideReadStatus, \.hideReadStatus)
    addSwitch(24, .privacy, "强制破解转发", settings.forceForward, \.forceForward)
    addSwitch(25, .privacy, "无限置顶", settings.unlimitedPin, \.unlimitedPin)
    addSwitch(26, .privacy, "显示未读聊天", settings.unreadDialogsTab, \.unreadDialogsTab)
    addSwitch(27, .privacy, "隐藏 Stories", settings.hideStories, \.hideStories)
    addSwitch(28, .privacy, "隐藏我的 Stories", settings.hideMyStories, \.hideMyStories)
    addFooter(29, .privacy, "隐私类功能仅影响本机显示，不会修改服务器状态。")

    // 关键词屏蔽
    addHeader(30, .keywordFilter, "关键词屏蔽")
    addSwitch(31, .keywordFilter, "启用关键词屏蔽", settings.keywordFilterEnabled, \.keywordFilterEnabled)
    addSwitch(32, .keywordFilter, "云端违禁词更新", settings.keywordFilterRemoteUpdates, \.keywordFilterRemoteUpdates)
    if settings.keywordFilterEnabled {
        addText(33, .keywordFilter, "违禁词", "违禁词，用逗号分隔", .keywordFilterKeywords)
        addText(34, .keywordFilter, "白名单", "白名单关键词，用逗号分隔", .keywordFilterWhitelist)
    }
    addFooter(35, .keywordFilter, "命中违禁词的消息会在本机隐藏；白名单命中则不屏蔽。")

    // 自动回复
    addHeader(36, .autoReply, "自动回复")
    addSwitch(37, .autoReply, "启用自动回复", settings.autoReplyEnabled, \.autoReplyEnabled)
    addSwitch(38, .autoReply, "任意消息都自动回复", settings.autoReplyAnyMessageEnabled, \.autoReplyAnyMessageEnabled)
    if settings.autoReplyAnyMessageEnabled {
        addText(39, .autoReply, "任意消息回复内容", "输入回复文字", .autoReplyAnyMessageText)
    }
    addFooter(40, .autoReply, "自动回复仅对私聊生效。关键词回复规则的精细管理将在后续版本补充。")

    // 媒体
    addHeader(41, .media, "媒体")
    addSwitch(42, .media, "视频默认静音", settings.keepVideoMuted, \.keepVideoMuted)
    addSwitch(43, .media, "隐藏贴纸时间", settings.hideStickerTime, \.hideStickerTime)
    addText(44, .media, "下载速度", "留空为正常（1 倍）", .downloadSpeedBoost)
    addText(45, .media, "上传速度", "留空为正常（1 倍）", .uploadSpeedBoost)
    addText(46, .media, "自定义下载路径", "输入文件夹完整路径", .customDownloadPath)
    addText(47, .media, "表情包显示大小", "百分比，默认 100", .stickerMessageSize)
    addText(48, .media, "文字显示大小", "字号，留空为默认", .messageTextSize)
    addSwitch(49, .media, "发送图片/视频默认最高质量", settings.defaultHighQualityMedia, \.defaultHighQualityMedia)
    addSwitch(50, .media, "隐藏频道身份发送", settings.hideChannelSendAs, \.hideChannelSendAs)
    addSwitch(51, .media, "自动清理缓存", settings.autoCleanupEnabled, \.autoCleanupEnabled)
    if settings.autoCleanupEnabled {
        addText(52, .media, "清理间隔天数", "默认 7 天", .autoCleanupIntervalDays)
    }
    addAction(53, .media, "立即清理缓存", .clearCacheNow)
    addFooter(54, .media, "自动清理在应用启动时检查并清除过期媒体缓存，不影响聊天记录。")

    // 自动化
    addHeader(55, .automation, "自动化")
    addSwitch(56, .automation, "自动已读", settings.autoRead, \.autoRead)
    addSwitch(57, .automation, "自动已读随机回复", settings.autoReadRandomReply, \.autoReadRandomReply)
    addSwitch(58, .automation, "群聊自动已读回复", settings.autoReadReplyGroups, \.autoReadReplyGroups)
    addSwitch(59, .automation, "自动翻译消息", settings.autoTranslateMessages, \.autoTranslateMessages)
    addSwitch(60, .automation, "出站消息自动翻译", settings.outgoingTranslationEnabled, \.outgoingTranslationEnabled)
    addFooter(61, .automation, "自动翻译将消息翻译为中文；需系统翻译服务可用。")

    // 外观
    addHeader(62, .appearance, "外观")
    addSwitch(63, .appearance, "隐藏代理图标", settings.hideProxyIcon, \.hideProxyIcon)
    addSwitch(64, .appearance, "禁用下拉搜索", settings.disablePullDownSearch, \.disablePullDownSearch)
    addText(65, .appearance, "输入栏文字", "输入要显示的提示文字", .inputBarText)
    addText(66, .appearance, "会话页标题", "输入左上角显示的文字", .dialogsTitleText)
    addText(67, .appearance, "软件名称", "输入新的软件名称", .appIdentityName)
    addSwitch(68, .appearance, "本地会员状态", settings.localPremiumStatus, \.localPremiumStatus)
    addText(69, .appearance, "状态表情", "输入状态表情", .localPremiumEmoji)
    addText(70, .appearance, "自定义星星数量", "留空显示真实数量", .customStarBalance)
    addFooter(71, .appearance, "外观类修改仅在本机显示。")

    // 工具
    addHeader(72, .tools, "工具")
    addText(73, .tools, "代理订阅链接", "输入 https://example.com/proxy.txt", .proxySubscriptionSource)
    addSwitch(74, .tools, "展开全部账号", settings.accountsExpand, \.accountsExpand)
    addSwitch(75, .tools, "跨账号收件箱", settings.crossAccountInbox, \.crossAccountInbox)
    addFooter(76, .tools, "代理订阅源支持定时拉取远程代理列表。")

    // 独立模块
    addHeader(77, .modules, "独立模块")
    addSwitch(78, .modules, "诈骗用户警告", settings.scamUserWarningEnabled, \.scamUserWarningEnabled)
    addSwitch(79, .modules, "大文件保护", settings.largeFileGuardEnabled, \.largeFileGuardEnabled)
    addSwitch(80, .modules, "通知规则", settings.notificationRulesEnabled, \.notificationRulesEnabled)
    addSwitch(81, .modules, "性能监控", settings.performanceMonitorEnabled, \.performanceMonitorEnabled)
    addSwitch(82, .modules, "设置同步", settings.settingsSyncEnabled, \.settingsSyncEnabled)
    addSwitch(83, .modules, "定时提醒", settings.messageReminderEnabled, \.messageReminderEnabled)
    addSwitch(84, .modules, "置顶搜索频道", settings.pinnedSearchChannelsEnabled, \.pinnedSearchChannelsEnabled)
    addSwitch(85, .modules, "自动加入频道", settings.autoJoinChannelsEnabled, \.autoJoinChannelsEnabled)
    addFooter(86, .modules, "独立模块功能逐步接入中。")

    // 关于
    addHeader(87, .about, "关于")
    entries.append(.footer(88, .about, "芒果客户端 iOS 版 · 基于 Telegram 源码\n功能与 Android 芒果客户端对齐"))

    return entries
}

public func mangoSettingsController(context: AccountContext) -> ViewController {
    let settingsPromise = ValuePromise(MangoSettingsStore.shared, ignoreRepeated: true)
    let searchTextPromise = ValuePromise("", ignoreRepeated: true)

    var textValues = initialMangoTextValues(MangoSettingsStore.shared)
    let textValuesPromise = ValuePromise(textValues, ignoreRepeated: true)

    var presentUndoImpl: ((UndoOverlayContent) -> Void)?
    var pushImpl: ((ViewController) -> Void)?

    let arguments = MangoSettingsControllerArguments(
        update: { transform in
            MangoSettingsStore.update(transform)
            settingsPromise.set(MangoSettingsStore.shared)
        },
        updateSearch: { text in
            searchTextPromise.set(text)
        },
        updateText: { field, value in
            textValues[field] = value
            textValuesPromise.set(textValues)
            applyMangoTextUpdate(field, value)
            settingsPromise.set(MangoSettingsStore.shared)
        },
        performAction: { action in
            switch action {
            case .clearCacheNow:
                let categories: [StorageUsageStats.CategoryKey] = [.photos, .videos, .files, .music, .stickers, .avatars, .misc, .stories]
                let _ = context.engine.resources.clearStorage(peerId: nil, categories: categories, includeMessages: [], excludeMessages: []).start()
                MangoSettingsStore.update { $0.lastAutoCleanupTimestamp = Date().timeIntervalSince1970 }
                settingsPromise.set(MangoSettingsStore.shared)
                presentUndoImpl?(.info(title: nil, text: "缓存清理已开始", timeout: nil, customUndoText: nil))
            case .openProxySettings:
                pushImpl?(proxySettingsController(context: context))
            }
        }
    )

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        settingsPromise.get(),
        searchTextPromise.get(),
        textValuesPromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, settings, searchText, textValues -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var presentationData = presentationData
        let updatedTheme = presentationData.theme.withModalBlocksBackground()
        presentationData = presentationData.withUpdated(theme: updatedTheme)

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("芒果设置"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: mangoSettingsEntries(settings: settings, searchText: searchText, textValues: textValues), style: .blocks, animateChanges: true)

        return (controllerState, (listState, arguments))
    }

    let controller = ItemListController(context: context, state: signal)
    controller.navigationPresentation = .modal

    presentUndoImpl = { [weak controller] content in
        guard let controller = controller else {
            return
        }
        let presentationData = context.sharedContext.currentPresentationData.with { $0 }
        controller.present(UndoOverlayController(presentationData: presentationData, content: content, elevatedLayout: false, action: { _ in
            return false
        }), in: .window(.root))
    }
    pushImpl = { [weak controller] c in
        controller?.push(c)
    }

    return controller
}
