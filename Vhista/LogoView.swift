//
//  LogoView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/19/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class LogoView: UIView {

    static let bgEffectViewTag = 101

    static let logoViewTopMargin: CGFloat = 16.0

    static let viewWidth: CGFloat = 80.0
    static let viewHeight: CGFloat = 80.0

    static let imageViewInset: CGFloat = 22.0

    var logoImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLogoImageView()
        setUpBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLogoImageView()
    }
}

extension LogoView {
    func setUpBackground() {
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = self.frame
        visualEffectView.tag = LogoView.bgEffectViewTag
        for view in self.subviews where view.tag == LogoView.bgEffectViewTag {
            view.removeFromSuperview()
        }
        self.insertSubview(visualEffectView, at: .zero)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            visualEffectView.widthAnchor.constraint(equalTo: self.widthAnchor),
            visualEffectView.heightAnchor.constraint(equalTo: self.heightAnchor),
            visualEffectView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            visualEffectView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        visualEffectView.clipsToBounds = true
        visualEffectView.layer.cornerRadius = LogoView.viewWidth / 2
    }
}

extension LogoView {
    func setUpLogoImageView() {
        logoImageView = UIImageView()
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.image = UIImage(named: "SmallTransparentWhiteLogo")
        self.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.topAnchor,
                                               constant: LogoView.imageViewInset),
            logoImageView.leftAnchor.constraint(equalTo: self.leftAnchor,
                                                constant: LogoView.imageViewInset),
            logoImageView.rightAnchor.constraint(equalTo: self.rightAnchor,
                                                 constant: -LogoView.imageViewInset),
            logoImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                                  constant: -LogoView.imageViewInset)
            ])
    }
}

extension LogoView {
    static func getViewLayoutConstraints(logoView: UIView,
                                         parentView: UIView) -> [NSLayoutConstraint] {
        return [
            logoView.topAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.topAnchor,
                                          constant: logoViewTopMargin),
            logoView.centerXAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerXAnchor),
            logoView.widthAnchor.constraint(equalToConstant: viewWidth),
            logoView.heightAnchor.constraint(equalToConstant: viewHeight)
        ]
    }
}
