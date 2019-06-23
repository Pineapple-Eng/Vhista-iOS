//
//  ViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/1/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision

class ARKitCameraViewController:
UIViewController,
UIGestureRecognizerDelegate,
ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!

    // Logo View
    var logoView: UIView!

    // Recognized Content View
    var recognizedContentViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var recognizedContentView: UIView!
    var recognizedContentViewController: RecognizedContentViewController?

    @IBOutlet weak var deepAnalysisButton: UIButton!

    @IBOutlet weak var upgradeButtonItem: UIBarButtonItem!

    @IBOutlet weak var bottomToolbar: UIToolbar!

    // ARSession Frame
    var previousFrameTimeInterval = Date().timeIntervalSince1970

    //Still Image
    private var persistentPixelBuffer: CVPixelBuffer?

    var selectedImage: UIImage!

    @IBOutlet weak var selectedImageView: UIImageView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpSceneView()
        VhistaSpeechManager.shared.parentARController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VhistaSpeechManager.shared.blockAllSpeech = false
        if SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            upgradeButtonItem.title = NSLocalizedString("Show_Subscription_Button_Title", comment: "")
            upgradeButtonItem.accessibilityHint = NSLocalizedString("Subscription_Button_Accessibility_Hint", comment: "")
        } else {
            upgradeButtonItem.title = NSLocalizedString("Upgrade_Button_Title", comment: "")
            upgradeButtonItem.accessibilityHint = NSLocalizedString("Upgrade_Button_Accessibility_Hint", comment: "")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            print("Activating vertical plane detection")
            configuration.planeDetection = .vertical
        } else {
            // Fallback on earlier versions
        }
        // Run the view's session
        sceneView.session.run(configuration)
    }

    func setUpUI() {
        if SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            upgradeButtonItem.title = NSLocalizedString("Show_Subscription_Button_Title", comment: "")
        }

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

        logoView = LogoView(frame: .zero)
        logoView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(logoView)
        NSLayoutConstraint.activate(LogoView.getViewLayoutConstraints(logoView: logoView,
                                                                      parentView: self.view))
    }

    func setUpSceneView() {
        sceneView.delegate = self
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        sceneView.session.delegate = self
        sceneView.showsStatistics = false
        let arScene = SCNScene()
        sceneView.scene = arScene
    }

    override func viewDidLayoutSubviews() {
        self.view.bringSubviewToFront(deepAnalysisButton)
        recognizedContentView.translatesAutoresizingMaskIntoConstraints = false
    }

    @IBAction func hitUpgradeAction(_ sender: Any) {
        if !SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
        } else {
            self.performSegue(withIdentifier: "ShowSubscriptionInfo", sender: nil)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecognizedContentView" {
            recognizedContentViewController = segue.destination as? RecognizedContentViewController
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }

    @IBAction func makeDeepAnalysis(_ sender: Any) {

        if !checkCameraPermissions() {
            return
        }

        guard self.persistentPixelBuffer != nil else {
            print("No Buffer \(String(describing: self.persistentPixelBuffer))")
            return
        }

        RekognitionManager.shared.playLoadingSound()
        VhistaSpeechManager.shared.stopSpeech(sender: sender)
        VhistaSpeechManager.shared.blockAllSpeech =  true

        ConfigurationManager.shared.serverAllowsRecognition({ (allowed) in

            if allowed {

                switch VhistaReachabilityManager.shared.networkStatus {
                case .notReachable, .unknown:
                    RekognitionManager.shared.backToDefaults()
                    VhistaSpeechManager.shared.blockAllSpeech =  false
                    VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("Not_Reachable",
                                                                                    comment: "Let the user know there is no internet access"),
                                                       isProtected: true,
                                                       rate: globalRate)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return
                case .reachableViaWWAN:
                    print("Network OK")
                case .reachableViaWiFi:
                    print("Network OK")
                @unknown default:
                    print("Network Unknown")
                    return
                }

                if !SubscriptionManager.shared.checkDeepSubscription() {
                    RekognitionManager.shared.backToDefaults()
                    VhistaSpeechManager.shared.blockAllSpeech =  false
                    self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
                    return
                }

                if let currentImage = UIImage(pixelBuffer: self.persistentPixelBuffer!) {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    processingImage = true
                    self.setImageForRekognition(image: currentImage)
                }

            } else {
                RekognitionManager.shared.backToDefaults()
                VhistaSpeechManager.shared.blockAllSpeech =  false
                self.showErrorAlertView(title: NSLocalizedString("Deep_Analysis_Deactivated_Title", comment: ""),
                                        message: NSLocalizedString("Deep_Analysis_Deactivated_Message", comment: ""))
                return
            }

        })

    }

    // MARK: - ARSessionDelegate

    // Pass camera frames received from ARKit to Vision (when not already processing one)
    /// - Tag: ConsumeARFrames
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.

        self.persistentPixelBuffer = frame.capturedImage

