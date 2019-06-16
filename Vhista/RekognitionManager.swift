//
//  RekognitionManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/3/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import UIKit
import AVFoundation
import AWSCore
import AWSRekognition

class RekognitionManager: NSObject {

    //Setup player for loading sounds
    var player: AVAudioPlayer?

    //Handle current Stage
    var nextIsProcessFaces: Bool = false
    var nextIsFinish: Bool = false

    //Faces Variables
    var resultFaces: [AWSRekognitionFaceDetail]?
    var errorGettingFaces: Bool? = false

    //Image to recognize
    var takenImage: UIImage!

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: RekognitionManager = {
        let instance = RekognitionManager()
        return instance
    }()

    func backToDefaults () {
        DispatchQueue.main.async {
            SwiftSpinner.hide()
            self.pauseLoadingSound()
            self.resultFaces = nil
            self.errorGettingFaces = nil
        }
    }
}

extension RekognitionManager {

    func startProcessing (_ sender: UIImage?) {

        recordAnalytics(analyticsEventName: AnalyticsConstants.TakenPicture, parameters: [
            "language": globalLanguage as NSObject
            ])

//        VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Processing_Image", comment: ""))

        takenImage = sender

        detectLabelsWithImage(pImage: takenImage, { (resultLabels: [AWSRekognitionLabel]?) in

            VhistaSpeechManager.shared.blockAllSpeech =  false

            if resultLabels != nil {

                if resultLabels!.count == 0 {

                    self.pauseLoadingSound()

                    VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("No_Objects_Found", comment: ""))

                    self.nextIsProcessFaces = true

                } else {
                    self.processLabels(labels: resultLabels!)
                }

            } else {

                self.pauseLoadingSound()

                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Error_Getting_Objects", comment: ""))

                self.nextIsProcessFaces = true
            }
        })

        //Asynchronic getter (Facial Recognition)
        self.faceAnalysisWithImage(pImage: self.takenImage) { (faces: [AWSRekognitionFaceDetail]?) in
            if faces != nil {
                self.resultFaces = faces
            } else {
                self.errorGettingFaces = true
            }
        }

    }

}

extension RekognitionManager {

    func processLabels(labels: [AWSRekognitionLabel]) {

        DispatchQueue.main.async {
            SwiftSpinner.show(NSLocalizedString("HUD_Processing_Response", comment: ""))
        }

        self.recordAnalytics(analyticsEventName: "labels_processed", parameters: [
            "language": globalLanguage as NSObject,
            "count": labels.count as NSObject
            ])

        var arrayLabels = [String]()

        if globalLanguage.contains("en-") {

            for labelTemp: AWSRekognitionLabel in labels {
                arrayLabels.append(labelTemp.name!)
            }
            print(arrayLabels)
            speakLabels(arrayLabels: arrayLabels)

        } else {

            let totalTranslations: Int = labels.count
            var translatedStrings: Int = 0

            for labelTemp: AWSRekognitionLabel in labels {

                translateString(pString: labelTemp.name!,
                                targetLanguage: globalLanguage.components(separatedBy: "-")[0],
                                { (stringTranslated: String?) in
                                    if stringTranslated != nil {
                                        arrayLabels.append(stringTranslated!)
                                    } else {

                                    }
                                    translatedStrings += 1
                                    if translatedStrings == totalTranslations {
                                        self.speakLabels(arrayLabels: arrayLabels)
                                    }
                })

            }
        }

    }

    func speakLabels(arrayLabels: [String]) {

        DispatchQueue.main.async {
            SwiftSpinner.show(NSLocalizedString("HUD_Reading_Response", comment: ""))
        }

        pauseLoadingSound()

        var stringResponse: String  = NSLocalizedString("Found_In_Picture", comment: "Object(s) were found, let the user know that")

        //Check for exact repeatition of words
        var assertArray: [String] = [String]()

        for labelTemp in arrayLabels {

            var alreadyAdded: Bool = false
            for assertItem in assertArray where labelTemp == assertItem {
                alreadyAdded = true
            }

            if !alreadyAdded {
                if labelTemp == arrayLabels[arrayLabels.count-1] {
                    stringResponse += labelTemp + "."
                } else {
                    stringResponse += labelTemp + ", "
                }
                assertArray.append(labelTemp)
            }

        }

        VhistaSpeechManager.shared.speakRekognition(stringToSpeak: stringResponse)

        nextIsProcessFaces = true

    }

}

extension RekognitionManager {

