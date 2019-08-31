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
UIGestureRecognizerDelegate,
VHBottomNavigationToolbarDelegate,
VHCameraButtonDelegate {

    // Features Collection View
    var featuresCollectionContentView: FeaturesCarouselContainerView!
    var featuresCollectionVC: FeaturesCollectionViewController!

    // Fast Recognized Content View
    var fastRecognizedContentViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var fastRecognizedContentView: UIView!
    var fastRecognizedContentViewController: FastRecognizedContentViewController?

    // Shutter Action Button
    var shutterButtonView: CameraShutterButtonView!

    var bottomToolbarViewBottomAnchorContraint: NSLayoutConstraint!
    var bottomToolbar: VHBottomNavigationToolbar!

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
    var arConfiguration = ARWorldTrackingConfiguration()
    var previousFrameTimeInterval: TimeInterval!
    //Still Image
    var persistentPixelBuffer: CVPixelBuffer?
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    var currentBuffer: CVPixelBuffer?
    // -- / AR Camera --

    // Queue for dispatching vision classification requests
    private let visionQueue = DispatchQueue(label: "com.juandavidcruz.Vhista.ARKitVision.serialVisionQueue")

    // Selected ImageView
    var selectedImage: VHImage!
    var selectedImageView: UIImageView!
    var selectedImageViewOverlay: UIView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpAccessibility()
        if arEnabled {
            setUpSceneView()
        } else {
            setUpCamera()
        }
        VhistaSpeechManager.shared.parentARController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bottomToolbar.setUpItems(showSubscriptionButton: true,
                                 isSubscribed: SubscriptionManager.shared.isUserSubscribedToFullAccess())
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeCurrentSession()
    }

    func setUpUI() {
        // Features View
        featuresCollectionContentView = FeaturesCarouselContainerView(frame: .zero)
        self.view.addSubview(featuresCollectionContentView)
        featuresCollectionVC = FeaturesCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        featuresCollectionContentView.collectionViewController = featuresCollectionVC
        addChild(featuresCollectionVC)
        featuresCollectionContentView.addSubview(featuresCollectionVC.view)
        featuresCollectionVC.didMove(toParent: self)
        featuresCollectionVC.setUpCollectionView()
        // Bottom Toolbar
        bottomToolbar = VHBottomNavigationToolbar(frame: .zero)
        bottomToolbar.customDelegate = self
        self.view.addSubview(bottomToolbar)
        // Shutter View
        shutterButtonView = CameraShutterButtonView(frame: .zero)
        shutterButtonView.buttonDelegate = self
        self.view.addSubview(shutterButtonView)
        // Selected ImageView
        selectedImageView = UIImageView(frame: .zero)
        selectedImageView.isHidden = true
        selectedImageView.contentMode = .scaleAspectFill
        self.view.addSubview(selectedImageView)
        selectedImageViewOverlay = UIView(frame: .zero)
        selectedImageViewOverlay.isHidden = true
        selectedImageViewOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.view.addSubview(selectedImageViewOverlay)
        // Constraints
        setUpUIConstraints()
    }

    override func viewDidLayoutSubviews() {
        self.view.bringSubviewToFront(shutterButtonView)
        fastRecognizedContentView.translatesAutoresizingMaskIntoConstraints = false
        if !arEnabled {
            updateNonARCameraConnectionOrientationAndFrame()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRecognizedContentView" {
            fastRecognizedContentViewController = segue.destination as? FastRecognizedContentViewController
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseCurrentSession()
    }

    func makeDeepAnalysis(_ sender: Any) {
        self.updateUIForDeepAnalysisChange(willAnalyze: true)
        if !checkCameraPermissions() {
            self.updateUIForDeepAnalysisChange(willAnalyze: false)
            return
        }

        guard self.persistentPixelBuffer != nil else {
            print("No Buffer \(String(describing: self.persistentPixelBuffer))")
            self.updateUIForDeepAnalysisChange(willAnalyze: false)
            return
        }

        self.deepAnalysisPreChecks { (allowed) in
            if allowed {
                if arEnabled {
                    self.processARImageAnalysis()
                } else {
                    self.processNonARImageAnalysis()
                }
            }
        }
    }

    func deepAnalysisPreChecks(completion: @escaping (_ allowed: Bool) -> Void) {
        ConfigurationManager.shared.serverAllowsRecognition({ (allowed) in
            if allowed {
                guard VhistaReachabilityManager.shared.validInternetConnection() else {
                    self.updateUIForDeepAnalysisChange(willAnalyze: false)
                    VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("Not_Reachable",
                                                                                        comment: "Let the user know there is no internet access"),
                                                       isProtected: true,
                                                       rate: globalRate)
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                    completion(false)
                    return
                }
                if !SubscriptionManager.shared.checkDeepSubscription() {
                    self.updateUIForDeepAnalysisChange(willAnalyze: false)
                    self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
                    completion(false)
                    return
                }
                completion(true)
                return
            } else {
                self.updateUIForDeepAnalysisChange(willAnalyze: false)
                self.showErrorAlertView(title: NSLocalizedString("Deep_Analysis_Deactivated_Title", comment: ""),
                                        message: NSLocalizedString("Deep_Analysis_Deactivated_Message", comment: ""))
                completion(false)
                return
            }
        })
    }

    func hitUpgradeAction(_ sender: Any) {
        if !SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
        } else {
            self.performSegue(withIdentifier: "ShowSubscriptionInfo", sender: nil)
        }
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
            // request.usesCPUOnly = true
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
                defer { self.currentBuffer = nil }
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

