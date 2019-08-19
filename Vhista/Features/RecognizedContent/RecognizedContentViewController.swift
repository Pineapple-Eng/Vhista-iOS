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

    var recognizedObjectsTextView: UITextView!
    var actionsToolbar: UIToolbar!

    static let recognizedTextViewHorizontalSpacing: CGFloat = 8.0

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpAccessibility()
        setUpUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate?.willDismissRecognizedContentViewController(self)
    }

    func updateWithText(_ text: String) {
        recognizedObjectsTextView.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + text
        DispatchQueue.main.async {
            self.recognizedObjectsTextView.text = text
            self.view.layoutIfNeeded()
        }
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged,
                             argument: recognizedObjectsTextView)
    }
}

extension RecognizedContentViewController {
    func setUpAccessibility() {
        self.accessibilityViewIsModal = true
    }
}

extension RecognizedContentViewController {
    func setUpUI() {
        setUpBackground()
        setUpToolbar()
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
            recognizedObjectsTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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

        var copyTextImage = UIImage()
        if #available(iOS 13.0, *) {
            copyTextImage = UIImage(systemName: "doc.on.doc") ?? copyTextImage
        }
        let copyTextItem = UIBarButtonItem(image: copyTextImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(copyContextText))
        copyTextItem.accessibilityLabel = NSLocalizedString("copy_text", comment: "")
        actionsToolbar.items?.append(copyTextItem)

        actionsToolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

        var savePhotoImage = UIImage()
        if #available(iOS 13.0, *) {
            savePhotoImage = UIImage(systemName: "square.and.arrow.up") ?? savePhotoImage
        }
        let savePhotoItem = UIBarButtonItem(image: savePhotoImage,
                                            style: .plain,
                                            target: self,
                                            action: nil)
        savePhotoItem.accessibilityLabel = NSLocalizedString("share_taken_picture", comment: "")
        actionsToolbar.items?.append(savePhotoItem)

        actionsToolbar.items?.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))

        let closeItem = UIBarButtonItem(title: NSLocalizedString("Close_Action", comment: ""),
                                        style: .done,
                                        target: self,
                                        action: #selector(dismissView))
        actionsToolbar.items?.append(closeItem)
    }
}

extension RecognizedContentViewController {

    @objc func copyContextText() {
        UIAccessibility.post(notification: .announcement,
                             argument: NSLocalizedString("text_copied", comment: ""))
        UIPasteboard.general.string = recognizedObjectsTextView.text
    }
    @objc func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
}