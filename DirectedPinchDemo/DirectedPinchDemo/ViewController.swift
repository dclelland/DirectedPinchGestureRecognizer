//
//  ViewController.swift
//  DirectedPinchDemo
//
//  Created by Daniel Clelland on 11/04/16.
//  Copyright © 2016 Daniel Clelland. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var pinchGestureRecognizer: DirectedPinchGestureRecognizer!
    
    @IBOutlet weak var linearScaleLabel: UILabel!
    @IBOutlet weak var geometricScaleLabel: UILabel!
    
    @IBOutlet weak var arrowLabel: UILabel!
    
    @IBOutlet weak var orientationSegmentedControl: UISegmentedControl!
    @IBOutlet weak var divergenceSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var minimumLinearScaleLabel: UILabel!
    @IBOutlet weak var minimumLinearScaleSlider: UISlider!
    
    @IBOutlet weak var minimumGeometricScaleLabel: UILabel!
    @IBOutlet weak var minimumGeometricScaleSlider: UISlider!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    // MARK: View state
    
    func updateView() {
        let currentOrientation = orientation(forIndex: orientationSegmentedControl.selectedSegmentIndex)!
        let currentDivergence = divergence(forIndex: divergenceSegmentedControl.selectedSegmentIndex)!
        
        let linearScaleText = String(format: "%.2f", pinchGestureRecognizer.linearScale())
        let geometricScaleText = String(format: "%.2f", pinchGestureRecognizer.geometricScale())
        
        linearScaleLabel.text = "Linear scale: " + linearScaleText
        geometricScaleLabel.text = "Geometric scale: " + geometricScaleText
        
        let linearScaleColor = pinchGestureRecognizer.linearScale() < pinchGestureRecognizer.minimumLinearScale ? UIColor.redColor() : UIColor.greenColor()
        let geometricScaleColor = pinchGestureRecognizer.geometricScale() < pinchGestureRecognizer.minimumGeometricScale ? UIColor.redColor() : UIColor.greenColor()

        linearScaleLabel.backgroundColor = linearScaleColor
        geometricScaleLabel.backgroundColor = geometricScaleColor

        let arrowText = arrows(forOrientation: currentOrientation, andDivergence: currentDivergence)

        arrowLabel.text = arrowText
        
        let minimumLinearScaleText = String(format: "%.2f", pinchGestureRecognizer.minimumLinearScale)
        let minimumGeometricScaleText = String(format: "%.2f", pinchGestureRecognizer.minimumGeometricScale)
        
        minimumLinearScaleLabel.text = "Minimum linear scale: " + minimumLinearScaleText
        minimumGeometricScaleLabel.text = "Minimum geometric scale: " + minimumGeometricScaleText
    }
    
    // MARK: Actions
    
    @IBAction func orientationSegmentedControlDidChangeValue(segmentedControl: UISegmentedControl) {
        updateView()
    }
    
    @IBAction func divergenceSegmentedControlDidChangeValue(segmentedControl: UISegmentedControl) {
        updateView()
    }
    
    @IBAction func minimumLinearScaleSliderDidChangeValue(slider: UISlider) {
        pinchGestureRecognizer.minimumLinearScale = minimumLinearScale(forValue: slider.value)
        updateView()
    }
    
    @IBAction func minimumGeometricScaleSliderDidChangeValue(slider: UISlider) {
        pinchGestureRecognizer.minimumGeometricScale = minimumGeometricScale(forValue: slider.value)
        updateView()
    }

}

// MARK: - Gesture recognizer delegate

extension ViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case let pinchGestureRecognizer as DirectedPinchGestureRecognizer where pinchGestureRecognizer == self.pinchGestureRecognizer:
            return pinchGestureRecognizer.orientation == orientation(forIndex: orientationSegmentedControl.selectedSegmentIndex)! && pinchGestureRecognizer.divergence == divergence(forIndex: divergenceSegmentedControl.selectedSegmentIndex)!
        default:
            return true
        }
    }
    
}

// MARK: - Directed pinch gesture recognizer delegate

extension ViewController: DirectedPinchGestureRecognizerDelegate {
    
    func directedPinchGestureRecognizerDidStart(gestureRecognizer: DirectedPinchGestureRecognizer) {
        arrowLabel.backgroundColor = UIColor.clearColor()
        updateView()
    }
    
    func directedPinchGestureRecognizerDidUpdate(gestureRecognizer: DirectedPinchGestureRecognizer) {
        arrowLabel.backgroundColor = UIColor.clearColor()
        updateView()
    }
    
    func directedPinchGestureRecognizerDidCancel(gestureRecognizer: DirectedPinchGestureRecognizer) {
        arrowLabel.backgroundColor = UIColor.redColor()
        updateView()
    }
    
    func directedPinchGestureRecognizerDidFinish(gestureRecognizer: DirectedPinchGestureRecognizer) {
        arrowLabel.backgroundColor = UIColor.greenColor()
        updateView()
    }
    
}

// MARK: - Private helpers

private extension ViewController {
    
    func orientation(forIndex index: Int) -> DirectedPinchGestureRecognizer.Orientation? {
        switch index {
        case 0:
            return .Vertical
        case 1:
            return .Horizontal
        default:
            return nil
        }
    }
    
    func divergence(forIndex index: Int) -> DirectedPinchGestureRecognizer.Divergence? {
        switch index {
        case 0:
            return .Inwards
        case 1:
            return .Outwards
        default:
            return nil
        }
    }
    
    func minimumLinearScale(forValue value: Float) -> CGFloat {
        return CGFloat(value) * view.frame.width
    }
    
    func minimumGeometricScale(forValue value: Float) -> CGFloat {
        return CGFloat(value) * 10.0
    }
    
    func arrows(forOrientation orientation: DirectedPinchGestureRecognizer.Orientation, andDivergence divergence: DirectedPinchGestureRecognizer.Divergence) -> String {
        switch (orientation, divergence) {
        case (.Vertical, .Inwards):
            return "↓\n↑"
        case (.Vertical, .Outwards):
            return "↑\n↓"
        case (.Horizontal, .Inwards):
            return "→ ←"
        case (.Horizontal, .Outwards):
            return "← →"
        }
    }
    
}

