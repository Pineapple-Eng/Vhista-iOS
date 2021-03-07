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
    var fastRecognizedContentView: UIView!
    var fastRecognizedContentViewController: FastRecognizedContentViewController?

    // Shutter Action Button
    var shutterButtonView: CameraShutterButtonView!

    var bottomToolbarViewBottomAnchorContraint: NSLayoutConstraint!
    var bottomToolbar: VHBottomNavigationToolbar!

    // -- Non AR Camera --
    var captureSession: AVCaptureSession!
    var videoLayer: AVCaptureVideoPreviewLayer!
    var cameraView: UIView!
    var stillImageOutput: AVCapturePhotoOutput!
    var shapeLayer: CAShapeLayer!
    // -- / Non AR Camera --

    // -- AR Camera --
    var sceneView: ARSCNView!
    var arConfiguration = ARWorldTrackingConfiguration()
    var previousFrameTimeInterval: TimeInterval!
    // Still Image
    var persistentPixelBuffer: CVPixelBuffer?
    // The pixel buffer being held for analysis; used to serialize Vision requests.
    var currentBuffer: CVPixelBuffer?
    // -- / AR Camera --

    // Queue for dispatching vision classification requests
    let visionQueue = DispatchQueue(label: "com.juandavidcruz.Vhista.ARKitVision.serialVisionQueue")

    // Selected ImageView
    var selectedImage: VHImage?
    var selectedImageView: UIImageView!
    var selectedImageViewOverlay: UIView!

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpAccessibility()
        setUpSceneView()
        VhistaSpeechManager.shared.parentARController = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpObservers()
        bottomToolbar.setUpItems()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumeCurrentSession()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func setUpObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeFeature(_:)),
                                               name: FeaturesManager.ChangedFeature,
                                               object: nil)
    }

    func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: FeaturesManager.ChangedFeature,
                                                  object: nil)
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

        // Fast Recognition
        fastRecognizedContentView = UIView(frame: .zero)
        self.view.addSubview(fastRecognizedContentView)
        fastRecognizedContentViewController = FastRecognizedContentViewController()
        addChild(fastRecognizedContentViewController!)
        fastRecognizedContentView.addSubview(fastRecognizedContentViewController!.view)
        fastRecognizedContentViewController?.didMove(toParent: self)

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

        setUpUIConstraints()
        setUpAccessibility()
    }

    override func viewDidLayoutSubviews() {
        self.view.bringSubviewToFront(shutterButtonView)
        fastRecognizedContentView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseCurrentSession()
        removeObservers()
    }

    func makeDeepAnalysis(_ sender: Any) {
        self.updateUIForDeepAnalysisChange(willAnalyze: true)
        if !checkCameraPermissions() {
            self.updateUIForDeepAnalysisChange(willAnalyze: false)
            return
        }

        if arEnabled {
            guard self.persistentPixelBuffer != nil else {
                print("No Buffer \(String(describing: self.persistentPixelBuffer))")
                self.updateUIForDeepAnalysisChange(willAnalyze: false)
                return
            }
        }

        self.deepAnalysisPreChecks { (allowed) in
            if allowed {
                self.processARImageAnalysis()
            }
        }
    }

    func stopDeepAnalysis(_ sender: Any) {
        ComputerVisionManager.shared.stopComputerVisionRequest()
        self.updateUIForDeepAnalysisChange(willAnalyze: false)
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

    // MARK: - Vision classification
    // Vision classification request and model
    /// - Tag: ClassificationRequest
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            // Instantiate the model from its generated Swift class.
            let modelConfiguration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: Inceptionv3(configuration: modelConfiguration).model)
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

    lazy var facesClassificationRequest: VNDetectFaceRectanglesRequest = {
        return VNDetectFaceRectanglesRequest(completionHandler: self.handleFaceLandmarks)
    }()

    @available(iOS 13.0, *)
    lazy var textClassificationRequest: VNRecognizeTextRequest = {
        return VNRecognizeTextRequest(completionHandler: self.handleText)
    }()
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
            guard let image = self.selectedImage?.getUIImage() else {
                self.updateUIForDeepAnalysisChange(willAnalyze: false)
                return
            }
            self.selectedImageView.image = image
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
        } else {
            stopDeepAnalysis(button)
        }
    }
}

// MARK: - Bottom Toolbar Delegate
extension ARKitCameraViewController {
    func didSelectBarButtonItemWithType(_ barButtonItem: UIBarButtonItem, _ type: VHBottomNavigationToolbarItemType) {
        switch type {
        case .gallery:
            showPhotoPicker(barButtonItem)
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
        infoVC.delegate = self
        pauseCurrentSession()
        self.present(infoVC, animated: true, completion: nil)
    }
}

// MARK: - Changed Feature
extension ARKitCameraViewController {
    @objc func didChangeFeature(_ notification: Notification) {
        configureViewForCurrentFeature()
    }

    func configureViewForCurrentFeature() {
        switch FeaturesManager.shared.getSelectedFeature().featureName {
        case FeatureNames.contextual:
            print("Changing to Image Recognition")
        case FeatureNames.text:
            print("Changing to Text Recognition")
        default:
            return
        }
        setUpAccessibility()
    }
}
