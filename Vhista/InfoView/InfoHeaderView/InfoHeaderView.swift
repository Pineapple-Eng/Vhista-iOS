//
//  InfoHeaderView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/31/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class InfoHeaderView: UIView {
    static let logoImageName: String = "SmallTransparentLogo"
    static let logoImageViewVerticalSpacing: CGFloat = 8.0
    static let logoImageViewSize: CGFloat = 40.0

    static let nameLabelText: String = "Vhista, Inc"
    static let nameLabelVerticalSpacing: CGFloat = 8.0
    static let nameLabelHorizontalSpacing: CGFloat = 8.0

    var logoImageView = UIImageView()
    var nameLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBackground()
        setUpLogoImageView()
        setUpNameLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBackground()
        setUpLogoImageView()
        setUpNameLabel()
    }
}

extension InfoHeaderView {
    func setUpBackground() {
        self.backgroundColor = .clear
    }

    func setUpLogoImageView() {
        logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: InfoHeaderView.logoImageName)
        self.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor,
                                               constant: InfoHeaderView.logoImageViewVerticalSpacing),
            logoImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: InfoHeaderView.logoImageViewSize),
            logoImageView.heightAnchor.constraint(equalToConstant: InfoHeaderView.logoImageViewSize)
        ])
    }

    func setUpNameLabel() {
        nameLabel = UILabel()
        nameLabel.textColor = getLabelDarkColorIfSupported(color: .black)
        nameLabel.text = InfoHeaderView.nameLabelText
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        nameLabel.numberOfLines = 0
        self.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor,
                                           constant: InfoHeaderView.nameLabelVerticalSpacing),
            nameLabel.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor,
            constant: InfoHeaderView.nameLabelHorizontalSpacing),
            nameLabel.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,
                                             constant: InfoHeaderView.nameLabelHorizontalSpacing)
        ])
    }
}

extension InfoHeaderView {
    static func getEstimatedHeight(width: CGFloat) -> CGFloat {
        return (logoImageViewVerticalSpacing
            + logoImageViewSize
            + nameLabelVerticalSpacing
            + self.calculateHeightForText(text: self.nameLabelText, width: width))
    }

    static func calculateHeightForText(text: String, width: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(x: .zero,
                                                   y: .zero,
                                                   width: width,
                                                   height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = .zero
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        label.text = text
        label.sizeToFit()
        return label.frame.height
    }
}
