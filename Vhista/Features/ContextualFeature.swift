//
//  ContextualFeature.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import Alamofire

extension ARKitCameraViewController {
    func startContextualRecognition() {
        ComputerVisionManager.shared.makeComputerVisionRequest(image: selectedImage,
                                                               features: [ComputerVisionManager.CVFeatures.Description],
                                                               details: nil,
                                                               language: ComputerVisionManager.CVLanguage.English) { (response) in
                                                                self.finishedContextualRecognition(response)
        }
    }

    func finishedContextualRecognition(_ response: DataResponse<CVResponse>) {
        let recognizedVC = RecognizedContentViewController()
        guard let fisrtCaption = response.value?.description?.captions?.first?.text else {
            return
        }
        self.present(recognizedVC, animated: true, completion: {
            recognizedVC.updateWithText(fisrtCaption)
        })
    }
}
