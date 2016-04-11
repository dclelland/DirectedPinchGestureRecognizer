# DirectedPinchGestureRecognizer

DirectedPinchGestureRecognizer is a UIPinchGestureRecognizer subclass providing a richer API for working with pinch gestures.

```
let gestureRecognizer = DirectedPinchGestureRecognizer()
gestureRecognizer.delegate = self
view.addGestureRecognizer(gestureRecognizer)
```

#### Installation:

```ruby
pod 'DirectedPinchGestureRecognizer', '~> 0.1'
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
if (gestureRecognizer.initialOrientation == .Horizontal) {
    if (gestureRecognizer.orientation == .Vertical) {
        print("Gesture recognizer started pinching horizontally and then rotated to a vertical orientation")
    }
}
```

✓ Enforce the gesture's starting orientation and divergence:

*Note: This library uses the word "divergence" as a Term of Art to designate whether a pinch is moving inwards or outwards.*

```swift
func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
    switch gestureRecognizer {
    case let pinchGestureRecognizer as DirectedPinchGestureRecognizer where pinchGestureRecognizer == self.pinchGestureRecognizer
        return pinchGestureRecognizer.orientation == .Vertical && pinchGestureRecognizer.divergence == .Outwards
    default:
        return true
    }
}
```

✓ Delegate protocol methods for `start`, `update`, `cancel`, and `finish` events:

```swift
func directedPinchGestureRecognizerDidStart(gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer started")
}

func directedPinchGestureRecognizerDidUpdate(gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer updated")
}

func directedPinchGestureRecognizerDidCancel(gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer cancelled")
}

func directedPinchGestureRecognizerDidFinish(gestureRecognizer: DirectedPinchGestureRecognizer) {
    print("Gesture recognizer finished")
}
```

✓ Convenience methods for `location`, `locations`, `orientation`, `divergence`, `linearScale` (scale in points), and `geometricScale` (scale as a dimensionless unit):

```swift
let location = gestureRecognizer.location // CGPoint?
let locations = gestureRecognizer.locations // (CGPoint, CGPoint)?
let orientation = gestureRecognizer.orientation // DirectedPinchGestureRecognizer.Orientation?
let divergence = gestureRecognizer.divergence // DirectedPinchGestureRecognizer.Divergence?
let linearScale = gestureRecognizer.linearScale(inOrientation: .Vertical, andDivergence: .Outwards) // CGFloat
let geometricScale = gestureRecognizer.geometricrScale(inOrientation: .Vertical, andDivergence: .Outwards) // CGFloat
```

✓ `IBDesignable` parameters for enforcing a minimum linear/geometric scale:

```swift
gestureRecognizer.minimumLinearScale = 64.0
gestureRecognizer.minimumGeometricScale = 1.0
```

### Todo:

- Fix bugs
- Make GIF preview
- Publish to Cocoapods
- Publish to Carthage
- Publish to Cocoa controls
