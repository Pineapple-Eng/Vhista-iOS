//  Created by Juan David Cruz Serrano on 8/31/19. Copyright © 2019 juandavidcruz. All rights reserved.

import UIKit

protocol InfoViewControllerDelegate: class {
    func willDismissInfoViewControllerr(_ controller: InfoViewController)
}

class InfoViewController: UIViewController {

    static let closeButtonHorizontalSpacing: CGFloat = 8.0
    static let closeButtonVerticalSpacing: CGFloat = 8.0

    static let headerViewVerticalSpacing: CGFloat = 8.0
    static let headerViewHorizontalSpacing: CGFloat = 8.0

    static let bodyViewVerticalSpacing: CGFloat = 8.0
    static let bodyViewHorizontalSpacing: CGFloat = 8.0

    static let footerViewVerticalSpacing: CGFloat = 8.0
    static let footerViewHorizontalSpacing: CGFloat = 8.0

    var closeButton: VHCloseButton!
    var infoHeaderView: InfoHeaderView!
    var infoBodyView: InfoBodyView!
    var infoFooterView: InfoFooterView!

    weak var delegate: InfoViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBackground()
        setUpCloseButton()
        setUpHeaderView()
        setUpFooterView()
        setUpBodyView()
        setUpAccessibility()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.willDismissInfoViewControllerr(self)
    }
}

extension InfoViewController {

    func setUpCloseButton() {
        closeButton = VHCloseButton(type: .system)
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        self.view.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: InfoViewController.closeButtonVerticalSpacing),
            closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -InfoViewController.closeButtonHorizontalSpacing),
            closeButton.widthAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize)
        ])
    }

    func setUpBackground() {
        guard let view = self.view else {
            return
        }
        let pickerVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
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
            infoHeaderView.topAnchor.constraint(equalTo: closeButton.bottomAnchor,
                                                constant: InfoViewController.headerViewVerticalSpacing),
            infoHeaderView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                 constant: InfoViewController.headerViewHorizontalSpacing),
            infoHeaderView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor,
                                                  constant: -InfoViewController.headerViewHorizontalSpacing),
            infoHeaderView.heightAnchor.constraint(equalToConstant: InfoHeaderView.getEstimatedHeight(width: self.view.frame.size.width))
        ])
    }

    func setUpBodyView() {
        infoBodyView = InfoBodyView(frame: .zero)
        self.view.addSubview(infoBodyView)
        infoBodyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoBodyView.topAnchor.constraint(equalTo: infoHeaderView.bottomAnchor,
                                                constant: InfoViewController.bodyViewVerticalSpacing),
            infoBodyView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                 constant: InfoViewController.bodyViewHorizontalSpacing),
            infoBodyView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor,
                                                  constant: -InfoViewController.bodyViewHorizontalSpacing),
            infoBodyView.bottomAnchor.constraint(equalTo: infoFooterView.topAnchor,
                                                 constant: -InfoViewController.bodyViewVerticalSpacing)
        ])
    }

    func setUpFooterView() {
        infoFooterView = InfoFooterView(frame: .zero)
        self.view.addSubview(infoFooterView)
        infoFooterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            infoFooterView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,
                                                   constant: -InfoViewController.footerViewVerticalSpacing),
            infoFooterView.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor,
                                                 constant: InfoViewController.footerViewHorizontalSpacing),
            infoFooterView.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor,
                                                  constant: -InfoViewController.footerViewHorizontalSpacing),
            infoFooterView.heightAnchor.constraint(equalToConstant: InfoFooterView.getEstimatedHeight(width: self.view.frame.size.width))
        ])
    }
}

extension InfoViewController {
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController {
    func setUpAccessibility() {
        self.accessibilityViewIsModal = true
    }
}
