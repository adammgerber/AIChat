//
//  CreateAvatarView.swift
//  AIChatCourse
//
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarViewModel {
    
    private let authManager: AuthManager
    private let aiManager: AIManager
    private let avatarManager: AvatarManager
    private let logManager: LogManager

    private(set) var isGenerating: Bool = false
    private(set) var isSaving: Bool = false
    private(set) var generatedImage: UIImage?
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var showAlert: AnyAppAlert?
    var avatarName: String = ""
    
    init(container: DependencyContainer) {
        self.authManager = container.resolve(AuthManager.self)!
        self.aiManager = container.resolve(AIManager.self)!
        self.avatarManager = container.resolve(AvatarManager.self)!
        self.logManager = container.resolve(LogManager.self)!
    }
    
    func onBackButtonPressed(onDismiss: () -> Void) {
        logManager.trackEvent(event: Event.backButtonPressed)
        onDismiss()
    }
    
    func onGenerateImagePressed() {
        isGenerating = true
        logManager.trackEvent(event: Event.backButtonPressed)

        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await aiManager.generateImage(input: prompt)
                logManager.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))

            } catch {
                logManager.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    func onSavePressed(onDismiss: @escaping () -> Void) {
        logManager.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }

        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try authManager.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )

                try await avatarManager.createAvatar(avatar: avatar, image: generatedImage)
                logManager.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))

                // Dismiss screen
                onDismiss()
            } catch {
                showAlert = AnyAppAlert(error: error)
                logManager.trackEvent(event: Event.saveAvatarFail(error: error))
            }
            
            isSaving = false
        }
    }
    
    enum Event: LoggableEvent {
        case backButtonPressed
        case generateImageStart
        case generateImageSuccess(avatarDescriptionBuilder: AvatarDescriptionBuilder)
        case generateImageFail(error: Error)
        case saveAvatarStart
        case saveAvatarSuccess(avatar: AvatarModel)
        case saveAvatarFail(error: Error)

        var eventName: String {
            switch self {
            case .backButtonPressed:         return "CreateAvatarView_BackButton_Pressed"
            case .generateImageStart:        return "CreateAvatarView_GenImage_Start"
            case .generateImageSuccess:      return "CreateAvatarView_GenImage_Success"
            case .generateImageFail:         return "CreateAvatarView_GenImage_Fail"
            case .saveAvatarStart:           return "CreateAvatarView_SaveAvatar_Start"
            case .saveAvatarSuccess:         return "CreateAvatarView_SaveAvatar_Success"
            case .saveAvatarFail:            return "CreateAvatarView_SaveAvatar_Fail"
            }
        }
        
        var parameters: [String: Any]? {
            switch self {
            case .generateImageSuccess(avatarDescriptionBuilder: let avatarDescriptionBuilder):
                return avatarDescriptionBuilder.eventParameters
            case .saveAvatarSuccess(avatar: let avatar):
                return avatar.eventParameters
            case .generateImageFail(error: let error), .saveAvatarFail(error: let error):
                return error.eventParameters
            default:
                return nil
            }
        }
        
        var type: LogType {
            switch self {
            case .generateImageFail:
                return .severe
            case .saveAvatarFail:
                return .warning
            default:
                return .analytic
            }
        }
    }
    
}
struct CreateAvatarView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State var viewModel: CreateAvatarViewModel

    var body: some View {
        NavigationStack {
            List {
                nameSection
                attributesSection
                imageSection
                saveSection
            }
            .navigationTitle("Create Avatar")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    backButton
                }
            }
            .showCustomAlert(alert: $viewModel.showAlert)
            .screenAppearAnalytics(name: "CreateAvatar")
        }
    }
    
    private var backButton: some View {
        Image(systemName: "xmark")
            .font(.title2)
            .fontWeight(.semibold)
            .anyButton(.plain) {
                viewModel.onBackButtonPressed(onDismiss: { dismiss() })
            }
    }
    
    private var nameSection: some View {
        Section {
            TextField("Player 1", text: $viewModel.avatarName)
        } header: {
            Text("Name your avatar*")
        }
    }
    
    private var attributesSection: some View {
        Section {
            Picker(selection: $viewModel.characterOption) {
                ForEach(CharacterOption.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("is a...")
            }

            Picker(selection: $viewModel.characterAction) {
                ForEach(CharacterAction.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("that is...")
            }
            
            Picker(selection: $viewModel.characterLocation) {
                ForEach(CharacterLocation.allCases, id: \.self) { option in
                    Text(option.rawValue.capitalized)
                        .tag(option)
                }
            } label: {
                Text("in the...")
            }
        } header: {
            Text("Attributes")
        }
    }
    
    private var imageSection: some View {
        Section {
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Text("Generate image")
                        .underline()
                        .foregroundStyle(.accent)
                        .anyButton(.plain) {
                            viewModel.onGenerateImagePressed()
                        }
                        .opacity(viewModel.isGenerating ? 0 : 1)

                    ProgressView()
                        .tint(.accent)
                        .opacity(viewModel.isGenerating ? 1 : 0)
                }
                .disabled(viewModel.isGenerating || viewModel.avatarName.isEmpty)
                
                Circle()
                    .fill(Color.secondary.opacity(0.3))
                    .overlay(
                        ZStack {
                            if let generatedImage = viewModel.generatedImage {
                                Image(uiImage: generatedImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                    )
                    .clipShape(Circle())
            }
            .removeListRowFormatting()
        }
    }
    
    private var saveSection: some View {
        Section {
            AsyncCallToActionButton(
                isLoading: viewModel.isSaving,
                title: "Save",
                action: {
                    viewModel.onSavePressed(onDismiss: {
                        dismiss()
                    })
                }
            )
            .removeListRowFormatting()
            .padding(.top, 24)
            .opacity(viewModel.generatedImage == nil ? 0.5 : 1.0)
            .disabled(viewModel.generatedImage == nil)
        }
    }
}

#Preview {
    CreateAvatarView(
        viewModel: CreateAvatarViewModel(
            container: DevPreview.shared.container
        )
    )
    .previewEnvironment()
}