//        Working "" flash solution.
//        let luminosity = frame.lightEstimate?.ambientIntensity
//        let device = AVCaptureDevice.default(for: .video)!
//        if device.hasTorch, device.isTorchAvailable {
//            do {
//                try device.lockForConfiguration()
//                if let lumens = luminosity, lumens < flashLumens {
//                    device.torchMode = .on
//                } else {
//                    if device.isTorchActive {
//                        device.torchMode = .off
//                    }
//                }
//                device.unlockForConfiguration()
//            } catch {
//                print("\(error)")
//            }
//        }

        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }

        let frameTimestamp = Date().timeIntervalSince1970
        if previousFrameTimeInterval.advanced(by: frameRateInterval) >= frameTimestamp {
            return
        } else {
            previousFrameTimeInterval = frameTimestamp
        }

        // Retain the image buffer for Vision processing.
        self.currentBuffer = frame.capturedImage
        classifyCurrentImage()
    }

    // MARK: - Vision classification

    // Vision classification request and model
    /// - Tag: ClassificationRequest
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Instantiate the model from its generated Swift class.
            let model = try VNCoreMLModel(for: Inceptionv3().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })

            // Crop input images to square area at center, matching the way the ML model was trained.
            request.imageCropAndScaleOption = .centerCrop

//            request.usesCPUOnly = true

            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()

    private lazy var facesClassificationRequest: VNDetectFaceRectanglesRequest = {
        return VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceLandmarks)
    }()

    // The pixel buffer being held for analysis; used to serialize Vision requests.
    private var currentBuffer: CVPixelBuffer?

    // Queue for dispatching vision classification requests
    private let visionQueue = DispatchQueue(label: "com.juandavidcruz.Vhista.ARKitVision.serialVisionQueue")

    // Run the Vision+ML classifier on the current image buffer.
    /// - Tag: ClassifyCurrentImage
    private func classifyCurrentImage() {

        if currentBuffer == nil {
            return
        }

        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)

        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer {
                    self.currentBuffer = nil
                }
                try requestHandler.perform([self.classificationRequest, self.facesClassificationRequest])
            } catch {
                print("Error: Vision request failed with error \"\(error)\"")
            }
        }
    }

    // Handle completion of the Vision request and choose results to display.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            print("Unable to classify image.\n\(error!.localizedDescription)")
            return
        }
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        guard let classifications = results as? [VNClassificationObservation] else {
            return
        }

        // Classification results
        var identifierString = ""
        var confidence: VNConfidence = 0.0

        // Show a label for the highest-confidence result (but only above a minimum confidence threshold).
        if let bestResult = classifications.first(where: { result in result.confidence > inceptionV3RecognitionThreshold }) {
            identifierString = String(bestResult.identifier)
            confidence = bestResult.confidence
        } else {
            identifierString = ""
            confidence = 0
        }

        DispatchQueue.main.async { [weak self] in
            self?.displayClassifierResults(identifierString, confidence: confidence)
        }
    }

    // Show the classification results in the UI.
    private func displayClassifierResults(_ result: String, confidence: VNConfidence) {
        guard !result.isEmpty else {
            return // No object was classified.
        }
        let message = String(format: "Detected \(result) with %.2f", confidence * 100) + "% confidence"
        print(message)

        let hitTestResults = sceneView.hitTest(sceneView.center, types: .featurePoint)
        guard let hitTestResult = hitTestResults.first else {
            addStringToRead(result, "", isProtected: false)
            return
        }
        addStringToRead(result, getLocalizedStringForDistance(hitTestResult.distance), isProtected: false)
    }

    // MARK: - AR Session Handling

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable, .limited: break
        case .normal: break
            // Unhide content after successful relocalization.
//            setOverlaysHidden(false)
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]

        // Filter out optional error messages.
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            self.displayErrorMessage(title: NSLocalizedString("AR_Session_Failed_Title", comment: ""), message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
//        setOverlaysHidden(true)
    }

    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        /*
         Allow the session to attempt to resume after an interruption.
         This process may not succeed, so the app must be prepared
         to reset the session if the relocalizing status continues
         for a long time -- see `escalateFeedback` in `StatusViewController`.
         */
        return true
    }

    private func restartSession() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        let configuration = ARWorldTrackingConfiguration()
        if #available(iOS 11.3, *) {
            configuration.planeDetection = .vertical
        } else {
            // Fallback on earlier versions
        }
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

}

// MARK: - Handle Reading of Identified Labels
extension ARKitCameraViewController {

    func handleFaceLandmarks(request: VNRequest, error: Error?) {
        if processingImage { return }
        if let landmarksResults = request.results as? [VNFaceObservation] {
            let resultText = ClassificationsManager.shared.addPeopleToRead(faceObservations: landmarksResults)
            if resultText != "" {
                self.addStringToReadFace(stringRecognized: resultText, isProtected: false)
            }
        }
    }

