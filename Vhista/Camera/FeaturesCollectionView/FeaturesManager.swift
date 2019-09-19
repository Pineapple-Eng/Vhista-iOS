//
//  FeaturesManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/12/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation

class FeaturesManager: NSObject {

    var features: [Feature]
    var selectedFeature: Feature?

    // MARK: - Initialization Method
    override init() {
        self.features = [Feature]()
        super.init()
        setUpFeatures()
    }

    static let shared: FeaturesManager = {
        let instance = FeaturesManager()
        return instance
    }()

    func setUpFeatures() {
        features = [Feature]()
        // Contextual Feature
        let contextualFeature = Feature(featureName: FeatureNames.contextual,
                                        imageName: LogoView.contextualImageName)
        features.append(contextualFeature)

//      Panoramic Feature - Adding in V4.0.1
        #if DEVELOPMENT
        let panoramicFeature = Feature(featureName: FeatureNames.panoramic,
                                        imageName: LogoView.panoramicImageName)
        features.append(panoramicFeature)
        #endif
    }

    func getSelectedFeature() -> Feature {
        guard let feature = selectedFeature else {
            // Default to first object in the array
            selectedFeature = features.first
            return selectedFeature!
        }
        return feature
    }

    func setSelectedFeature(_ feature: Feature) {
        selectedFeature = feature
    }
}
