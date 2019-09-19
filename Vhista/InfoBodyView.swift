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

    var subscriptionButton: VHRoundedButton!

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

    func reloadSubscriptionStates() {
        if SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            subscriptionButton.setTitle(NSLocalizedString("Show_Subscription_Button_Title", comment: ""), for: .normal)
            subscriptionButton.accessibilityHint = NSLocalizedString("Subscription_Button_Accessibility_Hint", comment: "")
            subscriptionButton.addTarget(self, action: #selector(showSubscriptionInfo), for: .touchUpInside)
        } else {
            subscriptionButton.setTitle(NSLocalizedString("Upgrade_Button_Title", comment: ""), for: .normal)
            subscriptionButton.accessibilityHint = NSLocalizedString("Upgrade_Button_Accessibility_Hint", comment: "")
            subscriptionButton.addTarget(self, action: #selector(showUpgrade), for: .touchUpInside)
        }
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
        addSubscriptionButton()
        addLegalButton()
    }

    func addSubscriptionButton() {
        subscriptionButton = VHRoundedButton(frame: .zero,
                                     title: NSLocalizedString("Upgrade", comment: ""),
                                     type: VHRoundedButtonType.darkBackground)
        bodyStack.insertArrangedSubview(subscriptionButton, at: bodyStack.arrangedSubviews.count)
        subscriptionButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subscriptionButton.widthAnchor.constraint(equalTo: bodyStack.widthAnchor),
            subscriptionButton.heightAnchor.constraint(equalToConstant: VHRoundedButton.defaultHeight)
        ])
        reloadSubscriptionStates()
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
    @objc func showSubscriptionInfo() {
        let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SubscriptionInfoVC")
        guard let topVC = getTopMostViewController() else {
            return
        }
        topVC.present(controller, animated: true, completion: nil)
    }

    @objc func showUpgrade() {
        let storyboard = UIStoryboard(name: "Subscription", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SubscriptionVC")
        guard let topVC = getTopMostViewController() else {
            return
        }
        topVC.present(controller, animated: true, completion: nil)
    }

    @objc func showLegal() {
        let safariVC = SFSafariViewController(url: URL(string: "https://vhista.com/legal")!)
        guard let topVC = getTopMostViewController() else {
            return
        }
        safariVC.preferredControlTintColor = getLabelDarkColorIfSupported(color: .black)
        topVC.present(safariVC, animated: true, completion: nil)
    }
}
