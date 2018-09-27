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
    var resultFaces:[AWSRekognitionFaceDetail]? = nil
    var errorGettingFaces:Bool? = false
    
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
    
    func startProcessing (_sender: Any) {
        
        recordAnalytics(analyticsEventName: AnalyticsConstants().TakenPicture, parameters: [
            "language": global_language as NSObject
            ])
        
//        VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Processing_Image", comment: "The picture has been taken so we need to tell the user we are now going to process the image."))
        
        
        takenImage = _sender as? UIImage
        
        
        detectLabelsWithImage(pImage: takenImage, { (resultLabels:[AWSRekognitionLabel]?) in
            
            VhistaSpeechManager.shared.blockAllSpeech =  false
            
            if resultLabels != nil {
                
                if resultLabels!.count == 0 {
                    
                    self.pauseLoadingSound()
                    
                    VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("No_Objects_Found", comment:"No objects were found on the image so we need to tell that to the user"))
                    
                    self.nextIsProcessFaces = true
                    
                } else {
                    self.processLabels(labels: resultLabels!)
                }
                
                
            } else {
                
                self.pauseLoadingSound()
                
                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Error_Getting_Objects", comment:"There was an error getting the objects in the image"))
                
                self.nextIsProcessFaces = true
            }
        })
        
        //Asynchronic getter (Facial Recognition)
        self.faceAnalysisWithImage(pImage: self.takenImage) { (faces:[AWSRekognitionFaceDetail]?) in
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
            "language": global_language as NSObject,
            "count": labels.count as NSObject
            ])
        
        var arrayLabels = [String]()
        
        if global_language.contains("en-") {
            
            for labelTemp: AWSRekognitionLabel in labels {
                arrayLabels.append(labelTemp.name!)
            }
            print(arrayLabels)
            speakLabels(arrayLabels: arrayLabels)
            
        } else {
            
            let totalTranslations: Int = labels.count
            var translatedStrings: Int = 0
            
            for labelTemp: AWSRekognitionLabel in labels {
                
                translateString(pString: labelTemp.name!,targetLanguage: global_language.components(separatedBy: "-")[0] , { (stringTranslated:String?) in
                    if stringTranslated != nil {
                        arrayLabels.append(stringTranslated!)
                    } else {
                        
                    }
                    translatedStrings = translatedStrings + 1
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
        
        var stringRespuesta: String  = NSLocalizedString("Found_In_Picture", comment: "Object(s) were found, let the user know that")
        
        //Check for exact repeatition of words
        var assertArray: [String] = [String]()
        
        for labelTemp in arrayLabels {
            
            var alreadyAdded:Bool = false
            for assertItem in assertArray {
                if labelTemp == assertItem {
                    alreadyAdded = true
                }
            }
            
            if !alreadyAdded {
                if labelTemp == arrayLabels[arrayLabels.count-1] {
                    stringRespuesta = stringRespuesta + labelTemp + "."
                } else {
                    stringRespuesta = stringRespuesta + labelTemp  + ", "
                }
                assertArray.append(labelTemp)
            }
            
            
        }
        
        VhistaSpeechManager.shared.speakRekognition(stringToSpeak: stringRespuesta)
        
        nextIsProcessFaces = true
        
    }
    
}

extension RekognitionManager {
    
    @objc func getFaces() {
        
        if errorGettingFaces != nil {
            if errorGettingFaces! == true {
                
                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("Error_Getting_People", comment: "There was an error analyzing faces"))
                self.nextIsFinish = true
            }
        }
        
        if resultFaces == nil {
            print("⏱ Faces were not obtained, retry in 0.2 seconds.")
            Timer.scheduledTimer(timeInterval: TimeInterval(0.2), target: self, selector: #selector(self.getFaces), userInfo: nil, repeats: false)
        } else {
            if resultFaces!.count == 0 {
                
                VhistaSpeechManager.shared.speakRekognition(stringToSpeak: NSLocalizedString("No_People", comment: "No people were found in the image"))
                
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
            "language": global_language as NSObject,
            "count": faces.count as NSObject
            ])
        
        
        var stringRespuesta: String = ""
        if faces.count > 1 {
            stringRespuesta = NSLocalizedString("Number_People_Plural", comment: "").replacingOccurrences(of: "XX", with: String(faces.count))
        } else {
            stringRespuesta = NSLocalizedString("One_Person", comment: "There is only one person in the picture")
        }
        
        
        for faceTemp: AWSRekognitionFaceDetail in faces {
            
            if faceTemp == faces[0] && faces.count > 1 {
                stringRespuesta = stringRespuesta + NSLocalizedString("First_Person", comment: "")
            } else if faceTemp == faces[0] && faces.count == 1 {
                stringRespuesta = stringRespuesta + NSLocalizedString("First_And_Only_Person", comment: "")
            } else if String(describing: faceTemp) == String(describing: faces[faces.count-1]) {
                stringRespuesta = stringRespuesta + NSLocalizedString("Last_Person", comment: "")
            } else {
                stringRespuesta = stringRespuesta + NSLocalizedString("Next_Person", comment: "")
            }
            
            
            if faceTemp.gender!.value == AWSRekognitionGenderType.male {
                stringRespuesta = stringRespuesta + NSLocalizedString("Is_Male", comment: "")
            } else if faceTemp.gender!.value == AWSRekognitionGenderType.female {
                stringRespuesta = stringRespuesta + NSLocalizedString("Is_Female", comment: "")
            }
            
            
            if faceTemp.beard!.value!.isEqual(to: 1) {
                stringRespuesta = stringRespuesta + NSLocalizedString("Has_Beard", comment: "")
            }
            
            if faceTemp.mustache!.value!.isEqual(to: 1) {
                stringRespuesta = stringRespuesta + NSLocalizedString("Has_Mustache", comment: "")
            }
            
            if faceTemp.eyeglasses!.value!.isEqual(to: 1) {
                stringRespuesta = stringRespuesta + NSLocalizedString("Has_Glasses", comment: "")
            }
            
            if faceTemp.smile!.value!.isEqual(to: 1) {
                stringRespuesta = stringRespuesta + NSLocalizedString("Is_Smiling", comment: "")
            }
            
            if faceTemp.emotions!.count > 0 {
                var emotionMostConfident: AWSRekognitionEmotion!
                var mostConfidency: NSNumber = 0.0
                for tempEmotion:AWSRekognitionEmotion in faceTemp.emotions! {
                    if tempEmotion.confidence!.doubleValue >= mostConfidency.doubleValue {
                        emotionMostConfident = tempEmotion
                        mostConfidency = tempEmotion.confidence!
                    }
                }
                
                stringRespuesta = stringRespuesta + NSLocalizedString("The_Person_Is", comment: "")
                
                if emotionMostConfident.types == AWSRekognitionEmotionName.angry {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Angry", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.calm {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Calm", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.confused {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Confused", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.disgusted {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Upset", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.happy {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Happy", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.sad {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Sad", comment: "")
                } else if emotionMostConfident.types == AWSRekognitionEmotionName.surprised {
                    stringRespuesta = stringRespuesta + NSLocalizedString("Surprised", comment: "")
                }
                
            }
            
            
        }
        
        VhistaSpeechManager.shared.sayText(stringToSpeak: stringRespuesta, isProtected: true, rate: Float(globalRate))
        
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
