//
//  InfoViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/31/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    static let headerViewVerticalSpacing: CGFloat = 8.0
    static let headerViewHorizontalSpacing: CGFloat = 8.0

    var infoHeaderView: InfoHeaderView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackground()
        setUpHeaderView()
    }

    override func viewDidLayoutSubviews() {
        setUpBackground()
        setUpHeaderView()
    }
}

extension InfoViewController {

    func setUpBackground() {
        guard let view = self.view else {
            return
        }
        let pickerVisualEffectView = UIVisualEffectView(effect: globalBlurEffect())
        pickerVisualEffectView.frame = self.view.frame
        self.view.insertSubview(pickerVisualEffectView, at: .zero)
        pickerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerVisualEffectView.widthAnchor.constraint(equalTo: view.widthAnchor),
            pickerVisualEffectView.heightAnchor.constraint(equalTo: view.heightAnchor),
            pickerVisualEffectView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerVisualEffectView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    func setUpHeaderView() {
        infoHeaderView = InfoHeaderView(frame: .zero)
        self.view.addSubview(infoHeaderView)
        infoHeaderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoHeaderView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor,
                                                constant: InfoViewController.headerViewVerticalSpacing),
            infoHeaderView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                 constant: InfoViewController.headerViewHorizontalSpacing),
            infoHeaderView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor,
                                                  constant: InfoViewController.headerViewHorizontalSpacing),
            infoHeaderView.heightAnchor.constraint(equalToConstant: InfoHeaderView.getEstimatedHeight(width: self.view.frame.size.width))
        ])
    }
}
