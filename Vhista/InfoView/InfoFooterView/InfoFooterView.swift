//
//  InfoFooterView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/31/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class InfoFooterView: UIView {

    var colombiaLabel = UILabel()
    var legalButton = UIButton()
    var versionButton = UIButton()

    static let footnoteItemsVerticalSpacing: CGFloat = 8.0
    static let footnoteItemsHorizontalSpacing: CGFloat = 8.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBackground()
        setUpLegalButton()
        setUpColombiaLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBackground()
        setUpLegalButton()
        setUpColombiaLabel()
    }
}

extension InfoFooterView {
    func setUpBackground() {
        self.backgroundColor = .clear
    }

    func setUpColombiaLabel() {
        colombiaLabel = InfoFooterView.generateFootnoteLabel(text: NSLocalizedString("made_with_love", comment: ""))
        self.addSubview(colombiaLabel)
        NSLayoutConstraint.activate([
            colombiaLabel.bottomAnchor.constraint(equalTo: legalButton.topAnchor,
                                                  constant: InfoFooterView.footnoteItemsVerticalSpacing),
            colombiaLabel.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor,
                                                constant: InfoFooterView.footnoteItemsHorizontalSpacing),
            colombiaLabel.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,
                                                 constant: InfoFooterView.footnoteItemsHorizontalSpacing)
        ])
    }

    func setUpLegalButton() {
        legalButton = UIButton(frame: .zero)
        legalButton.setTitle(NSLocalizedString("legal", comment: ""), for: .normal)
        legalButton.tintColor = getLabelDarkColorIfSupported(color: .black)
        legalButton.titleLabel?.font = InfoFooterView.generateFootnoteLabel().font
        self.addSubview(legalButton)
        NSLayoutConstraint.activate([
            legalButton.bottomAnchor.constraint(equalTo: versionButton.topAnchor,
                                                constant: InfoFooterView.footnoteItemsVerticalSpacing),
            legalButton.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor,
                                              constant: InfoFooterView.footnoteItemsHorizontalSpacing),
            legalButton.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,
                                               constant: InfoFooterView.footnoteItemsHorizontalSpacing),
            legalButton.heightAnchor.constraint(equalToConstant: InfoFooterView.generateFootnoteLabel().frame.size.height)
        ])
    }

    func setUpVersionButton() {
        versionButton = UIButton(frame: .zero)
        versionButton.setTitle(getFormattedAppVersion(), for: .normal)
        versionButton.tintColor = getLabelDarkColorIfSupported(color: .black)
        versionButton.titleLabel?.font = InfoFooterView.generateFootnoteLabel().font
        self.addSubview(versionButton)
        NSLayoutConstraint.activate([
            versionButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor,
                                                  constant: InfoFooterView.footnoteItemsVerticalSpacing),
            versionButton.leftAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leftAnchor,
                                                constant: InfoFooterView.footnoteItemsHorizontalSpacing),
            versionButton.rightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.rightAnchor,
                                                 constant: InfoFooterView.footnoteItemsHorizontalSpacing),
            versionButton.heightAnchor.constraint(equalToConstant: InfoFooterView.generateFootnoteLabel().frame.size.height)
        ])
    }
}

extension InfoFooterView {
    static func generateFootnoteLabel(text: String? = "") -> UILabel {
        let label = UILabel()
        label.textColor = getLabelDarkColorIfSupported(color: .black)
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }
}
