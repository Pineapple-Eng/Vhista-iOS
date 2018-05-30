//
//  ObjectAnalysis.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 3/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AWSCore
import AWSRekognition

extension NSObject {
    func detectLabelsWithImage(pImage: UIImage, _ completition: @escaping (_ success: [AWSRekognitionLabel]?) -> ()) {
        
        let rekognitionClient = AWSRekognition.default()
        let sourceImage = pImage
        
        let image = AWSRekognitionImage()
        image!.bytes = UIImageJPEGRepresentation(sourceImage, 0.35)
        
        let request = AWSRekognitionDetectLabelsRequest()
        
        request!.image = image
        request!.maxLabels = 99
        request!.minConfidence = 70
        
        rekognitionClient.detectLabels(request!, completionHandler: { (response:AWSRekognitionDetectLabelsResponse?, error:Error?) in
            
            if (error == nil) {
                completition(response!.labels!)
            } else {
                print(error!.localizedDescription)
                completition(nil)
            }
            
            
        })
        
    }
}
