//
//  DirectedPinchGestureRecognizer.swift
//  DirectedPinchGestureRecognizer
//
//  Created by Daniel Clelland on 28/03/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

/// Extension of `UIGestureRecognizerDelegate` which allows the delegate to receive messages when the pinch gesture recognizer starts, updates, cancels, and finishes. The `delegate` property can be set to a class implementing `DirectedPinchGestureRecognizerDelegate` and it will receive these messages.
@objc public protocol DirectedPinchGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    
    /// Called when the pinch gesture recognizer starts.
    @objc optional func directedPinchGestureRecognizer(didStart gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer updates.
    @objc optional func directedPinchGestureRecognizer(didUpdate gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer cancels. A pinch gesture recognizer may cancel if its linear or geometric scale in `initialDirection` and `initialAxis` is less than the value of `minimumLinearScale` or `minimumGeometricScale`, respectively.
    @objc optional func directedPinchGestureRecognizer(didCancel gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer cancels. A pinch gesture recognizer may finish if its linear or geometric scale in `initialDirection` and `initialAxis` are greater than or equal to the value of `minimumLinearScale` or `minimumGeometricScale`, respectively.
    @objc optional func directedPinchGestureRecognizer(didFinish gestureRecognizer: DirectedPinchGestureRecognizer)

}

public class DirectedPinchGestureRecognizer: UIPinchGestureRecognizer {
    
    /// The pinch gesture recognizer's direction, i.e. inwards or outwards. Also used to calculate attributes for a given type.
    public enum Direction {
        /// The pinch gesture recognizer's touches move inwards relative to one another.
        case inwards
        /// The pinch gesture recognizer's touches move outwards relative to one another.
        case outwards
    }
    
    /// The pinch gesture recognizer's primary axis. Also used to calculate attributes along a given axis.
    public enum Axis {
        /// The pinch gesture recognizer's touches are oriented vertically relative to one another.
        case vertical
        /// The pinch gesture recognizer's touches are oriented horizontally relative to one another.
        case horizontal
    }
    
    // MARK: Configuration
    
    /// Minimum linear scale (in `initialDirection` and `initialAxis`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable public var minimumLinearScale: CGFloat = 0.0
    
    /// Minimum geometric scale (in `initialDirection` and `initialAxis`) required for the gesture to finish. Defaults to `1.0`.
    /// **KNOWN ISSUE**: As this variable is `@IBInspectable`, its value may be reset to `0.0` when used in Interface Builder.
    @IBInspectable public var minimumGeometricScale: CGFloat = 1.0
    
    // MARK: Internal variables
    
    /// The current location in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    public private(set) var initialLocation: CGPoint?
    
    /// The current location of both touches in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    public private(set) var initialLocations: (CGPoint, CGPoint)?
    
    /// The current direction in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    public private(set) var initialDirection: Direction?
    
    /// The current axis in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    public private(set) var initialAxis: Axis?
    
    // MARK: Delegation
    
    override public var delegate: UIGestureRecognizerDelegate? {
        didSet {
            self.addTarget(self, action: #selector(onPinch))
        }
    }
    
    internal var directedPinchDelegate: DirectedPinchGestureRecognizerDelegate? {
        return delegate as? DirectedPinchGestureRecognizerDelegate
    }
    
    // MARK: Initialization
    
    /// Initialize the pinch gesture recognizer with no target or action set.
    public convenience init() {
        self.init(target: nil, action: nil)
    }
    
    // MARK: Overrides
    
    public override func reset() {
        super.reset()
        
        initialLocation = nil
        initialLocations = nil
        initialDirection = nil
        initialAxis = nil
    }
    
    // MARK: Actions
    
    internal func onPinch() {
        if (state == .began) {
            initialLocation = location
            initialLocations = locations
            initialDirection = direction
            initialAxis = axis
        }
        
        if (state != .ended && locations == nil) {
            state = .ended
        }
        
        switch state {
        case .began:
            directedPinchDelegate?.directedPinchGestureRecognizer?(didStart: self)
        case .changed:
            directedPinchDelegate?.directedPinchGestureRecognizer?(didUpdate: self)
        case .cancelled:
            directedPinchDelegate?.directedPinchGestureRecognizer?(didCancel: self)
        case .ended where shouldCancel:
            directedPinchDelegate?.directedPinchGestureRecognizer?(didCancel: self)
        case .ended:
            directedPinchDelegate?.directedPinchGestureRecognizer?(didFinish: self)
        default:
            break
        }
    }
    
    // MARK: Cancellation
    
    private var shouldCancel: Bool {
        return linearScale() < minimumLinearScale || geometricScale() < minimumGeometricScale
    }
    
}

// MARK: - Dynamic variables

public extension DirectedPinchGestureRecognizer {
    
    /// The pinch gesture recognizer's current location in `view`, calculated using `location(in:)`. Returns `nil` if `view` is `nil`.
    public var location: CGPoint? {
        guard let view = view else {
            return nil
        }
        
        return location(in: view)
    }
    
    /// The pinch gesture recognizer's first two touch locations in `view`, calculated using `location(ofTouch:in:)`. Returns `nil` if `view` is `nil`, or the number of touches is less than two.
    public var locations: (CGPoint, CGPoint)? {
        guard let view = view, numberOfTouches >= 2 else {
            return nil
        }
        
        let firstLocation = location(ofTouch: 0, in: view)
        let secondLocation = location(ofTouch: 1, in: view)
        
        return (firstLocation, secondLocation)
    }
    
    /// The pinch gesture recognizer's current direction. Returns `nil` if `scale` is `1.0`, `.inwards` if `scale` is less than `1.0`, or `.outwards` if `scale` is greater than `1.0`.
    public var direction: Direction? {
        if (scale == 1.0) {
            return nil
        } else if (scale < 1.0) {
            return .inwards
        } else {
            return .outwards
        }
    }
    
    /// The pinch gesture recognizer's current axis in `view`, calculated by comparing the first two touch locations with one another. Returns `nil` if `view` is `nil`, or if the touches are on top of one another (which should never happen).
    public var axis: Axis? {
        guard let vector = vector else {
            return nil
        }
        
        if (vector == .zero) {
            return nil
        } else if (fabs(vector.dx) < fabs(vector.dy)) {
            return .vertical
        } else {
            return .horizontal
        }
    }
    
}

// MARK: - Directional helpers

public extension DirectedPinchGestureRecognizer {
    
    /**
     The pan gesture recognizer's current scale, *in points*, in a given direction and axis.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     - parameter axis: The axis. Defaults to `nil`, in which case `initialAxis` is used.
     
     - returns: Returns `0.0` if either `direction` or `axis` (or the `initialDirection` and `initialAxis` fallbacks, respectively) are `nil`. Else, takes the current two touch locations and calculates how far they have moved relative to one another, in the given direction and axis. For example, if the two points were vertically 20 points away from each other, and they then move to be 30 points away from each other, then `linearScale(inDirection: .outwards, onAxis: .vertical)` should return `10.0`.
     */
    
    public func linearScale(inDirection direction: Direction? = nil, onAxis axis: Axis? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, let axis = axis ?? initialAxis else {
            return 0.0
        }
        
        guard let initialMagnitude = initialVector?.magnitude(onAxis: axis), let magnitude = vector?.magnitude(onAxis: axis) else {
            return 0.0
        }
        
        switch direction {
        case .inwards:
            return initialMagnitude - magnitude
        case .outwards:
            return magnitude - initialMagnitude
        }
    }
    
    /**
     The pan gesture recognizer's current scale, *in a relative, dimensionless unit*, in a given direction and axis.
     
     - parameter direction: The direction. Defaults to `nil`, in which case `initialDirection` is used.
     - parameter axis: The axis. Defaults to `nil`, in which case `initialAxis` is used.
     
     - returns: Returns `0.0` if either `direction` or `axis` (or the `initialDirection` and `initialAxis` fallbacks, respectively) are `nil`. Else, takes the current two touch locations and calculates how far they have moved relative to one another, in the given direction and axis. For example, if the two points were vertically 20 points away from each other, and they then move to be 30 points away from each other, then `geometricScale(inDirection: .outwards, onAxis: .vertical)` should return `1.5`.
     */
    
    public func geometricScale(inDirection direction: Direction? = nil, onAxis axis: Axis? = nil) -> CGFloat {
        guard let direction = direction ?? initialDirection, let axis = axis ?? initialAxis else {
            return 0.0
        }
        
        guard let initialMagnitude = initialVector?.magnitude(onAxis: axis), let magnitude = vector?.magnitude(onAxis: axis) else {
            return 0.0
        }
        
        switch direction {
        case .inwards:
            return initialMagnitude / magnitude
        case .outwards:
            return magnitude / initialMagnitude
        }
    }
    
}

// MARK: - Private helpers

private extension DirectedPinchGestureRecognizer {
    
    var initialVector: CGVector? {
        guard let (firstLocation, secondLocation) = initialLocations else {
            return nil
        }
        
        let dx = secondLocation.x - firstLocation.x
        let dy = secondLocation.y - firstLocation.y
        
        return CGVector(dx: dx, dy: dy)
    }
    
    var vector: CGVector? {
        guard let (firstLocation, secondLocation) = locations else {
            return nil
        }
        
        let dx = secondLocation.x - firstLocation.x
        let dy = secondLocation.y - firstLocation.y
        
        return CGVector(dx: dx, dy: dy)
    }
    
}

private extension CGVector {
    
    func magnitude(onAxis axis: DirectedPinchGestureRecognizer.Axis) -> CGFloat {
        switch axis {
        case .vertical:
            return abs(dy)
        case .horizontal:
            return abs(dx)
        }
    }
    
}

