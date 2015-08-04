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

var previousPoint1Lower = CGPointZero
var previousPoint2Lower = CGPointZero
var currentPointLower = CGPoint()

var temp_bezier = UIBezierPath()
var full_bezier = UIBezierPath()

var top_bezier = UIBezierPath()
var bottom_bezier = UIBezierPath()

var startedDrawing: Bool = false
var startedShape: Bool = false
var startPoint = CGPoint()
var touchLocation = CGPoint()
var lineCounter = 0

class drawingFunctions {
    
    func tapOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, shapelayer: CAShapeLayer!, sender: UITapGestureRecognizer) {
        if sender.numberOfTouches() == 1 {
            
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            let newlayer = CAShapeLayer()
            canvas.layer.insertSublayer(newlayer, below: shapelayer)
            
            newlayer.lineDashPattern = nil
            newlayer.lineCap = kCALineCapRound
            newlayer.lineWidth = lineWeight
            newlayer.opacity = Float(lineOpacity)
            newlayer.strokeColor = selectedcolor.value.CGColor
            
            touchLocation = sender.locationInView(canvas)

            temp_bezier.moveToPoint(touchLocation)
            temp_bezier.addLineToPoint(touchLocation)
            temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
            
            newlayer.path = temp_bezier.CGPath
            
            UIGraphicsEndImageContext()
            
            temp_bezier.closePath()
            temp_bezier.removeAllPoints()
            
        }
    }
    
    
    func drawOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, pencil_texture: UIImage!, shapelayer: CAShapeLayer!, sender: UIPanGestureRecognizer) {
        
        if drawingstyle.value == "pencil" {
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)

            if sender.state == UIGestureRecognizerState.Began {
                let texture_layer = CALayer()
                texture_layer.frame = canvas.frame
                canvas.layer.insertSublayer(texture_layer, below: shapelayer)
                texture_layer.contents = pencil_texture.CGImage
                texture_layer.mask = shapelayer
                
                currentPoint = sender.locationInView(canvas)
                previousPoint1 = sender.locationInView(canvas)
                previousPoint2 = sender.locationInView(canvas)
                temp_bezier.moveToPoint(currentPoint)
                full_bezier.moveToPoint(currentPoint)
                startedDrawing = true
                shapelayer.lineDashPattern = nil
            
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
                
                if lineCounter == 2000 {
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
        
        if drawingstyle.value == "brush" {
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            
            if sender.state == UIGestureRecognizerState.Began {
                let topPoint = dynamicPoint(sender, canvas: canvas, type: "upper")
                let bottomPoint = dynamicPoint(sender, canvas: canvas, type: "lower")
                currentPoint = topPoint
                previousPoint1 = topPoint
                previousPoint2 = topPoint
                currentPointLower = bottomPoint
                previousPoint1Lower = bottomPoint
                previousPoint2Lower = bottomPoint
                top_bezier.moveToPoint(currentPoint)
                bottom_bezier.moveToPoint(currentPoint)
                startedDrawing = true
                shapelayer.lineDashPattern = nil
            }
            else if sender.state == UIGestureRecognizerState.Changed {
                
                previousPoint2 = previousPoint1
                previousPoint1 = currentPoint
                currentPoint = dynamicPoint(sender, canvas: canvas, type: "upper")
                
                previousPoint2Lower = previousPoint1Lower
                previousPoint1Lower = currentPointLower
                currentPointLower = dynamicPoint(sender, canvas: canvas, type: "lower")
                
                let mid2 = midpoint(currentPoint, point2: previousPoint1)
                let mid2lower = midpoint(currentPointLower, point2: previousPoint1Lower)
                
                top_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
                top_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
                bottom_bezier.addQuadCurveToPoint(mid2lower, controlPoint: previousPoint1Lower)
                bottom_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: CGFloat(1.0))
                
                //let reverse_bezier = bottom_bezier.bezierPathByReversingPath()
                //top_bezier.appendPath(bottom_bezier)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                shapelayer.strokeColor = selectedcolor.value.CGColor
                shapelayer.fillColor = nil
                shapelayer.lineWidth = lineWeight
                shapelayer.lineCap = kCALineCapRound
                shapelayer.opacity = Float(lineOpacity)
                shapelayer.path = bottom_bezier.CGPath
                CATransaction.commit()
            }
            else if sender.state == UIGestureRecognizerState.Ended {
                // Make a copy of shape layer and add it to canvas.layer
                let newlayer = CAShapeLayer()
                canvas.layer.insertSublayer(newlayer, below: shapelayer)
                
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                newlayer.strokeColor = nil
                newlayer.fillColor = selectedcolor.value.CGColor
                newlayer.lineWidth = lineWeight
                newlayer.lineCap = kCALineCapRound
                newlayer.opacity = Float(lineOpacity)
                newlayer.path = bottom_bezier.CGPath
                CATransaction.commit()
                
                // Close Path
                top_bezier.closePath()
                bottom_bezier.closePath()
                // Remove Bezier Points
                top_bezier.removeAllPoints()
                bottom_bezier.removeAllPoints()
                // Clear shapelayer to be drawn in again
                shapelayer.path = nil
                shapelayer.sublayers?.removeAll()
                
                startedDrawing = false
            }
            UIGraphicsEndImageContext()
        }
        
    }

    func dynamicPoint(sender: UIPanGestureRecognizer, canvas: CanvasView, type: String!) -> CGPoint {
//        let slope = sender.velocityInView(canvas).y / sender.velocityInView(canvas).x

        let perp_slope = -sender.velocityInView(canvas).x / sender.velocityInView(canvas).y

        let magnitude = (abs(sender.velocityInView(canvas).x) + abs(sender.velocityInView(canvas).y)) / 2
        
        var adjusted_magnitude = ((magnitude / 750) * 10) + 1
        
        if type == "lower" {
            adjusted_magnitude = -adjusted_magnitude
        }
        
        let r = sqrt(1 + pow(Double(perp_slope), Double(2)))
        let x1 = sender.locationInView(canvas).x + adjusted_magnitude / CGFloat(r)
        let y1 = sender.locationInView(canvas).y + 3 * adjusted_magnitude / CGFloat(r)
        
        return (CGPointMake(x1, y1))
    }
    
    func buildShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, sender: UITapGestureRecognizer, shapelayer: CAShapeLayer!, tapToFinishButton: UIButton!, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if sender.numberOfTouches() == 1 {
            if startedShape == false {
                startedShape = true
            }
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)
            //tempCache.image?.drawInRect(CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height))
            
            let pattern: [CGFloat] = [0.05, 3.0]
            
            shapelayer.lineDashPattern = pattern
            shapelayer.lineCap = kCALineCapRound
            shapelayer.lineWidth = CGFloat(1.0)
            shapelayer.strokeColor = selectedcolor.value.CGColor

            touchLocation = sender.locationInView(canvas)
            
            if startedDrawing == false {
                temp_bezier.moveToPoint(touchLocation)
                full_bezier.moveToPoint(touchLocation)
                startPoint = touchLocation
                tapToFinishButton.hidden = false
                tapToFinishButton.center = touchLocation
                tapToFinishButton.layer.borderWidth = CGFloat(2.0)
                let bordercolor = UIColor(hue: 0.45, saturation: 0.8, brightness: 0.8, alpha: 1.0).CGColor
                tapToFinishButton.layer.borderColor = bordercolor
                startedDrawing = true
            } else if startedDrawing == true {
                if ((touchLocation.x < startPoint.x + 10 && touchLocation.x > startPoint.x - 10)) && ((touchLocation.y < startPoint.y + 10) && (touchLocation.y > startPoint.y - 10)) {
                    finishShape(canvas, canvasContainer: canvasContainer, cache: cache, tempCache: tempCache, shapelayer: shapelayer, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
                } else {
                    temp_bezier.addLineToPoint(touchLocation)
                    full_bezier.addLineToPoint(touchLocation)
                    temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
                    full_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
                    shapelayer.path = temp_bezier.CGPath
                    
                    UIGraphicsEndImageContext()
                }
            }
        }
        UIGraphicsEndImageContext()
    }
    
    
    func finishShape(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, shapelayer: CAShapeLayer!, tapToFinishButton: UIButton, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        if startedShape == true {
            tapToFinishButton.hidden = true
            
            startedShape = false
            
            let newlayer = CAShapeLayer()
            
            let texturelayer = CALayer()
            texturelayer.frame = canvas.frame

            // Begin create texture section
            // It might be better to do all of this when I choose a color rather than every time I draw a shape
            UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 2.0)
            
            let context = UIGraphicsGetCurrentContext()
            CGContextSetShouldAntialias(context, true)

            let drawingRect = CGRect(x: 0, y: 0, width: canvas.frame.size.width, height: canvas.frame.size.height)

            selectedcolor.value.setFill()
            UIRectFillUsingBlendMode(drawingRect, CGBlendMode.Normal)
            
            CGContextTranslateCTM(context, 0, canvas.frame.size.height);
            CGContextScaleCTM(context, 1.0, -1.0)
            CGContextSetAlpha(context, 0.5)
            CGContextSetBlendMode(context, CGBlendMode.SoftLight)
            CGContextDrawImage(context, CGRectMake(0, 0, paper_texture.size.width, paper_texture.size.height), paper_texture.CGImage)
            CGContextSetAlpha(context, 0.2)
            CGContextSetBlendMode(context, CGBlendMode.Overlay)
            CGContextDrawImage(context, CGRectMake(0, 0, splatter_texture.size.width, splatter_texture.size.height), splatter_texture.CGImage)
            CGContextSetAlpha(context, 0.25)
            CGContextSetBlendMode(context, CGBlendMode.SoftLight)
            CGContextDrawImage(context, CGRectMake(0, 0, muddy_colors.size.width, muddy_colors.size.height), muddy_colors.CGImage)
            // End create texture section
            
            texturelayer.contents = UIGraphicsGetImageFromCurrentImageContext().CGImage
            canvas.layer.insertSublayer(texturelayer, below: shapelayer)
            
            UIGraphicsEndImageContext()
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            newlayer.strokeColor = nil
            newlayer.fillColor = selectedcolor.value.CGColor
            newlayer.lineWidth = lineWeight
            newlayer.lineCap = kCALineCapRound
            newlayer.opacity = Float(lineOpacity)
            newlayer.path = temp_bezier.CGPath
            CATransaction.commit()
            
            texturelayer.mask = newlayer
            
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
    }
    
    
    func drawShapeOnCanvas(canvas: CanvasView!, canvasContainer: UIView!, cache: UIImageView!, tempCache: UIImageView!, shapelayer: CAShapeLayer!, sender: UIPanGestureRecognizer, tapToFinishButton: UIButton!, paper_texture: UIImage!, muddy_colors: UIImage!, splatter_texture: UIImage!) {
        UIGraphicsBeginImageContextWithOptions(canvas.frame.size, false, 0.0)

        let pattern: [CGFloat] = [0.05, 3.0]
        
        shapelayer.lineDashPattern = pattern
        shapelayer.lineCap = kCALineCapRound
        shapelayer.lineWidth = CGFloat(1.0)
        shapelayer.strokeColor = selectedcolor.value.CGColor
        
        if sender.state == UIGestureRecognizerState.Began {
            currentPoint = sender.locationInView(canvas)
            previousPoint1 = sender.locationInView(canvas)
            previousPoint2 = sender.locationInView(canvas)

            if startedShape == true {
                let mid2 = midpoint(currentPoint, point2: previousPoint1)

                temp_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
                full_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
                temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
                full_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
            } else {
                temp_bezier.moveToPoint(currentPoint)
                full_bezier.moveToPoint(currentPoint)
                tapToFinishButton.hidden = false
                tapToFinishButton.center = currentPoint
                tapToFinishButton.layer.borderWidth = CGFloat(2.0)
                let bordercolor = UIColor(hue: 0.45, saturation: 0.8, brightness: 0.8, alpha: 1.0).CGColor
                tapToFinishButton.layer.borderColor = bordercolor
                startPoint = currentPoint
                startedShape = true
                startedDrawing = true
            }

            lineCounter = 0
            
            spring(0.3, animations: { () -> Void in
                // scale tapToFinishButton a little larger while drawing
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 1.2, 1.2)
            })
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            lineCounter += 1
            
            previousPoint2 = previousPoint1
            previousPoint1 = currentPoint
            currentPoint = sender.locationInView(canvas)
            
            let mid2 = midpoint(currentPoint, point2: previousPoint1)
            
            temp_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            full_bezier.addQuadCurveToPoint(mid2, controlPoint: previousPoint1)
            temp_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
            full_bezier.strokeWithBlendMode(CGBlendMode.Normal, alpha: 1.0)
            
            shapelayer.path = temp_bezier.CGPath

            if lineCounter == 100 {
                let lastpoint = temp_bezier.currentPoint
                let segmentlayer = CAShapeLayer()
                shapelayer.addSublayer(segmentlayer)
                segmentlayer.lineDashPattern = pattern
                segmentlayer.lineCap = kCALineCapRound
                segmentlayer.lineWidth = CGFloat(1.0)
                segmentlayer.strokeColor = selectedcolor.value.CGColor
                temp_bezier.closePath()
                temp_bezier.removeAllPoints()
                temp_bezier.moveToPoint(lastpoint)
                shapelayer.path = nil
                lineCounter = 0
            }
            
            UIGraphicsEndImageContext()

        } else if sender.state == UIGestureRecognizerState.Ended {
            spring(0.3, animations: { () -> Void in
                // Restore tapToFinishButton to scaled state using inverse of 1.2
                tapToFinishButton.transform = CGAffineTransformScale(tapToFinishButton.transform, 0.834, 0.834)
            })
            if ((currentPoint.x < startPoint.x + 15 && currentPoint.x > startPoint.x - 15)) && ((currentPoint.y < startPoint.y + 15) && (currentPoint.y > startPoint.y - 15)) {
                finishShape(canvas, canvasContainer: canvasContainer, cache: cache, tempCache: tempCache, shapelayer: shapelayer, tapToFinishButton: tapToFinishButton, paper_texture: paper_texture, muddy_colors: muddy_colors, splatter_texture: splatter_texture)
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