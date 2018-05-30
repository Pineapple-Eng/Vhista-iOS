//
//  FaceAnalysis.swift
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


extension UIViewController {
    func faceAnalysisWithImage (pImage: UIImage,_ completition: @escaping (_ success: [AWSRekognitionFaceDetail]?) -> ()) {
        
        let rekognitionClient = AWSRekognition.default()
        let sourceImage = pImage
        
        let image = AWSRekognitionImage()
        image!.bytes = UIImageJPEGRepresentation(sourceImage, 0.35)
        
        let request = AWSRekognitionDetectFacesRequest()
        
        request!.attributes = ["ALL"]
        request!.image = image
        
        rekognitionClient.detectFaces(request!, completionHandler: { (response:AWSRekognitionDetectFacesResponse?, error:Error?) in
            
            if (error == nil) {
                completition(response!.faceDetails)
            } else {
                print("Error:😀" + error!.localizedDescription)
                completition(nil)
            }
            
        })
        
    }
    
}

