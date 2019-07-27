//
//  VhistaSpeechManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/2/17.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit
import AVFoundation

var processingImage = false

class VhistaSpeechManager: NSObject {

    var parentARController: ARKitCameraViewController?

    //Speech Synthesizer
    let speechSynthesizer = AVSpeechSynthesizer()

    var voice: AVSpeechSynthesisVoice!

    var playingProtectedContent = false

    var blockAllSpeech = false

    // MARK: - Initialization Method
    override init() {
        super.init()

        for availableVoice in AVSpeechSynthesisVoice.speechVoices() {
            if (availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode()) &&
                (availableVoice.quality == AVSpeechSynthesisVoiceQuality.enhanced) {
                // If you have found the enhanced version of the currently selected language voice amongst your available voices
                // Usually there's only one selected.
                self.voice = availableVoice
                print("\(availableVoice.name) selected as voice for uttering speeches. Quality: \(availableVoice.quality.rawValue)")
            } else if availableVoice.language == AVSpeechSynthesisVoice.currentLanguageCode() {
                self.voice = availableVoice
                print("\(availableVoice.name) selected as voice for uttering speeches. Quality: \(availableVoice.quality.rawValue)")
            }
        }
        if let selectedVoice = self.voice { // if sucessfully unwrapped, the previous routine was able to identify one of the enhanced voices
            print("The following voice identifier has been loaded: ", selectedVoice.identifier)
        } else {
            self.voice = AVSpeechSynthesisVoice(language: AVSpeechSynthesisVoice.currentLanguageCode())
        }
    }

    static let shared: VhistaSpeechManager = {

        let instance = VhistaSpeechManager()

        if globalLanguage.contains("es-") {
            instance.voice = AVSpeechSynthesisVoice(language: "es-MX")
        }

        instance.speechSynthesizer.delegate = instance

        return instance
    }()

    func sayText(stringToSpeak: String, isProtected: Bool, rate: Float) {

        if blockAllSpeech {
            return
        }

        if playingProtectedContent && !isProtected { return }

        if !playingProtectedContent && isProtected {
            playingProtectedContent = true
        }

        let speechUtterance = AVSpeechUtterance(string: stringToSpeak)

        speechUtterance.voice = voice
        speechUtterance.rate = rate

        stopSpeech(sender: stringToSpeak)

        speechSynthesizer.speak(speechUtterance)
//        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, stringToSpeak)
    }

    func speakRekognition(stringToSpeak: String) {
        sayText(stringToSpeak: stringToSpeak, isProtected: true, rate: Float(globalRate))
    }

}

extension VhistaSpeechManager: AVSpeechSynthesizerDelegate {

    func pauseSpeech(sender: Any) {
        speechSynthesizer.pauseSpeaking(at: AVSpeechBoundary.word)
    }

    func stopSpeech(sender: Any) {
        if speechSynthesizer.isSpeaking == true {
            speechSynthesizer.stopSpeaking(at: AVSpeechBoundary.immediate)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if processingImage {
//            if RekognitionManager.shared.nextIsProcessFaces == true {
//                print("👦🏼 Getting Rekognition Faces")
//                speakRekognition(stringToSpeak: NSLocalizedString("Analizying_People",
//                                                                  comment: "We now need to search for faces in the picture"))
//                RekognitionManager.shared.nextIsProcessFaces = false
//                RekognitionManager.shared.getFaces()
//            } else if RekognitionManager.shared.nextIsFinish {
//                print("🏃🏽 Finishing Rekognition")
//                RekognitionManager.shared.nextIsFinish = false
//                RekognitionManager.shared.backToDefaults()
//                self.playingProtectedContent = false
//                if let parentVCAR = self.parentARController {
//                    parentVCAR.finishedRekognitionAnalisis()
//                }
//            }
//        } else {
//            if playingProtectedContent {
//                playingProtectedContent = false
//            }
        }
    }
}
