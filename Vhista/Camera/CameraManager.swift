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
            
            VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("No_Camera_Access", comment: ""), isProtected: true, rate: Float(globalRate))
            
            let alert: UIAlertController = UIAlertController(title: NSLocalizedString("Camera_Access", comment: ""), message: NSLocalizedString("No_Camera_Access", comment: ""), preferredStyle: .alert)
            
            let button: UIAlertAction = UIAlertAction(title: NSLocalizedString("Go_To_Settings", comment: ""), style: .default, handler: { (action:UIAlertAction) in
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (completition) in
                })
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
