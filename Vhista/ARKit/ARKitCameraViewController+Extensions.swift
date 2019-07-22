import ARKit
import Vision

extension ARKitCameraViewController {
    func arCameraViewDidAppear() {
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

    func setUpSceneView() {
        previousFrameTimeInterval = Date().timeIntervalSince1970

        sceneView = ARSCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)
        self.view.sendSubviewToBack(sceneView)
        setUpARCameraViewSceneConstraints()

        sceneView.delegate = self
        sceneView.debugOptions = [SCNDebugOptions.showFeaturePoints]
        sceneView.session.delegate = self
        sceneView.showsStatistics = false

        let arScene = SCNScene()
        sceneView.scene = arScene
    }
}

extension ARKitCameraViewController {
    func processARImageAnalysis() {
        if let currentImage = UIImage(pixelBuffer: self.persistentPixelBuffer!) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            processingImage = true
            self.setImageForRecognition(image: currentImage)
            self.startContextualRecognition()
        }
    }
}

extension ARKitCameraViewController: ARSessionDelegate {

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

    func restartSession() {
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

    // Run the Vision+ML classifier on the current image buffer.
    /// - Tag: ClassifyCurrentImage
    private func classifyCurrentImage() {
        if currentBuffer == nil {
            return
        }
        // Most computer vision tasks are not rotation agnostic so it is important to pass in the orientation of the image with respect to device.
        let orientation = CGImagePropertyOrientation(UIDevice.current.orientation)
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: currentBuffer!, orientation: orientation)
        runVisionQueueWithRequestHandler(requestHandler)
    }
}

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
