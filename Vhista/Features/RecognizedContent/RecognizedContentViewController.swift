//
//  RecognizedContentViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 7/27/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit

protocol RecognizedContentViewControllerDelegate: class {
    func willDismissRecognizedContentViewController(_ controller: RecognizedContentViewController)
}

class RecognizedContentViewController: UIViewController {

    weak var delegate: RecognizedContentViewControllerDelegate?

    var closeButton: VHCloseButton!
    var recognizedImageView: UIImageView!
    var recognizedObjectsTextView: UITextView!
    var actionsToolbar: UIToolbar!

    static let recognizedCloseButtonHorizontalSpacing: CGFloat = 8.0
    static let recognizedCloseButtonVerticalSpacing: CGFloat = 8.0
    static let recognizedTextViewHorizontalSpacing: CGFloat = 8.0
    static let recognizedTextViewVerticalSpacing: CGFloat = 8.0
    static let recognizedImageViewVerticalSpacing: CGFloat = 20.0
    static let recognizedImageViewMaxHeight: CGFloat = 150.0
    static let recognizedImageViewCornerRadius: CGFloat = 8.0

    static let timeIntervalAnimateHeightChange: TimeInterval = 0.15

    static let copyImageName: String = "doc.on.doc"
    static let shareImageName: String = "square.and.arrow.up"

    var recognizedImageViewWidthContraint: NSLayoutConstraint!
    var recognizedImageViewHeightContraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAccessibility()
        setUpUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.willDismissRecognizedContentViewController(self)
    }

    func updateWithText(_ text: String, image: UIImage? = nil) {
        recognizedObjectsTextView.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + text
        DispatchQueue.main.async {
            self.recognizedObjectsTextView.text = text
            if let takenImage = image {
                self.recognizedImageView.image = takenImage
                self.recognizedImageViewHeightContraint.constant = RecognizedContentViewController.recognizedImageViewMaxHeight
                let imageSizeRatio = takenImage.size.width / takenImage.size.height
                self.recognizedImageViewWidthContraint.constant = imageSizeRatio * RecognizedContentViewController.recognizedImageViewMaxHeight
                UIView.animate(withDuration: RecognizedContentViewController.timeIntervalAnimateHeightChange,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil)
            } else {
                self.recognizedImageViewHeightContraint.constant = 0.0
                UIView.animate(withDuration: RecognizedContentViewController.timeIntervalAnimateHeightChange,
                               animations: { self.view.layoutIfNeeded() },
                               completion: nil)
            }
        }
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged,
                             argument: closeButton)
    }
}

extension RecognizedContentViewController {
    func setUpAccessibility() {
        self.accessibilityViewIsModal = true
        self.view.accessibilityElements = [
            closeButton as Any,
            recognizedImageView as Any,
            recognizedObjectsTextView as Any,
            actionsToolbar as Any
        ]
    }
}

extension RecognizedContentViewController {
    func setUpUI() {
        setUpBackground()
        setUpCloseButton()
        setUpToolbar()
        setUpImageView()
        setUpTextView()
    }

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

    func setUpCloseButton() {
        closeButton = VHCloseButton(type: .system)
        closeButton.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(closeButton)
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                             constant: RecognizedContentViewController.recognizedCloseButtonVerticalSpacing),
            closeButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                               constant: -RecognizedContentViewController.recognizedCloseButtonHorizontalSpacing),
            closeButton.widthAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize),
            closeButton.heightAnchor.constraint(equalToConstant: VHCloseButton.closeButtonSize)
        ])
    }

    func setUpImageView() {
        recognizedImageView = UIImageView(frame: .zero)
        recognizedImageView.contentMode = .scaleAspectFit
        recognizedImageView.clipsToBounds = true
        recognizedImageView.layer.masksToBounds = true
        recognizedImageView.layer.cornerRadius = RecognizedContentViewController.recognizedImageViewCornerRadius
        recognizedImageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(recognizedImageView)
        recognizedImageViewHeightContraint = recognizedImageView.heightAnchor.constraint(equalToConstant: 0.0)
        recognizedImageViewWidthContraint = recognizedImageView.widthAnchor.constraint(equalToConstant: 0.0)

        NSLayoutConstraint.activate([
            recognizedImageView.topAnchor.constraint(equalTo: closeButton.bottomAnchor,
                                                     constant: RecognizedContentViewController.recognizedImageViewVerticalSpacing),
            recognizedImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            recognizedImageViewWidthContraint,
            recognizedImageViewHeightContraint
        ])
    }
    func setUpTextView() {
        recognizedObjectsTextView = UITextView(frame: .zero)
        recognizedObjectsTextView.textColor = getLabelDarkColorIfSupported(color: .white)
        recognizedObjectsTextView.isEditable = false
        recognizedObjectsTextView.isSelectable = false
        recognizedObjectsTextView.backgroundColor = .clear
        recognizedObjectsTextView.textAlignment = .center
        recognizedObjectsTextView.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        recognizedObjectsTextView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(recognizedObjectsTextView)
        NSLayoutConstraint.activate([
            recognizedObjectsTextView.topAnchor.constraint(equalTo: recognizedImageView.safeAreaLayoutGuide.bottomAnchor,
                                                           constant: RecognizedContentViewController.recognizedTextViewVerticalSpacing),
            recognizedObjectsTextView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor,
                                                            constant: RecognizedContentViewController.recognizedTextViewHorizontalSpacing),
            recognizedObjectsTextView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor,
                                                             constant: -RecognizedContentViewController.recognizedTextViewHorizontalSpacing),
            recognizedObjectsTextView.bottomAnchor.constraint(equalTo: actionsToolbar.topAnchor)
        ])
    }

    func setUpToolbar() {
        actionsToolbar = UIToolbar()
        actionsToolbar.tintColor = getLabelDarkColorIfSupported(color: .white)
        actionsToolbar.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(actionsToolbar)
        NSLayoutConstraint.activate([
            actionsToolbar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            actionsToolbar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            actionsToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        // Items
        actionsToolbar.items = [UIBarButtonItem]()

        var copyTextImage = UIImage(named: RecognizedContentViewController.copyImageName)
        if #available(iOS 13.0, *) {
            copyTextImage = UIImage(systemName: RecognizedContentViewController.copyImageName) ?? copyTextImage
        }
        let copyTextItem = UIBarButtonItem(image: copyTextImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(copyContextText))
        copyTextItem.accessibilityLabel = NSLocalizedString("copy_text", comment: "")
        actionsToolbar.items?.append(copyTextItem)

        actionsToolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

        var savePhotoImage = UIImage(named: RecognizedContentViewController.shareImageName)
        if #available(iOS 13.0, *) {
            savePhotoImage = UIImage(systemName: RecognizedContentViewController.shareImageName) ?? savePhotoImage
        }
        let savePhotoItem = UIBarButtonItem(image: savePhotoImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(shareImage(_:)))
        savePhotoItem.accessibilityLabel = NSLocalizedString("share_taken_picture", comment: "")
        actionsToolbar.items?.append(savePhotoItem)

        actionsToolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
    }
}

extension RecognizedContentViewController {

    @objc func copyContextText() {
        UIAccessibility.post(notification: .announcement,
                             argument: NSLocalizedString("text_copied", comment: ""))
        UIPasteboard.general.string = recognizedObjectsTextView.text
    }

    @objc func shareImage(_ sender: UIBarButtonItem) {
        guard let image = recognizedImageView.image else {
            return
        }
        let imagesToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imagesToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender

        self.present(activityViewController, animated: true, completion: nil)
    }

    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}