    @objc func getFaces() {

        if errorGettingFaces != nil {
            if errorGettingFaces! == true {

                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Error_Getting_People",
                                                                                             comment: "There was an error analyzing faces"))
                self.nextIsFinish = true
            }
        }

        if resultFaces == nil {
            print("⏱ Faces were not obtained, retry in 0.2 seconds.")
            Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(self.getFaces), userInfo: nil, repeats: false)
        } else {
            if resultFaces!.count == 0 {

                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("No_People",
                                                                                             comment: "No people were found in the image"))

                self.nextIsFinish = true

            } else {

                self.processFaces(faces: resultFaces!)

            }

        }

    }

    func processFaces(faces: [AWSRekognitionFaceDetail]) {

        DispatchQueue.main.async {
            SwiftSpinner.show(NSLocalizedString("HUD_Describing_People", comment: ""))
        }

        recordAnalytics(analyticsEventName: "faces_processed", parameters: [
            "language": globalLanguage as NSObject,
            "count": faces.count as NSObject
            ])

        var stringResonse: String = ""
        if faces.count > 1 {
            stringResonse = NSLocalizedString("Number_People_Plural", comment: "").replacingOccurrences(of: "XX", with: String(faces.count))
        } else {
            stringResonse = NSLocalizedString("One_Person", comment: "There is only one person in the picture")
        }

        for faceTemp: AWSRekognitionFaceDetail in faces {

            if faceTemp == faces[0] && faces.count > 1 {
                stringResonse += NSLocalizedString("First_Person", comment: "")
            } else if faceTemp == faces[0] && faces.count == 1 {
                stringResonse += NSLocalizedString("First_And_Only_Person", comment: "")
            } else if String(describing: faceTemp) == String(describing: faces[faces.count-1]) {
                stringResonse += NSLocalizedString("Last_Person", comment: "")
            } else {
                stringResonse += NSLocalizedString("Next_Person", comment: "")
            }

            if faceTemp.gender!.value == AWSRekognitionGenderType.male {
                stringResonse += NSLocalizedString("Is_Male", comment: "")
            } else if faceTemp.gender!.value == AWSRekognitionGenderType.female {
                stringResonse += NSLocalizedString("Is_Female", comment: "")
            }

            if faceTemp.beard!.value!.isEqual(to: 1) {
                stringResonse += NSLocalizedString("Has_Beard", comment: "")
            }

            if faceTemp.mustache!.value!.isEqual(to: 1) {
                stringResonse += NSLocalizedString("Has_Mustache", comment: "")
            }

            if faceTemp.eyeglasses!.value!.isEqual(to: 1) {
                stringResonse += NSLocalizedString("Has_Glasses", comment: "")
            }

            if faceTemp.smile!.value!.isEqual(to: 1) {
                stringResonse += NSLocalizedString("Is_Smiling", comment: "")
            }

            if faceTemp.emotions!.count > 0 {
                var emotionMostConfident: AWSRekognitionEmotion!
                var mostConfidency: NSNumber = 0.0
                for tempEmotion: AWSRekognitionEmotion in faceTemp.emotions!
                    where tempEmotion.confidence!.doubleValue >= mostConfidency.doubleValue {
                        emotionMostConfident = tempEmotion
                        mostConfidency = tempEmotion.confidence!
                }

                stringResonse += NSLocalizedString("The_Person_Is", comment: "")

                if emotionMostConfident.types == AWSRekognitionEmotionName.angry {
                    stringResonse += NSLocalizedString("Angry", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.calm {
                    stringResonse += NSLocalizedString("Calm", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.confused {
                    stringResonse += NSLocalizedString("Confused", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.disgusted {
                    stringResonse += NSLocalizedString("Upset", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.happy {
                    stringResonse += NSLocalizedString("Happy", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.sad {
                    stringResonse += NSLocalizedString("Sad", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.surprised {
                    stringResonse += NSLocalizedString("Surprised", comment: "")
                }

            }

        }

        VhistaSpeechManager.shared.sayText(stringToSpeak: stringResonse, isProtected: true, rate: Float(globalRate))

        nextIsFinish = true

    }

}

extension RekognitionManager {

    func playLoadingSound() {

        DispatchQueue.main.async {
            SwiftSpinner.show(NSLocalizedString("HUD_Processing_Image", comment: ""))
        }

        let url = Bundle.main.url(forResource: "pad_confirm", withExtension: "aif")!

        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            player.volume = 0.5
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }

    func pauseLoadingSound() {
        if player != nil {
            if player!.isPlaying {
                player!.stop()
            }
        }
    }

}