    func addStringToRead(_ stringRecognized: String, _ distanceString: String, isProtected: Bool) {
        if !ClassificationsManager.shared.allowStringRecognized(stringRecognized: stringRecognized) { return }
        print(distanceString)
        let stringRecognizedTranslated = translateModelString(pString: stringRecognized, targetLanguage: globalLanguage)

        ClassificationsManager.shared.lastRecognition = stringRecognized
        ClassificationsManager.shared.recognitionsAsText.insert(stringRecognizedTranslated, at: 0)
        if ClassificationsManager.shared.recognitionsAsText.count == 3 {
            ClassificationsManager.shared.recognitionsAsText.remove(at: 2)
        }
        guard let text = ClassificationsManager.shared.recognitionsAsText.first else {
            return
        }
        updateRecognizedContentView(text: text)

        VhistaSpeechManager.shared.sayText(stringToSpeak: text + distanceString,
                                           isProtected: isProtected,
                                           rate: Float(globalRate))
    }

    func addStringToReadFace(stringRecognized: String, isProtected: Bool) {
        ClassificationsManager.shared.lastRecognition = stringRecognized
        ClassificationsManager.shared.recognitionsAsText.insert(stringRecognized, at: 0)
        if ClassificationsManager.shared.recognitionsAsText.count == 3 {
            ClassificationsManager.shared.recognitionsAsText.removeLast()
        }
        guard let text = ClassificationsManager.shared.recognitionsAsText.first else {
            return
        }
        updateRecognizedContentView(text: text)

        VhistaSpeechManager.shared.sayText(stringToSpeak: stringRecognized, isProtected: isProtected, rate: Float(globalRate))

    }
}

// MARK: - Handle ARSCNView Delegate Methods
extension ARKitCameraViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {

        let anchorNode = SCNNode()
        let planeNode = SCNNode()
        if let anchor = anchor as? ARPlaneAnchor {
            planeNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
            // transforming node
            planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 0.50)
            planeNode.eulerAngles = SCNVector3(-Float.pi/2, 0, 0)
        }
        anchorNode.addChildNode(planeNode)
        return anchorNode
    }

//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//
//        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
//
//        let width = CGFloat(planeAnchor.extent.x)
//        let height = CGFloat(planeAnchor.extent.y)
//        let plane = SCNPlane(width: width, height: height)
//        plane.materials.first?.diffuse.contents = UIColor.white
//        let planeNode = SCNNode(geometry: plane)
//        let x = CGFloat(planeAnchor.center.x)
//        let y = CGFloat(planeAnchor.center.y)
//        let z = CGFloat(planeAnchor.center.z)
//        planeNode.position = SCNVector3(x,y,z)
//        node.addChildNode(planeNode)
//    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let anchor = anchor as? ARPlaneAnchor {
            if let planeNode = node.childNodes.first {
                planeNode.geometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
                // transforming node
                planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
                planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.35)
            }
        }
    }

}

// MARK: - Error Handling
extension ARKitCameraViewController {
    private func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: NSLocalizedString("Restart_Session", comment: ""), style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            if !self.checkCameraPermissions() {
                return
            } else {
                self.restartSession()
            }
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ARKitCameraViewController {

    func setImageForRekognition(image: UIImage) {

        selectedImage = image

        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation

        switch orientation {
        case .portrait:
            selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .right)
        case .landscapeRight:
            selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .down)
        case .landscapeLeft:
            selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .up)
        case .portraitUpsideDown:
            selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .left)
        default:
            selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .right)
        }

        RekognitionManager.shared.startProcessing(selectedImage)
        showSelectedImage()
    }

    func showSelectedImage() {
        selectedImageView.image = selectedImage
        selectedImageView.isHidden = false
    }

    func finishedRekognitionAnalisis() {
        print("🏁 Finished Rekognition Analysis")
        DispatchQueue.main.async {
            self.selectedImageView.isHidden = true
            self.selectedImageView.image = nil
        }
        selectedImage = nil
        processingImage = false
    }
}

// MARK: - Update Recognized Content View
extension ARKitCameraViewController {
    func updateRecognizedContentView(text: String) {
        recognizedContentViewController?.updateWithText(text)
        DispatchQueue.main.async {
            let height = RecognizedContentViewController.calculateHeightForText(text: text,
                                                                                width: self.recognizedContentView.frame.width,
                                                                                safeAreaHeight: self.view.safeAreaInsets.bottom)
            self.recognizedContentViewHeightContraint.constant = height
            UIView.animate(withDuration: RecognizedContentViewController.timeIntervalAnimateHeightChange,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}
