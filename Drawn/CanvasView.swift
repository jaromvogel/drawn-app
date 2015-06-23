//
//  CanvasView.swift
//  Drawn
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
    
    /*
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
        /*
        UIGraphicsBeginImageContext(self.frame.size)
        let context = UIGraphicsGetCurrentContext()
        cache.image?.drawInRect(CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        
        cache.image = UIGraphicsGetImageFromCurrentImageContext()
        cache.alpha = CGFloat(0.5)
        UIGraphicsEndImageContext()
        */
    }
    */
    
}