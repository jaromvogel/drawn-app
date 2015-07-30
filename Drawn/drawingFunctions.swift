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
var temp_bezier = UIBezierPath()
var full_bezier = UIBezierPath()
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
            
            temp_bezier.setLineDash(nil, count: 0, phase: 0)
            temp_bezier.lineCapStyle = CGLineCap.Round
            temp_bezier.lineWidth = lineWeight
            selectedcolor.value.setStroke()
            
            touchLocation = sender.locationInView(canvas)

            temp_bezier.moveToPoint(touchLocation)
            temp_bezier.addLineToPoint(touchLocation)
            temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = lineOpacity
            UIGraphicsEndImageContext()
            
            temp_bezier.closePath()
            temp_bezier.removeAllPoints()
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            cache.image = nil
            
            let drawingLayer = UIImageView()
            drawingLayer.frame = canvas.frame
            
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: lineOpacity)
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
    
    
    func drawOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, shapelayer: CAShapeLayer!, sender: UIPanGestureRecognizer) {
       
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)

        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)
            temp_bezier.moveToPoint(currentPoint)
            full_bezier.moveToPoint(currentPoint)
            startedDrawing = true
        }
        else if sender.state == UIGestureRecognizerState.Changed {
            
            lineCounter += 1
            
            previousPoint2 = previousPoint1
            previousPoint1 = currentPoint
            currentPoint = sender.locationInView(canvas)
            
            let mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            temp_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            full_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            full_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            styleStroke(shapelayer, path: temp_bezier, opacity: lineOpacity)
            
            if lineCounter == 500 {
                let lastpoint = temp_bezier.currentPoint
                let segmentlayer = CAShapeLayer()
                shapelayer.addSublayer(segmentlayer)
                styleStroke(segmentlayer, path: temp_bezier, opacity: 1.0)
                temp_bezier.closePath()
                temp_bezier.removeAllPoints()
                temp_bezier.moveToPoint(lastpoint)
                shapelayer.path = nil
                lineCounter = 0
            }
        }
        else if sender.state == UIGestureRecognizerState.Ended {
            // Make a copy of shape layer and add it to canvas.layer
            let newlayer = CAShapeLayer()
            canvas.layer.insertSublayer(newlayer, below: shapelayer)
            styleStroke(newlayer, path: full_bezier, opacity: lineOpacity)
            // Close Path
            temp_bezier.closePath()
            full_bezier.closePath()
            // Remove Bezier Points
            temp_bezier.removeAllPoints()
            full_bezier.removeAllPoints()
            // Clear shapelayer to be drawn in again
            shapelayer.path = nil
            shapelayer.sublayers?.removeAll()
            
            startedDrawing = false
        }
        UIGraphicsEndImageContext()
    }

    
    func buildShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer, tapToFinishButton: UIButton!, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if sender.numberOfTouches() == 1 {
            if startedShape == false {
                startedShape = true
            }
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            let pattern: [CGFloat] = [1.0, 4.0]
            temp_bezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
            temp_bezier.lineCapStyle = CGLineCap.Round
            temp_bezier.lineWidth = CGFloat(1.0)
            selectedcolor.value.setStroke()
            selectedcolor.value.setFill()
            
            touchLocation = sender.locationInView(canvas)
            
            if startedDrawing == false {
                temp_bezier.moveToPoint(touchLocation)
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
                    temp_bezier.addLineToPoint(touchLocation)
                    temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
                    tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
                    tempCache.alpha = lineOpacity
                    
                    UIGraphicsEndImageContext()
                }
            }
        }
        UIGraphicsEndImageContext()
    }
    
    
    func finishShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, tapToFinishButton: UIButton, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if startedShape == true {
            tapToFinishButton.hidden = true
            startedShape = false
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetShouldAntialias(context, true)
            
            selectedcolor.value.setFill()
            tempCache.image = nil
            
            temp_bezier.fillWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
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
            CGContextSetAlpha(context, 0.25)
            CGContextSetBlendMode(context, CGBlendMode.SoftLight)
            CGContextDrawImage(context, CGRectMake(0, 0, muddy_colors.size.width, muddy_colors.size.height), muddy_colors.CGImage)
            
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = lineOpacity
            
            temp_bezier.closePath()
            temp_bezier.removeAllPoints()
            startedDrawing = false
            UIGraphicsEndImageContext()

            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
                        
            let drawingLayer = UIImageView()
            drawingLayer.frame = canvas.frame

            tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height), blendMode: CGBlendMode.Normal, alpha: lineOpacity)
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
        temp_bezier.setLineDash(pattern, count: 2, phase: CGFloat(2.0))
        temp_bezier.lineCapStyle = CGLineCap.Round
        temp_bezier.lineWidth = CGFloat(1.0)
        selectedcolor.value.setStroke()
        selectedcolor.value.setFill()
        
        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)
            
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

                temp_bezier.moveToPoint(touchLocation)
                
                startPoint = touchLocation
                tapToFinishButton.hidden = false
                tapToFinishButton.center = touchLocation
                tapToFinishButton.layer.borderWidth = CGFloat(2.0)
                let bordercolor = UIColor(hue: 0.45, saturation: 0.8, brightness: 0.8, alpha: 1.0).CGColor
                tapToFinishButton.layer.borderColor = bordercolor
                
                startedDrawing = true
                startedShape = true
            }
            temp_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
            tempCache.image = UIGraphicsGetImageFromCurrentImageContext()
            tempCache.alpha = lineOpacity

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
    
    
    func styleStroke(layer: CAShapeLayer, path: UIBezierPath, opacity: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        layer.strokeColor = selectedcolor.value.CGColor
        layer.fillColor = nil
        layer.lineWidth = lineWeight
        layer.lineCap = kCALineCapRound
        layer.opacity = Float(opacity)
        layer.path = path.CGPath
        CATransaction.commit()
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