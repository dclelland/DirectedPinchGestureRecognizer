# DirectedPinchGestureRecognizer

DirectedPinchGestureRecognizer is a UIPinchGestureRecognizer subclass providing a richer API for working with pinch gestures in Swift 3.

```
let gestureRecognizer = DirectedPinchGestureRecognizer()
gestureRecognizer.delegate = self
view.addGestureRecognizer(gestureRecognizer)
```

#### Installation:

```ruby
pod 'DirectedPinchGestureRecognizer', '~> 1.0'
```

#### Usage:

```swift
let gestureRecognizer = DirectedPinchGestureRecognizer()
gestureRecognizer.delegate = self
view.addGestureRecognizer(gestureRecognizer)
```

### Features:

✓ Keeps track of the initial state of the gesture:

```swift
if (gestureRecognizer.initialAxis == .horizontal) {
    if (gestureRecognizer.axis == .vertical) {
        print("Gesture recognizer started pinching horizontally and then rotated to a vertical axis")
    }
}
```

✓ Enforce the gesture's starting direction and axisx:

```swift
func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch gestureRecognizer {
    case let pinchGestureRecognizer as DirectedPinchGestureRecognizer where pinchGestureRecognizer == self.pinchGestureRecognizer
        return pinchGestureRecognizer.direction == .outwards && pinchGestureRecognizer.axis == .vertical
    default:
        return true
    }
}
```

✓ Delegate protocol methods for `start`, `update`, `cancel`, and `finish` events:

```swift
func directedPinchGestureRecognizer(didStart gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer started")
}

func directedPinchGestureRecognizer(didUpdate gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer updated")
}

func directedPinchGestureRecognizer(didCancel gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer cancelled")
}

func directedPinchGestureRecognizer(didFinish gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer finished")
}
```

✓ Convenience methods for `location`, `locations`, `direction`, `axis`, `linearScale` (scale in points), and `geometricScale` (scale as a dimensionless unit):

```swift
let location = gestureRecognizer.location // CGPoint?
let locations = gestureRecognizer.locations // (CGPoint, CGPoint)?
let direction = gestureRecognizer.direction // DirectedPinchGestureRecognizer.Direction?
let axis = gestureRecognizer.axis // DirectedPinchGestureRecognizer.Axis?
let linearScale = gestureRecognizer.linearScale(inAxis: .vertical, andDirection: .outwards) // CGFloat
let geometricScale = gestureRecognizer.geometricrScale(inAxis: .vertical, andDirection: .outwards) // CGFloat
```

✓ `IBDesignable` parameters for enforcing a minimum linear/geometric scale:

```swift
gestureRecognizer.minimumLinearScale = 64.0
gestureRecognizer.minimumGeometricScale = 1.0
```
