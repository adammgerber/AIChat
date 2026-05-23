//
//  CreateAvatarPresenter.swift
//  AIChatCourse
//
//  Created by Adam Gerber on 12/04/2026.
//

import SwiftUI

@Observable
@MainActor
class CreateAvatarPresenter {
    
    private let interactor: CreateAvatarInteractor
    private let router: CreateAvatarRouter
    
    init(interactor: CreateAvatarInteractor, router: CreateAvatarRouter) {
        self.interactor = interactor
        self.router = router
    }

    private(set) var isGenerating: Bool = false
    private(set) var isSaving: Bool = false
    private(set) var generatedImage: UIImage?
    
    var characterOption: CharacterOption = .default
    var characterAction: CharacterAction = .default
    var characterLocation: CharacterLocation = .default
    var avatarName: String = ""
    
    func onBackButtonPressed() {
        interactor.trackEvent(event: Event.backButtonPressed)
        router.dismissScreen()
    }
    
    func onGenerateImagePressed() {
        isGenerating = true
        interactor.trackEvent(event: Event.backButtonPressed)

        Task {
            do {
                let avatarDescriptionBuilder = AvatarDescriptionBuilder(
                    characterOption: characterOption,
                    characterAction: characterAction,
                    characterLocation: characterLocation
                )
                let prompt = avatarDescriptionBuilder.characterDescription
                
                generatedImage = try await interactor.generateImage(input: prompt)
                interactor.trackEvent(event: Event.generateImageSuccess(avatarDescriptionBuilder: avatarDescriptionBuilder))

            } catch {
                interactor.trackEvent(event: Event.generateImageFail(error: error))
            }
            
            isGenerating = false
        }
    }
    
    func onSavePressed() {
        interactor.trackEvent(event: Event.saveAvatarStart)
        guard let generatedImage else { return }

        isSaving = true
        
        Task {
            do {
                try TextValidationHelper.checkIfTextIsValid(text: avatarName, minimumCharacterCount: 3)
                let uid = try interactor.getAuthId()
                
                let avatar = AvatarModel.newAvatar(
                    name: avatarName,
                    option: characterOption,
                    action: characterAction,
                    location: characterLocation,
                    authorId: uid
                )

                try await interactor.createAvatar(avatar: avatar, image: generatedImage)
                interactor.trackEvent(event: Event.saveAvatarSuccess(avatar: avatar))

                // Dismiss screen
                router.dismissScreen()
            } catch {
                router.showAlert(error: error)
                interactor.trackEvent(event: Event.saveAvatarFail(error: error))
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
