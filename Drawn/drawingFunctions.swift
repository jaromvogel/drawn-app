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

class drawingFunctions {
    
    func tapOnCanvas(canvas: CanvasView!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            let touchLocation = sender.locationInView(canvas)
            canvas.lines.append(Line(
                start: touchLocation,
                end: touchLocation,
                ctr1: touchLocation,
                ctr2: touchLocation,
                color: canvas.lineColor,
                weight: canvas.lineWeight,
                opacity: canvas.lineOpacity
            ))
            canvas.setNeedsDisplay()
        }
    }
    
    func drawOnCanvas(canvas: CanvasView!, cache: UIImageView!, sender: UIPanGestureRecognizer) {
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
            
            canvas.lines.append(Line(
                start: mid1,
                end: mid2,
                ctr1: previousPoint1,
                ctr2: previousPoint2,
                color: canvas.lineColor,
                weight: canvas.lineWeight,
                opacity: canvas.lineOpacity
                ))
            
            //UIGraphicsBeginImageContext(canvas.frame.size)
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()
            
            for line in canvas.lines {
                var myBezier = UIBezierPath()
                myBezier.lineCapStyle = kCGLineCapRound
                myBezier.moveToPoint(CGPoint(x: line.start.x, y: line.start.y))
                myBezier.addQuadCurveToPoint(line.end, controlPoint: line.ctr1)
                line.color.setStroke()
                myBezier.lineWidth = line.weight
                myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: line.opacity)
                myBezier.closePath()
            }
            
            cache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            cache.image = UIGraphicsGetImageFromCurrentImageContext()
            
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            canvas.lines.removeAll(keepCapacity: true)
            cache.alpha = CGFloat(1)
            UIGraphicsEndImageContext()
            canvas.setNeedsDisplay()
        }
    }
    
    func midpoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
        var midx = ((point1.x + point2.x)/2)
        var midy = ((point1.y + point2.y)/2)
        return CGPointMake(midx, midy)
    }
    
}