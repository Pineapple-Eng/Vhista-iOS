//
//  VHBottomNavigationToolbar.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

protocol VHBottomNavigationToolbarDelegate: AnyObject {
    func didSelectBarButtonItemWithType(_ barButtonItem: UIBarButtonItem, _ type: VHBottomNavigationToolbarItemType)
}

enum VHBottomNavigationToolbarItemType {
    case gallery
    case subscription
    case upgrade
}

class VHBottomNavigationToolbar: UIToolbar {

    let gallerySystemImageName = "photo.on.rectangle"
    let cameraSystemImageName = "ring.circle.fill"

    static let estimatedToolbarHeight: CGFloat = 44.0

    weak var customDelegate: VHBottomNavigationToolbarDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpItems()
    }

    func setUpUI() {
        self.tintColor = getLabelDarkColorIfSupported(color: .black)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension VHBottomNavigationToolbar {
    public func setUpItems(showGallery: Bool = true,
                           showSubscriptionButton: Bool = false,
                           isSubscribed: Bool = false) {
        self.items = [UIBarButtonItem]()
        if showGallery {
            let galleryItem = UIBarButtonItem(image: getButtonItemGalleryImage(),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didSelectBarButtonItemGallery(_:)))
            self.items?.append(galleryItem)
        }

        self.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

        if showSubscriptionButton {
            let subscriptionItem = UIBarButtonItem(title: nil,
                                                   style: .plain,
                                                   target: self,
                                                   action: nil)
            if isSubscribed {
                subscriptionItem.title = NSLocalizedString("Show_Subscription_Button_Title", comment: "")
                subscriptionItem.accessibilityHint = NSLocalizedString("Subscription_Button_Accessibility_Hint", comment: "")
                subscriptionItem.action = #selector(didSelectBarButtonItemSubscription(_:))
            } else {
                subscriptionItem.title = NSLocalizedString("Upgrade_Button_Title", comment: "")
                subscriptionItem.accessibilityHint = NSLocalizedString("Upgrade_Button_Accessibility_Hint", comment: "")
                subscriptionItem.action = #selector(didSelectBarButtonItemUpgrade(_:))
            }
            self.items?.append(subscriptionItem)
        }
    }
}

extension VHBottomNavigationToolbar {
    func getButtonItemGalleryImage() -> UIImage {
        var image = UIImage()
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: gallerySystemImageName) ?? image
        }
        return image
    }
}

extension VHBottomNavigationToolbar {
    @objc func didSelectBarButtonItemGallery(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.gallery)
    }

    @objc func didSelectBarButtonItemSubscription(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.subscription)
    }

    @objc func didSelectBarButtonItemUpgrade(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.upgrade)
    }
}