extension ARKitCameraViewController {
    func setImageForRecognition(image: UIImage, source: String) {
        var rawImage = image
        if source == VHImageSource.camera {
            rawImage = image.adjustImageRotation()
        }
        selectedImage = VHImage(image: rawImage, withSource: source)
        showSelectedImage()
    }

    func showSelectedImage() {
        DispatchQueue.main.async {
            self.selectedImageView.image = self.selectedImage.getUIImage()
            self.selectedImageView.isHidden = false
            self.selectedImageViewOverlay.isHidden = false
        }
    }

    func finishedRekognitionAnalisis() {
        print("🏁 Finished Rekognition Analysis")
        updateUIForDeepAnalysisChange(willAnalyze: false)
    }
}

// MARK: - Shutter Button Delegate
extension ARKitCameraViewController {
    func didChangeCameraButtonSelection(_ button: VHCameraButton, _ selected: Bool) {
        if selected && !processingImage {
            makeDeepAnalysis(button)
        }
    }
}

// MARK: - Bottom Toolbar Delegate
extension ARKitCameraViewController {
    func didSelectBarButtonItemWithType(_ barButtonItem: UIBarButtonItem, _ type: VHBottomNavigationToolbarItemType) {
        switch type {
        case .gallery:
            showPhotoPicker(barButtonItem)
        case .subscription, .upgrade:
            hitUpgradeAction(barButtonItem)
        case .info:
            showInfoVC(barButtonItem)
        }
    }
}

// MARK: - View Handling
extension ARKitCameraViewController {
    func updateUIForDeepAnalysisChange(willAnalyze: Bool) {
        toggleBottomAndRecognizedContentViewsVisibility(hide: willAnalyze)
        processingImage = willAnalyze
        if willAnalyze {
            pauseCurrentSession()
            VhistaSoundManager.shared.playLoadingSound()
            shutterButtonView.showLoadingRippleView(parentView: self.view)
        } else {
            resumeCurrentSession()
            shutterButtonView.shutterButton.reset()
            DispatchQueue.main.async {
                self.selectedImageView.isHidden = true
                self.selectedImageViewOverlay.isHidden = true
                self.selectedImageView.image = nil
            }
            selectedImage = nil
            VhistaSoundManager.shared.pauseLoadingSound()
            shutterButtonView.stopLoadingRippleView(parentView: self.view)
        }
    }
}

// MARK: - Info View
extension ARKitCameraViewController {
    func showInfoVC(_ sender: Any) {
        let infoVC = InfoViewController()
        pauseCurrentSession()
        self.present(infoVC, animated: true, completion: nil)
    }
}
