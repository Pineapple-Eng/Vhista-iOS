//
//  ViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/1/17.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import Vision
import AVFoundation

class ARKitCameraViewController:
UIViewController,
UIGestureRecognizerDelegate {

    // Recognized Content View
    var recognizedContentViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var recognizedContentView: UIView!
    var recognizedContentViewController: FastRecognizedContentViewController?

    @IBOutlet weak var deepAnalysisButton: UIButton!

    @IBOutlet weak var upgradeButtonItem: UIBarButtonItem!

    var bottomToolbarViewBottomAnchorContraint: NSLayoutConstraint!
    @IBOutlet weak var bottomToolbar: UIToolbar!

    // -- Non AR Camera --
    var captureSession: AVCaptureSession!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var cameraView: UIView!
    var captureQueue: DispatchQueue!
    var stillImageOutput: AVCapturePhotoOutput!
    var shapeLayer: CAShapeLayer!
    // -- / Non AR Camera --

    // -- AR Camera --
    var sceneView: ARSCNView!
    var previousFrameTimeInterval: TimeInterval!
    //Still Image
    var persistentPixelBuffer: CVPixelBuffer?
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    var currentBuffer: CVPixelBuffer?
    // -- / AR Camera --

    // Queue for dispatching vision classification requests
    private let visionQueue = DispatchQueue(label: "com.juandavidcruz.Vhista.ARKitVision.serialVisionQueue")
    var selectedImage: UIImage!

    @IBOutlet weak var selectedImageView: UIImageView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        if arEnabled {
            setUpSceneView()
        } else {
            setUpCamera()
        }
        VhistaSpeechManager.shared.parentARController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        resumeCurrentSession()
    }

    func setUpUI() {
        if SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            upgradeButtonItem.title = NSLocalizedString("Show_Subscription_Button_Title", comment: "")
        }
        setUpUIConstraints()
    }

    override func viewDidLayoutSubviews() {
        self.view.bringSubviewToFront(deepAnalysisButton)
        recognizedContentView.translatesAutoresizingMaskIntoConstraints = false
        if !arEnabled {
            updateNonARCameraConnectionOrientationAndFrame()
        }
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
            recognizedContentViewController = segue.destination as? FastRecognizedContentViewController
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseCurrentSession()
    }

    @IBAction func makeDeepAnalysis(_ sender: Any) {
        if !checkCameraPermissions() {
            return
        }

        guard self.persistentPixelBuffer != nil else {
            print("No Buffer \(String(describing: self.persistentPixelBuffer))")
            return
        }
        updateUIForDeepAnalysisChange(willAnalyze: true)
        ConfigurationManager.shared.serverAllowsRecognition({ (allowed) in
            if allowed {
                guard VhistaReachabilityManager.shared.validInternetConnection() else {
                    self.updateUIForDeepAnalysisChange(willAnalyze: false)
                    VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("Not_Reachable",
                                                                                        comment: "Let the user know there is no internet access"),
                                                       isProtected: true,
                                                       rate: globalRate)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    return
                }

                if !SubscriptionManager.shared.checkDeepSubscription() {
                    self.updateUIForDeepAnalysisChange(willAnalyze: false)
                    self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
                    return
                }

                if arEnabled {
                    self.processARImageAnalysis()
                } else {
                    self.processNonARImageAnalysis()
                }
            } else {
                self.updateUIForDeepAnalysisChange(willAnalyze: false)
                self.showErrorAlertView(title: NSLocalizedString("Deep_Analysis_Deactivated_Title", comment: ""),
                                        message: NSLocalizedString("Deep_Analysis_Deactivated_Message", comment: ""))
                return
            }
        })
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

    func runVisionQueueWithRequestHandler(_ requestHandler: VNImageRequestHandler) {
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

        if arEnabled {
            let hitTestResults = sceneView.hitTest(sceneView.center, types: .featurePoint)
            guard let hitTestResult = hitTestResults.first else {
                addStringToRead(result, "", isProtected: false)
                return
            }
            addStringToRead(result, getLocalizedStringForDistance(hitTestResult.distance), isProtected: false)
        } else {
            addStringToRead(result, "", isProtected: false)
        }
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

    func addStringToRead(_ stringRecognized: String, _ distanceString: String = "", isProtected: Bool) {
        if !ClassificationsManager.shared.allowStringRecognized(stringRecognized: stringRecognized) { return }
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

extension ARKitCameraViewController {

    func setImageForRecognition(image: UIImage) {

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
        showSelectedImage()
    }

    func showSelectedImage() {
        DispatchQueue.main.async {
//            self.view.bringSubviewToFront(self.logoView)
            self.selectedImageView.image = self.selectedImage
            self.selectedImageView.isHidden = false
        }
    }

    func finishedRekognitionAnalisis() {
        print("🏁 Finished Rekognition Analysis")
        DispatchQueue.main.async {
            self.selectedImageView.isHidden = true
            self.selectedImageView.image = nil
        }
        selectedImage = nil
        processingImage = false
        updateUIForDeepAnalysisChange(willAnalyze: false)
    }
}

// MARK: - Update Recognized Content View
extension ARKitCameraViewController {
    func updateRecognizedContentView(text: String) {
        recognizedContentViewController?.updateWithText(text)
        DispatchQueue.main.async {
            let height = FastRecognizedContentViewController.calculateHeightForText(text: text,
                                                                                width: self.recognizedContentView.frame.width,
                                                                                safeAreaHeight: self.view.safeAreaInsets.bottom)
            self.recognizedContentViewHeightContraint.constant = height
            UIView.animate(withDuration: FastRecognizedContentViewController.timeIntervalAnimateHeightChange,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
}

// MARK: - View Handling
extension ARKitCameraViewController {
    func updateUIForDeepAnalysisChange(willAnalyze: Bool) {
        toggleBottomAndRecognizedContentViewsVisibility(hide: willAnalyze)
        if willAnalyze {
            pauseCurrentSession()
//            logoView.showLoadingLogoView(parentView: self.view)
//            RekognitionManager.shared.playLoadingSound()
        } else {
            resumeCurrentSession()
//            logoView.stopLoadingLogoView(parentView: self.view)
//            RekognitionManager.shared.backToDefaults()
        }
    }
}

// MARK: - Session Handling
extension ARKitCameraViewController {
    func pauseCurrentSession() {
        VhistaSpeechManager.shared.stopSpeech(sender: self)
        VhistaSpeechManager.shared.blockAllSpeech = true
        // Pause the view's session
        if arEnabled {
            sceneView.session.pause()
        }
    }

    func resumeCurrentSession() {
        VhistaSpeechManager.shared.blockAllSpeech = false
        if arEnabled {
            arCameraViewDidAppear()
        } else {
            nonARCameraViewDidAppear()
        }
    }
}

// MARK: - Error Handling
extension ARKitCameraViewController {
    func displayErrorMessage(title: String, message: String) {
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
