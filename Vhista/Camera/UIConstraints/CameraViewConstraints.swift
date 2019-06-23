import UIKit

extension ARKitCameraViewController {
    func setUpUIConstraints() {
        bottomToolbar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomToolbar.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomToolbar.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])

        recognizedContentViewHeightContraint = recognizedContentView.heightAnchor.constraint(equalToConstant: .zero)
        recognizedContentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recognizedContentViewHeightContraint,
            recognizedContentView.bottomAnchor.constraint(equalTo: bottomToolbar.topAnchor),
            recognizedContentView.rightAnchor.constraint(equalTo: view.rightAnchor),
            recognizedContentView.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])

        deepAnalysisButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deepAnalysisButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            deepAnalysisButton.bottomAnchor.constraint(equalTo: recognizedContentView.topAnchor),
            deepAnalysisButton.rightAnchor.constraint(equalTo: view.rightAnchor),
            deepAnalysisButton.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])

        logoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(LogoView.getViewLayoutConstraints(logoView: logoView,
                                                                      parentView: self.view))
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
