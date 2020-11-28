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

    static let footnoteItemsVerticalSpacing: CGFloat = 8.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpBackground()
        setUpColombiaLabel()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpBackground()
        setUpColombiaLabel()
    }
}

extension InfoFooterView {
    func setUpBackground() {
        self.backgroundColor = .clear
    }

    func setUpColombiaLabel() {
        colombiaLabel = InfoFooterView.generateFootnoteLabel(text: NSLocalizedString("Made_With_Love", comment: ""))
        colombiaLabel.accessibilityLabel = NSLocalizedString("Made_With_Love_Ax", comment: "")
        self.addSubview(colombiaLabel)
        colombiaLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            colombiaLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            colombiaLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
    }
}

extension InfoFooterView {
    static func generateFootnoteLabel(text: String? = "", frame: CGRect = .zero) -> UILabel {
        let label = UILabel(frame: frame)
        label.textColor = getLabelDarkColorIfSupported(color: .black)
        label.text = text
        label.textAlignment = .center
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        return label
    }
}

extension InfoFooterView {
    static func getEstimatedHeight(width: CGFloat) -> CGFloat {
        let labelFrame = CGRect(x: .zero,
                                y: .zero,
                                width: width,
                                height: CGFloat.greatestFiniteMagnitude)
        let labelColombia = self.generateFootnoteLabel(text: NSLocalizedString("Made_With_Love", comment: ""), frame: labelFrame)

        return (InfoFooterView.footnoteItemsVerticalSpacing + labelColombia.frame.size.height
            + InfoFooterView.footnoteItemsVerticalSpacing)
    }
}
