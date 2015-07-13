//
//  drawingFunctions.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/13/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit


var previousPoint1 = CGPointZero
var previousPoint2 = CGPointZero
var currentPoint = CGPoint()
var myBezier = UIBezierPath()
var startedDrawing: Bool = false
var startedShape: Bool = false
var startPoint = CGPoint()
var touchLocation = CGPoint()

class drawingFunctions {
    
    func tapOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            
            //UIGraphicsBeginImageContext(canvas.frame.size)
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            myBezier.setLineDash(nil, count: 0, phase: 0)
            myBezier.lineCapStyle = CGLineCap.Round
            myBezier.lineWidth = canvas.lineWeight
            canvas.lineColor.setStroke()
            
            touchLocation = sender.locationInView(canvas)

            myBezier.moveToPoint(touchLocation)
            myBezier.addLineToPoint(touchLocation)
            myBezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            UIGraphicsEndImageContext()
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    
    func drawOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer) {
        //UIGraphicsBeginImageContext(canvas.frame.size)
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
        
        myBezier.setLineDash(nil, count: 0, phase: 0)
        myBezier.lineCapStyle = CGLineCap.Round
        myBezier.lineWidth = canvas.lineWeight
        canvas.lineColor.setStroke()
        
        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            
            previousPoint2 = previousPoint1
            previousPoint1 = currentPoint
            currentPoint = sender.locationInView(canvas)
            
            let mid1 = midpoint(previousPoint1, point2: previousPoint2)
            let mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            if startedDrawing == false {
                myBezier.moveToPoint(CGPoint(x: mid1.x, y: mid1.y))
                startedDrawing = true
            }
            myBezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            myBezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
    }

    
    func buildShape(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer, tapToFinishButton: UIButton!) {
        if sender.numberOfTouches() == 1 {
            if startedShape == false {
                startedShape = true
            }
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            let pattern: [CGFloat] = [1.0, 4.0]
            myBezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
            myBezier.lineCapStyle = CGLineCap.Round
            myBezier.lineWidth = CGFloat(1.0)
            canvas.lineColor.setStroke()
            canvas.lineColor.setFill()
            
            touchLocation = sender.locationInView(canvas)
            
            if startedDrawing == false {
                myBezier.moveToPoint(touchLocation)
                startPoint = touchLocation
                tapToFinishButton.hidden = false
                tapToFinishButton.center = touchLocation
                tapToFinishButton.layer.borderWidth = CGFloat(2.0)
                let bordercolor = UIColor(hue: 0.45, saturation: 0.8, brightness: 0.8, alpha: 1.0).CGColor
                tapToFinishButton.layer.borderColor = bordercolor
                startedDrawing = true
            } else if startedDrawing == true {
                if ((touchLocation.x < startPoint.x + 10 && touchLocation.x > startPoint.x - 10)) && ((touchLocation.y < startPoint.y + 10) && (touchLocation.y > startPoint.y - 10)) {
                    finishShape(canvas, cache: cache, tempCache: tempCache, tapToFinishButton: tapToFinishButton)
                } else {
                    myBezier.addLineToPoint(touchLocation)
                    myBezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
                    tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
                    tempCache.alpha = canvas.lineOpacity
                    
                    UIGraphicsEndImageContext()
                }
            }
        }
        if sender.state == UIGestureRecognizerState.Ended {
            tapToFinishButton.transform = CGAffineTransformIdentity
        }
        UIGraphicsEndImageContext()
    }
    
    
    func finishShape(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, tapToFinishButton: UIButton) {
        if startedShape == true {
            tapToFinishButton.hidden = true
            startedShape = false
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            for view in canvas.subviews {
                if view.tag == 1 {
                    view.removeFromSuperview()
                }
            }
            
            canvas.lineColor.setFill()
            tempCache.image = nil
            
            myBezier.fillWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
    }
    
    
    func drawShapeOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer, tapToFinishButton: UIButton!) {
        //UIGraphicsBeginImageContext(canvas.frame.size)
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)

        let pattern: [CGFloat] = [1.0, 4.0]
        myBezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
        myBezier.lineCapStyle = CGLineCap.Round
        myBezier.lineWidth = CGFloat(1.0)
        canvas.lineColor.setStroke()
        canvas.lineColor.setFill()
        
        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)
            spring(0.3, animations: { () -> Void in
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1.2, 1.2)
            })
        } else if sender.state == UIGestureRecognizerState.Changed {
            previousPoint2 = previousPoint1
            previousPoint1 = currentPoint
            currentPoint = sender.locationInView(canvas)
            
            let mid1 = midpoint(previousPoint1, point2: previousPoint2)
            let mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            touchLocation = CGPointMake(mid1.x, mid1.y)

            if startedDrawing == false {

                myBezier.moveToPoint(touchLocation)
                
                startPoint = touchLocation
                tapToFinishButton.hidden = false
                tapToFinishButton.center = touchLocation
                tapToFinishButton.layer.borderWidth = CGFloat(2.0)
                let bordercolor = UIColor(hue: 0.45, saturation: 0.8, brightness: 0.8, alpha: 1.0).CGColor
                tapToFinishButton.layer.borderColor = bordercolor
                
                startedDrawing = true
                startedShape = true
            }
            myBezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            myBezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity

            UIGraphicsEndImageContext()

        } else if sender.state == UIGestureRecognizerState.Ended {
            spring(0.3, animations: { () -> Void in
                tapToFinishButton.transform = CGAffineTransformIdentity
            })
            if ((touchLocation.x < startPoint.x + 15 && touchLocation.x > startPoint.x - 15)) && ((touchLocation.y < startPoint.y + 15) && (touchLocation.y > startPoint.y - 15)) {
                finishShape(canvas, cache: cache, tempCache: tempCache, tapToFinishButton: tapToFinishButton)
            }
        }
        UIGraphicsEndImageContext()
    }
    
    
    func midpoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
        let midx = ((point1.x + point2.x)/2)
        let midy = ((point1.y + point2.y)/2)
        return CGPointMake(midx, midy)
    }
    
}