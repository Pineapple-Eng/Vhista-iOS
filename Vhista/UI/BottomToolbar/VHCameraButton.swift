//
//  VHCameraButton.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 8/18/19.
//  Copyright © 2019 juandavidcruz. All rights reserved.
//

import Foundation
import UIKit

protocol VHCameraButtonDelegate: AnyObject {
    func didChangeCameraButtonSelection(_ button: VHCameraButton, _ selected: Bool)
}

class VHCameraButton: UIButton {

    var pathLayer: CAShapeLayer!
    let animationDuration = 0.1

    weak var buttonDelegate: VHCameraButtonDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUp()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setUp()
    }

    func setUp() {
        //add a shape layer for the inner shape to be able to animate it
        self.pathLayer = CAShapeLayer()

        //show the right shape for the current state of the control
        self.pathLayer.path = self.currentInnerPath().cgPath

        //don't use a stroke color, which would give a ring around the inner circle
        self.pathLayer.strokeColor = nil

        //set the color for the inner shape
        self.pathLayer.fillColor = UIColor.white.cgColor

        //add the path layer to the control layer so it gets drawn
        self.layer.addSublayer(self.pathLayer)

        self.setTitle("", for: UIControl.State.normal)

        self.addTarget(self, action: #selector(touchUpInside), for: UIControl.Event.touchUpInside)
        self.addTarget(self, action: #selector(touchDown), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(touchUpOutside), for: UIControl.Event.touchUpOutside)
    }

    override var isSelected: Bool {
        didSet {
            //change the inner shape to match the state
            let morph = CABasicAnimation(keyPath: "path")
            morph.duration = animationDuration
            morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

            //change the shape according to the current state of the control
            morph.toValue = self.currentInnerPath().cgPath

            //ensure the animation is not reverted once completed
            morph.fillMode = CAMediaTimingFillMode.forwards
            morph.isRemovedOnCompletion = false

            //add the animation
            self.pathLayer.add(morph, forKey: "")

            self.buttonDelegate?.didChangeCameraButtonSelection(self, self.isSelected)
        }
    }

    @objc func touchUpInside(sender: UIButton) {
        resetColor()
        //change the state of the control to update the shape
        self.isSelected = !self.isSelected
    }

    @objc func touchUpOutside(sender: UIButton) {
        resetColor()
    }

    @objc func touchDown(sender: UIButton) {
        //when the user touches the button, the inner shape should change transparency
        //create the animation for the fill color
        let morph = CABasicAnimation(keyPath: "fillColor")
        morph.duration = animationDuration

        //set the value we want to animate to
        morph.toValue = self.pathLayer.fillColor?.copy(alpha: 0.5)

        //ensure the animation does not get reverted once completed
        morph.fillMode = CAMediaTimingFillMode.forwards
        morph.isRemovedOnCompletion = false

        morph.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.pathLayer.add(morph, forKey: "")
    }

    override func draw(_ rect: CGRect) {
        //always draw the outer ring, the inner control is drawn during the animations
        let outerRing = UIBezierPath(ovalIn: CGRect(x: 3, y: 3, width: 60, height: 60))
        outerRing.lineWidth = 6
        if #available(iOS 13.0, *) {
            UIColor.label.setStroke()
        } else {
            UIColor.white.setStroke()
        }
        outerRing.stroke()
    }

    func reset() {
        resetColor()
        //change the state of the control to update the shape
        self.isSelected = !self.isSelected
    }

    func resetColor() {
        //Create the animation to restore the color of the button
        let colorChange = CABasicAnimation(keyPath: "fillColor")
        colorChange.duration = animationDuration
        colorChange.toValue = UIColor.white.cgColor

        //make sure that the color animation is not reverted once the animation is completed
        colorChange.fillMode = CAMediaTimingFillMode.forwards
        colorChange.isRemovedOnCompletion = false

        //indicate which animation timing function to use, in this case ease in and ease out
        colorChange.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        //add the animation
        self.pathLayer.add(colorChange, forKey: "darkColor")
    }

    func currentInnerPath () -> UIBezierPath {
        //choose the correct inner path based on the control state
        var returnPath: UIBezierPath
        if self.isSelected {
            returnPath = self.innerSquarePath()
        } else {
            returnPath = self.innerCirclePath()
        }
        return returnPath
    }

    func innerCirclePath () -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 8, y: 8, width: 50, height: 50), cornerRadius: 25)
    }

    func innerSquarePath () -> UIBezierPath {
        return UIBezierPath(roundedRect: CGRect(x: 18, y: 18, width: 30, height: 30), cornerRadius: 4)
    }
}
