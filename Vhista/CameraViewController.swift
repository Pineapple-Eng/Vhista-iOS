//
//  ViewController.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/1/17.
//  Copyright © 2017 juandavidcruz. All rights reserved.
//

import UIKit
import AVFoundation

import AWSCore
import AWSRekognition

import AFNetworking
import Firebase
import StoreKit

import Vision

class CameraViewController: UIViewController {

    // MARK: - Parameters

    //UIElements
    @IBOutlet weak var userInterfaceView: UIView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var vhistaLogoButton: UIButton!
    @IBOutlet weak var pickerContainerView: UIView!
    @IBOutlet weak var textHistoryPicker: UIPickerView!
    @IBOutlet weak var loveTextField: UILabel!
    @IBOutlet weak var deepAnalysisButton: UIButton!
    @IBOutlet weak var upgradeButtonItem: UIBarButtonItem!

    let shapeLayer = CAShapeLayer()

    //Camera & Recognition
    let captureSession = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer!
    var detectFaceLandmarkRequest: VNDetectFaceLandmarksRequest!
    let captureQueue = DispatchQueue(label: "captureQueue")
    var gradientLayer: CAGradientLayer!
    var visionRequests = [VNRequest]()

    //Rekognition variables
    var stillImageOutput: AVCapturePhotoOutput = AVCapturePhotoOutput()
    var selectedImage: UIImage!
    @IBOutlet weak var selectedImageView: UIImageView!

    // MARK: - ViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCamera()
        setUpUI()
        VhistaSpeechManager.shared.parentController = self
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

        if UIDevice.current.orientation == .landscapeLeft {
            videoLayer!.connection?.videoOrientation = .landscapeRight
        } else if UIDevice.current.orientation == .landscapeRight {
            videoLayer!.connection?.videoOrientation = .landscapeLeft
        } else if UIDevice.current.orientation == .portraitUpsideDown {
            videoLayer!.connection?.videoOrientation = .portraitUpsideDown
        } else {
            videoLayer!.connection?.videoOrientation = .portrait
        }

