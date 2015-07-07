//
//  colorPicker.swift
//  Drawn
//
//  Created by Jarom Vogel on 6/24/15.
//  Copyright (c) 2015 Jarom Vogel. All rights reserved.
//

import Foundation
import UIKit
import Darwin

class colorWheel {
    
    func calcColor(angle: CGFloat, distance: CGFloat, brightness: CGFloat) -> UIColor {
        
        var adjustedangle = (((angle + 360)/2)/360)
        if 0 < adjustedangle && adjustedangle <= 0.25 {
            adjustedangle = adjustedangle + 0.75
        } else {
            adjustedangle = adjustedangle - 0.25
        }
        adjustedangle = -(adjustedangle - 1)
        let color = UIColor(hue: adjustedangle, saturation: distance / 100, brightness: brightness, alpha: 1.0)
        
        return color
        
        /*
        let π = CGFloat(M_PI)
        let radians = angle * (π/360)
        let π_radians = radians/π

        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        
        // Calculate Red
        if (5/6 < π_radians) && (π_radians <= 1) || (-1 < π_radians) && (π_radians <= 1/6) {
            if (-5/6 < π_radians) && (π_radians < -1/6) {
                red = CGFloat(255)
            } else if (-1/6 < π_radians) && (π_radians <= 1/6) {
                let redpercent = (-(π_radians - (1/6))/(1/3))
                red = redpercent * 255
            } else {
                if (-5/6 > π_radians) && (π_radians > -1) {
                    let redpercent = ((π_radians + (1))/(1/3)) + (0.5)
                    red = redpercent * 255
                } else {
                    let redpercent = (π_radians - (5/6))/(1/3)
                    red = redpercent * 255
                }
            }
        }
        // Calculate Blue
        if (-1/2 < π_radians) && (π_radians <= 2/3) {
            if (-1/6 <= π_radians) && (π_radians <= 1/2) {
                blue = CGFloat(255)
            } else if (-1/2 <= π_radians) && (π_radians < -1/6) {
                let bluepercent = (π_radians + (1/2))/(1/3)
                blue = bluepercent * 255
            } else {
                let bluepercent = ((1/6)-(π_radians - 1/2))/(1/6)
                blue = bluepercent * 255
            }
        }
        
        // Calculate Green
        if (-1 <= π_radians) && (π_radians < -1/2) || (1/6 < π_radians) && (π_radians <= 1) {
            if (1/2 <= π_radians) && (π_radians <= 1) || (-1 <= π_radians) && (π_radians <= -5/6) {
                green = CGFloat(255)
            } else if (1/6 < π_radians) && (π_radians < 1/2) {
                let greenpercent = (π_radians - 1/6)/(1/3)
                green = greenpercent * 255
            } else {
                let greenpercent = (-(π_radians + (1/2)))/(1/3)
                green = greenpercent * 255
            }
        }
        
        red = desaturate(distance, colorValue: red)
        green = desaturate(distance, colorValue: green)
        blue = desaturate(distance, colorValue: blue)
        
        red = darken(darkness, colorValue: red)
        green = darken(darkness, colorValue: green)
        blue = darken(darkness, colorValue: blue)
        
        let newColor = UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1.0)
        return newColor
    }
    
    func desaturate(distance: CGFloat, colorValue: CGFloat) -> CGFloat {
        var colordistance = (255-colorValue)
        var distancemultiplier = 1 - (distance/100)
        var coloroffset = colordistance * distancemultiplier
        var desaturated = colorValue + coloroffset
        return desaturated
    }
    
    func darken(percent: CGFloat, colorValue: CGFloat) -> CGFloat {
        let darkColor = colorValue * percent
        return darkColor
    }
    */
    }
}