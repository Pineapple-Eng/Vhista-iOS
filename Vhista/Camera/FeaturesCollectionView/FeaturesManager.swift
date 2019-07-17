//
//  FeaturesManager.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/12/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation

class FeaturesManager: NSObject {

    var features: [Feature]

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

        // Panoramic Feature
        let panoramicFeature = Feature(featureName: FeatureNames.panoramic,
                                        imageName: LogoView.panoramicImageName)
        features.append(panoramicFeature)
    }
}
