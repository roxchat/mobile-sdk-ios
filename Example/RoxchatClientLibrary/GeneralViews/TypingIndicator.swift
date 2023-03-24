
import Foundation
import UIKit

class TypingIndicator: UIView {
    
    // MARK: - Properties
    enum CirclePosition {
        case leading, center, trailing
    }
    var circleDiameter: CGFloat = 20.0 {
        didSet {
            setNeedsLayout()
        }
    }
    var circleColour = UIColor.red {
        didSet {
            colourChangeAnimation.values = [
                circleColour.cgColor,
                circleColour.withAlphaComponent(0.5).cgColor
            ]
        }
    }
    var animationDuration: CFTimeInterval = 1.0 {
        didSet {
            for index in 0...TypingIndicator.QUANTITY - 1 {
                groupAnimations[index].duration = animationDuration
                let i = Double(index)
                groupAnimations[index].timeOffset = i * 1 / 3
            }
            setNeedsLayout()
        }
    }
    
    // MARK: - Private properties
    private static let QUANTITY = 3
    
    private var colourChangeAnimation = CAKeyframeAnimation()
    
    private var midX = CGFloat()
    private var midY = CGFloat()
    private var circles = Array(
        repeating: CAShapeLayer(),
        count: QUANTITY
    )
    private var groupAnimations = Array(
        repeating: CAAnimationGroup(),
        count: QUANTITY
    )
    private var paths = Array(
        repeating: UIBezierPath(),
        count: QUANTITY
    )
    private var positionChangeAnimations = Array(
        repeating: CAKeyframeAnimation(),
        count: QUANTITY
    )

    // MARK: - Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        midX = bounds.midX
        midY = bounds.midY
        positionCircles()
        setupPaths()
        setupPositionChangeAnimations()
        setupColourChangeAnimation()
        setupGroupAnimations()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCircles()
        setupPaths()
        setupPositionChangeAnimations()
        setupColourChangeAnimation()
        setupGroupAnimations()
    }
    
    func addAllAnimations() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            let groupAnimation = groupAnimations[index]
            circles[index].add(groupAnimation, forKey: "multiAnimation")
        }
    }
    
    func removeAllAnimations() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            circles[index].removeAllAnimations()
        }
    }
    
    // MARK: - Private methods
    private func createCircle() -> CAShapeLayer {
        let circle = CAShapeLayer()
        circle.frame = CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter)
        circle.cornerRadius = circleDiameter / 2
        return circle
    }
    
    private func setupCircles() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            circles[index] = createCircle()
            layer.addSublayer(circles[index])
        }
    }
    
    private func positionCircles() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            let i = CGFloat(index)
            circles[index].frame = CGRect(
                x: midX / 2 + (i * midX / 2) - circleDiameter / 2,
                y: 3 * midY / 2 - circleDiameter / 2,
                width: circleDiameter,
                height: circleDiameter
            )
            circles[index].cornerRadius = circleDiameter / 2
        }
    }
    
    private func setupPaths() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            paths[index] = UIBezierPath()
            let i = CGFloat(index)
            let startPoint = CGPoint(x: midX / 2 + (i * midX / 2), y: 3 * midY / 2)
            let endPoint = CGPoint(x: midX / 2 + (i * midX / 2), y: midY / 2)
            paths[index].move(to: startPoint)
            paths[index].addLine(to: endPoint)
        }
    }
 
    private func setupPositionChangeAnimations() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            positionChangeAnimations[index] = CAKeyframeAnimation()
            positionChangeAnimations[index].keyPath = #keyPath(CALayer.position)
            positionChangeAnimations[index].path = paths[index].cgPath
        }
    }
    
    private func setupColourChangeAnimation() {
        let colours = [circleColour.cgColor, circleColour.withAlphaComponent(0.5).cgColor]
        colourChangeAnimation.keyPath = #keyPath(CALayer.backgroundColor)
        colourChangeAnimation.values = colours
    }
    
    private func setupGroupAnimations() {
        for index in 0...TypingIndicator.QUANTITY - 1 {
            let i = Double(index)
            groupAnimations[index] = CAAnimationGroup()
            groupAnimations[index].animations = [
                positionChangeAnimations[index],
                colourChangeAnimation
            ]
            groupAnimations[index].duration = animationDuration
            groupAnimations[index].timingFunction = CAMediaTimingFunction(name: .easeIn)
            groupAnimations[index].timeOffset = i * 1 / 3
            groupAnimations[index].repeatCount = .infinity
            groupAnimations[index].autoreverses = true
        }
    }

}
