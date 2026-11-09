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

private final class MangoSettingsControllerArguments {
    let update: (inout MangoSettings) -> Void
    let updateSearch: (String) -> Void
    let updateKeywordsText: (String) -> Void
    let updateWhitelistText: (String) -> Void
    let clearCacheNow: () -> Void
    let openProxySettings: () -> Void

    init(
        update: @escaping (inout MangoSettings) -> Void,
        updateSearch: @escaping (String) -> Void,
        updateKeywordsText: @escaping (String) -> Void,
        updateWhitelistText: @escaping (String) -> Void,
        clearCacheNow: @escaping () -> Void,
        openProxySettings: @escaping () -> Void
    ) {
        self.update = update
        self.updateSearch = updateSearch
        self.updateKeywordsText = updateKeywordsText
        self.updateWhitelistText = updateWhitelistText
        self.clearCacheNow = clearCacheNow
        self.openProxySettings = openProxySettings
    }
}

private enum MangoSettingsSection: Int32 {
    case search
    case messages
    case ads
    case media
    case proxy
    case about
}

private enum MangoSettingsEntry: ItemListNodeEntry {
    case searchInput(String)

    case messagesHeader
    case keywordAlertsEnabled(Bool)
    case keywordsInput(String)
    case keywordMutedEnabled(Bool)
    case sendConfirmationEnabled(Bool)
    case antiRecallEnabled(Bool)
    case messagesFooter

    case adsHeader
    case adBlockEnabled(Bool)
    case adWhitelistInput(String)
    case adsFooter

    case mediaHeader
    case autoCleanupEnabled(Bool)
    case clearCacheNow
    case mediaFooter

    case proxyHeader
    case hideProxyIcon(Bool)
    case openProxySettings

    case aboutHeader
    case aboutText

    var section: ItemListSectionId {
        switch self {
        case .searchInput:
            return MangoSettingsSection.search.rawValue
        case .messagesHeader, .keywordAlertsEnabled, .keywordsInput, .keywordMutedEnabled, .sendConfirmationEnabled, .antiRecallEnabled, .messagesFooter:
            return MangoSettingsSection.messages.rawValue
        case .adsHeader, .adBlockEnabled, .adWhitelistInput, .adsFooter:
            return MangoSettingsSection.ads.rawValue
        case .mediaHeader, .autoCleanupEnabled, .clearCacheNow, .mediaFooter:
            return MangoSettingsSection.media.rawValue
        case .proxyHeader, .hideProxyIcon, .openProxySettings:
            return MangoSettingsSection.proxy.rawValue
        case .aboutHeader, .aboutText:
            return MangoSettingsSection.about.rawValue
        }
    }

    var stableId: Int32 {
        switch self {
        case .searchInput: return 0
        case .messagesHeader: return 1
        case .keywordAlertsEnabled: return 2
        case .keywordsInput: return 3
        case .keywordMutedEnabled: return 4
        case .sendConfirmationEnabled: return 5
        case .antiRecallEnabled: return 6
        case .messagesFooter: return 7
        case .adsHeader: return 8
        case .adBlockEnabled: return 9
        case .adWhitelistInput: return 10
        case .adsFooter: return 11
        case .mediaHeader: return 12
        case .autoCleanupEnabled: return 13
        case .clearCacheNow: return 14
        case .mediaFooter: return 15
        case .proxyHeader: return 16
        case .hideProxyIcon: return 17
        case .openProxySettings: return 18
        case .aboutHeader: return 19
        case .aboutText: return 20
        }
    }

    /// 设置搜索：返回该条目参与搜索的标题文本（空串表示不参与）
    var searchableTitle: String {
        switch self {
        case .keywordAlertsEnabled: return "关键词提醒"
        case .keywordsInput: return "关键词列表"
        case .keywordMutedEnabled: return "静音会话关键词提醒"
        case .sendConfirmationEnabled: return "发送前确认"
        case .antiRecallEnabled: return "防撤回"
        case .adBlockEnabled: return "广告屏蔽"
        case .adWhitelistInput: return "广告白名单"
        case .autoCleanupEnabled: return "自动清理缓存"
        case .clearCacheNow: return "立即清理缓存"
        case .hideProxyIcon: return "隐藏代理图标"
        case .openProxySettings: return "代理设置"
        default: return ""
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
        case .messagesHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "消息增强", sectionId: self.section)
        case let .keywordAlertsEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "关键词提醒", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.keywordAlertsEnabled = value }
            })
        case let .keywordsInput(text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: "关键词，用逗号分隔", maxLength: nil, sectionId: self.section, style: .blocks, minimalHeight: 60.0, textUpdated: { value in
                arguments.updateKeywordsText(value)
            }, updatedFocus: nil, tag: nil, action: nil)
        case let .keywordMutedEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "静音会话也提醒", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.alertMutedChatsOnKeywordMatch = value }
            })
        case let .sendConfirmationEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "发送前确认", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.sendConfirmationEnabled = value }
            })
        case let .antiRecallEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "防撤回", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.antiRecallEnabled = value }
            })
        case .messagesFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("开启关键词提醒后，应用内收到含关键词的消息会强提醒。防撤回开启后，对方撤回的消息仍保留在本机。"), sectionId: self.section)
        case .adsHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "广告屏蔽", sectionId: self.section)
        case let .adBlockEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "屏蔽赞助消息", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.adBlockEnabled = value }
            })
        case let .adWhitelistInput(text):
            return ItemListMultilineInputItem(presentationData: presentationData, systemStyle: .glass, text: text, placeholder: "白名单频道 ID，用逗号分隔", maxLength: nil, sectionId: self.section, style: .blocks, minimalHeight: 60.0, textUpdated: { value in
                arguments.updateWhitelistText(value)
            }, updatedFocus: nil, tag: nil, action: nil)
        case .adsFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("开启后隐藏频道内的赞助广告消息；白名单中的频道不受影响（填数字 ID）。"), sectionId: self.section)
        case .mediaHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "媒体清理", sectionId: self.section)
        case let .autoCleanupEnabled(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "自动清理缓存（每 7 天）", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.autoCleanupEnabled = value }
            })
        case .clearCacheNow:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "立即清理缓存", kind: .destructive, alignment: .center, sectionId: self.section, style: .blocks, action: {
                arguments.clearCacheNow()
            })
        case .mediaFooter:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("自动清理会在应用启动时检查并清除超过 7 天未清理的媒体缓存，不影响聊天记录。"), sectionId: self.section)
        case .proxyHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "网络与代理", sectionId: self.section)
        case let .hideProxyIcon(value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: "隐藏代理图标", value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.update { $0.hideProxyIcon = value }
            })
        case .openProxySettings:
            return ItemListActionItem(presentationData: presentationData, systemStyle: .glass, title: "打开代理设置", kind: .generic, alignment: .center, sectionId: self.section, style: .blocks, action: {
                arguments.openProxySettings()
            })
        case .aboutHeader:
            return ItemListSectionHeaderItem(presentationData: presentationData, text: "关于", sectionId: self.section)
        case .aboutText:
            return ItemListTextItem(presentationData: presentationData, text: .markdown("芒果客户端 iOS 版 · 基于 Telegram 源码\n功能与 Android 芒果客户端对齐"), sectionId: self.section)
        }
    }
}

