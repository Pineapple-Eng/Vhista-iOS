//
//  ARKitCameraViewController+PhotoGallery.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/22/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices

extension ARKitCameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPhotoPicker(_ sender: UIBarButtonItem) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = false
        pickerController.mediaTypes = ["public.image"]
        pickerController.sourceType = .photoLibrary
        pickerController.imageExportPreset = .compatible
        pickerController.popoverPresentationController?.barButtonItem = sender
        self.present(pickerController, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.pickerController(picker, didSelect: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return self.pickerController(picker, didSelect: nil)
        }
        self.pickerController(picker, didSelect: image)
    }

    private func pickerController(_ controller: UIImagePickerController, didSelect image: UIImage?) {
        guard let rawImage = image else {
            return
        }
        self.updateUIForDeepAnalysisChange(willAnalyze: true)
        controller.dismiss(animated: true, completion: {
            self.deepAnalysisPreChecks { (allowed) in
                if allowed {
                    self.setImageForRecognition(image: rawImage, source: VHImageSource.photoLibrary)
                    self.startContextualRecognition()
                }
            }
        })
    }
}
