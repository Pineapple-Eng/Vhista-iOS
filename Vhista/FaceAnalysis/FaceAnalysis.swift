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

extension NSObject {
    func faceAnalysisWithImage (pImage: UIImage, _ completition: @escaping (_ success: [AWSRekognitionFaceDetail]?) -> Void) {

        let rekognitionClient = AWSRekognition.default()
        let sourceImage = pImage

        let image = AWSRekognitionImage()
        image!.bytes = sourceImage.jpegData(compressionQuality: 0.45)

        let request = AWSRekognitionDetectFacesRequest()

        request!.attributes = ["ALL"]
        request!.image = image

        rekognitionClient.detectFaces(request!) { (response, error) in
            if response != nil {
                print(response!)
                completition(response!.faceDetails)
            } else {
                print("Error:😀" + (error?.localizedDescription ?? "No Error Message"))
                completition(nil)
            }
        }

    }

}
