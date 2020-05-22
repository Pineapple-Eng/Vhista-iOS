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
    case info
}

class VHBottomNavigationToolbar: UIToolbar {

    let gallerySystemImageName = "photo.on.rectangle"
    let infoSystemImageName = "info.circle.fill"

    static let estimatedToolbarHeight: CGFloat = 44.0
    static let maxToolbarIconSize: CGSize = CGSize(width: 28, height: 28)

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
    public func setUpItems(showGallery: Bool = true) {
        self.items = [UIBarButtonItem]()
        if showGallery {
            let galleryItem = UIBarButtonItem(image: getButtonItemGalleryImage(),
                                              style: .plain,
                                              target: self,
                                              action: #selector(didSelectBarButtonItemGallery(_:)))
            galleryItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            galleryItem.accessibilityLabel = NSLocalizedString("choose_from_library", comment: "")
            self.items?.append(galleryItem)
        }

        self.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

        let infoItem = UIBarButtonItem(image: getButtonItemInfoImage(),
                                       style: .plain,
                                       target: self,
                                       action: #selector(didSelectBarButtonItemInfo(_:)))
        infoItem.accessibilityLabel = NSLocalizedString("more_information", comment: "")
        self.items?.append(infoItem)
    }
}

extension VHBottomNavigationToolbar {
    func getButtonItemGalleryImage() -> UIImage {
        var image = UIImage(named: gallerySystemImageName)
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: gallerySystemImageName) ?? image
        }
        return image ?? UIImage()
    }

    func getButtonItemInfoImage() -> UIImage {
        var image = UIImage(named: infoSystemImageName)
        if #available(iOS 13.0, *) {
            image = UIImage(systemName: infoSystemImageName) ?? image
        }
        return image ?? UIImage()
    }
}

extension VHBottomNavigationToolbar {
    @objc func didSelectBarButtonItemGallery(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.gallery)
    }

    @objc func didSelectBarButtonItemInfo(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.info)
    }
}
