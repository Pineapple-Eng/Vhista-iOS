//
//  LoadingRippleView.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

class LoadingRippleView: UIView {

    static let viewWidth: CGFloat = 80.0
    static let viewHeight: CGFloat = 80.0

    private static let centerDiskRadius: CGFloat = CameraShutterButtonView.buttonSize / 2
    private static let animationDuration: CGFloat = 0.85
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

extension LoadingRippleView {
    private func setUpRadarView() {
        radarView = RadarView(frame: .zero)
        radarView.diskRadius = LoadingRippleView.centerDiskRadius
        radarView.circleOnColor = LoadingRippleView.circleOnColor
        radarView.diskColor = LoadingRippleView.diskColor
        radarView.circleOffColor = LoadingRippleView.circleOffColor
        radarView.numberOfCircles = LoadingRippleView.numberOfCircles
        radarView.animationDuration = LoadingRippleView.animationDuration
        radarView.paddingBetweenCircles = LoadingRippleView.paddingBetweenCircles
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

extension LoadingRippleView {
    static func getViewLayoutConstraints(rippleLoadingView: LoadingRippleView,
                                         parentView: UIView) -> [NSLayoutConstraint] {
        return [
            rippleLoadingView.centerYAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerYAnchor),
            rippleLoadingView.centerXAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.centerXAnchor),
            rippleLoadingView.widthAnchor.constraint(equalToConstant: viewWidth),
            rippleLoadingView.heightAnchor.constraint(equalToConstant: viewHeight)
        ]
    }
}
