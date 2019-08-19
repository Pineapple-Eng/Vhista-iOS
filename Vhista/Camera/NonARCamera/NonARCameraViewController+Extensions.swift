//
//  NonARCameraViewController+Extensions.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 6/23/19.
//  Copyright © Juan David Cruz Serrano & Vhista Inc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Vision

// MARK: - Camera Configuration
extension ARKitCameraViewController {
    func setUpCamera() {
        cameraView = UIView(frame: self.view.bounds)
        self.view.addSubview(cameraView)
        self.view.sendSubviewToBack(cameraView)
        setUpNonARCameraViewConstraints()

        captureSession = AVCaptureSession()
        captureQueue = DispatchQueue(label: "captureQueue")
        stillImageOutput = AVCapturePhotoOutput()
        shapeLayer = CAShapeLayer()

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
        } catch {
            print(error.localizedDescription)
        }
    }

    func updateNonARCameraConnectionOrientationAndFrame() {
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

    func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        layer.videoOrientation = orientation
        layer.videoPreviewLayer?.videoGravity = .resizeAspectFill
        cameraView.frame = self.view.bounds
    }

    func nonARCameraViewDidAppear() {
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
    }
}

extension ARKitCameraViewController {
    func processNonARImageAnalysis() {
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
}

// MARK: - After Taken Picture Methods
extension ARKitCameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            print(error!.localizedDescription)
            return
        }
        selectedImage = UIImage(cgImage: (photo.cgImageRepresentation()?.takeUnretainedValue())!, scale: 1.0, orientation: UIImage.Orientation.right)
        startContextualRecognition()
        showSelectedImage()
    }
}

// MARK: - Handle Capture Classifications
extension ARKitCameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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
        runVisionQueueWithRequestHandler(imageRequestHandler)
    }
}
