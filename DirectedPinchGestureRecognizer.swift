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
@objc protocol DirectedPinchGestureRecognizerDelegate: UIGestureRecognizerDelegate {
    
    /// Called when the pinch gesture recognizer starts.
    optional func directedPinchGestureRecognizerDidStart(gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer updates.
    optional func directedPinchGestureRecognizerDidUpdate(gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer cancels. A pinch gesture recognizer may cancel if its linear or geometric scale in `initialOrientation` and `initialDivergence` is less than the value of `minimumLinearScale` or `minimumGeometricScale`, respectively.
    optional func directedPinchGestureRecognizerDidCancel(gestureRecognizer: DirectedPinchGestureRecognizer)
    
    /// Called when the pinch gesture recognizer cancels. A pinch gesture recognizer may finish if its linear or geometric scale in `initialOrientation` and `initialDivergence` are greater than or equal to the value of `minimumLinearScale` or `minimumGeometricScale`, respectively.
    optional func directedPinchGestureRecognizerDidFinish(gestureRecognizer: DirectedPinchGestureRecognizer)

}

class DirectedPinchGestureRecognizer: UIPinchGestureRecognizer {
    
    /// The pinch gesture recognizer's orientation. Also used to calculate attributes for a given orientation.
    enum Orientation {
        /// The pinch gesture recognizer's touches are oriented vertically relative to one another.
        case Vertical
        /// The pinch gesture recognizer's touches are oriented horizontally relative to one another.
        case Horizontal
    }
    
    /// The pinch gesture recognizer's divergence type, i.e. inwards or outwards. Also used to calculate attributes for a given type.
    enum Divergence {
        /// The pinch gesture recognizer's touches move inwards relative to one another.
        case Inwards
        /// The pinch gesture recognizer's touches move outwards relative to one another.
        case Outwards
    }
    
    // MARK: Configuration
    
    /// Minimum linear scale (in `initialOrientation` and `initialDivergence`) required for the gesture to finish. Defaults to `0.0`.
    @IBInspectable var minimumLinearScale: CGFloat = 0.0
    
    /// Minimum geometric scale (in `initialOrientation` and `initialDivergence`) required for the gesture to finish. Defaults to `1.0`.
    /// **KNOWN ISSUE**: As this variable is `@IBInspectable`, its value may be reset to `0.0` when used in Interface Builder.
    @IBInspectable var minimumGeometricScale: CGFloat = 1.0
    
    // MARK: Internal variables
    
    /// The current location in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialLocation: CGPoint?
    
    /// The current location of both touches in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialLocations: (CGPoint, CGPoint)?
    
    /// The current orientation in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialOrientation: Orientation?
    
    /// The current divergence in `view` when the pinch gesture recognizer begins. Defaults to `nil`. Resets to `nil` when `reset()` is called.
    private(set) var initialDivergence: Divergence?
    
    // MARK: Delegation
    
    override var delegate: UIGestureRecognizerDelegate? {
        didSet {
            self.addTarget(self, action: "onPinch")
        }
    }
    
    private var directedPinchDelegate: DirectedPinchGestureRecognizerDelegate? {
        return delegate as? DirectedPinchGestureRecognizerDelegate
    }
    
    // MARK: Initialization
    
    /// Initialize the pinch gesture recognizer with no target or action set.
    convenience init() {
        self.init(target: nil, action: nil)
    }
    
    // MARK: Overrides
    
    override func reset() {
        super.reset()
        
        initialLocation = nil
        initialLocations = nil
        initialOrientation = nil
        initialDivergence = nil
    }
    
    // MARK: Actions
    
    /// Called when the pinch gesture recognizer updates. Final function which should otherwise be private, as this method's selector is added as a target when the `delegate` is set, and selectors require their methods to be public.
    final func onPinch() {
        if (state == .Began) {
            initialLocation = location
            initialLocations = locations
            initialOrientation = orientation
            initialDivergence = divergence
        }
        
        if (state != .Ended && locations == nil) {
            state = .Ended
        }
        
        switch state {
        case .Began:
            directedPinchDelegate?.directedPinchGestureRecognizerDidStart?(self)
        case .Changed:
            directedPinchDelegate?.directedPinchGestureRecognizerDidUpdate?(self)
        case .Cancelled:
            directedPinchDelegate?.directedPinchGestureRecognizerDidCancel?(self)
        case .Ended where shouldCancel():
            directedPinchDelegate?.directedPinchGestureRecognizerDidCancel?(self)
        case .Ended:
            directedPinchDelegate?.directedPinchGestureRecognizerDidFinish?(self)
        default:
            break
        }
    }
    
    // MARK: Cancellation
    
    private func shouldCancel() -> Bool {
        return linearScale() < minimumLinearScale || geometricScale() < minimumGeometricScale
    }
    
}

// MARK: - Dynamic variables

extension DirectedPinchGestureRecognizer {
    
    /// The pinch gesture recognizer's current location in `view`, calculated using `locationInView()`. Returns `nil` if `view` is `nil`.
    var location: CGPoint? {
        guard let view = view else {
            return nil
        }
        
        return locationInView(view)
    }
    
    /// The pinch gesture recognizer's first two touch locations in `view`, calculated using `locationOfTouch()`. Returns `nil` if `view` is `nil`, or the number of touches is less than two.
    var locations: (CGPoint, CGPoint)? {
        guard let view = view where numberOfTouches() >= 2 else {
            return nil
        }
        
        let firstLocation = locationOfTouch(0, inView: view)
        let secondLocation = locationOfTouch(1, inView: view)
        
        return (firstLocation, secondLocation)
    }
    
    /// The pinch gesture recognizer's current orientation in `view`, calculated by comparing the first two touch locations with one another. Returns `nil` if `view` is `nil`, or if the touches are on top of one another (which should never happen).
    var orientation: Orientation? {
        guard let vector = vector() else {
            return nil
        }
        
        if (vector == CGVector.zero) {
            return nil
        } else if (fabs(vector.dx) < fabs(vector.dy)) {
            return .Vertical
        } else {
            return .Horizontal
        }
    }
    
    /// The pinch gesture recognizer's current divergence type. Returns `nil` if `scale` is `1.0`, `.Inwards` if `scale` is less than `1.0`, or `.Outwards` if `scale` is greater than `1.0`.
    var divergence: Divergence? {
        if (scale == 1.0) {
            return nil
        } else if (scale < 1.0) {
            return .Inwards
        } else {
            return .Outwards
        }
    }
    
}

// MARK: - Orientational helpers

extension DirectedPinchGestureRecognizer {
    
    /**
     The pan gesture recognizer's current scale, *in points*, in a given orientation and divergence.
     
     - parameter orientation: The orientation. Defaults to `nil`, in which case `initialOrientation` is used.
     - parameter divergence: The divergence. Defaults to `nil`, in which case `initialDivergence` is used.
     
     - returns: Returns `0.0` if either `orientation` or `divergence` (or the `initialOrientation` and `initialDivergence` fallbacks, respectively) are `nil`. Else, takes the current two touch locations and calculates how far they have moved relative to one another, in the given orientation and divergence. For example, if the two points were vertically 20 points away from each other, and they then move to be 30 points away from each other, then `linearScale(forOrientation: .Vertical, andDivergence: .Outwards)` should return `10.0`.
     */
    
    func linearScale(inOrientation orientation: Orientation? = nil, andDivergence divergence: Divergence? = nil) -> CGFloat {
        guard let orientation = orientation ?? initialOrientation, divergence = divergence ?? initialDivergence else {
            return 0.0
        }
        
        guard let initialMagnitude = initialVector()?.magnitude(inOrientation: orientation), magnitude = vector()?.magnitude(inOrientation: orientation) else {
            return 0.0
        }
        
        switch divergence {
        case .Inwards:
            return initialMagnitude - magnitude
        case .Outwards:
            return magnitude - initialMagnitude
        }
    }
    
    /**
     The pan gesture recognizer's current scale, *in a relative, dimensionless unit*, in a given orientation and divergence.
     
     - parameter orientation: The orientation. Defaults to `nil`, in which case `initialOrientation` is used.
     - parameter divergence: The divergence. Defaults to `nil`, in which case `initialDivergence` is used.
     
     - returns: Returns `0.0` if either `orientation` or `divergence` (or the `initialOrientation` and `initialDivergence` fallbacks, respectively) are `nil`. Else, takes the current two touch locations and calculates how far they have moved relative to one another, in the given orientation and divergence. For example, if the two points were vertically 20 points away from each other, and they then move to be 30 points away from each other, then `geometricScale(forOrientation: .Vertical, andDivergence: .Outwards)` should return `1.5`.
     */
    
    func geometricScale(inOrientation orientation: Orientation? = nil, withDivergence divergence: Divergence? = nil) -> CGFloat {
        guard let orientation = orientation ?? initialOrientation, divergence = divergence ?? initialDivergence else {
            return 0.0
        }
        
        guard let initialMagnitude = initialVector()?.magnitude(inOrientation: orientation), magnitude = vector()?.magnitude(inOrientation: orientation) else {
            return 0.0
        }
        
        switch divergence {
        case .Inwards:
            return initialMagnitude / magnitude
        case .Outwards:
            return magnitude / initialMagnitude
        }
    }
    
}

// MARK: - Private helpers

private extension DirectedPinchGestureRecognizer {
    
    func initialVector() -> CGVector? {
        guard let (firstLocation, secondLocation) = initialLocations else {
            return nil
        }
        
        let dx = secondLocation.x - firstLocation.x
        let dy = secondLocation.y - firstLocation.y
        
        return CGVector(dx: dx, dy: dy)
    }
    
    func vector() -> CGVector? {
        guard let (firstLocation, secondLocation) = locations else {
            return nil
        }
        
        let dx = secondLocation.x - firstLocation.x
        let dy = secondLocation.y - firstLocation.y
        
        return CGVector(dx: dx, dy: dy)
    }
    
}

private extension CGVector {
    
    func magnitude(inOrientation orientation: DirectedPinchGestureRecognizer.Orientation) -> CGFloat {
        switch orientation {
        case .Vertical:
            return abs(dy)
        case .Horizontal:
            return abs(dx)
        }
    }
    
}

