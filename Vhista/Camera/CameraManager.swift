//
//  CameraManager.swift
//  Vhista
//
//  Created by David Cruz on 3/6/18.
//  Copyright © 2018 juandavidcruz. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension UIViewController {

    func checkCameraPermissions() -> Bool {

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) !=  AVAuthorizationStatus.authorized {

            VhistaSpeechManager.shared.stopSpeech(sender: self)

            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Camera_Access", comment: ""),
                                                             message: NSLocalizedString("No_Camera_Access", comment: ""),
                                                             preferredStyle: .alert)

            let button: UIAlertAction = UIAlertAction(title: NSLocalizedString("Go_To_Settings", comment: ""),
                                                      style: .default,
                                                      handler: { (_: UIAlertAction) in
                                                        if UIApplication.shared.canOpenURL(URL(string: UIApplication.openSettingsURLString)!) {
                                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                                                      options: convertToOpenExternalURLOptionsKeyDictionary([:]),
                                                                                      completionHandler: { (_) in
                                                            })
                                                        }
            })

            alert.addAction(button)

            self.present(alert, animated: true, completion: nil)

            return false

        } else if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            return true
        } else {
            return false
        }

    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
