//
//  ClassificationsManager.swift
//  Vhista
//
//  Created by David Cruz on 3/6/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
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
    
    func allowStringRecognized(stringRecognized:String) -> Bool {
        if lastRecognition == stringRecognized { return false }
        if lastRecognition.contains(",") {
            if stringRecognized.contains(",") {
                let lastSplit = lastRecognition.split(separator: ",")
                let currentSplit = stringRecognized.split(separator: ",")
                if lastSplit.count > 1 && currentSplit.count > 1 {
                    if lastSplit[0] == currentSplit[0] {
                        return false
                    }
                }
            } else {
                let lastSplit = lastRecognition.split(separator: ",")
                if lastSplit.count > 1 {
                    if lastSplit[0] == stringRecognized {
                        return false
                    }
                }
            }
        } else {
            if stringRecognized.contains(",") {
                let currentSplit = stringRecognized.split(separator: ",")
                if currentSplit.count > 1 {
                    if lastRecognition == currentSplit[0] {
                        return false
                    }
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
        if (lastNumberOfFaces < 2) {
            return String(lastNumberOfFaces) + NSLocalizedString("One_Person", comment: "")
        } else {
            return String(lastNumberOfFaces) + NSLocalizedString("Many_People", comment: "")
        }
    }
    
    
    
    
}
