//
//  canvasGestures.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/13/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit


// Keep track of rotation
var rotationAngleInRadians = 0.0 as CGFloat

// Keep track of scale
var scale = 1 as CGFloat

var canvastranslated = false
var containerTouchPosition = CGPoint()
var lastPosition = CGPointMake(0,0)
var anchorPoint = CGPointMake(0,0)
var scalelabel_visible = false

class canvasGestures {
    
    func rotateCanvas(canvas: CanvasView!, canvasContainer: UIView!, gestureControlView: UIView!, sender: UIRotationGestureRecognizer!, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint, scaleLabel: UIView!) {
        
        if sender.state == UIGestureRecognizerState.Began {
            setAnchorPoint(canvas, view: canvasContainer, gestureControlView: gestureControlView, centerX: centerX, centerY: centerY, sender: sender)
        }

        if let view = canvasContainer {
            
            let gestureRotationDegrees = rotationAngleInRadians*57.2957795
            let canvasRotationRadians = (atan2(view.transform.b, view.transform.a))
            let rotationOffset = gestureRotationDegrees%90
            
            // Snap rotation to 90° points
            if (rotationOffset > -5 && rotationOffset < 5) || (rotationOffset > -90 && rotationOffset < -85) || (rotationOffset > 85 && rotationOffset < 90) {
                let anglePosition = CGFloat((round(gestureRotationDegrees/90))%4) * CGFloat(0.5)
                let π = CGFloat(M_PI)
                let snapAngle = -(canvasRotationRadians) + (π * anglePosition)
                
                view.transform = CGAffineTransformRotate(view.transform, (snapAngle))
            } else {
                view.transform = CGAffineTransformRotate(view.transform, sender.rotation)
            
            }
            
            rotationAngleInRadians += sender.rotation;
            sender.rotation = 0
        }
    }
    
    func zoomCanvas(canvas: CanvasView!, canvasContainer: UIView!, gestureControlView: UIView!, sender: UIPinchGestureRecognizer, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint, tapToFinishButton: UIButton!, scaleLabel: UIView!, scaleLabelText: UILabel) {

        if sender.state == UIGestureRecognizerState.Began {
            setAnchorPoint(canvas, view: canvasContainer, gestureControlView: gestureControlView, centerX: centerX, centerY: centerY, sender: sender)
        }
    
        let gesture_scale = scale * sender.scale
        
        if (gesture_scale >= 0.25 || sender.scale >= 1) && (gesture_scale <= 20 || sender.scale <= 1) {
            scale = scale * sender.scale
            canvasContainer.transform = CGAffineTransformScale(canvasContainer.transform, sender.scale, sender.scale)
            
            if sender.numberOfTouches() >= 2 && scalelabel_visible == false {
                scalelabel_visible = true

                let touch1 = sender.locationOfTouch(0, inView: gestureControlView)
                let touch2 = sender.locationOfTouch(1, inView: gestureControlView)

                let midx = ((touch1.x + touch2.x)/2)
                let midy = ((touch1.y + touch2.y)/2)

                scaleLabel.center = CGPoint(x: midx, y: midy)
                scaleLabel.hidden = false
                scaleLabel.transform = CGAffineTransformScale(scaleLabel.transform, CGFloat(0.1), CGFloat(0.1))
                spring(0.5, animations: {
                    scaleLabel.transform = CGAffineTransformIdentity
                })
            }
        }
        
        scaleLabel.hidden = false
        scaleLabelText.text = String(Int(round(scale * 100))) + String("%")
        tapToFinishButton.transform = CGAffineTransformIdentity
        tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1/scale, 1/scale)
        
        sender.scale = 1
        
        // Remove label when the gesture ends
        if sender.state == UIGestureRecognizerState.Ended {
            scalelabel_visible = false
            springComplete(0.5, animations: {
                scaleLabel.transform = CGAffineTransformScale(scaleLabel.transform, 0.1, 0.1)
                scaleLabel.alpha = 0
            }, completion: {
                (value: Bool) in
                scaleLabel.hidden = true
                scaleLabel.alpha = 0.9
            })
        }
    }
    
    func panCanvas(canvas: UIView!, containerView: UIView!, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint, sender: UIPanGestureRecognizer, scaleLabel: UIView!) {
        if sender.numberOfTouches() == 2 {
            let translation = sender.translationInView(containerView)
            centerX.constant = centerX.constant + translation.x
            centerY.constant = centerY.constant + translation.y
            canvas.center = CGPoint(x:canvas.center.x + translation.x, y:canvas.center.y + translation.y)
            scaleLabel.center = canvas.center
            sender.setTranslation(CGPointZero, inView: containerView)
        }
    }
    
    func setAnchorPoint(canvas: CanvasView!, view: UIView, gestureControlView: UIView!, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint, sender: AnyObject) {
        
        let containertouch1 = sender.locationOfTouch(0, inView: gestureControlView)
        let containertouch2 = sender.locationOfTouch(1, inView: gestureControlView)
        
        containerTouchPosition = CGPointMake(((containertouch1.x + containertouch2.x)/2), ((containertouch1.y + containertouch2.y)/2))
        
        let touch1 = sender.locationOfTouch(0, inView: view)
        let touch2 = sender.locationOfTouch(1, inView: view)
        
        let midx = ((touch1.x + touch2.x)/2)
        let midy = ((touch1.y + touch2.y)/2)
        
        let canvasmidx = midx/canvas.frame.width
        let canvasmidy = midy/canvas.frame.height
        
        anchorPoint = CGPoint(x: canvasmidx, y: canvasmidy)
        
        var newPoint: CGPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint: CGPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position: CGPoint = view.layer.position
        
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        //view.translatesAutoresizingMaskIntoConstraints = true     // Added to deal with auto layout constraints
        view.layer.anchorPoint = anchorPoint
        view.layer.position = position
        centerX.constant = -canvas.frame.width/2 + view.layer.position.x
        centerY.constant = -canvas.frame.height/2 + view.layer.position.y
    }
}