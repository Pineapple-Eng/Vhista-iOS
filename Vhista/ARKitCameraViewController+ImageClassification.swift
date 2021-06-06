// Created by Juan David Cruz Serrano on 5/31/20. Copyright © 2020 juandavidcruz. All rights reserved.

import UIKit
import Vision

extension ARKitCameraViewController {
    func runVisionQueueWithRequestHandler(_ requestHandler: VNImageRequestHandler) {
        visionQueue.async {
            do {
                // Release the pixel buffer when done, allowing the next buffer to be processed.
                defer { self.currentBuffer = nil }
                var requests = [VNRequest]()
                switch FeaturesManager.shared.getSelectedFeature().featureName {
                case FeatureNames.contextual:
                    requests = [
                        self.classificationRequest,
                        self.facesClassificationRequest
                    ]
                case FeatureNames.text:
					requests = [
						self.textClassificationRequest
					]
                default:
                    break
                }
                try requestHandler.perform(requests)
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
    func displayClassifierResults(_ result: String,
                                  confidence: VNConfidence,
                                  isProtected: Bool = false,
                                  calculateDistance: Bool = true) {
        guard !result.isEmpty else {
            return // No object was classified.
        }
        let message = String(format: "Detected \(result) with %.2f", confidence * 100) + "% confidence"
        print(message)

		if calculateDistance {
			let hitTestResults = sceneView.hitTest(sceneView.center, types: .featurePoint)
			guard let hitTestResult = hitTestResults.first else {
				addStringToRead(result, "", isProtected: isProtected, confidence: Double(confidence * 100))
				return
			}
			addStringToRead(result,
							getLocalizedStringForDistance(hitTestResult.distance),
							isProtected: isProtected,
							confidence: Double(confidence * 100))
		} else {
			addStringToRead(result,
							"",
							isProtected: isProtected,
							confidence: Double(confidence * 100))
		}
    }
}
