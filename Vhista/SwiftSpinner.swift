//
//  SwiftSpinner.swift
//  Vhista
//
//  Created by Juan David Cruz Serrano on 1/2/17.
//  Copyright © 2017 Juan David Cruz. All rights reserved.
//

import UIKit

public class SwiftSpinner: UIView {
    // MARK: - Singleton
    public class var sharedInstance: SwiftSpinner {
        struct Singleton {
            static let instance = SwiftSpinner(frame: CGRect.zero)
        }
        return Singleton.instance
    }

    // MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)

        blurEffect = UIBlurEffect(style: blurEffectStyle)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.2

        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0.7
        addSubview(blackView)

        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
//        addSubview(vibrancyView)

        let titleScale: CGFloat = 0.85
        titleLabel.frame.size = CGSize(width: frameSize.width * titleScale, height: frameSize.height * titleScale)
        titleLabel.font = defaultTitleFont
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.lineBreakMode = .byWordWrapping
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textColor = UIColor.white
        titleLabel.isAccessibilityElement = false

        addSubview(titleLabel)
        blurView.contentView.addSubview(vibrancyView)

        outerCircleView.frame.size = frameSize

        outerCircle.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: frameSize.width, height: frameSize.height)).cgPath
        outerCircle.lineWidth = 8.0
        outerCircle.strokeStart = 0.0
        outerCircle.strokeEnd = 0.45
        outerCircle.lineCap = CAShapeLayerLineCap.square
        outerCircle.fillColor = UIColor.clear.cgColor
        outerCircle.strokeColor = outerCircleDefaultColor
        outerCircleView.layer.addSublayer(outerCircle)

        outerCircle.strokeStart = 0.0
        outerCircle.strokeEnd = 1.0

        addSubview(outerCircleView)

        innerCircleView.frame.size = frameSize

        let innerCirclePadding: CGFloat = 12
        innerCircle.path = UIBezierPath(ovalIn: CGRect(x: innerCirclePadding,
                                                       y: innerCirclePadding,
                                                       width: frameSize.width - 2*innerCirclePadding,
                                                       height: frameSize.height - 2*innerCirclePadding)).cgPath
        innerCircle.lineWidth = 4.0
        innerCircle.strokeStart = 0.5
        innerCircle.strokeEnd = 0.9
        innerCircle.lineCap = CAShapeLayerLineCap.square
        innerCircle.fillColor = UIColor.clear.cgColor
        innerCircle.strokeColor = innerCircleDefaultColor
        innerCircleView.layer.addSublayer(innerCircle)

        innerCircle.strokeStart = 0.0
        innerCircle.strokeEnd = 1.0

        addSubview(innerCircleView)

        isUserInteractionEnabled = true
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }

    // MARK: - Public interface
    public lazy var titleLabel = UILabel()
    public var subtitleLabel: UILabel?

    private let outerCircleDefaultColor = UIColor.white.cgColor
    fileprivate var _outerColor: UIColor?
    public var outerColor: UIColor? {
        get { return _outerColor }
        set(newColor) {
            _outerColor = newColor
            outerCircle.strokeColor = newColor?.cgColor ?? outerCircleDefaultColor
        }
    }

    private let innerCircleDefaultColor = UIColor(white: 0.9, alpha: 1.0).cgColor
    fileprivate var _innerColor: UIColor?
    public var innerColor: UIColor? {
        get { return _innerColor }
        set(newColor) {
            _innerColor = newColor
            innerCircle.strokeColor = newColor?.cgColor ?? innerCircleDefaultColor
        }
    }

    private static weak var customSuperview: UIView?
    private static func containerView() -> UIView? {
        return customSuperview ?? UIApplication.shared.keyWindow
    }
    public class func useContainerView(_ sv: UIView?) {
        customSuperview = sv
    }

    @discardableResult
    public class func show(_ title: String, animated: Bool = true) -> SwiftSpinner {

        let spinner = SwiftSpinner.sharedInstance

        spinner.clearTapHandler()

        spinner.updateFrame()

        if spinner.superview == nil {
            //show the spinner
            spinner.alpha = 0.0

            guard let containerView = containerView() else {
                return spinner
            }

            containerView.addSubview(spinner)

            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.alpha = 1.0
            }, completion: nil)

            #if os(iOS)
                // Orientation change observer
                NotificationCenter.default.addObserver(
                    spinner,
                    selector: #selector(SwiftSpinner.updateFrame),
                    name: UIApplication.didChangeStatusBarOrientationNotification,
                    object: nil)
            #endif
        }

        spinner.title = title
        spinner.animating = animated

        return spinner
    }

    @discardableResult
    public class func show(duration: Double, title: String, animated: Bool = true) -> SwiftSpinner {
        let spinner = SwiftSpinner.show(title, animated: animated)
        spinner.delay(duration) {
            SwiftSpinner.hide()
        }
        return spinner
    }

    private static var delayedTokens = [String]()

    public class func show(delay: Double, title: String, animated: Bool = true) {
        let token = UUID().uuidString
        delayedTokens.append(token)
        SwiftSpinner.sharedInstance.delay(delay, completion: {
            if let index = delayedTokens.firstIndex(of: token) {
                delayedTokens.remove(at: index)
                _ = SwiftSpinner.show(title, animated: animated)
            }
        })
    }

    @discardableResult
    public class func show(progress: Double, title: String) -> SwiftSpinner {
        let spinner = SwiftSpinner.show(title, animated: false)
        spinner.outerCircle.strokeEnd = CGFloat(progress)
        return spinner
    }

    public static var hideCancelsScheduledSpinners = true
    public class func hide(_ completion: (() -> Void)? = nil) {

        let spinner = SwiftSpinner.sharedInstance

        NotificationCenter.default.removeObserver(spinner)
        if hideCancelsScheduledSpinners {
            delayedTokens.removeAll()
        }

        DispatchQueue.main.async(execute: {
            spinner.clearTapHandler()

            if spinner.superview == nil {
                return
            }

            UIView.animate(withDuration: 0.33, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.alpha = 0.0
            }, completion: {_ in
                spinner.alpha = 1.0
                spinner.removeFromSuperview()
                spinner.titleLabel.font = spinner.defaultTitleFont
                spinner.titleLabel.text = nil

                completion?()
            })

            spinner.animating = false
        })
    }

    public class func setTitleFont(_ font: UIFont?) {
        let spinner = SwiftSpinner.sharedInstance

        if let font = font {
            spinner.titleLabel.font = font
        } else {
            spinner.titleLabel.font = spinner.defaultTitleFont
        }
    }

    public var title: String = "" {
        didSet {
            let spinner = SwiftSpinner.sharedInstance

            guard spinner.animating else {
                spinner.titleLabel.transform = CGAffineTransform.identity
                spinner.titleLabel.alpha = 1.0
                spinner.titleLabel.text = self.title
                return
            }

            UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: {
                spinner.titleLabel.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
                spinner.titleLabel.alpha = 0.2
            }, completion: {_ in
                spinner.titleLabel.text = self.title
                UIView.animate(withDuration: 0.35, delay: 0.0, usingSpringWithDamping: 0.35, initialSpringVelocity: 0.0, options: [], animations: {
                    spinner.titleLabel.transform = CGAffineTransform.identity
                    spinner.titleLabel.alpha = 1.0
                }, completion: nil)
            })
        }
    }

    public override var frame: CGRect {
        didSet {
            if frame == CGRect.zero {
                return
            }
            blurView.frame = bounds
            blackView.frame = bounds
            vibrancyView.frame = blurView.bounds
            titleLabel.center = vibrancyView.center
            outerCircleView.center = vibrancyView.center
            innerCircleView.center = vibrancyView.center
            if let subtitle = subtitleLabel {
                subtitle.bounds.size = subtitle.sizeThatFits(bounds.insetBy(dx: 20.0, dy: 0.0).size)
                subtitle.center = CGPoint(x: bounds.midX, y: bounds.maxY - subtitle.bounds.midY - subtitle.font.pointSize)
            }
        }
    }

    public var animating: Bool = false {
        willSet (shouldAnimate) {
            if shouldAnimate && !animating {
                spinInner()
                spinOuter()
            }
        }
        didSet {
            // update UI
            if animating {
                self.outerCircle.strokeStart = 0.0
                self.outerCircle.strokeEnd = 0.45
                self.innerCircle.strokeStart = 0.5
                self.innerCircle.strokeEnd = 0.9
            } else {
                self.outerCircle.strokeStart = 0.0
                self.outerCircle.strokeEnd = 1.0
                self.innerCircle.strokeStart = 0.0
                self.innerCircle.strokeEnd = 1.0
            }
        }
    }

    public func addTapHandler(_ tap: @escaping (() -> Void), subtitle subtitleText: String? = nil) {
        clearTapHandler()

        //vibrancyView.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapSpinner")))
        tapHandler = tap

        if subtitleText != nil {
            subtitleLabel = UILabel()
            if let subtitle = subtitleLabel {
                subtitle.text = subtitleText
                subtitle.font = UIFont(name: defaultTitleFont.familyName, size: defaultTitleFont.pointSize * 0.8)
                subtitle.textColor = UIColor.white
                subtitle.numberOfLines = 0
                subtitle.textAlignment = .center
                subtitle.lineBreakMode = .byWordWrapping
                subtitle.bounds.size = subtitle.sizeThatFits(bounds.insetBy(dx: 20.0, dy: 0.0).size)
                subtitle.center = CGPoint(x: bounds.midX, y: bounds.maxY - subtitle.bounds.midY - subtitle.font.pointSize)
                vibrancyView.contentView.addSubview(subtitle)
            }
        }
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if tapHandler != nil {
            tapHandler?()
            tapHandler = nil
        }
    }

    public func clearTapHandler() {
        isUserInteractionEnabled = false
        subtitleLabel?.removeFromSuperview()
        tapHandler = nil
    }

    // MARK: - Private interface
    private var blurEffectStyle: UIBlurEffect.Style = .dark
    private var blurEffect: UIBlurEffect!
    private var blurView: UIVisualEffectView!
    private var blackView: UIView = UIView()
    private var vibrancyView: UIVisualEffectView!
    var defaultTitleFont = UIFont(name: "HelveticaNeue", size: 22.0)!
    let frameSize = CGSize(width: 200.0, height: 200.0)
    private lazy var outerCircleView = UIView()
    private lazy var innerCircleView = UIView()
    private let outerCircle = CAShapeLayer()
    private let innerCircle = CAShapeLayer()
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Not coder compliant")
    }
    private var currentOuterRotation: CGFloat = 0.0
    private var currentInnerRotation: CGFloat = 0.1

    private func spinOuter() {

        if superview == nil {
            return
        }

        let duration = Double(Float(arc4random()) /  Float(UInt32.max)) * 2.0 + 1.5
        let randomRotation = Double(Float(arc4random()) /  Float(UInt32.max)) * .pi/4 + .pi/4

        //outer circle
        UIView.animate(withDuration: duration, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [], animations: {
            self.currentOuterRotation -= CGFloat(randomRotation)
            self.outerCircleView.transform = CGAffineTransform(rotationAngle: self.currentOuterRotation)
        }, completion: {_ in
            let waitDuration = Double(Float(arc4random()) /  Float(UInt32.max)) * 1.0 + 1.0
            self.delay(waitDuration, completion: {
                if self.animating {
                    self.spinOuter()
                }
            })
        })
    }

    private func spinInner() {
        if superview == nil {
            return
        }
        //inner circle
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.currentInnerRotation += CGFloat(Double.pi/4)
            self.innerCircleView.transform = CGAffineTransform(rotationAngle: self.currentInnerRotation)
        }, completion: {_ in
            self.delay(0.5, completion: {
                if self.animating {
                    self.spinInner()
                }
            })
        })
    }

    @objc public func updateFrame() {
        if let containerView = SwiftSpinner.containerView() {
            SwiftSpinner.sharedInstance.frame = containerView.bounds
        }
    }

    // MARK: - Util methods
    func delay(_ seconds: Double, completion:@escaping () -> Void) {
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * seconds )) / Double(NSEC_PER_SEC)

        DispatchQueue.main.asyncAfter(deadline: popTime) {
            completion()
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        updateFrame()
    }

    // MARK: - Tap handler
    private var tapHandler: (() -> Void)?
    func didTapSpinner() {
        tapHandler?()
    }
}
