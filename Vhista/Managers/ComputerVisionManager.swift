//
//  ComputerVisionManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/21/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation
import Alamofire

class ComputerVisionManager: NSObject {

    static let compressionQuality: CGFloat = 1.0
    let afSession = Alamofire.Session()

    // MARK: - Initialization Method
    override init() {
        super.init()
    }

    static let shared: ComputerVisionManager = {
        let instance = ComputerVisionManager()
        return instance
    }()

    @discardableResult
    func makeComputerVisionRequest(image: UIImage,
                                   features: [String],
                                   details: [String]?,
                                   language: String?,
                                   completion: @escaping (DataResponse<CVResponse>) -> Void) -> Request? {
        guard let imageData = image.jpegData(compressionQuality: ComputerVisionManager.compressionQuality) else {
            print("🚨 Unable to get JPEG Data 🖼")
            return nil
        }
        if (Double(imageData.count) / 1_024 / 1_024) > 4 {
            print("🚨 Data size 🐋 more than 4bm Size: \(Double(imageData.count) / 1_024 / 1_024)")
            return nil
        }
        guard let url = buildRequestURL(features: features, details: details, language: language) else {
            print("🚨 Got nil URL 🕸")
            return nil
        }
        let headers: HTTPHeaders = [
          "Ocp-Apim-Subscription-Key": azureAPIKey,
          "Content-Type": "application/octet-stream"
        ]
        return afSession.upload(imageData,
                                to: url,
                                method: .post,
                                headers: headers).responseDecodable { (response) in
            completion(response)
        }
    }
}

extension ComputerVisionManager {
    private func buildRequestURL(features: [String],
                                 details: [String]?,
                                 language: String?) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "westus.api.cognitive.microsoft.com"
        components.path = "/vision/v2.0/analyze"
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: CVRequestParameters.VisualFeatures,
                                       value: features.joined(separator: ",")))
        queryItems.append(URLQueryItem(name: CVRequestParameters.Language,
                                       value: (language ?? CVLanguage.English)))
        components.queryItems = queryItems
        return components.url
    }
}

extension ComputerVisionManager {

    struct CVRequestParameters {
        static let VisualFeatures = "visualFeatures"
        static let Language = "language"
    }
    struct CVFeatures {
        static let Adult = "Adult"
        static let Brands = "Brands"
        static let Categories = "Categories"
        static let Color = "Color"
        static let Description = "Description"
        static let Faces = "Faces"
        static let ImageType = "ImageType"
        static let Objects = "Objects"
        static let Tags = "Tags"
    }

    struct CVDetails {
        static let Celebrities = "Celebrities"
        static let Landmarks = "Landmarks"
    }

    struct CVLanguage {
        static let English = "en"
        static let Spanish = "es"
        static let Japanese = "ja"
        static let SimplifiedChinese = "zh"
    }
}
