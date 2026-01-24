//
//  ExploreView.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 10/5/25.
//
import SwiftUI

struct ExploreView: View {
    
    @Environment(AvatarManager.self) private var avatarManager
    @Environment(LogManager.self) private var logManager
    @Environment(PushManager.self) private var pushManager

    @State private var categories: [CharacterOption] = CharacterOption.allCases

    @State private var featuredAvatars: [AvatarModel] = []
    @State private var popularAvatars: [AvatarModel] = []
    @State private var isLoadingFeatured: Bool = true
    @State private var isLoadingPopular: Bool = true

    @State private var path: [NavigationPathOption] = []
    @State private var showDevSettings: Bool = false
    @State private var showNotificationButton: Bool = false
    @State private var showPushNotificationModal: Bool = false

    private var showDevSettingsButton: Bool {
        #if DEV || MOCK
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        NavigationStack(path: $path) {
            List {
                if featuredAvatars.isEmpty && popularAvatars.isEmpty {
                    ZStack {
                        if isLoadingFeatured || isLoadingPopular {
                            loadingIndicator
                        } else {
                            errorMessageView
                        }
                    }
                    .removeListRowFormatting()
                }
                
                if !featuredAvatars.isEmpty {
                    featuredSection
                }
                
                if !popularAvatars.isEmpty {
                    categorySection
                    popularSection
                }
            }
            .navigationTitle("Explore")
            .screenAppearAnalytics(name: "ExploreView")
            .showModal(showModal: $showPushNotificationModal) {
                pushNotificationModal
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    if showDevSettingsButton {
                        devSettingsButton
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if showNotificationButton {
                        pushNotificationButton
                    }
                }
            })
            .sheet(isPresented: $showDevSettings, content: {
                DevSettingsView()
            })
            .navigationDestinationForCoreModule(path: $path)
            .task {
                await loadFeaturedAvatars()
            }
            .task {
                await loadPopularAvatars()
            }
            .task {
                await handleShowPushNotificationButton()
            }
            .onFirstAppear {
                schedulePushNotifications()
            }
        }
    }
    
    private func schedulePushNotifications() {
        pushManager.schedulePushNotificationsForTheNextWeek()
    }
    
    private func handleShowPushNotificationButton() async {
        showNotificationButton = await pushManager.canRequestAuthorization()
    }
    
    private func onPushNotificationButtonPressed() {
        showPushNotificationModal = true
        logManager.trackEvent(event: Event.pushNotifcStart)
    }
    
    private func onEnablePushNotificationsPressed() {
        showPushNotificationModal = false
        Task {
            let isAuthorized = try await pushManager.requestAuthorization()
            logManager.trackEvent(event: Event.pushNotifsEnable(isAuthorized: isAuthorized))
            await handleShowPushNotificationButton()
        }
    }
    
    private func onCancelPushNotificationsPressed() {
        showPushNotificationModal = false
        logManager.trackEvent(event: Event.pushNotifsCancel)
    }
    
    private var pushNotificationModal: some View {
        CustomModalView(
            title: "Enable push notifications?",
            subtitle: "We'll send you reminders and updates!",
            primaryButtonTitle: "Enable",
            primaryButtonAction: {
                onEnablePushNotificationsPressed()
            },
            secondaryButtonTitle: "Cancel",
            secondaryButtonAction: {
                onCancelPushNotificationsPressed()
            }
        )
    }
    private var pushNotificationButton: some View {
        Image(systemName: "bell.fill")
            .font(.headline)
            .padding(4)
            .tappableBackground()
            .foregroundStyle(.accent)
            .anyButton {
                onPushNotificationButtonPressed()
            }
    }
    private var devSettingsButton: some View {
        Text("DEV 🤫")
            .badgeButton()
            .anyButton(.press) {
                onDevSettingsPressed()
            }
    }
    
    enum Event: LoggableEvent {
        case devSettingsPressed
        case tryAgainPressed
        case loadFeaturedAvatarsStart
        case loadFeaturedAvatarsSuccess(count: Int)
        case loadFeaturedAvatarsFail(error: Error)
        case loadPopularAvatarsStart
        case loadPopularAvatarsSuccess(count: Int)
        case loadPopularAvatarsFail(error: Error)
        case avatarPressed(avatar: AvatarModel)
        case categoryPressed(category: CharacterOption)
        case pushNotifcStart
        case pushNotifsEnable(isAuthorized: Bool)
        case pushNotifsCancel

        var eventName: String {
            switch self {
            case .devSettingsPressed:           return "ExploreView_DevSettings_Pressed"
            case .tryAgainPressed:              return "ExploreView_TryAgain_Pressed"
            case .loadFeaturedAvatarsStart:     return "ExploreView_LoadFeaturedAvatars_Start"
            case .loadFeaturedAvatarsSuccess:   return "ExploreView_LoadFeaturedAvatars_Success"
            case .loadFeaturedAvatarsFail:      return "ExploreView_LoadFeaturedAvatars_Fail"
            case .loadPopularAvatarsStart:      return "ExploreView_LoadPopularAvatars_Start"
            case .loadPopularAvatarsSuccess:    return "ExploreView_LoadPopularAvatars_Success"
            case .loadPopularAvatarsFail:       return "ExploreView_LoadPopularAvatars_Fail"
            case .avatarPressed:                return "ExploreView_Avatar_Pressed"
            case .categoryPressed:              return "ExploreView_Category_Pressed"
            case .pushNotifcStart:              return "ExploreView_PushNotifs_Start"
            case .pushNotifsEnable:             return "ExploreView_PushNotifs_Enable"
            case .pushNotifsCancel:             return "ExploreView_PushNotifs_Cancel"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .loadPopularAvatarsSuccess(count: let count), .loadFeaturedAvatarsSuccess(count: let count):
                return [
                    "avatars_count": count
                ]
            case .loadPopularAvatarsFail(error: let error), .loadFeaturedAvatarsFail(error: let error):
                return error.eventParameters
            case .avatarPressed(avatar: let avatar):
                return avatar.eventParameters
            case .categoryPressed(category: let category):
                return [
                    "category": category.rawValue
                ]
            case .pushNotifsEnable(isAuthorized: let isAuthorized):
                return [
                    "is_authorized": isAuthorized
                ]
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .loadPopularAvatarsFail, .loadFeaturedAvatarsFail:
                return .severe
            default:
                return .analytic
            }
        }
    }
    
    private func onDevSettingsPressed() {
        showDevSettings = true
        logManager.trackEvent(event: Event.devSettingsPressed)
    }
    
    private var loadingIndicator: some View {
        ProgressView()
            .tint(.accent)
            .padding(40)
            .frame(maxWidth: .infinity)
    }
    
    private var errorMessageView: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("Error")
                .font(.headline)
            Text("Please check your internet connection and try again.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Try again") {
                onTryAgainPressed()
            }
            .foregroundStyle(.blue)
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
        .padding(40)
    }
    
    private func onTryAgainPressed() {
        isLoadingFeatured = true
        isLoadingPopular = true
        logManager.trackEvent(event: Event.tryAgainPressed)

        Task {
            await loadFeaturedAvatars()
        }
        Task {
            await loadPopularAvatars()
        }
    }
    
    private func loadFeaturedAvatars() async {
        // If already loaded, no need to fetch again
        guard featuredAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadFeaturedAvatarsStart)

        do {
            featuredAvatars = try await avatarManager.getFeaturedAvatars()
            logManager.trackEvent(event: Event.loadFeaturedAvatarsSuccess(count: featuredAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadFeaturedAvatarsFail(error: error))
        }
        
        isLoadingFeatured = false
    }
    
    private func loadPopularAvatars() async {
        guard popularAvatars.isEmpty else { return }
        logManager.trackEvent(event: Event.loadPopularAvatarsStart)

        do {
            popularAvatars = try await avatarManager.getPopularAvatars()
            logManager.trackEvent(event: Event.loadPopularAvatarsSuccess(count: popularAvatars.count))
        } catch {
            logManager.trackEvent(event: Event.loadPopularAvatarsFail(error: error))
        }
        
        isLoadingPopular = false
    }
    
    private var featuredSection: some View {
        Section {
            ZStack {
                CarouselView(items: featuredAvatars) { avatar in
                    HeroCellView(
                        title: avatar.name,
                        subtitle: avatar.characterDescription,
                        imageName: avatar.profileImageName
                    )
                    .anyButton {
                        onAvatarPressed(avatar: avatar)
                    }
                }
            }
            .removeListRowFormatting()
        } header: {
            Text("Featured")
        }
    }
        
    private var categorySection: some View {
        Section {
            ZStack {
                ScrollView(.horizontal) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            let imageName = popularAvatars.last(where: { $0.characterOption == category })?.profileImageName
                            if let imageName {
                                CategoryCellView(
                                    title: category.plural.capitalized,
                                    imageName: imageName
                                )
                                .anyButton {
                                    onCategoryPressed(category: category, imageName: imageName)
                                }
                            }
                        }
                    }
                }
                .frame(height: 140)
                .scrollIndicators(.hidden)
                .scrollTargetLayout()
                .scrollTargetBehavior(.viewAligned)
            }
            .removeListRowFormatting()
        } header: {
            Text("Categories")
        }
    }
    
    private var popularSection: some View {
        Section {
            ForEach(popularAvatars, id: \.self) { avatar in
                CustomListCellView(
                    imageName: avatar.profileImageName,
                    title: avatar.name,
                    subtitle: avatar.characterDescription
                )
                .anyButton(.highlight) {
                    onAvatarPressed(avatar: avatar)
                }
                .removeListRowFormatting()
            }
        } header: {
            Text("Popular")
        }
    }
    
    private func onAvatarPressed(avatar: AvatarModel) {
        path.append(.chat(avatarId: avatar.avatarId, chat: nil))
        logManager.trackEvent(event: Event.avatarPressed(avatar: avatar))
    }

    private func onCategoryPressed(category: CharacterOption, imageName: String) {
        path.append(.category(category: category, imageName: imageName))
        logManager.trackEvent(event: Event.categoryPressed(category: category))
    }
}

#Preview("Has data") {
    ExploreView()
        .previewEnvironment()
}
#Preview("No data") {
    ExploreView()
        .previewEnvironment()
}
#Preview("Slow loading") {
    ExploreView()
        .previewEnvironment()
}
