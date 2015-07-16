//
//  drawingFunctions.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/13/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore


var previousPoint1 = CGPointZero
var previousPoint2 = CGPointZero
var currentPoint = CGPoint()
var myBezier = UIBezierPath()
var startedDrawing: Bool = false
var startedShape: Bool = false
var startPoint = CGPoint()
var touchLocation = CGPoint()
var lineCounter = 0

class drawingFunctions {
    
    func tapOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            
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
            
            cache.image = nil
            
            let drawingLayer = UIImageView()
            drawingLayer.frame = canvas.frame
            
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            drawingLayer.image = UIGraphicsGetImageFromCurrentImageContext();
            if canvas.subviews.count > 0 {
                canvas.insertSubview(drawingLayer, aboveSubview: canvas.subviews.last!)
            } else {
                canvas.insertSubview(drawingLayer, atIndex: 0)
            }
            tempCache.image = nil
            UIGraphicsEndImageContext()
            
        }
        UIGraphicsEndImageContext()
    }
    
    
    func drawOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer) {
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
            
            lineCounter += 1
            
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
            
            if lineCounter == 10 {
                // possibly do some kind of prerendering then actually render to an image here?
                // CAShapeLayer might work
                lineCounter = 0
            }
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            let drawingLayer = UIImageView()
            drawingLayer.frame = canvas.frame
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            drawingLayer.image = UIGraphicsGetImageFromCurrentImageContext()
            if canvas.subviews.count > 0 {
                canvas.insertSubview(drawingLayer, aboveSubview: canvas.subviews.last!)
            } else {
                canvas.insertSubview(drawingLayer, atIndex: 0)
            }
            tempCache.image = nil
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            UIGraphicsEndImageContext()
        }
        UIGraphicsEndImageContext()
    }

    
    func buildShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer, tapToFinishButton: UIButton!, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if sender.numberOfTouches() == 1 {
            if startedShape == false {
                // if drawing hasn't started, scale tapToFinishButton to appropriate size
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1/scale, 1/scale)
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
                    finishShape(canvas, canvasContainer: canvasContainer, cache: cache, tempCache: tempCache, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
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
            // Reset tapToFinishButton Scale if it needs it
            tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1/scale, 1/scale)
        }
        UIGraphicsEndImageContext()
    }
    
    
    func finishShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, tapToFinishButton: UIButton, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if startedShape == true {
            tapToFinishButton.hidden = true
            startedShape = false
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetShouldAntialias(context, false)
            
            canvas.lineColor.setFill()
            tempCache.image = nil
            
            myBezier.fillWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            let drawingRect = CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height)

            let shapeImage = UIGraphicsGetImageFromCurrentImageContext()
            
            CGContextTranslateCTM(context, 0, canvas.frame.size.height);
            CGContextScaleCTM(context, 1.0, -1.0)
            CGContextClipToMask(context, drawingRect, shapeImage.CGImage)
            CGContextSetAlpha(context, 0.5)
            CGContextSetBlendMode(context, CGBlendMode.SoftLight)
            CGContextDrawImage(context, CGRectMake(0, 0, paper_texture.size.width, paper_texture.size.height), paper_texture.CGImage)
            CGContextSetAlpha(context, 0.2)
            CGContextSetBlendMode(context, CGBlendMode.Overlay)
            CGContextDrawImage(context, CGRectMake(0, 0, splatter_texture.size.width, splatter_texture.size.height), splatter_texture.CGImage)
            CGContextSetAlpha(context, 0.35)
            CGContextSetBlendMode(context, CGBlendMode.Difference)
            CGContextDrawImage(context, CGRectMake(0, 0, muddy_colors.size.width, muddy_colors.size.height), muddy_colors.CGImage)
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = canvas.lineOpacity
            
            myBezier.closePath()
            myBezier.removeAllPoints()
            startedDrawing = false
            UIGraphicsEndImageContext()

            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
                        
            let drawingLayer = UIImageView()
            drawingLayer.frame = canvas.frame

            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: canvas.lineOpacity)
            drawingLayer.image = UIGraphicsGetImageFromCurrentImageContext()
            if canvas.subviews.count > 0 {
                canvas.insertSubview(drawingLayer, aboveSubview: canvas.subviews.last!)
            } else {
                canvas.insertSubview(drawingLayer, atIndex: 0)
            }
            tempCache.image = nil
            UIGraphicsEndImageContext()
        }
    }
    
    
    func drawShapeOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UIPanGestureRecognizer, tapToFinishButton: UIButton!, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
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
            if startedShape == false {
                // If drawing hasn't started, scale tapToFinishButton to appropriate size
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1/scale, 1/scale)
            }
            spring(0.3, animations: { () -> Void in
                // scale tapToFinishButton a little larger while drawing
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
                // Restore tapToFinishButton to scaled state using inverse of 1.2
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 0.834, 0.834)
            })
            if ((touchLocation.x < startPoint.x + 15 && touchLocation.x > startPoint.x - 15)) && ((touchLocation.y < startPoint.y + 15) && (touchLocation.y > startPoint.y - 15)) {
                finishShape(canvas, canvasContainer: canvasContainer, cache: cache, tempCache: tempCache, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
            }
        }
        UIGraphicsEndImageContext()
    }
    
    
    func midpoint(point1: CGPoint, point2: CGPoint) -> CGPoint {
        let midx = ((point1.x + point2.x)/2)
        let midy = ((point1.y + point2.y)/2)
        return CGPointMake(midx, midy)
    }
    
    func renderLayersToCache(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!) {
        // Draw Current Canvas to Cache Image to use for color picker and saving image
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
        canvasContainer.drawViewHierarchyInRect(canvasContainer.bounds, afterScreenUpdates: false)
        cache.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
}