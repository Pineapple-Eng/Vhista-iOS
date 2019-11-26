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

        let description = response.value?.description
        let caption = description?.captions?.first
        let captionConfidence = caption?.confidence
        let captionText = caption?.text

        let tags = description?.tags

        if caption == nil && captionText == nil && tags == nil && tags?.count == 0 {
            let alertEmpty = UIAlertController(title: NSLocalizedString("No_Objects_Found", comment: ""),
                                               message: nil,
                                               preferredStyle: .alert)
            let actionCancel = UIAlertAction(title: NSLocalizedString("Close_Action", comment: ""),
                                             style: .cancel) { (action) in
                self.updateUIForDeepAnalysisChange(willAnalyze: false)
            }
            alertEmpty.addAction(actionCancel)
            self.present(alertEmpty, animated: true, completion: nil)
            return
        }
        recognizedVC.delegate = self
        recognizedVC.captionText = captionText ?? ""
        recognizedVC.tags = tags ?? [String]()
        recognizedVC.image = self.selectedImage.getUIImage()
        recognizedVC.confidence = captionConfidence

        self.shutterButtonView.stopLoadingRippleView(parentView: self.view)
        self.present(recognizedVC, animated: true, completion: {
            recognizedVC.update()
            SubscriptionManager.shared.incrementNumberOfPictures()
            VhistaSoundManager.shared.pauseLoadingSound()
        })
    }

    // MARK: RecognizedContentViewControllerDelegate
    func willDismissRecognizedContentViewController(_ controller: RecognizedContentViewController) {
        self.updateUIForDeepAnalysisChange(willAnalyze: false)
    }

    // MARK: InfoViewControllerDelegate
    func willDismissInfoViewControllerr(_ controller: InfoViewController) {
        self.updateUIForDeepAnalysisChange(willAnalyze: false)
    }

}
