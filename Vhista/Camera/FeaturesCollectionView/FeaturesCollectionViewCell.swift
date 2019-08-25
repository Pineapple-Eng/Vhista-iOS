//
//  FeaturesCollectionViewCell.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/12/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

class FeaturesCollectionViewCell: UICollectionViewCell {

    var nameLabel: UILabel!
    var logoView: LogoView!
    var feature: Feature?

    override init(frame: CGRect) {
        self.nameLabel = UILabel()
        self.logoView = LogoView(frame: .zero)
        super.init(frame: frame)
        setUpUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setUpUI() {
        setUpLogoView()
        setUpNameLabel()
    }

    func configureCellWithFeature(_ feature: Feature) {
        self.feature = feature
        var image = UIImage()
        if #available(iOS 13.0, *) {
            guard let systemImage = UIImage(systemName: feature.imageName) else {
                return
            }
            image = systemImage
        } else {
            // Fallback on earlier versions
        }
        nameLabel.text = feature.featureName
        logoView.configureViewWithImage(image)
        self.isAccessibilityElement = true
        self.accessibilityLabel = feature.featureName
        self.shouldGroupAccessibilityChildren = true
    }
}

extension FeaturesCollectionViewCell {

    func setUpLogoView() {
        logoView = LogoView(frame: .zero)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(logoView)
        NSLayoutConstraint.activate([
            logoView.topAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.topAnchor),
            logoView.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                            constant: 4),
            logoView.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                             constant: 4),
            logoView.heightAnchor.constraint(equalTo: logoView.widthAnchor)
        ])
        logoView.tintColor = getLabelDarkColorIfSupported(color: .black)
    }

    func setUpNameLabel() {
        nameLabel = UILabel()
        nameLabel.textColor = getLabelDarkColorIfSupported(color: .white)
        nameLabel.numberOfLines = .zero
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byWordWrapping
        nameLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: self.logoView.bottomAnchor),
            nameLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor,
                                            constant: 4),
            nameLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor,
                                             constant: 4),
            nameLabel.bottomAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
