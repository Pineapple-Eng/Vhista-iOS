//
//  ContextualFeature.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import Alamofire

extension ARKitCameraViewController: RecognizedContentViewControllerDelegate, InfoViewControllerDelegate {

    func startContextualRecognition() {
        ComputerVisionManager.shared.makeComputerVisionRequest(image: selectedImage.getUIImage(),
                                                               features: [ComputerVisionManager.CVFeatures.Description],
                                                               details: nil,
                                                               language: ComputerVisionManager.shared.getCVLanguageForCurrentGlobalLanguage()) { (response) in
                                                                self.finishedContextualRecognition(response)
        }
    }

    func finishedContextualRecognition(_ response: DataResponse<CVResponse>) {
        let recognizedVC = RecognizedContentViewController()
        guard let firstCaption = response.value?.description?.captions?.first?.text else {
            self.updateUIForDeepAnalysisChange(willAnalyze: false)
            return
        }
        recognizedVC.delegate = self
        self.present(recognizedVC, animated: true, completion: {
            recognizedVC.updateWithText(firstCaption, image: self.selectedImage.getUIImage())
            SubscriptionManager.shared.incrementNumberOfPictures()
            self.updateUIForDeepAnalysisChange(willAnalyze: false)
        })
    }

    // MARK: RecognizedContentViewControllerDelegate
    func willDismissRecognizedContentViewController(_ controller: RecognizedContentViewController) {
        resumeCurrentSession()
    }

    // MARK: InfoViewControllerDelegate
    func willDismissInfoViewControllerr(_ controller: InfoViewController) {
        resumeCurrentSession()
    }

}
