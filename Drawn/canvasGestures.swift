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
var containerPosition = CGPoint()
var lastPosition = CGPointMake(0,0)
var anchorPoint = CGPointMake(0,0)

class canvasGestures {
    
    func rotateCanvas(canvas: UIView!, containerView: UIView, sender: UIRotationGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Began {
            
            let touch1 = sender.locationOfTouch(0, inView: canvas)
            let touch2 = sender.locationOfTouch(1, inView: canvas)
            
            let containertouch1 = sender.locationOfTouch(0, inView: containerView)
            let containertouch2 = sender.locationOfTouch(1, inView: containerView)
            
            containerPosition = CGPointMake(((containertouch1.x + containertouch2.x)/2), ((containertouch1.y + containertouch2.y)/2))
            
            let midx = ((touch1.x + touch2.x)/2)
            let midy = ((touch1.y + touch2.y)/2)
            
            let canvasmidx = midx/canvas.frame.width
            let canvasmidy = midy/canvas.frame.height
            
            anchorPoint=CGPoint(x: canvasmidx, y: canvasmidy)
            
            setAnchorPoint(anchorPoint, view: canvas, containerPosition: containerPosition)
            
            /*
            // Debugging - trying to figure out where it's putting the anchorpoint
            var rotationpoint = UIView()
            rotationpoint.frame = CGRectMake(0, 0, 30, 30)
            rotationpoint.backgroundColor = UIColor.redColor()
            rotationpoint.layer.cornerRadius = 15
            rotationpoint.center = CGPoint(x: midx, y: midy)
            rotationpoint.center = CGPoint(x: canvas.layer.anchorPoint.x * canvas.frame.width, y: canvas.layer.anchorPoint.y * canvas.frame.height)
            rotationpoint.tag = 1
            
            canvas.insertSubview(rotationpoint, atIndex: 3)
            */
        }

        if let view = canvas {
            
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
        
        /*
        // More Debugging
        if sender.state == UIGestureRecognizerState.Ended {
            for view in canvas.subviews {
                if view.tag == 1 {
                    view.removeFromSuperview()
                }
            }
        }
        */
        
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
    
    func setAnchorPoint(anchorPoint: CGPoint, view: UIView, containerPosition: CGPoint) {

    }
}