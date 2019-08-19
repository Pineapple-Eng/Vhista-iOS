//
//  LogoView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/19/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

class LogoView: UIView {

    static let bgEffectViewTag = 101

    static let logoViewTopMargin: CGFloat = 16.0
    static let viewWidth: CGFloat = 80.0
    static let viewHeight: CGFloat = 80.0

    static let imageViewInset: CGFloat = 22.0

    static let logoStartLoadingAnimationDuration: TimeInterval = 0.5
    static let logoStartLoadingStringDamping: CGFloat = 0.7
    static let logoStartLoadingInitialSpringVelocity: CGFloat = 0.7

    static let defaultImageName = "SmallTransparentLogo"
    static let contextualImageName = "eye.fill"
    static let panoramicImageName = "pano.fill"

    var logoImage: UIImage?
    var logoImageView = UIImageView()
    var logoRippleView: LogoRippleView?

    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        self.logoImage = image
        configureViewWithImage(image)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpLogoImageView()
        setUpBackground()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpLogoImageView()
        setUpBackground()
    }

    func configureViewWithImage(_ image: UIImage) {
        logoImage = image
        logoImageView.image = logoImage
    }
}

extension LogoView {
    func setUpBackground() {
        let visualEffectView = UIVisualEffectView(effect: globalBlurEffect())
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
        logoImageView.image = logoImage ?? UIImage(named: LogoView.defaultImageName)
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

    func showLoadingLogoView(parentView: UIView) {
        toggleLoadingLogoView(parentView: parentView, stop: false)
    }

    func stopLoadingLogoView(parentView: UIView) {
        toggleLoadingLogoView(parentView: parentView, stop: true)
    }

    private func toggleLoadingLogoView(parentView: UIView, stop: Bool) {
        var yDelta = parentView.center.y - self.center.y
        if stop {
            yDelta = (parentView.safeAreaInsets.top + LogoView.logoViewTopMargin + LogoView.viewHeight/2) - self.center.y
        }
        UIView.animate(withDuration: LogoView.logoStartLoadingAnimationDuration,
                       delay: .zero,
                       usingSpringWithDamping: LogoView.logoStartLoadingStringDamping,
                       initialSpringVelocity: LogoView.logoStartLoadingInitialSpringVelocity,
                       options: .curveEaseOut,
                       animations: {
                        self.transform = CGAffineTransform(translationX: .zero,
                                                           y: yDelta)
        },
                       completion: { (_) in
                        self.toggleLoadingAnimation(stop: stop)
        })
    }
    private func toggleLoadingAnimation(stop: Bool) {
        if logoRippleView == nil {
            setUpLogoRippleView()
        }
        if stop {
            logoRippleView?.radarView.stopAnimation()
            logoRippleView?.isHidden = true
        } else {
            logoRippleView?.radarView.startAnimation()
            logoRippleView?.isHidden = false
        }

    }
}

// MARK: Loading Ripple View
extension LogoView {
    func setUpLogoRippleView() {
        logoRippleView = LogoRippleView(frame: .zero)
        guard logoRippleView != nil else {
            return
        }
        logoRippleView?.isAccessibilityElement = false
        self.addSubview(logoRippleView!)
        logoRippleView!.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(LogoRippleView.getViewLayoutConstraints(rippleLogoView: logoRippleView!,
                                                                            parentView: self))
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
