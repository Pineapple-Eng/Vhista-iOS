//
//  InfoBodyView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 9/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

class InfoBodyView: UIView {

    static let stackVerticalSpacing: CGFloat = 8.0
    static let stackMaxWidth: CGFloat = 300.0

    var bodyStack: UIStackView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpStackView()
        setUpContents()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpStackView()
        setUpContents()
    }
}

extension InfoBodyView {
    func setUpStackView() {
        bodyStack = UIStackView(frame: .zero)
        bodyStack.spacing = InfoBodyView.stackVerticalSpacing
        bodyStack.distribution = .fill
        bodyStack.alignment = .center
        bodyStack.axis = .vertical
        self.addSubview(bodyStack)
        bodyStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bodyStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            bodyStack.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bodyStack.widthAnchor.constraint(equalToConstant: InfoBodyView.stackMaxWidth)
        ])
    }

    func setUpContents() {
        addLegalButton()
    }

    func addLegalButton() {
        let button = VHRoundedButton(frame: .zero,
                                     title: NSLocalizedString("Legal", comment: ""),
                                     type: VHRoundedButtonType.darkBackground)
        button.addTarget(self, action: #selector(showLegal), for: .touchUpInside)
        bodyStack.insertArrangedSubview(button, at: bodyStack.arrangedSubviews.count)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalTo: bodyStack.widthAnchor),
            button.heightAnchor.constraint(equalToConstant: VHRoundedButton.defaultHeight)
        ])
    }
}

extension InfoBodyView {
    @objc func showLegal() {
        let safariVC = SFSafariViewController(url: URL(string: "https://vhista.com/legal")!)
        guard let topVC = getTopMostViewController() else {
            return
        }
        safariVC.preferredControlTintColor = .black
        topVC.present(safariVC, animated: true, completion: nil)
    }
}
