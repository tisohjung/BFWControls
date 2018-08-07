//
//  ArcView.swift
//  BFWControls
//
//  Created by Danielle on 1/8/17.
//  Copyright © 2017 BareFeetWare. All rights reserved.
//  Free to use at your own risk, with acknowledgement to BareFeetWare.
//

import UIKit

@IBDesignable open class ArcView: UIView {
    
    // MARK: - IBInspectable variables

    @IBInspectable open var start: Double = 0.0
    @IBInspectable open var end: Double = 1.0
    @IBInspectable open var lineWidth: CGFloat = 2.0
    @IBInspectable open var duration: Double = 1.0
    @IBInspectable open var fillColor: UIColor = .clear
    @IBInspectable open var strokeColor: UIColor = .gray
    @IBInspectable open var clockwise: Bool {
        get {
            return overriddenClockwise ?? true
        }
        set {
            overriddenClockwise = newValue
        }
    }
    
    @IBInspectable open var animationCurveInt: Int {
        get {
            return animationCurve.rawValue
        }
        set {
            animationCurve = UIViewAnimationCurve(rawValue: newValue) ?? .linear
        }
    }
    
    @IBInspectable open var isPaused = false {
        didSet {
            if oldValue != isPaused {
                if !isPaused {
                    animate()
                }
            }
        }
    }
    
    // MARK: - Variables

    open var animationCurve: UIViewAnimationCurve = .linear
    
    open var bezierPath: UIBezierPath {
        return UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.midX, bounds.midY) - lineWidth / 2,
            startAngle: CGFloat(start) * 2 * .pi,
            endAngle: CGFloat(end) * 2 * .pi,
            clockwise: overriddenClockwise ?? (start < end)
        )
    }
    
    let shapeLayer = CAShapeLayer()
    
    private var overriddenClockwise: Bool?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        #if TARGET_INTERFACE_BUILDER
        // TODO: Draw something in IB
        backgroundColor = UIColor.cyan.withAlphaComponent(0.2)
        #else
        backgroundColor = UIColor.clear
        #endif

        // Add the shapeLayer to the view's layer's sublayers
        layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Functions

    private func updateShapeLayer() {
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        
        // Don't draw the arc initially
        shapeLayer.strokeEnd = 0.0
    }
    
    open func animate() {
        updateShapeLayer()
        
        #if TARGET_INTERFACE_BUILDER
        // TODO: Draw something in IB
        backgroundColor = UIColor.cyan
        #endif
        
        // Animate the strokeEnd property of the shapeLayer.
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.duration = duration
        
        // Animate from 0 (no arc) to 1 (full arc)
        animation.fromValue = 0.0
        animation.toValue = 1.0
        
        // Do a linear animation (i.e. the speed of the animation stays the same)
        animation.timingFunction = animationCurve.mediaTimingFunction
        
        // Set the shapeLayer's strokeEnd property to 1.0 now so that it's the
        // right value when the animation ends.
        shapeLayer.strokeEnd = 1.0
        
        // Do the actual animation
        shapeLayer.add(animation, forKey: "animate")
    }
    
    // MARK: UIView

    open override func layoutSubviews() {
        super.layoutSubviews()
        if window != nil {
            animate()
        }
    }
    
}

private extension UIViewAnimationCurve {
    
    var mediaTimingFunctionString: String {
        switch self {
        case .linear: return kCAMediaTimingFunctionLinear
        case .easeIn: return kCAMediaTimingFunctionEaseIn
        case .easeOut: return kCAMediaTimingFunctionEaseOut
        case .easeInOut: return kCAMediaTimingFunctionEaseInEaseOut
        }
    }
    
    var mediaTimingFunction: CAMediaTimingFunction {
        return CAMediaTimingFunction(name: mediaTimingFunctionString)
    }

}