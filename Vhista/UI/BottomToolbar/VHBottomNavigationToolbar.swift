//  Created by Juan David Cruz Serrano on 8/18/19. Copyright © 2019 juandavidcruz. All rights reserved.

import UIKit

protocol VHBottomNavigationToolbarDelegate: AnyObject {
    func didSelectBarButtonItemWithType(_ barButtonItem: UIBarButtonItem, _ type: VHBottomNavigationToolbarItemType)
}

enum VHBottomNavigationToolbarItemType {
    case gallery
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
        self.tintColor = .black
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
            galleryItem.accessibilityLabel = NSLocalizedString("Choose_From_Library", comment: "")
            self.items?.append(galleryItem)
        }

        self.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil, action: nil))
    }
}

extension VHBottomNavigationToolbar {
    func getButtonItemGalleryImage() -> UIImage {
        return UIImage(systemName: gallerySystemImageName) ?? UIImage()
    }

    func getButtonItemInfoImage() -> UIImage {
        return UIImage(systemName: infoSystemImageName) ?? UIImage()
    }
}

extension VHBottomNavigationToolbar {
    @objc func didSelectBarButtonItemGallery(_ barButtonItem: UIBarButtonItem) {
        self.customDelegate?.didSelectBarButtonItemWithType(barButtonItem,
                                                            VHBottomNavigationToolbarItemType.gallery)
    }
}
