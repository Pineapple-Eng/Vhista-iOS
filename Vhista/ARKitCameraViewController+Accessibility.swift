//
//  ARKitCameraViewController+Accessibility.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/25/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

extension ARKitCameraViewController {
    func setUpAccessibility() {
        let feature = FeaturesManager.shared.getSelectedFeature()
        self.view.accessibilityElements = [
            featuresCollectionContentView as Any,
            shutterButtonView as Any
        ]
        if feature.featureName == FeatureNames.contextual
            && fastRecognizedContentViewController != nil {
            self.view.accessibilityElements?.append(fastRecognizedContentViewController as Any)
        }
        self.view.accessibilityElements?.append(bottomToolbar as Any)
    }
}
