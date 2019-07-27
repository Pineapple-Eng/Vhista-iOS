//
//  ClassificationsManager.swift
//  Vhista
//
//  Created by David Cruz on 3/6/18.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit
import Vision

class ClassificationsManager: NSObject {

    //Supplementary Variables Objects
    var lastRecognition = ""
    var recognitionsAsText = [String]()

    //Supplementary Variables Face LandMarks
    var lastNumberOfFaces = 0

    //Feedback Elements
    var faceGenerator = UIImpactFeedbackGenerator(style: .heavy)

    // MARK: - Initialization Method
    override init() {
        super.init()
        lastRecognition = ""
        recognitionsAsText = [String]()
        lastNumberOfFaces = 0
        faceGenerator = UIImpactFeedbackGenerator(style: .heavy)
    }

    static let shared: ClassificationsManager = {
        let instance = ClassificationsManager()
        return instance
    }()

    func allowStringRecognized(stringRecognized: String) -> Bool {
        if lastRecognition == stringRecognized { return false }
        if lastRecognition.contains(",") {
            if stringRecognized.contains(",") {
                let lastSplit = lastRecognition.split(separator: ",")
                let currentSplit = stringRecognized.split(separator: ",")
                for splitString in currentSplit {
                    for lastSplitString in lastSplit where splitString == lastSplitString {
                        return false
                    }
                }
            } else {
                let lastSplit = lastRecognition.split(separator: ",")
                for lastSplitString in lastSplit where stringRecognized == lastSplitString {
                    return false
                }
            }
        } else {
            if stringRecognized.contains(",") {
                let currentSplit = stringRecognized.split(separator: ",")
                for splitString in currentSplit where splitString == lastRecognition {
                    return false
                }
            }
        }
        return true
    }

    func addPeopleToRead(faceObservations: [VNFaceObservation]) -> String {
        if lastNumberOfFaces == faceObservations.count { return "" }
        if faceObservations.count == 0 { lastNumberOfFaces = 0; return "" }
        if lastNumberOfFaces < faceObservations.count {
            for _ in faceObservations {
                DispatchQueue.main.sync {
                    faceGenerator.impactOccurred()
                }
            }
        }
        lastNumberOfFaces = faceObservations.count
        if lastNumberOfFaces < 2 {
            return String(lastNumberOfFaces) + NSLocalizedString("One_Person", comment: "")
        } else {
            return String(lastNumberOfFaces) + NSLocalizedString("Many_People", comment: "")
        }
    }

}
