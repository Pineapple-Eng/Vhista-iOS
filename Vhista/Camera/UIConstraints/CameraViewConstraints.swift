import UIKit

extension ARKitCameraViewController {
    func setUpUIConstraints() {
        bottomToolbarViewBottomAnchorContraint = bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomToolbarViewBottomAnchorContraint,
            bottomToolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomToolbar.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])

        shutterButtonView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            shutterButtonView.widthAnchor.constraint(equalToConstant: CameraShutterButtonView.buttonSize),
            shutterButtonView.heightAnchor.constraint(equalToConstant: CameraShutterButtonView.buttonSize),
            shutterButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                      constant: -CameraShutterButtonView.paddingFromBottom),
            shutterButtonView.centerXAnchor.constraint(equalTo: bottomToolbar.centerXAnchor)
        ])

        fastRecognizedContentViewHeightContraint = fastRecognizedContentView.heightAnchor.constraint(equalToConstant: .zero)
        fastRecognizedContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            fastRecognizedContentViewHeightContraint,
            fastRecognizedContentView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            fastRecognizedContentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            fastRecognizedContentView.leftAnchor.constraint(equalTo: view.leftAnchor)
        ])

        featuresCollectionContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featuresCollectionContentView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,
                                                               constant: FeaturesCollectionViewController.viewTopPadding),
            featuresCollectionContentView.heightAnchor.constraint(equalToConstant: FeaturesCollectionViewController.viewHeight),
            featuresCollectionContentView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            featuresCollectionContentView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        ])

        featuresCollectionVC.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            featuresCollectionVC.view.topAnchor.constraint(equalTo:
                featuresCollectionContentView.safeAreaLayoutGuide.topAnchor),
            featuresCollectionVC.view.heightAnchor.constraint(equalTo: featuresCollectionContentView.heightAnchor),
            featuresCollectionVC.view.rightAnchor.constraint(equalTo: featuresCollectionContentView.rightAnchor),
            featuresCollectionVC.view.leftAnchor.constraint(equalTo: featuresCollectionContentView.leftAnchor)
        ])

        setUpSelectedImageConstraints()
    }

    func setUpSelectedImageConstraints() {
        selectedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            selectedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectedImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            selectedImageView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])

        selectedImageViewOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            selectedImageViewOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            selectedImageViewOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectedImageViewOverlay.leftAnchor.constraint(equalTo: view.leftAnchor),
            selectedImageViewOverlay.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }

    func setUpARCameraViewSceneConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sceneView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            sceneView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
        ])
    }

    func setUpNonARCameraViewConstraints() {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cameraView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            cameraView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor)
            ])
    }
}

extension ARKitCameraViewController {
    func toggleBottomAndRecognizedContentViewsVisibility(hide: Bool) {
        var deltaY: CGFloat = 0.0
        if hide {
            deltaY = bottomToolbar.frame.size.height + fastRecognizedContentViewHeightContraint.constant + self.view.safeAreaInsets.bottom
        }
        DispatchQueue.main.async {
            self.bottomToolbarViewBottomAnchorContraint.constant = deltaY
            UIView.animate(withDuration: FastRecognizedContentViewController.timeIntervalAnimateHeightChange,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
