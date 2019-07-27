//
//  LogoRippleView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import UIKit
import HGRippleRadarView

class LogoRippleView: UIView {

    static let viewWidth: CGFloat = 160.0
    static let viewHeight: CGFloat = 160.0

    private static let centerDiskRadius: CGFloat = LogoView.viewWidth / 2
    private static let animationDuration: CGFloat = 0.9
    private static let paddingBetweenCircles: CGFloat = 15.0
    private static let numberOfCircles: Int = 6
    private static let diskColor: UIColor = .clear
    private static let circleOnColor: UIColor = .white
    private static let circleOffColor: UIColor = .clear

    var radarView: RadarView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpRadarView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpRadarView()
    }
}

extension LogoRippleView {
    private func setUpRadarView() {
        radarView = RadarView(frame: .zero)
        radarView.diskRadius = LogoRippleView.centerDiskRadius
        radarView.circleOnColor = LogoRippleView.circleOnColor
        radarView.diskColor = LogoRippleView.diskColor
        radarView.circleOffColor = LogoRippleView.circleOffColor
        radarView.numberOfCircles = LogoRippleView.numberOfCircles
        radarView.animationDuration = LogoRippleView.animationDuration
        radarView.paddingBetweenCircles = LogoRippleView.paddingBetweenCircles
        self.addSubview(radarView)
        radarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            radarView.topAnchor.constraint(equalTo: self.topAnchor),
            radarView.leftAnchor.constraint(equalTo: self.leftAnchor),
            radarView.rightAnchor.constraint(equalTo: self.rightAnchor),
            radarView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
    }
}

extension LogoRippleView {
    static func getViewLayoutConstraints(rippleLogoView: LogoRippleView,
                                         parentView: UIView) -> [NSLayoutConstraint] {
        return [
            rippleLogoView.centerYAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerYAnchor),
            rippleLogoView.centerXAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerXAnchor),
            rippleLogoView.widthAnchor.constraint(equalToConstant: viewWidth),
            rippleLogoView.heightAnchor.constraint(equalToConstant: viewHeight)
        ]
    }
}