        shapeLayer.strokeColor = UIColor.red.cgColor
        shapeLayer.lineWidth = 2.0
        //needs to filp coordinate system for Vision
        shapeLayer.setAffineTransform(CGAffineTransform(scaleX: -1, y: -1))
        shapeLayer.frame = view.frame
        view.layer.addSublayer(shapeLayer)
        UIApplication.shared.statusBarStyle = .lightContent
    }

    func setUpUI() {

        textHistoryPicker.delegate = self
        textHistoryPicker.dataSource = self
        textHistoryPicker.isAccessibilityElement = false
        textHistoryPicker.isUserInteractionEnabled = false
        textHistoryPicker.accessibilityTraits = UIAccessibilityTraits.none
        textHistoryPicker.showsSelectionIndicator = false

        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.pickerContainerView.frame
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        let rigthAnchor = NSLayoutConstraint(item: blurEffectView,
                                             attribute: .trailing,
                                             relatedBy: .equal,
                                             toItem: self.view,
                                             attribute: .trailing,
                                             multiplier: 1,
                                             constant: 0)
        let leftAnchor = NSLayoutConstraint(item: blurEffectView,
                                            attribute: .leading,
                                            relatedBy: .equal,
                                            toItem: self.view,
                                            attribute: .leading,
                                            multiplier: 1,
                                            constant: 0)
        let heightAnchor = NSLayoutConstraint(item: blurEffectView,
                                              attribute: .height,
                                              relatedBy: .equal,
                                              toItem: nil,
                                              attribute: .height,
                                              multiplier: 1,
                                              constant: 240)
        let bottomAnchor = NSLayoutConstraint(item: blurEffectView,
                                              attribute: .bottom,
                                              relatedBy: .equal,
                                              toItem: self.view,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 0)

        self.view.insertSubview(blurEffectView, at: 1)

        NSLayoutConstraint.activate([rigthAnchor, leftAnchor, heightAnchor, bottomAnchor])

        loveTextField.isAccessibilityElement = false

        SwiftSpinner.useContainerView(userInterfaceView)

        if SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            upgradeButtonItem.title = NSLocalizedString("Show_Subscription_Button_Title", comment: "")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        videoLayer.frame = self.cameraView.bounds
        shapeLayer.frame = view.frame

        if let connection =  self.videoLayer?.connection {

            let currentDevice: UIDevice = UIDevice.current

            let orientation: UIDeviceOrientation = currentDevice.orientation

            let previewLayerConnection: AVCaptureConnection = connection

            if previewLayerConnection.isVideoOrientationSupported {
                switch orientation {
                case .portrait:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                case .landscapeRight:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                case .landscapeLeft:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                case .portraitUpsideDown:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                default:
                    updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                }
            }
        }
    }

    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        layer.videoPreviewLayer?.videoGravity = .resizeAspectFill
        cameraView.frame = self.view.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        VhistaSpeechManager.shared.stopSpeech(sender: self)
        VhistaSpeechManager.shared.blockAllSpeech = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - IBActions

    @IBAction func makeDeepAnalysis(_ sender: Any) {

        if !checkCameraPermissions() {
            return
        }

        switch VhistaReachabilityManager.shared.networkStatus {
        case .notReachable, .unknown:
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
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
            return
        }

        processingImage = true
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        if stillImageOutput.connection(with: AVMediaType.video) != nil {

            let settings = AVCapturePhotoSettings()
            //            let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
            //            let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
            //                                 kCVPixelBufferWidthKey as String: 160,
            //                                 kCVPixelBufferHeightKey as String: 160]
            //            settings.previewPhotoFormat = previewFormat
            let deviceDescoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                                          mediaType: AVMediaType.video,
                                                                          position: .back)
            for device in deviceDescoverySession.devices {
                if device.hasFlash {
                    settings.flashMode = .auto
                } else {
                    settings.flashMode = .off
                }
            }

            settings.isAutoStillImageStabilizationEnabled = true
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
    }

    @IBAction func hitUpgradeAction(_ sender: Any) {
        if !SubscriptionManager.shared.isUserSubscribedToFullAccess() {
            self.performSegue(withIdentifier: "ShowUpgradeView", sender: nil)
        } else {
            self.performSegue(withIdentifier: "ShowSubscriptionInfo", sender: nil)
        }
    }
}

// MARK: - Labels UIPickerView
extension CameraViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return ClassificationsManager.shared.recognitionsAsText.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let label = (view as? UILabel) ?? UILabel()

        label.accessibilityLabel = NSLocalizedString("LAST_RECOGNITION", comment: "") + ClassificationsManager.shared.recognitionsAsText[row]

        label.textColor = UIColor.white
        label.textAlignment = .center
        label.contentMode = UIView.ContentMode.center
        label.font = UIFont.boldSystemFont(ofSize: 50)
        label.attributedText =  NSAttributedString(string: ClassificationsManager.shared.recognitionsAsText[row],
                                                   attributes: [NSAttributedString.Key.strokeWidth: -3.0,
                                                                NSAttributedString.Key.strokeColor: UIColor(white: 0.0, alpha: 0.9)])

        label.adjustsFontSizeToFitWidth = true

        return label
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
}

// MARK: - Camera Configuration
extension CameraViewController {

