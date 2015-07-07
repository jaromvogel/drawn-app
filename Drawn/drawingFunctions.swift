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

class drawingFunctions {
    
    func tapOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            
            //UIGraphicsBeginImageContext(canvas.frame.size)
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            myBezier.lineCapStyle = kCGLineCapRound
            myBezier.lineWidth = canvas.lineWeight
            canvas.lineColor.setStroke()
            
            let touchLocation = sender.locationInView(canvas)

            myBezier.moveToPoint(touchLocation)
            myBezier.addQuadCurveToPoint(touchLocation, controlPoint: touchLocation)
            myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            UIGraphicsEndImageContext()
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            canvas.setNeedsDisplay()
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
    }
    
    
    func buildShape(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            if startedShape == false {
                startedShape = true
            }
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            let pattern: [CGFloat] = [1.0, 4.0]
            myBezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
            myBezier.lineCapStyle = kCGLineCapRound
            myBezier.lineWidth = CGFloat(1.0)
            canvas.lineColor.setStroke()
            canvas.lineColor.setFill()
            
            let touchLocation = sender.locationInView(canvas)
            
            if startedDrawing == false {
                myBezier.moveToPoint(touchLocation)
                startedDrawing = true
            }
            myBezier.addLineToPoint(touchLocation)
            myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: 1.0)
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            
            UIGraphicsEndImageContext()
        }
    }
    
    
    func finishShape(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!) {
        if startedShape == true {
            startedShape = false
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            canvas.lineColor.setFill()
            tempCache.image = nil
            
            myBezier.fillWithBlendMode(kCGBlendModeNormal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            
            canvas.setNeedsDisplay()
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
    }
    
    
    func drawOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer) {
        
        //UIGraphicsBeginImageContext(canvas.frame.size)
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
        tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
        
        myBezier.setLineDash(nil, count: 0, phase: 0)
        myBezier.lineCapStyle = kCGLineCapRound
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
            
            var mid1 = midpoint(previousPoint1, point2: previousPoint2)
            var mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            if startedDrawing == false {
                myBezier.moveToPoint(CGPoint(x: mid1.x, y: mid1.y))
                startedDrawing = true
            }
            myBezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: CGFloat(1.0))

            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            UIGraphicsEndImageContext()
            
            canvas.setNeedsDisplay()
            
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
        }
    }
    
    
    func drawShapeOnCanvas(canvas: CanvasView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer) {
        //UIGraphicsBeginImageContext(canvas.frame.size)
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
        tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))

        let pattern: [CGFloat] = [1.0, 4.0]
        myBezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
        myBezier.lineCapStyle = kCGLineCapRound
        myBezier.lineWidth = CGFloat(1.0)
        canvas.lineColor.setStroke()
        canvas.lineColor.setFill()
        
        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            previousPoint2 = previousPoint1
            previousPoint1 = currentPoint
            currentPoint = sender.locationInView(canvas)
            
            var mid1 = midpoint(previousPoint1, point2: previousPoint2)
            var mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            if startedDrawing == false {
                myBezier.moveToPoint(CGPoint(x: mid1.x, y: mid1.y))
                startedDrawing = true
            }
            myBezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: 1.0)
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity

            UIGraphicsEndImageContext()

        }
        else if sender.state == UIGestureRecognizerState.Ended && startedShape == false {
            UIColor.clearColor().setStroke()
            tempCache.image = nil
            UIGraphicsEndImageContext()

            myBezier.fillWithBlendMode(kCGBlendModeNormal, alpha: CGFloat(1.0))

            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            
            canvas.setNeedsDisplay()
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: CGFloat(1.0))
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: kCGBlendModeNormal, alpha: canvas.lineOpacity)
            cache.image = UIGraphicsGetImageFromCurrentImageContext();
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
    }
    
    
    func midpoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
        var midx = ((point1.x + point2.x)/2)
        var midy = ((point1.y + point2.y)/2)
        return CGPointMake(midx, midy)
    }
    
}