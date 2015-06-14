//
//  CanvasView.swift
//  chatbook
//
//  Created by Jarom Vogel on 4/10/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import UIKit

class CanvasView: UIView {

    var lines: [Line] = []
    var lastPoint: CGPoint!
    var lineColor = UIColor.blackColor()
    var lineWeight = CGFloat(7.0)
    var lineOpacity = CGFloat(1.0)
    var incrementalImage = UIImage()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // your initialization code here
    }

    override func drawRect(rect: CGRect) {
        for line in lines {
            var myBezier = UIBezierPath()
            myBezier.lineCapStyle = kCGLineCapRound
            myBezier.moveToPoint(CGPoint(x: line.start.x, y: line.start.y))
            myBezier.addQuadCurveToPoint(line.end, controlPoint: line.ctr1)
            line.color.setStroke()
            myBezier.lineWidth = line.weight
            myBezier.strokeWithBlendMode(kCGBlendModeNormal, alpha: line.opacity)
            myBezier.closePath()
        }
    }
    
    func drawBitmap(rect: CGRect) {
        println("This is a test")
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, true, 0.0)
        var rectpath = UIBezierPath(rect: self.bounds)
        rectpath.fill()
        incrementalImage.drawAtPoint(CGPointZero)
        incrementalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    /* OBJ - C example of drawing bitmap
    
    - (void)drawBitmap // (3)
    {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    [[UIColor blackColor] setStroke];
    if (!incrementalImage) // first draw; paint background white by ...
    {
    UIBezierPath *rectpath = [UIBezierPath bezierPathWithRect:self.bounds]; // enclosing bitmap by a rectangle defined by another UIBezierPath object
    [[UIColor whiteColor] setFill];
    [rectpath fill]; // filling it with white
    }
    [incrementalImage drawAtPoint:CGPointZero];
    [path stroke];
    incrementalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    }
    
    */
}