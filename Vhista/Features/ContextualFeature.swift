//
//  ContextualFeature.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation

extension ARKitCameraViewController {
    func startContextualRecognition() {
        ComputerVisionManager.shared.makeComputerVisionRequest(image: selectedImage,
                                                               features: [ComputerVisionManager.CVFeatures.Description],
                                                               details: nil,
                                                               language: ComputerVisionManager.CVLanguage.English) { (response) in
                                                                print(response)
        }
    }
}
