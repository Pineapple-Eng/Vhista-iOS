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

class ARKitCameraViewController: UIViewController, UIGestureRecognizerDelegate, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var pickerContainerView: UIView!
    
    @IBOutlet weak var textHistoryPicker: UIPickerView!
    
    @IBOutlet weak var loveTextField: UILabel!
    
    @IBOutlet weak var deepAnalysisButton: UIButton!
    
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
//        VhistaSpeechManager.shared.sayGreetingMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        textHistoryPicker.delegate = self
        textHistoryPicker.dataSource = self
        textHistoryPicker.isAccessibilityElement = false
        textHistoryPicker.isUserInteractionEnabled = false
        textHistoryPicker.accessibilityTraits = UIAccessibilityTraitNone
        textHistoryPicker.showsSelectionIndicator = false
        textHistoryPicker.shouldGroupAccessibilityChildren = false
        
        loveTextField.isAccessibilityElement = false
        
    }
    
    func setUpSceneView() {
        
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.session.delegate = self
        sceneView.showsStatistics = false
        let arScene = SCNScene()
        sceneView.scene = arScene
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let blurEffect = UIBlurEffect(style: .dark)
        let pickerVisualEffectView = UIVisualEffectView(effect: blurEffect)
        pickerVisualEffectView.frame = self.pickerContainerView.frame
        pickerVisualEffectView.tag = 99
        for view in self.view.subviews {
            if view.tag == 99 {
                view.removeFromSuperview()
            }
        }
        
        pickerVisualEffectView.translatesAutoresizingMaskIntoConstraints = false
        let rigthAnchor = NSLayoutConstraint(item: pickerVisualEffectView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let leftAnchor = NSLayoutConstraint(item: pickerVisualEffectView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let heightAnchor = NSLayoutConstraint(item: pickerVisualEffectView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 240)
        let bottomAnchor = NSLayoutConstraint(item: pickerVisualEffectView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.view.insertSubview(pickerVisualEffectView, at: 1)
        
        NSLayoutConstraint.activate([rigthAnchor, leftAnchor, heightAnchor, bottomAnchor])
        
        self.view.bringSubview(toFront: deepAnalysisButton)
    }
    
    @IBAction func hitUpgradeAction(_ sender: Any) {
        if !SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
        } else {
            self.performSegue(withIdentifier: "ShowSubscriptionInfo", sender: nil)
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
        
        switch VhistaReachabilityManager.shared.networkStatus {
        case .notReachable:
            VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("Not_Reachable", comment: "Let the user know there is no internet access"), isProtected: true, rate: globalRate)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        case .unknown:
            VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("Not_Reachable", comment: "Let the user know there is no internet access"), isProtected: true, rate: globalRate)
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        case .reachableViaWWAN:
            print("Network OK")
        case .reachableViaWiFi:
            print("Network OK")
        }
        
        guard self.persistentPixelBuffer != nil else {
            print("No Buffer \(String(describing: self.persistentPixelBuffer))")
            return
        }
        
        if !SubscriptionManager.shared.checkDeepSubscription() {
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
            return
        }
        
        if let currentImage = UIImage(pixelBuffer: self.persistentPixelBuffer!) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            processingImage = true
            setImageForRekognition(image: currentImage)
        }
        
    }
    
    // MARK: - ARSessionDelegate
    
    // Pass camera frames received from ARKit to Vision (when not already processing one)
    /// - Tag: ConsumeARFrames
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // Do not enqueue other buffers for processing while another Vision task is still running.
        // The camera stream has only a finite amount of buffers available; holding too many buffers for analysis would starve the camera.
        
        self.persistentPixelBuffer = frame.capturedImage
        
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }
        
        let frameTimestamp = Date().timeIntervalSince1970
        if (previousFrameTimeInterval.advanced(by: frameRateInterval) >= frameTimestamp) {
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
        let classifications = results as! [VNClassificationObservation]
        
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
        case .notAvailable, .limited: break;
        case .normal: break;
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
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
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

// MARK: - Labels UIPickerView
extension ARKitCameraViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ClassificationsManager.shared.recognitionsAsText.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = (view as? UILabel) ?? UILabel()
        
        label.isAccessibilityElement = false
        label.isUserInteractionEnabled = false
        label.accessibilityTraits = UIAccessibilityTraitNone
        
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.contentMode = UIViewContentMode.center
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.attributedText =  NSAttributedString(string: ClassificationsManager.shared.recognitionsAsText[row], attributes: [NSAttributedStringKey.strokeWidth:-3.0, NSAttributedStringKey.strokeColor: UIColor(white: 0.0, alpha: 0.9)])
        
        label.adjustsFontSizeToFitWidth = true
        
        return label
        
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
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
    
    func addStringToRead(_ stringRecognized:String, _ distanceString:String, isProtected: Bool) {
        
        if !ClassificationsManager.shared.allowStringRecognized(stringRecognized: stringRecognized) { return }
        print(distanceString)
        let stringRecognizedTranslated = translateModelString(pString: stringRecognized, targetLanguage: global_language)
        
        ClassificationsManager.shared.lastRecognition = stringRecognized
        ClassificationsManager.shared.recognitionsAsText.insert(stringRecognizedTranslated, at: 0)
        if ClassificationsManager.shared.recognitionsAsText.count == 3 {
            ClassificationsManager.shared.recognitionsAsText.remove(at: 2)
        }
        DispatchQueue.main.async {
            self.textHistoryPicker.reloadAllComponents()
        }
        
        VhistaSpeechManager.shared.sayText(stringToSpeak: stringRecognizedTranslated + distanceString, isProtected: isProtected, rate: Float(globalRate))
        
    }
    
    func addStringToReadFace(stringRecognized:String, isProtected: Bool) {
        
        ClassificationsManager.shared.lastRecognition = stringRecognized
        ClassificationsManager.shared.recognitionsAsText.insert(stringRecognized, at: 0)
        if ClassificationsManager.shared.recognitionsAsText.count == 3 {
            ClassificationsManager.shared.recognitionsAsText.removeLast()
        }
        DispatchQueue.main.async {
            self.textHistoryPicker.reloadAllComponents()
        }
        
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
            planeNode.eulerAngles = SCNVector3(-Float.pi/2,0,0)
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
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.restartSession()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
}


extension ARKitCameraViewController {
    
    func setImageForRekognition(image: UIImage) {
        selectedImage = image
        RekognitionManager.shared.startProcessing(_sender: selectedImage)
        showSelectedImage()
    }
    
    func showSelectedImage() {
        let currentDevice: UIDevice = UIDevice.current
        let orientation: UIDeviceOrientation = currentDevice.orientation
        
        switch (orientation) {
            case .portrait: selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .right)
                break
            case .landscapeRight: selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .down)
                break
            case .landscapeLeft: selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .up)
                break
            case .portraitUpsideDown: selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .left)
                break
            default: selectedImage = UIImage(cgImage: selectedImage.cgImage!, scale: 1.0, orientation: .right)
                break
        }
        
        
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

