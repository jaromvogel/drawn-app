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


class canvasGestures {
    
    func rotateCanvas(canvas: UIView!, containerView: UIView, sender: UIRotationGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            let touch1 = sender.locationOfTouch(0, inView: canvas)
            let touch2 = sender.locationOfTouch(1, inView: canvas)
            let frametouch1 = sender.locationOfTouch(0, inView: containerView)
            let frametouch2 = sender.locationOfTouch(1, inView: containerView)
            
            let midx = ((touch1.x + touch2.x)/2)
            let midy = ((touch1.y + touch2.y)/2)
            
            let canvasmidx = midx/canvas.frame.width
            let canvasmidy = midy/canvas.frame.height
            
            let framemidx = ((frametouch1.x + frametouch2.x)/2)
            let framemidy = ((frametouch1.y + frametouch2.y)/2)
            
            //canvas.layer.anchorPoint=CGPoint(x: canvasmidx, y: canvasmidy)
            //canvas.layer.position = CGPoint(x: framemidx, y: framemidy)
            //let transform = CGAffineTransformTranslate(canvas.transform, framemidx, framemidy)
        }

        if let view = canvas {
            var gestureRotationDegrees = rotationAngleInRadians*57.2957795
            var canvasRotationRadians = (atan2(view.transform.b, view.transform.a))
            var canvasRotationDegrees = (atan2(view.transform.b, view.transform.a) * 57.2957795)
            var rotationOffset = gestureRotationDegrees%90
            
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
    
    func zoomCanvas(canvas: UIView!, sender: UIPinchGestureRecognizer) {
        canvas.transform = CGAffineTransformScale(canvas.transform,
            sender.scale, sender.scale)
        scale = sender.scale
        sender.scale = 1
    }
    
    func panCanvas(canvas: UIView!, containerView: UIView!, sender: UIPanGestureRecognizer) {
        if sender.numberOfTouches() == 2 {
            let translation = sender.translationInView(containerView)
            canvas.center = CGPoint(x:canvas.center.x + translation.x, y:canvas.center.y + translation.y)
            sender.setTranslation(CGPointZero, inView: containerView)
        }
    }
    
}