private func mangoSettingsEntries(
    settings: MangoSettings,
    searchText: String,
    keywordsText: String,
    whitelistText: String
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

    entries.append(.messagesHeader)
    if include(.keywordAlertsEnabled(false)) { entries.append(.keywordAlertsEnabled(settings.keywordAlertsEnabled)) }
    if settings.keywordAlertsEnabled && include(.keywordsInput("")) {
        entries.append(.keywordsInput(keywordsText))
    }
    if settings.keywordAlertsEnabled && include(.keywordMutedEnabled(false)) {
        entries.append(.keywordMutedEnabled(settings.alertMutedChatsOnKeywordMatch))
    }
    if include(.sendConfirmationEnabled(false)) { entries.append(.sendConfirmationEnabled(settings.sendConfirmationEnabled)) }
    if include(.antiRecallEnabled(false)) { entries.append(.antiRecallEnabled(settings.antiRecallEnabled)) }
    entries.append(.messagesFooter)

    entries.append(.adsHeader)
    if include(.adBlockEnabled(false)) { entries.append(.adBlockEnabled(settings.adBlockEnabled)) }
    if settings.adBlockEnabled && include(.adWhitelistInput("")) {
        entries.append(.adWhitelistInput(whitelistText))
    }
    entries.append(.adsFooter)

    entries.append(.mediaHeader)
    if include(.autoCleanupEnabled(false)) { entries.append(.autoCleanupEnabled(settings.autoCleanupEnabled)) }
    if include(.clearCacheNow) { entries.append(.clearCacheNow) }
    entries.append(.mediaFooter)

    entries.append(.proxyHeader)
    if include(.hideProxyIcon(false)) { entries.append(.hideProxyIcon(settings.hideProxyIcon)) }
    if include(.openProxySettings) { entries.append(.openProxySettings) }

    entries.append(.aboutHeader)
    entries.append(.aboutText)

    return entries
}

public func mangoSettingsController(context: AccountContext) -> ViewController {
    let settingsPromise = ValuePromise(MangoSettingsStore.shared, ignoreRepeated: true)
    let searchTextPromise = ValuePromise("", ignoreRepeated: true)

    let initialSettings = MangoSettingsStore.shared
    var keywordsText = initialSettings.keywords.joined(separator: ", ")
    var whitelistText = initialSettings.adBlockWhitelistPeerIds.map { String($0) }.joined(separator: ", ")

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
        updateKeywordsText: { value in
            keywordsText = value
            let keywords = value.components(separatedBy: CharacterSet(charactersIn: ",，\n")).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            MangoSettingsStore.update { $0.keywords = keywords }
        },
        updateWhitelistText: { value in
            whitelistText = value
            let ids = value.components(separatedBy: CharacterSet(charactersIn: ",，\n")).compactMap { Int64($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
            MangoSettingsStore.update { $0.adBlockWhitelistPeerIds = ids }
        },
        clearCacheNow: {
            let categories: [StorageUsageStats.CategoryKey] = [.photos, .videos, .files, .music, .stickers, .avatars, .misc, .stories]
            let _ = context.engine.resources.clearStorage(peerId: nil, categories: categories, includeMessages: [], excludeMessages: []).start()
            MangoSettingsStore.update { $0.lastAutoCleanupTimestamp = Date().timeIntervalSince1970 }
            settingsPromise.set(MangoSettingsStore.shared)
            presentUndoImpl?(.info(title: nil, text: "缓存清理已开始", timeout: nil, customUndoText: nil))
        },
        openProxySettings: {
            pushImpl?(proxySettingsController(context: context))
        }
    )

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        settingsPromise.get(),
        searchTextPromise.get()
    )
    |> deliverOnMainQueue
    |> map { presentationData, settings, searchText -> (ItemListControllerState, (ItemListNodeState, Any)) in
        var presentationData = presentationData
        let updatedTheme = presentationData.theme.withModalBlocksBackground()
        presentationData = presentationData.withUpdated(theme: updatedTheme)

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("芒果设置"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: mangoSettingsEntries(settings: settings, searchText: searchText, keywordsText: keywordsText, whitelistText: whitelistText), style: .blocks, animateChanges: true)

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
