//
//  FeaturesAccessibilityElement.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/24/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class FeaturesAccessibilityElement: UIAccessibilityElement {

    override init(accessibilityContainer: Any) {
        super.init(accessibilityContainer: accessibilityContainer)
    }

    override var accessibilityLabel: String? {
        get {
            return NSLocalizedString("feature_picker", comment: "")
        }
        set {
            super.accessibilityLabel = newValue
        }
    }

    override var accessibilityValue: String? {
        get {
            if let currentFeature = FeaturesManager.shared.selectedFeature {
                return currentFeature.featureName
            }

            return super.accessibilityValue
        }

        set {
            super.accessibilityValue = newValue
        }
    }

    // This tells VoiceOver that our element will support the increment and decrement callbacks.
   /// - Tag: accessibility_traits
   override var accessibilityTraits: UIAccessibilityTraits {
       get {
           return .adjustable
       }
       set {
           super.accessibilityTraits = newValue
       }
   }

    /**
        A convenience for forward scrolling in both `accessibilityIncrement` and `accessibilityScroll`.
        It returns a `Bool` because `accessibilityScroll` needs to know if the scroll was successful.
    */
    func accessibilityScrollForward() -> Bool {

        // Initialize the container view which will house the collection view.
        guard let containerView = accessibilityContainer as? FeaturesCarouselContainerView else {
            return false
        }

        // Store the currently focused feature and the list of all features.
        guard let currentFeature = FeaturesManager.shared.selectedFeature else {
            return false
        }

        // Get the index of the currently focused feature from the list of features (if it's a valid index).
        guard let
            index = FeaturesManager.shared.features.firstIndex(of: currentFeature),
            index < FeaturesManager.shared.features.count - 1 else {
            return false
        }

        // Scroll the collection view to the currently focused Feature.
        containerView.collectionViewController.collectionView.selectItem(
            at: IndexPath(row: index + 1, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
        containerView.collectionViewController.collectionView(containerView.collectionViewController.collectionView,
                                                              didSelectItemAt: IndexPath(row: index + 1, section: 0))

        return true
    }

    /**
        A convenience for backward scrolling in both `accessibilityIncrement` and `accessibilityScroll`.
        It returns a `Bool` because `accessibilityScroll` needs to know if the scroll was successful.
    */
    func accessibilityScrollBackward() -> Bool {
        guard let containerView = accessibilityContainer as? FeaturesCarouselContainerView else {
            return false
        }

        guard let currentFeature = FeaturesManager.shared.selectedFeature else {
            return false
        }

        guard let index = FeaturesManager.shared.features.firstIndex(of: currentFeature), index > 0 else {
            return false
        }

        containerView.collectionViewController.collectionView.selectItem(
            at: IndexPath(row: index - 1, section: 0),
            animated: true,
            scrollPosition: .centeredHorizontally
        )
        containerView.collectionViewController.collectionView(containerView.collectionViewController.collectionView,
                                                              didSelectItemAt: IndexPath(row: index - 1, section: 0))

        return true
    }

    // MARK: Accessibility

    /*
        Overriding the following two methods allows the user to perform increment and decrement actions
        (done by swiping up or down).
    */
    /// - Tag: accessibility_increment_decrement
    override func accessibilityIncrement() {
        // This causes the picker to move forward one if the user swipes up.
        _ = accessibilityScrollForward()
    }

    override func accessibilityDecrement() {
        // This causes the picker to move back one if the user swipes down.
        _ = accessibilityScrollBackward()
    }

    /*
        This will cause the picker to move forward or backwards on when the user does a 3-finger swipe,
        depending on the direction of the swipe. The return value indicates whether or not the scroll was successful,
        so that VoiceOver can alert the user if it was not.
    */
    override func accessibilityScroll(_ direction: UIAccessibilityScrollDirection) -> Bool {
        if direction == .left {
            return accessibilityScrollForward()
        } else if direction == .right {
            return accessibilityScrollBackward()
        }
        return false
    }
}

class FeaturesCarouselContainerView: UIView {

    var collectionViewController: UICollectionViewController!
    private var _previousFeature: Feature?

    // MARK: Accessibility
    /*
        VoiceOver relies on `accessibilityElements` returning an array of consistent objects that persist
        as the user swipes through an app. We therefore have to cache our array of computed `accessibilityElements`
        so that we don't get into an infinite loop of swiping. We reset this cached array whenever a new object is set
        so that `accessibilityElements` can be recomputed.
    */
    var carouselAccessibilityElement: FeaturesAccessibilityElement?
    private var _accessibilityElements: [Any]?
    override var accessibilityElements: [Any]? {
        set {
            _accessibilityElements = newValue
        }

        get {

            if FeaturesManager.shared.selectedFeature == nil {
                return _accessibilityElements
            }

            if _previousFeature == FeaturesManager.shared.selectedFeature {
                return _accessibilityElements
            }
            _previousFeature = FeaturesManager.shared.selectedFeature

            let carouselAccessibilityElement: FeaturesAccessibilityElement
            if let theCarouselAccessibilityElement = self.carouselAccessibilityElement {
                carouselAccessibilityElement = theCarouselAccessibilityElement
            } else {
                carouselAccessibilityElement = FeaturesAccessibilityElement(
                    accessibilityContainer: self
                )

                carouselAccessibilityElement.accessibilityFrameInContainerSpace = collectionViewController.collectionView.frame
                self.carouselAccessibilityElement = carouselAccessibilityElement
            }

            _accessibilityElements = [carouselAccessibilityElement]

            return _accessibilityElements
        }
    }
}