    func setUpCamera() {

        guard let camera = AVCaptureDevice.default(for: .video) else {
            print("No video camera available")
            VhistaSpeechManager.shared.sayText(stringToSpeak: NSLocalizedString("No_Camera",
                                                                                comment: "Let the user know there is no camera in the device"),
                                               isProtected: true,
                                               rate: Float(0.6))
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            return
        }

        do {
            videoLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraView.layer.addSublayer(videoLayer)

            print(cameraView.frame)

            let input = try AVCaptureDeviceInput(device: camera)

            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: captureQueue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
            captureSession.sessionPreset = .high

            captureSession.addInput(input)
            captureSession.addOutput(videoOutput)

            let connection = videoOutput.connection(with: .video)
            connection?.videoOrientation = .portrait

            captureSession.addOutput(stillImageOutput)

            captureSession.startRunning()

            setUpModels()
//            setUpVisionFaces()
            setUpVisionLandMarks()
//            setUpOCR()

        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Configure Models and Vision
extension CameraViewController {
    func setUpModels() {
        //Inception V3 Object Model
        guard let inceptionV3Model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            print("Error loading InceptionV3")
            return
        }

        let classificationRequestInceptionV3 = VNCoreMLRequest(model: inceptionV3Model, completionHandler: handleClassificationsInceptionV3)
        classificationRequestInceptionV3.imageCropAndScaleOption = VNImageCropAndScaleOption.init(rawValue: 0)!

        visionRequests.append(classificationRequestInceptionV3)
    }

    func setUpVisionLandMarks() {
        detectFaceLandmarkRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceLandmarks)
        visionRequests.append(detectFaceLandmarkRequest)
    }

    func setUpOCR() {
        let textRectsRequest = VNDetectTextRectanglesRequest(completionHandler: handleOCR)
        textRectsRequest.reportCharacterBoxes = true
        visionRequests.append(textRectsRequest)
    }
}

// MARK: - Handle Capture Classifications
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        connection.videoOrientation = .portrait

        var requestOptions: [VNImageOption: Any] = [:]

        if let cameraIntrinsicData = CMGetAttachment(sampleBuffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
            requestOptions = [.cameraIntrinsics: cameraIntrinsicData]
        }

        // for orientation see kCGImagePropertyOrientation
        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                                        orientation: CGImagePropertyOrientation(rawValue: 1)!,
                                                        options: requestOptions)

        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }

    func handleClassificationsInceptionV3(request: VNRequest, error: Error?) {

        if processingImage { return }

        if let theError = error {
            print("Error: \(theError.localizedDescription)")
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }

        let classifications = observations[0...1] // top item.
            .compactMap({ $0 as? VNClassificationObservation })
            .compactMap({$0.confidence > inceptionV3RecognitionThreshold ? $0 : nil})
            .map({ "\($0.identifier)" })
            .joined(separator: "\n")

        DispatchQueue.main.async {
            if !classifications.isEmpty {
                self.addStringToRead(stringRecognized: classifications, isProtected: false)
            }
        }
    }

    func handleFaceLandmarks(request: VNRequest, error: Error?) {
        if processingImage { return }
        if let landmarksResults = request.results as? [VNFaceObservation] {
            let resultText = ClassificationsManager.shared.addPeopleToRead(faceObservations: landmarksResults)
            if resultText != "" {
                self.addStringToReadFace(stringRecognized: resultText, isProtected: false)
            }
        }
    }

    func handleOCR (request: VNRequest, error: Error?) {
        if processingImage { return }
        if let results = request.results as? [VNTextObservation] {
            for _ in results {
//                print("boundingBox \(result.boundingBox)")
//                print("characterBoxes \(result.characterBoxes)")
            }
        }
    }

}

// MARK: - Handle Reading of Identified Labels
extension CameraViewController {

    func addStringToRead(stringRecognized: String, isProtected: Bool) {

        if !ClassificationsManager.shared.allowStringRecognized(stringRecognized: stringRecognized) { return }

        let stringRecognizedTranslated = translateModelString(pString: stringRecognized, targetLanguage: globalLanguage)

        ClassificationsManager.shared.lastRecognition = stringRecognized
        ClassificationsManager.shared.recognitionsAsText.insert(stringRecognizedTranslated, at: 0)
        if ClassificationsManager.shared.recognitionsAsText.count == 3 {
            ClassificationsManager.shared.recognitionsAsText.remove(at: 2)
        }
        DispatchQueue.main.async {
            self.textHistoryPicker.reloadAllComponents()
        }

        VhistaSpeechManager.shared.sayText(stringToSpeak: stringRecognizedTranslated, isProtected: isProtected, rate: Float(globalRate))
    }

    func addStringToReadFace(stringRecognized: String, isProtected: Bool) {

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

// MARK: - After Taken Picture Methods
extension CameraViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        selectedImage = UIImage(cgImage: (photo.cgImageRepresentation()?.takeUnretainedValue())!, scale: 1.0, orientation: UIImage.Orientation.right)
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
