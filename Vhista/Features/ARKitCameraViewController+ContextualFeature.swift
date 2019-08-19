//
//  ContextualFeature.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import Alamofire

extension ARKitCameraViewController: RecognizedContentViewControllerDelegate {
    func startContextualRecognition() {
        ComputerVisionManager.shared.makeComputerVisionRequest(image: selectedImage,
                                                               features: [ComputerVisionManager.CVFeatures.Description],
                                                               details: nil,
                                                               language: ComputerVisionManager.CVLanguage.English) { (response) in
                                                                self.finishedContextualRecognition(response)
        }
    }

    func finishedContextualRecognition(_ response: DataResponse<CVResponse>) {
        self.updateUIForDeepAnalysisChange(willAnalyze: false)
        let recognizedVC = RecognizedContentViewController()
        guard let firstCaption = response.value?.description?.captions?.first?.text else {
            return
        }
        recognizedVC.delegate = self
        self.present(recognizedVC, animated: true, completion: {
            recognizedVC.updateWithText(firstCaption)
        })
    }

    // MARK: RecognizedContentViewControllerDelegate
    func willDismissRecognizedContentViewController(_ controller: RecognizedContentViewController) {

    }

}
