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
