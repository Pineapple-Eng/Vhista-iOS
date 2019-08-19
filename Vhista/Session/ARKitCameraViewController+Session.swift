//
//  ARKitCameraViewController+Session.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

// MARK: - Session Handling
extension ARKitCameraViewController {
    func pauseCurrentSession() {
        VhistaSpeechManager.shared.stopSpeech(sender: self)
        VhistaSpeechManager.shared.blockAllSpeech = true
        // Pause the view's session
        if arEnabled {
            sceneView.session.pause()
        }
    }

    func resumeCurrentSession() {
        VhistaSpeechManager.shared.blockAllSpeech = false
        if arEnabled {
            arCameraViewDidAppear()
        } else {
            nonARCameraViewDidAppear()
        }
    }
}

// MARK: - Error Handling
extension ARKitCameraViewController {
    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: NSLocalizedString("Restart_Session", comment: ""), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            if !self.checkCameraPermissions() {
                return
            } else {
                self.restartSession()
            }
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}
