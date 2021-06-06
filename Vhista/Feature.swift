//  Created by Juan David Cruz Serrano on 6/27/19. Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.

import Foundation

struct FeatureNames {
    static let contextual = NSLocalizedString("Image_Recognition", comment: "")
    static let text = NSLocalizedString("Text_Recognition", comment: "")
}

struct Feature {
    var featureName: String
    var imageName: String
}

extension Feature: Equatable {
    static func == (lhs: Feature, rhs: Feature) -> Bool {
        return lhs.featureName == rhs.featureName &&
               lhs.imageName == rhs.imageName
    }
}
